module order

import veb
import log
import time
import model.schema_pay { PayOrder }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/all'; get]
pub fn (app &Order) find_pay_order_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[PayOrderListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_pay_order_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_pay_order_all_usecase(mut ctx Context, req PayOrderListReq) !PayOrderListResp {
	find_pay_order_all_domain(&req)!
	return find_pay_order_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_pay_order_all_domain(req &PayOrderListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

// ═══ DTO ═══
pub struct PayOrderListReq {
	page              int    @[json: 'page'; description: '页码，从 1 开始']
	page_size         int    @[json: 'pageSize'; description: '每页记录数']
	merchant_order_id string @[json: 'merchantOrderId'; description: '商户订单号']
	channel_code      string @[json: 'channelCode'; description: '支付渠道编码']
	status            []u8   @[json: 'status'; description: '状态：0 禁用，1 启用']
}

pub struct PayOrderData {
	id                string  @[json: 'id'; description: '唯一标识']
	channel_code      ?string @[json: 'channelCode'; description: '支付渠道编码']
	merchant_order_id string  @[json: 'merchantOrderId'; description: '商户订单号']
	subject           string  @[json: 'subject'; description: '交易标题']
	body              string  @[json: 'body'; description: '交易描述']
	price             int     @[json: 'price'; description: '支付金额（分）']
	channel_fee_rate  ?f64    @[json: 'channelFeeRate'; description: '渠道手续费率']
	channel_fee_price ?int    @[json: 'channelFeePrice'; description: '渠道手续费金额（分）']
	user_ip           string  @[json: 'userIp'; description: '用户 IP 地址']
	refund_price      int     @[json: 'refundPrice'; description: '退款金额（分）']
	channel_order_no  ?string @[json: 'channelOrderNo'; description: '渠道订单号']
	status            u8      @[json: 'status'; description: '支付状态']
	updater_id        ?string @[json: 'updaterId'; description: '更新者 ID']
	creator_id        ?string @[json: 'creatorId'; description: '创建者 ID']
	created_at        string  @[json: 'createdAt'; description: '创建时间']
	updated_at        string  @[json: 'updatedAt'; description: '更新时间']
	deleted_at        string  @[json: 'deletedAt'; description: '删除时间']
}

pub struct PayOrderListResp {
	total int            @[description: '总记录数']
	data  []PayOrderData @[description: '响应数据']
}

// ═══ Repository ═══
fn find_pay_order_all_repo(mut ctx Context, req PayOrderListReq) !PayOrderListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from PayOrder where del_flag == 0
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
		del_flag == 0,
		if req.merchant_order_id != '' {merchant_order_id == req.merchant_order_id},
		if req.channel_code != '' {channel_code == req.channel_code},
		if req.status.len > 0 {status in req.status}
	}
	// vfmt on
	result := sql db {
		dynamic select from PayOrder where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []PayOrderData{}
	for row in result {
		datalist << PayOrderData{
			id:                row.id
			channel_code:      row.channel_code
			merchant_order_id: row.merchant_order_id
			subject:           row.subject
			body:              row.body
			price:             row.price
			channel_fee_rate:  row.channel_fee_rate
			channel_fee_price: row.channel_fee_price
			user_ip:           row.user_ip
			refund_price:      row.refund_price
			channel_order_no:  row.channel_order_no
			status:            row.status
			creator_id:        row.creator_id
			updater_id:        row.updater_id
			created_at:        row.created_at.format_ss()
			updated_at:        row.updated_at.format_ss()
			deleted_at:        (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return PayOrderListResp{
		total: count
		data:  datalist
	}
}
