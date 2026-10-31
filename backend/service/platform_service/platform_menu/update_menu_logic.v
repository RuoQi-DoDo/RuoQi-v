module platform_menu

import dto
import veb
import log
import json2 as json
import model { Context }
import model.schema_platform { PfMenu }
import common.api
import time

// ═══ Handler ═══
@['/update_menu'; post]
pub fn (app &PlatformMenu) update_menu_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateMenuReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := update_menu_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_menu_usecase(mut ctx Context, req UpdateMenuReq) !dto.MsgResp {
	update_menu_domain(&req)!
	return update_menu_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_menu_domain(req &UpdateMenuReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateMenuReq {
	id         string  @[json: 'id'; description: '唯一标识']
	parent_id  ?string @[json: 'parentId'; description: '父级 ID']
	menu_level ?u8     @[json: 'menuLevel'; description: '菜单层级']
	menu_type  ?u8     @[json: 'menuType'; description: '菜单类型']
	path       ?string @[json: 'path'; description: '路径']
	name       ?string @[json: 'name'; description: '名称']
	redirect   ?string @[json: 'redirect'; description: '跳转地址']
	component  ?string @[json: 'component'; description: '前端组件']
	order_no   ?u32    @[json: 'orderNo'; description: '订单号']
	icon       ?string @[json: 'icon'; description: '图标']
	title      ?string @[json: 'title'; description: '标题']
	status     ?u8     @[json: 'status'; description: '状态：0 禁用，1 启用']
}

// ═══ Repository ═══
fn update_menu_repo(mut ctx Context, req UpdateMenuReq) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	// vfmt off
	up_expr := {
		if v := req.parent_id {
			parent_id == v
		},
		if v := req.menu_level {
			menu_level == v
		},
		if v := req.menu_type {
			menu_type == v
		},
		if v := req.path {
			path == v
		},
		if v := req.name {
			name == v
		},
		if v := req.redirect {
			redirect == v
		},
		if v := req.component {
			component == v
		},
		if v := req.order_no {
			order_no == v
		},
		if v := req.icon {
			icon == v
		},
		if v := req.title {
			title == v
		},
		if v := req.status {
			status == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on
	sql db {
		dynamic update PfMenu set up_expr where id == req.id
	}!
	return dto.MsgResp{
		msg: 'Menu updated'
	}
}
