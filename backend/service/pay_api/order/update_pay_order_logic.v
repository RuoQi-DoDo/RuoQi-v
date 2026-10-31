module order

import dto
import veb
import log
import time
import json2 as json
import model.schema_pay { PayOrder }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &Order) update_pay_order_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdatePayOrderReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_pay_order_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_pay_order_usecase(mut ctx Context, req UpdatePayOrderReq) !dto.MsgResp {
	update_pay_order_domain(&req)!
	return update_pay_order_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_pay_order_domain(req &UpdatePayOrderReq) ! {
	if req.id == '' {
		return error('pay order id is required')
	}
}

// ═══ DTO ═══
pub struct UpdatePayOrderReq {
	id                string     @[json: 'id'; description: '唯一标识']
	channel_code      ?string    @[json: 'channelCode'; description: '支付渠道编码']
	merchant_order_id ?string    @[json: 'merchantOrderId'; description: '商户订单号']
	subject           ?string    @[json: 'subject'; description: '交易标题']
	body              ?string    @[json: 'body'; description: '交易描述']
	price             ?int       @[json: 'price'; description: '价格']
	channel_fee_rate  ?f64       @[json: 'channelFeeRate'; description: '渠道手续费率']
	channel_fee_price ?int       @[json: 'channelFeePrice'; description: '渠道手续费金额']
	user_ip           ?string    @[json: 'userIp'; description: '用户 IP 地址']
	refund_price      ?int       @[json: 'refundPrice'; description: '退款金额']
	channel_user_id   ?string    @[json: 'channelUserId'; description: '渠道用户 ID']
	channel_order_no  ?string    @[json: 'channelOrderNo'; description: '渠道订单号']
	success_time      ?time.Time @[json: 'successTime'; description: '成功时间']
	notify_time       ?time.Time @[json: 'notifyTime'; description: '通知时间']
	status            ?u8        @[json: 'status'; description: '状态：0 禁用，1 启用']
}

// ═══ Repository ═══
fn update_pay_order_repo(mut ctx Context, req UpdatePayOrderReq) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// vfmt off
	up_expr := {
		if v := req.channel_code {
			channel_code == v
		},
		if v := req.merchant_order_id {
			merchant_order_id == v
		},
		if v := req.subject {
			subject == v
		},
		if v := req.body {
			body == v
		},
		if v := req.price {
			price == v
		},
		if v := req.channel_fee_rate {
			channel_fee_rate == v
		},
		if v := req.channel_fee_price {
			channel_fee_price == v
		},
		if v := req.user_ip {
			user_ip == v
		},
		if v := req.refund_price {
			refund_price == v
		},
		if v := req.channel_user_id {
			channel_user_id == v
		},
		if v := req.channel_order_no {
			channel_order_no == v
		},
		if v := req.success_time {
			success_time == v
		},
		if v := req.notify_time {
			notify_time == v
		},
		if v := req.status {
			status == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on

	sql db {
		dynamic update PayOrder set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return dto.MsgResp{
		msg: 'PayOrder updated successfully'
	}
}
