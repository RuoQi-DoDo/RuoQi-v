module reqid

import rand
import sync

// Registry 以线程为键保存当前请求的 id（MDC 模式）。
// veb 的每条连接由一个工作线程顺序处理请求，因此"线程 → 当前请求"的映射是稳定的；
// 业务代码里 spawn 出去的新线程不会自动继承，这是已知边界。
//
// Registry 由 main 创建一份，通过闭包注入请求中间件和日志 Writer，
// 项目内不使用全局变量。
@[heap]
pub struct Registry {
mut:
	mu  &sync.Mutex = sync.new_mutex()
	ids map[u64]string
}

pub fn new_registry() &Registry {
	return &Registry{}
}

// set 把请求 id 绑定到当前线程，由请求入口中间件调用。
pub fn (mut r Registry) set(id string) {
	r.mu.lock()
	r.ids[sync.thread_id()] = id
	r.mu.unlock()
}

// current 返回当前线程绑定的请求 id；不在请求上下文中时返回空串。
pub fn (r &Registry) current() string {
	r.mu.lock()
	id := r.ids[sync.thread_id()] or { '' }
	r.mu.unlock()
	return id
}

// generate 生成一个新的请求 id。
pub fn generate() string {
	return rand.uuid_v7()
}

// sanitize 校验上游透传的请求 id，不合法时返回空串。
// 只接受 1~64 位 [A-Za-z0-9._-]，避免日志注入和超长请求头。
pub fn sanitize(raw string) string {
	if raw.len == 0 || raw.len > 64 {
		return ''
	}
	for c in raw {
		is_valid := (c >= `a` && c <= `z`) || (c >= `A` && c <= `Z`) || (c >= `0` && c <= `9`)
			|| c == `-` || c == `_` || c == `.`
		if !is_valid {
			return ''
		}
	}
	return raw
}
