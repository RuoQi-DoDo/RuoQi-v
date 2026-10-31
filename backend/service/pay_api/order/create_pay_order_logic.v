module order

import dto
import veb
import log
import time
import rand
import json2 as json
import model.schema_pay { PayOrder }
import common.api
import model { Context }

// ═══ Handler ═══
@['/create'; post]
pub fn (app &Order) create_pay_order_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreatePayOrderReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := create_pay_order_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn create_pay_order_usecase(mut ctx Context, req CreatePayOrderReq) !dto.MsgResp {
	create_pay_order_domain(&req)!
	return create_pay_order_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_pay_order_domain(req &CreatePayOrderReq) ! {
	if req.merchant_order_id == '' {
		return error('merchant order id is required')
	}
	if req.price <= 0 {
		return error('price must be greater than 0')
	}
}

// ═══ DTO ═══
pub struct CreatePayOrderReq {
	channel_code      ?string   @[json: 'channelCode'; description: '支付渠道编码']
	merchant_order_id string    @[json: 'merchantOrderId'; description: '商户订单号']
	subject           string    @[json: 'subject'; description: '交易标题']
	body              string    @[json: 'body'; description: '交易描述']
	price             int       @[json: 'price'; description: '价格']
	channel_fee_rate  ?f64      @[json: 'channelFeeRate'; description: '渠道手续费率']
	channel_fee_price ?int      @[json: 'channelFeePrice'; description: '渠道手续费金额']
	user_ip           string    @[json: 'userIp'; description: '用户 IP 地址']
	expire_time       time.Time @[json: 'expireTime'; description: '过期时间']
	status            u8        @[json: 'status'; description: '状态：0 禁用，1 启用']
}

// ═══ Repository ═══
fn create_pay_order_repo(mut ctx Context, req CreatePayOrderReq) !dto.MsgResp {
	time_now := time.now()
	order := PayOrder{
		id:                rand.uuid_v7()
		channel_code:      req.channel_code
		merchant_order_id: req.merchant_order_id
		subject:           req.subject
		body:              req.body
		price:             req.price
		channel_fee_rate:  req.channel_fee_rate
		channel_fee_price: req.channel_fee_price
		user_ip:           req.user_ip
		expire_time:       req.expire_time
		refund_price:      0
		status:            req.status
		creator_id:        ctx.svc_iam.user_id
		updater_id:        ctx.svc_iam.user_id
		created_at:        time_now
		updated_at:        time_now
	}

	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert order into PayOrder
	} or { return error('Failed to create PayOrder: ${err}') }

	return dto.MsgResp{
		msg: 'PayOrder created successfully'
	}
}
