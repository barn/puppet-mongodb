# Class: mongodb

class mongodb {

	include mongodb::params
	include mongodb::logrotate

	case $operatingsystem {
		/(?i)(Debian|Ubuntu|RedHat|CentOS)/: {
			include mongodb::install
		}
		default: {
			fail "Unsupported OS ${operatingsystem} in 'mongodb' module"
		}
	}

	File {
		require => [Class['mongodb::install'],Class['mongodb::params']]
	}

	define mongod (
		$mongod_instance = $name,
		$mongod_bind_ip = '',
		$mongod_port = 27017,
		$mongod_replSet = '',
		$mongod_enable = 'true',
		$mongod_running = 'true',
		$mongod_configsvr = 'false',
		$mongod_shardsvr = 'false',
		$mongod_logappend = 'true',
		$mongod_rest = 'true',
		$mongod_fork = 'true',
		$mongod_add_options = ''
	) {
		file {
			"/etc/mongod_${mongod_instance}.conf":
				content => template('mongodb/mongod.conf.erb'),
				mode    => '0755',
				# no auto restart of a db because of a config change
				#	notify  => Class['mongodb::service'],
				require => Class['mongodb::install'];
			"/etc/init.d/mongod_${mongod_instance}":
				content => template('mongodb/mongod-init.conf.erb'),
				mode    => '0755',
				require => Class['mongodb::install'],
		}

		service { "mongod_${mongod_instance}":
			enable     => $mongod_enable,
			ensure     => $mongod_running,
			hasstatus  => true,
			hasrestart => true,
			require    => File["/etc/init.d/mongod_${mongod_instance}"],
		}
	}

	define mongos (
		$mongos_instance = $name,
		$mongos_bind_ip = '',
		$mongos_port = 27017,
		$mongos_configServers,
		$mongos_enable = 'true',
		$mongos_running = 'true',
		$mongos_logappend = 'true',
		$mongos_fork = 'true',
		$mongos_add_options = ''
	) {
		file {
			"/etc/mongos_${mongos_instance}.conf":
				content => template('mongodb/mongos.conf.erb'),
				mode    => '0755',
				# no auto restart of a db because of a config change
				#	notify  => Class['mongodb::service'],
				require => Class['mongodb::install'];
			"/etc/init.d/mongos_${mongos_instance}":
				content => template('mongodb/mongos-init.conf.erb'),
				mode    => '0755',
				require => Class['mongodb::install'],
		}

		service { "mongos_${mongos_instance}":
			enable     => $mongos_enable,
			ensure     => $mongos_running,
			hasstatus  => true,
			hasrestart => true,
			require    => File["/etc/init.d/mongos_${mongos_instance}"],
		}
	}

}

