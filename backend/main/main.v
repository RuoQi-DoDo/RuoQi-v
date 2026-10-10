module main

import check
import common.reqid

fn main() {
	banner()
	check.check_all()!
	mut registry := reqid.new_registry()
	reqid.install_logger(registry)

	new_app(registry)
}
