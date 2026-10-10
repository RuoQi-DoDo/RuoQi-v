module api

import json2
import common.reqid

pub struct ValidationError {
pub:
	field string
	msg   string // 使用 message 更符合RESTful 接口规范
	rule  string
	meta  map[string]string // 扩展参数（如 { "min": ’8‘, "max": 20 }）
}

// 业务失败响应体 —— code 为具体业务错误码，msg 用于展示
@[params]
pub struct ApiErrorResponse {
pub:
	code       int
	request_id string
	msg        string
}

// 业务成功响应体 —— code 恒为 0，data 为已编码的 JSON 片段。
// 刻意不做泛型：泛型响应体会让每个业务数据类型都单态化一份
// ApiSuccessResponse[T] + veb 的 ctx.json[ApiSuccessResponse[T]]，
// 170 个响应类型就是 170 套 veb/json2 实例化，编译时间被显著拉长。
pub struct ApiSuccessResponse {
pub:
	code       int
	request_id string
	data       string // 已编码的 JSON 片段（由 json_success 内部 json2.encode 得到）
	msg        string
}

// 业务成功入参 —— 保留泛型，只为让 `json_success(data: x, msg: '...')` 的调用写法不变。
// 每个不同的 T 会实例化一个 json_success[T]（约 180 个，~3s 级），
// 但它不参与响应类型，不会像 ApiSuccessResponse[T] 那样再放大 veb/json2 的实例化。
@[params]
pub struct ApiSuccessInput[T] {
pub:
	data T
	msg  string = 'success'
}

// json2 的 JsonEncoder 接口：to_json 的返回值会被原样写入，
// 因此 data 不会被再转义成 JSON 字符串。
pub fn (r ApiSuccessResponse) to_json() string {
	data := if r.data == '' { 'null' } else { r.data }
	// 正常情况下 request_id 已由 ctx.json 注入；直接编码（非 HTTP 场景）时兜底生成。
	request_id := if r.request_id != '' { r.request_id } else { reqid.generate() }
	return '{"code":${r.code},"request_id":${json2.encode(request_id)},"data":${data},"msg":${json2.encode(r.msg)}}'
}
