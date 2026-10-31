module refund

import veb
import log
import time
import model.schema_pay { PayRefund }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/all'; get]
pub fn (app &Refund) find_pay_refund_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[PayRefundListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_pay_refund_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_pay_refund_all_usecase(mut ctx Context, req PayRefundListReq) !PayRefundListResp {
	find_pay_refund_all_domain(&req)!
	return find_pay_refund_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_pay_refund_all_domain(req &PayRefundListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

// ═══ DTO ═══
pub struct PayRefundListReq {
	page         int    @[json: 'page'; description: '页码，从 1 开始']
	page_size    int    @[json: 'pageSize'; description: '每页记录数']
	order_id     string @[json: 'orderId'; description: '订单 ID']
	channel_code string @[json: 'channelCode'; description: '支付渠道编码']
	status       []u8   @[json: 'status'; description: '状态：0 禁用，1 启用']
}

pub struct PayRefundData {
	id                 string  @[json: 'id'; description: '唯一标识']
	no                 string  @[json: 'no'; description: '退款单号']
	channel_code       string  @[json: 'channelCode'; description: '支付渠道编码']
	order_id           string  @[json: 'orderId'; description: '支付订单 ID']
	order_no           string  @[json: 'orderNo'; description: '支付订单号']
	merchant_order_id  string  @[json: 'merchantOrderId'; description: '商户订单号']
	merchant_refund_id string  @[json: 'merchantRefundId'; description: '商户退款单号']
	pay_price          int     @[json: 'payPrice'; description: '支付金额（分）']
	refund_price       int     @[json: 'refundPrice'; description: '退款金额（分）']
	reason             string  @[json: 'reason'; description: '退款原因']
	channel_refund_no  ?string @[json: 'channelRefundNo'; description: '渠道退款单号']
	status             u8      @[json: 'status'; description: '退款状态']
	updater_id         ?string @[json: 'updaterId'; description: '更新者 ID']
	creator_id         ?string @[json: 'creatorId'; description: '创建者 ID']
	created_at         string  @[json: 'createdAt'; description: '创建时间']
	updated_at         string  @[json: 'updatedAt'; description: '更新时间']
	deleted_at         string  @[json: 'deletedAt'; description: '删除时间']
}

pub struct PayRefundListResp {
	total int             @[description: '总记录数']
	data  []PayRefundData @[description: '响应数据']
}

// ═══ Repository ═══
fn find_pay_refund_all_repo(mut ctx Context, req PayRefundListReq) !PayRefundListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from PayRefund where del_flag == 0
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
		del_flag == 0,
		if req.order_id != '' {order_id == req.order_id},
		if req.channel_code != '' {channel_code == req.channel_code},
		if req.status.len > 0 {status in req.status}
	}
	// vfmt on
	result := sql db {
		dynamic select from PayRefund where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []PayRefundData{}
	for row in result {
		datalist << PayRefundData{
			id:                 row.id
			no:                 row.no
			channel_code:       row.channel_code
			order_id:           row.order_id
			order_no:           row.order_no
			merchant_order_id:  row.merchant_order_id
			merchant_refund_id: row.merchant_refund_id
			pay_price:          row.pay_price
			refund_price:       row.refund_price
			reason:             row.reason
			channel_refund_no:  row.channel_refund_no
			status:             row.status
			creator_id:         row.creator_id
			updater_id:         row.updater_id
			created_at:         row.created_at.format_ss()
			updated_at:         row.updated_at.format_ss()
			deleted_at:         (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return PayRefundListResp{
		total: count
		data:  datalist
	}
}
