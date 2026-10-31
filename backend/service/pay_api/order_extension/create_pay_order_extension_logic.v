module order_extension

import dto
import veb
import log
import time
import rand
import json2 as json
import model.schema_pay { PayOrderExtension }
import common.api
import model { Context }

// ═══ Handler ═══
@['/create'; post]
pub fn (app &OrderExtension) create_pay_order_extension_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreatePayOrderExtensionReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := create_pay_order_extension_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn create_pay_order_extension_usecase(mut ctx Context, req CreatePayOrderExtensionReq) !dto.MsgResp {
	create_pay_order_extension_domain(&req)!
	return create_pay_order_extension_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_pay_order_extension_domain(req &CreatePayOrderExtensionReq) ! {
	if req.order_id == '' {
		return error('order id is required')
	}
}

// ═══ DTO ═══
pub struct CreatePayOrderExtensionReq {
	no             string  @[json: 'no'; description: '单号']
	order_id       string  @[json: 'orderId'; description: '订单 ID']
	channel_code   string  @[json: 'channelCode'; description: '支付渠道编码']
	user_ip        string  @[json: 'userIp'; description: '用户 IP 地址']
	channel_extras ?string @[json: 'channelExtras'; description: '渠道扩展信息']
	status         u8      @[json: 'status'; description: '状态：0 禁用，1 启用']
}

// ═══ Repository ═══
fn create_pay_order_extension_repo(mut ctx Context, req CreatePayOrderExtensionReq) !dto.MsgResp {
	time_now := time.now()
	ext := PayOrderExtension{
		id:             rand.uuid_v7()
		no:             req.no
		order_id:       req.order_id
		channel_code:   req.channel_code
		user_ip:        req.user_ip
		channel_extras: req.channel_extras
		status:         req.status
		creator_id:     ctx.svc_iam.user_id
		updater_id:     ctx.svc_iam.user_id
		created_at:     time_now
		updated_at:     time_now
	}

	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert ext into PayOrderExtension
	} or { return error('Failed to create PayOrderExtension: ${err}') }

	return dto.MsgResp{
		msg: 'PayOrderExtension created successfully'
	}
}
