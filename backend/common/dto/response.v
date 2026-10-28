module dto

// MsgResp is the shared response for operations that only return a message.
pub struct MsgResp {
pub:
	msg string @[json: 'msg']
}

// CreatedResp is the shared response for operations that create a resource.
pub struct CreatedResp {
pub:
	id  string @[json: 'id']
	msg string @[json: 'msg']
}
