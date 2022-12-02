function setup_common::host(
  $config,
) {
  include provide_control

  if $config['common_packages'] {
    manage::packages::present($config['common_packages'])
  }

  # set locale
  if $config['locales'] or $config['default_locale'] {
    class { 'locales':
      default_locale => $config['default_locale'],
      locales        => $config['locales'],
    }
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

  if $config['admins'] {
    class { 'admins':
      admins => $config['admins'],
    }
  }

  if $config['users'] {
    $return = setup_user_accounts::host($config)
  } else {
    $return = []
  }

  # Return dependencies
  $return
}
