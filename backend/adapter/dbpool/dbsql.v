module dbpool

import orm
import pool
import db.mysql
import db.pg

pub fn new_db_pool(config DatabaseConfig) !&DatabasePoolable {
	match config.type {
		'mysql', 'tidb' {
			p := new_mysql_pool(config)!
			return &DatabasePoolable(p)
		}
		'pgsql' {
			p := new_pgsql_pool(config)!
			return &DatabasePoolable(p)
		}
		else {
			return error('unsupported db_type: ${config.type}')
		}
	}
}

fn new_pgsql_pool(config DatabaseConfig) !&DatabasePool[pg.DB] {
	pool_conf := pool.ConnectionPoolConfig{
		max_conns:      config.max_conns
		min_idle_conns: config.min_idle_conns
		max_lifetime:   config.max_lifetime
		idle_timeout:   config.idle_timeout
		get_timeout:    config.get_timeout
	}
	host := config.host
	port := config.port
	username := config.username
	password := config.password
	dbname := config.dbname
	ssl_verify := config.ssl_verify
	ssl_key := config.ssl_key
	ssl_cert := config.ssl_cert
	ssl_ca := config.ssl_ca
	create_conn := fn [host, port, username, password, dbname, ssl_verify, ssl_key, ssl_cert, ssl_ca] () !&pool.ConnectionPoolable {
		ssl_on := ssl_verify || ssl_key != '' || ssl_cert != '' || ssl_ca != ''
		ssl_mode_val := if ssl_on {
			if ssl_verify { pg.SslMode.verify_full } else { pg.SslMode.require }
		} else {
			pg.SslMode.unset
		}
		cfg := pg.Config{
			host:     host
			port:     int(port)
			user:     username
			password: password
			dbname:   dbname
			ssl_key:  ssl_key
			ssl_cert: ssl_cert
			ssl_ca:   ssl_ca
			ssl_mode: ssl_mode_val
		}
		mut db := pg.connect(cfg)!
		return db
	}
	inner_pool := pool.new_connection_pool(create_conn, pool_conf)!
	return &DatabasePool[pg.DB]{
		inner: inner_pool
	}
}

fn new_mysql_pool(config DatabaseConfig) !&DatabasePool[mysql.DB] {
	pool_conf := pool.ConnectionPoolConfig{
		max_conns:      config.max_conns
		min_idle_conns: config.min_idle_conns
		max_lifetime:   config.max_lifetime
		idle_timeout:   config.idle_timeout
		get_timeout:    config.get_timeout
	}
	host := config.host
	port := config.port
	username := config.username
	password := config.password
	dbname := config.dbname
	ssl_verify := config.ssl_verify
	ssl_key := config.ssl_key
	ssl_cert := config.ssl_cert
	ssl_ca := config.ssl_ca
	ssl_capath := config.ssl_capath
	ssl_cipher := config.ssl_cipher
	create_conn := fn [host, port, username, password, dbname, ssl_verify, ssl_key, ssl_cert, ssl_ca, ssl_capath, ssl_cipher] () !&pool.ConnectionPoolable {
		mut cfg := mysql.Config{
			host:     host
			port:     port
			username: username
			password: password
			dbname:   dbname
		}

		if ssl_verify || ssl_key != '' || ssl_cert != '' || ssl_ca != '' || ssl_capath != ''
			|| ssl_cipher != '' {
			cfg.flag = .client_ssl
			if ssl_verify {
				cfg.ssl_mode = .verify_identity
			} else {
				cfg.ssl_mode = .required
			}
			cfg.ssl_key = ssl_key
			cfg.ssl_cert = ssl_cert
			cfg.ssl_ca = ssl_ca
			cfg.ssl_capath = ssl_capath
			cfg.ssl_cipher = ssl_cipher
		}

		mut db := mysql.connect(cfg)!
		return &db
	}
	inner_pool := pool.new_connection_pool(create_conn, pool_conf)!
	return &DatabasePool[mysql.DB]{
		inner: inner_pool
	}
}

// acquire 返回 orm.Connection，数据库无关，用于 sql db { ... } 块。
pub fn (mut p DatabasePool[T]) acquire() !(orm.Connection, &pool.ConnectionPoolable) {
	raw_conn := p.inner.get()!
	raw := raw_conn as T
	return raw, raw_conn
}

// acquire_raw 返回具体类型 T，可用于调用驱动特有方法（如 db.exec()）。
pub fn (mut p DatabasePool[T]) acquire_raw() !(T, &pool.ConnectionPoolable) {
	raw_conn := p.inner.get()!
	raw := raw_conn as T
	return raw, raw_conn
}

pub fn (mut p DatabasePool[T]) release(conn &pool.ConnectionPoolable) ! {
	p.inner.put(conn)!
}

pub fn (mut p DatabasePool[T]) close() {
	p.inner.close()
}
