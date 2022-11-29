function setup_webserver::host(
  $config,
) {
  
  # TODO: add vhosts based on hiera config
  #
  # include 'webserver'
  #
  #    apache::vhost { 'www_example_nonssl':
  #      port    => '80',
  #      servername => 'www.example.com',
  #      docroot => '/var/www/example',
  #	 docroot_owner => 'www-data',
  #	 docroot_group => 'www-data',
  #	 redirect_status => 'permanent',
  #	 redirect_dest   => 'https://www.example.com/',
  #    }

  #    apache::vhost { 'example_nossl':
  #      port    => '80',
  #      servername => 'example.com',
  #      docroot => '/var/www/example',
  #	 docroot_owner => 'www-data',
  #	 docroot_group => 'www-data',
  #	 redirect_status => 'permanent',
  #	 redirect_dest   => 'https://www.example.com/',
  #    }

  #    apache::vhost { 'example_ssl':
  #      port    => '443',
  #      servername => 'example.com',
  #      docroot => '/var/www/example',
  #	 docroot_owner => 'www-data',
  #	 docroot_group => 'www-data',
  #	 ssl => true,
  #	 redirect_status => 'permanent',
  #	 redirect_dest   => 'https://www.example.com/',
  # 	 ssl_cert => '/etc/letsencrypt/live/example.com/fullchain.pem',
  # 	 ssl_key => '/etc/letsencrypt/live/example.com/privkey.pem'
  #    }

  #    apache::vhost { 'www_example_ssl':
  #      port    => '443',
  #      servername => 'www.example.com',
  #      docroot => '/var/www/example',
  # 	 docroot_owner => 'www-data',
  #	 docroot_group => 'www-data',
  #	 ssl => true,
  #	 ssl_cert => '/etc/letsencrypt/live/example.com/fullchain.pem',
  #	 ssl_key => '/etc/letsencrypt/live/example.com/privkey.pem'
  #    }

  #  include 'certbot_apache'

  #  certbot_apache::request { 'example':
  #  	certbot_domains => ['example.com', 'www.example.com'],
  #	certbot_email => 'certbot@example.com',
  #	agree_tos => true,
  #	eff_email => false,
  #	https_redirect => true,
  #	notify => Class['Apache::Service']    
  #  }

    # Return dependecies
    []
    
}

