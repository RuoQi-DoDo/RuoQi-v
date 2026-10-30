module dto

import json2

fn test_msg_resp_json_contract() {
	assert json2.encode(MsgResp{
		msg: 'ok'
	}) == '{"msg":"ok"}'
}

fn test_created_resp_json_contract() {
	assert json2.encode(CreatedResp{
		id:  '123'
		msg: 'created'
	}) == '{"id":"123","msg":"created"}'
}

fn test_shared_requests_decode() {
	id_req := json2.decode[IdReq]('{"id":"123"}')!
	assert id_req.id == '123'

	delete_req := json2.decode[DeleteIdsReq]('{"ids":["a","b"]}')!
	assert delete_req.ids == ['a', 'b']
}
