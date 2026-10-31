module order_extension

import veb
import log
import time
import model.schema_pay { PayOrderExtension }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/all'; get]
pub fn (app &OrderExtension) find_pay_order_extension_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[PayOrderExtensionListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_pay_order_extension_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_pay_order_extension_all_usecase(mut ctx Context, req PayOrderExtensionListReq) !PayOrderExtensionListResp {
	find_pay_order_extension_all_domain(&req)!
	return find_pay_order_extension_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_pay_order_extension_all_domain(req &PayOrderExtensionListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

// ═══ DTO ═══
pub struct PayOrderExtensionListReq {
	page         int    @[json: 'page'; description: '页码，从 1 开始']
	page_size    int    @[json: 'pageSize'; description: '每页记录数']
	order_id     string @[json: 'orderId'; description: '订单 ID']
	channel_code string @[json: 'channelCode'; description: '支付渠道编码']
	status       []u8   @[json: 'status'; description: '状态：0 禁用，1 启用']
}

pub struct PayOrderExtensionData {
	id                  string  @[json: 'id'; description: '唯一标识']
	no                  string  @[json: 'no'; description: '支付扩展单号']
	order_id            string  @[json: 'orderId'; description: '支付订单 ID']
	channel_code        string  @[json: 'channelCode'; description: '支付渠道编码']
	user_ip             string  @[json: 'userIp'; description: '用户 IP 地址']
	channel_extras      ?string @[json: 'channelExtras'; description: '渠道扩展参数']
	channel_error_code  ?string @[json: 'channelErrorCode'; description: '渠道错误码']
	channel_error_msg   ?string @[json: 'channelErrorMsg'; description: '渠道错误信息']
	channel_notify_data ?string @[json: 'channelNotifyData'; description: '渠道通知数据']
	status              u8      @[json: 'status'; description: '支付状态']
	updater_id          ?string @[json: 'updaterId'; description: '更新者 ID']
	creator_id          ?string @[json: 'creatorId'; description: '创建者 ID']
	created_at          string  @[json: 'createdAt'; description: '创建时间']
	updated_at          string  @[json: 'updatedAt'; description: '更新时间']
	deleted_at          string  @[json: 'deletedAt'; description: '删除时间']
}

pub struct PayOrderExtensionListResp {
	total int                     @[description: '总记录数']
	data  []PayOrderExtensionData @[description: '响应数据']
}

// ═══ Repository ═══
fn find_pay_order_extension_all_repo(mut ctx Context, req PayOrderExtensionListReq) !PayOrderExtensionListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from PayOrderExtension where del_flag == 0
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
		dynamic select from PayOrderExtension where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []PayOrderExtensionData{}
	for row in result {
		datalist << PayOrderExtensionData{
			id:                  row.id
			no:                  row.no
			order_id:            row.order_id
			channel_code:        row.channel_code
			user_ip:             row.user_ip
			channel_extras:      row.channel_extras
			channel_error_code:  row.channel_error_code
			channel_error_msg:   row.channel_error_msg
			channel_notify_data: row.channel_notify_data
			status:              row.status
			creator_id:          row.creator_id
			updater_id:          row.updater_id
			created_at:          row.created_at.format_ss()
			updated_at:          row.updated_at.format_ss()
			deleted_at:          (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return PayOrderExtensionListResp{
		total: count
		data:  datalist
	}
}
