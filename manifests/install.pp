# Class: mongodb::install
#
#
class mongodb::install {

	include $mongodb::params::repo_class

	package { 'mongodb-stable':
		name   => $mongodb::params::old_server_pkg_name,
		ensure => absent,
	}
	
	package { 'mongodb-10gen':
		name    => $mongodb::params::server_pkg_name,
		ensure  => installed,
		require => Class[$mongodb::params::repo_class],
	}
	
}
