class setups::common(
      $config,
){
    include provide_control

    # firewall config
    class { 'network_firewall::setup':
      whitelist => $config['firewall_whitelist'],
      rate_limit_ssh => $config['rate_limit_ssh'],
      rate_limit_ssh_forward => $config['rate_limit_ssh_forward'],
      ssh_ports => $config['ssh_port'],
      ssh_forward_ports => $config['ssh_forward_ports'],
      ssh_exclude => $config['ssh_exclude'],
      ssh_forward_exclude => $config['ssh_forward_exclude'],
    }

    # sshd config
    class { 'ssh::server':
      port => $config['ssh_port'],
      password_auth => $config['ssh_passwords'],
      fail2ban_exclude => $config['fail2ban_exclude'],
    }

    # common packages needed everywhere
    $package_list = [
      'git',
      'screen',
    ]
    manage::packages::present($package_list)
    
    # set locale
    class { 'locales':
        default_locale => 'en_US.UTF-8',
        locales        => ['en_US.UTF-8', 'sv_SE.UTF-8', 'UTF-8'],
    }

    file {
      '/usr/control/puppet-apply':
        owner => root, group => root, mode => '0755',
        ensure  => present,
	require => File['/usr/control'],
        content => template('setups/root-control-puppet-apply.erb'),
        ;
      '/usr/control/puppet-pull':
        owner => root, group => root, mode => '0755',
        ensure  => present,
	require => File['/usr/control'],
        content => template('setups/root-control-puppet-pull.erb'),
        ;
      '/usr/control/puppet-push':
        owner => root, group => root, mode => '0755',
        ensure  => present,
	require => File['/usr/control'],
        content => template('setups/root-control-puppet-push.erb'),
        ;
      '/usr/control/puppet-validate':
        owner => root, group => root, mode => '0755',
        ensure  => present,
	require => File['/usr/control'],
        content => template('setups/root-control-puppet-validate.erb'),
        ;      
      '/usr/control/puppet-update-safe':
        owner => root, group => root, mode => '0755',
        ensure  => present,
	require => File['/usr/control'],
        content => template('setups/root-control-puppet-update-safe.erb'),
        ;
    }

    if $config['motd'] {

      class { 'motd':
        message => $config['motd'],
      }

    }

}
