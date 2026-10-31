module utc

import veb
import log
// import time
import model.schema_base { BaseUtc }
import common.api
import model { Context }

// ═══ Handler ═══
@['/all'; get]
pub fn (app &Utc) find_utc_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	result := find_utc_all_usecase(mut ctx) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_utc_all_usecase(mut ctx Context) !UtcListResp {
	find_utc_all_domain()
	return find_utc_all_repo(mut ctx)
}

// ═══ Domain ═══
fn find_utc_all_domain() {
}

// ═══ DTO ═══
pub struct UtcListReq {}

pub struct UtcData {
	id              string @[json: 'id'; description: '唯一标识']
	sort            ?int   @[json: 'sort'; description: '排序值']
	name            string @[json: 'name'; description: 'UTC 时区名称']
	lng_range_start f64    @[json: 'lngRangeStart'; description: '经度范围起始值']
	lng_range_end   f64    @[json: 'lngRangeEnd'; description: '经度范围结束值']
	lng_mid         f64    @[json: 'lngMid'; description: '经度范围中间值']
}

pub struct UtcListResp {
	total int       @[description: '总记录数']
	data  []UtcData @[description: '响应数据']
}

// ═══ Repository ═══
fn find_utc_all_repo(mut ctx Context) !UtcListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut result := sql db {
		select from BaseUtc order by sort
	} or { return error('Failed to execute SQL query: ${err}') }

	// 构造返回数据
	mut datalist := []UtcData{}
	for row in result {
		datalist << UtcData{
			id:              row.id
			sort:            row.sort
			name:            row.name
			lng_range_start: row.lng_range_start
			lng_range_end:   row.lng_range_end
			lng_mid:         row.lng_mid
		}
	}

	return UtcListResp{
		data: datalist
	}
}
