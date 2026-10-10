module reqid

import io
import log
import os

// RequestIdWriter 在每条日志前加上当前请求 id 前缀：[<request_id>] ...
// vlib 的 log 模块把一整行组装好后调用一次 write，因此这里按写入单位加前缀即可。
struct RequestIdWriter {
mut:
	registry &Registry = unsafe { nil }
	inner    io.Writer = os.stderr()
}

fn (mut w RequestIdWriter) write(buf []u8) !int {
	id := if w.registry == unsafe { nil } { '' } else { w.registry.current() }
	if id == '' {
		return w.inner.write(buf)!
	}
	prefix := '[${id}] '.bytes()
	w.inner.write(prefix)!
	return w.inner.write(buf)!
}

// install_logger 用带 request_id 前缀的 logger 替换全局默认 logger。
// 在日志级别设置完成之后、开始处理请求之前调用。
pub fn install_logger(registry &Registry) {
	mut l := &log.ThreadSafeLog{}
	l.set_level(log.get_level())
	l.set_output_stream(RequestIdWriter{
		registry: registry
	})
	log.set_logger(l)
}
