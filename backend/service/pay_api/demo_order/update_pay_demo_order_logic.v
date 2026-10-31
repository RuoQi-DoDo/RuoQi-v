module demo_order

import dto
import veb
import log
import time
import json2 as json
import model.schema_pay { PayDemoOrder }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &DemoOrder) update_pay_demo_order_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdatePayDemoOrderReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_pay_demo_order_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_pay_demo_order_usecase(mut ctx Context, req UpdatePayDemoOrderReq) !dto.MsgResp {
	update_pay_demo_order_domain(&req)!
	return update_pay_demo_order_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_pay_demo_order_domain(req &UpdatePayDemoOrderReq) ! {
	if req.id == '' {
		return error('demo order id is required')
	}
}

// ═══ DTO ═══
pub struct UpdatePayDemoOrderReq {
	id               string     @[json: 'id'; description: '唯一标识']
	spu_name         ?string    @[json: 'spuName'; description: '商品 SPU 名称']
	pay_status       ?u8        @[json: 'payStatus'; description: '支付状态']
	pay_order_id     ?string    @[json: 'payOrderId'; description: '支付订单 ID']
	pay_time         ?time.Time @[json: 'payTime'; description: '支付时间']
	pay_channel_code ?string    @[json: 'payChannelCode'; description: '支付渠道编码']
	pay_refund_id    ?string    @[json: 'payRefundId'; description: '支付退款 ID']
	refund_price     ?int       @[json: 'refundPrice'; description: '退款金额']
	refund_time      ?time.Time @[json: 'refundTime'; description: '退款时间']
}

// ═══ Repository ═══
fn update_pay_demo_order_repo(mut ctx Context, req UpdatePayDemoOrderReq) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// vfmt off
	up_expr := {
		if v := req.spu_name {
			spu_name == v
		},
		if v := req.pay_status {
			pay_status == v
		},
		if v := req.pay_order_id {
			pay_order_id == v
		},
		if v := req.pay_time {
			pay_time == v
		},
		if v := req.pay_channel_code {
			pay_channel_code == v
		},
		if v := req.pay_refund_id {
			pay_refund_id == v
		},
		if v := req.refund_price {
			refund_price == v
		},
		if v := req.refund_time {
			refund_time == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on

	sql db {
		dynamic update PayDemoOrder set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return dto.MsgResp{
		msg: 'PayDemoOrder updated successfully'
	}
}
