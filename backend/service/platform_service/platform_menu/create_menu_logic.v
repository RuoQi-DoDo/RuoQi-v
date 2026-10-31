module platform_menu

import dto
import veb
import log
import time
import rand
import json2 as json
import model { Context }
import model.schema_platform { PfMenu }
import common.api

// ═══ Handler ═══
@['/create_menu'; post]
pub fn (app &PlatformMenu) create_menu_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CreateMenuReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := create_menu_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn create_menu_usecase(mut ctx Context, req CreateMenuReq) !dto.CreatedResp {
	create_menu_domain(&req)!
	return create_menu_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_menu_domain(req &CreateMenuReq) ! {
	if req.name == '' {
		return error('name is required')
	}
}

// ═══ DTO ═══
pub struct CreateMenuReq {
	parent_id  string @[json: 'parentId'; description: '父级 ID']
	menu_level u8     @[json: 'menuLevel'; description: '菜单层级']
	menu_type  u8     @[json: 'menuType'; description: '菜单类型']
	path       string @[json: 'path'; description: '路径']
	name       string @[json: 'name'; description: '名称']
	redirect   string @[json: 'redirect'; description: '跳转地址']
	component  string @[json: 'component'; description: '前端组件']
	order_no   u32    @[json: 'orderNo'; description: '订单号']
	icon       string @[json: 'icon'; description: '图标']
	title      string @[json: 'title'; description: '标题']
}

// ═══ Repository ═══
fn create_menu_repo(mut ctx Context, req CreateMenuReq) !dto.CreatedResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	menu := PfMenu{
		id:         rand.uuid_v7()
		parent_id:  req.parent_id
		menu_level: req.menu_level
		menu_type:  req.menu_type
		path:       req.path
		name:       req.name
		redirect:   req.redirect
		component:  req.component
		order_no:   req.order_no
		icon:       req.icon
		title:      req.title
		status:     1
		created_at: time.now()
		updated_at: time.now()
	}
	sql db {
		insert menu into PfMenu
	} or { return error('Failed: ${err}') }
	return dto.CreatedResp{
		id:  menu.id
		msg: 'Menu created'
	}
}
