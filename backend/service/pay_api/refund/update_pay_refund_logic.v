module refund

import dto
import veb
import log
import time
import json2 as json
import model.schema_pay { PayRefund }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &Refund) update_pay_refund_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdatePayRefundReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_pay_refund_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_pay_refund_usecase(mut ctx Context, req UpdatePayRefundReq) !dto.MsgResp {
	update_pay_refund_domain(&req)!
	return update_pay_refund_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_pay_refund_domain(req &UpdatePayRefundReq) ! {
	if req.id == '' {
		return error('pay refund id is required')
	}
}

// ═══ DTO ═══
pub struct UpdatePayRefundReq {
	id                  string     @[json: 'id'; description: '唯一标识']
	channel_refund_no   ?string    @[json: 'channelRefundNo'; description: '渠道退款单号']
	success_time        ?time.Time @[json: 'successTime'; description: '成功时间']
	channel_error_code  ?string    @[json: 'channelErrorCode'; description: '渠道错误码']
	channel_error_msg   ?string    @[json: 'channelErrorMsg'; description: '渠道错误信息']
	channel_notify_data ?string    @[json: 'channelNotifyData'; description: '渠道通知原始数据']
	status              ?u8        @[json: 'status'; description: '状态：0 禁用，1 启用']
}

// ═══ Repository ═══
fn update_pay_refund_repo(mut ctx Context, req UpdatePayRefundReq) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// vfmt off
	up_expr := {
		if v := req.channel_refund_no {
			channel_refund_no == v
		},
		if v := req.success_time {
			success_time == v
		},
		if v := req.channel_error_code {
			channel_error_code == v
		},
		if v := req.channel_error_msg {
			channel_error_msg == v
		},
		if v := req.channel_notify_data {
			channel_notify_data == v
		},
		if v := req.status {
			status == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on

	sql db {
		dynamic update PayRefund set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return dto.MsgResp{
		msg: 'PayRefund updated successfully'
	}
}
