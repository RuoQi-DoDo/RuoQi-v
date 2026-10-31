module authentication

import veb
import log
import time
import rand
import json2 as json
import model { Context }
import model.schema_iam { IamUser }
import common.api
import common.crypt
import common.encrypt

// ═══ Handler ═══
@['/signup_by_email'; post]
pub fn (app &Authentication) signup_by_email_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[SignupByEmailReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := signup_by_email_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn signup_by_email_usecase(mut ctx Context, req SignupByEmailReq) !SignupByEmailResp {
	signup_by_email_domain(&req)!
	return signup_by_email_repo(mut ctx, req)
}

// ═══ Domain ═══
fn signup_by_email_domain(req &SignupByEmailReq) ! {
	if req.email == '' {
		return error('email is required')
	}
	if !req.email.contains('@') || !req.email.contains('.') {
		return error('invalid email format')
	}
	if req.password == '' {
		return error('password is required')
	}
	if req.password.len < 8 {
		return error('password must be at least 8 characters')
	}
	if req.opt_num == '' || req.opt_token == '' {
		return error('OTP is required')
	}
}

// ═══ DTO ═══
pub struct SignupByEmailReq {
	username  string @[json: 'username'; description: '用户名']
	password  string @[json: 'password'; description: '密码']
	nickname  string @[json: 'nickname'; description: '昵称']
	email     string @[json: 'email'; description: '邮箱地址']
	opt_num   string @[json: 'optNum'; description: '一次性验证码']
	opt_token string @[json: 'optToken'; description: '一次性验证码令牌']
}

pub struct SignupByEmailResp {
	user_id string @[json: 'user_id'; description: '用户 ID']
	msg     string @[json: 'msg'; description: '提示消息']
}

// ═══ Repository ═══
fn signup_by_email_repo(mut ctx Context, req SignupByEmailReq) !SignupByEmailResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	if !crypt.opt_verify(ctx.config.crypt.jwt_secret, req.opt_token, req.opt_num) {
		return error('OTP error')
	}
	dup := sql db {
		select from IamUser where email == req.email limit 1
	} or { return error('Failed: ${err}') }
	if dup.len > 0 {
		return error('email already registered')
	}
	user_id := rand.uuid_v7()
	password_hash := encrypt.bcrypt_hash(req.password) or {
		return error('Failed to hash password')
	}
	user := IamUser{
		id:         user_id
		username:   req.username
		password:   password_hash
		nickname:   req.nickname
		email:      req.email
		home_path:  '"/dashboard"'
		status:     1
		created_at: time.now()
		updated_at: time.now()
	}
	sql db {
		insert user into IamUser
	} or { return error('Failed to create user: ${err}') }
	return SignupByEmailResp{
		user_id: user_id
		msg:     'Signup successful'
	}
}
