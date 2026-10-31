module refund

import dto
import veb
import log
import time
import rand
import json2 as json
import model.schema_pay { PayOrder, PayRefund }
import common.api
import model { Context }

// ═══ Handler ═══
@['/create'; post]
pub fn (app &Refund) create_pay_refund_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreatePayRefundReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := create_pay_refund_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn create_pay_refund_usecase(mut ctx Context, req CreatePayRefundReq) !dto.MsgResp {
	create_pay_refund_domain(&req)!
	return create_pay_refund_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_pay_refund_domain(req &CreatePayRefundReq) ! {
	if req.order_id == '' {
		return error('order id is required')
	}
	if req.reason == '' {
		return error('refund reason is required')
	}
	if req.refund_price <= 0 {
		return error('refund price must be greater than 0')
	}
	if req.pay_price <= 0 {
		return error('pay price must be greater than 0')
	}
}

// ═══ DTO ═══
pub struct CreatePayRefundReq {
	no                 string  @[json: 'no'; description: '单号']
	channel_code       string  @[json: 'channelCode'; description: '支付渠道编码']
	order_id           string  @[json: 'orderId'; description: '订单 ID']
	order_no           string  @[json: 'orderNo'; description: '订单号']
	merchant_order_id  string  @[json: 'merchantOrderId'; description: '商户订单号']
	merchant_refund_id string  @[json: 'merchantRefundId'; description: '商户退款单号']
	pay_price          int     @[json: 'payPrice'; description: '支付金额']
	refund_price       int     @[json: 'refundPrice'; description: '退款金额']
	reason             string  @[json: 'reason'; description: '原因']
	user_ip            ?string @[json: 'userIp'; description: '用户 IP 地址']
	channel_order_no   string  @[json: 'channelOrderNo'; description: '渠道订单号']
}

// ═══ Repository ═══
fn create_pay_refund_repo(mut ctx Context, req CreatePayRefundReq) !dto.MsgResp {
	time_now := time.now()

	mut db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// Transaction: all validation + insert + update within single transaction to prevent race
	db.execute('BEGIN') or { return error('Failed to begin transaction: ${err}') }

	// Validate target order exists and is refundable
	orders := sql db {
		select from PayOrder where id == req.order_id && del_flag == 0
	} or {
		db.execute('ROLLBACK') or {}
		return error('Failed to query order: ${err}')
	}
	if orders.len == 0 {
		db.execute('ROLLBACK') or {}
		return error('order not found')
	}
	order := orders[0]
	if order.status != 1 {
		db.execute('ROLLBACK') or {}
		return error('order is not in a refundable state')
	}
	if req.refund_price > order.price {
		db.execute('ROLLBACK') or {}
		return error('refund price exceeds pay price')
	}

	// Validate cumulative refunds would not exceed pay price
	existing_refunds := sql db {
		select from PayRefund where order_id == req.order_id && del_flag == 0
	} or {
		db.execute('ROLLBACK') or {}
		return error('Failed to query existing refunds: ${err}')
	}
	mut total_refunded := 0
	for r in existing_refunds {
		total_refunded += r.refund_price
	}
	if total_refunded + req.refund_price > order.price {
		db.execute('ROLLBACK') or {}
		return error('cumulative refunds would exceed pay price')
	}

	refund := PayRefund{
		id:                 rand.uuid_v7()
		no:                 req.no
		channel_code:       req.channel_code
		order_id:           req.order_id
		order_no:           req.order_no
		merchant_order_id:  req.merchant_order_id
		merchant_refund_id: req.merchant_refund_id
		pay_price:          req.pay_price
		refund_price:       req.refund_price
		reason:             req.reason
		user_ip:            req.user_ip
		channel_order_no:   req.channel_order_no
		status:             1
		creator_id:         ctx.svc_iam.user_id
		updater_id:         ctx.svc_iam.user_id
		created_at:         time_now
		updated_at:         time_now
	}

	sql db {
		insert refund into PayRefund
	} or {
		db.execute('ROLLBACK') or {}
		return error('Failed to create PayRefund: ${err}')
	}

	// Update order's total refund amount (new_total = pre-existing + this refund)
	new_total := total_refunded + req.refund_price
	sql db {
		update PayOrder set refund_price = new_total, updated_at = time_now where id == req.order_id
	} or {
		db.execute('ROLLBACK') or {}
		return error('Failed to update order refund price: ${err}')
	}

	db.execute('COMMIT') or { return error('Failed to commit transaction: ${err}') }

	return dto.MsgResp{
		msg: 'PayRefund created successfully'
	}
}
