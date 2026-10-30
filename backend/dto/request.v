module dto

// IdReq is the shared request body for operations addressed by a single ID.
pub struct IdReq {
pub:
	id string @[json: 'id']
}

// DeleteIdsReq is the shared request body for deleting resources by ID list.
pub struct DeleteIdsReq {
pub:
	ids []string @[json: 'ids']
}
