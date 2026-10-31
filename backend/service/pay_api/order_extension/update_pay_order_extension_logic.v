module order_extension

import dto
import veb
import log
import time
import json2 as json
import model.schema_pay { PayOrderExtension }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &OrderExtension) update_pay_order_extension_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdatePayOrderExtensionReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_pay_order_extension_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_pay_order_extension_usecase(mut ctx Context, req UpdatePayOrderExtensionReq) !dto.MsgResp {
	update_pay_order_extension_domain(&req)!
	return update_pay_order_extension_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_pay_order_extension_domain(req &UpdatePayOrderExtensionReq) ! {
	if req.id == '' {
		return error('order extension id is required')
	}
}

// ═══ DTO ═══
pub struct UpdatePayOrderExtensionReq {
	id                  string  @[json: 'id'; description: '唯一标识']
	channel_code        ?string @[json: 'channelCode'; description: '支付渠道编码']
	channel_extras      ?string @[json: 'channelExtras'; description: '渠道扩展信息']
	channel_error_code  ?string @[json: 'channelErrorCode'; description: '渠道错误码']
	channel_error_msg   ?string @[json: 'channelErrorMsg'; description: '渠道错误信息']
	channel_notify_data ?string @[json: 'channelNotifyData'; description: '渠道通知原始数据']
	status              ?u8     @[json: 'status'; description: '状态：0 禁用，1 启用']
}

// ═══ Repository ═══
fn update_pay_order_extension_repo(mut ctx Context, req UpdatePayOrderExtensionReq) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// vfmt off
	up_expr := {
		if v := req.channel_code {
			channel_code == v
		},
		if v := req.channel_extras {
			channel_extras == v
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
		dynamic update PayOrderExtension set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return dto.MsgResp{
		msg: 'PayOrderExtension updated successfully'
	}
}
