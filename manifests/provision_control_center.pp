class { 'control':
}

class { 'gssh':
  path => '/usr/control/gssh',
  require => File['/usr/control'],
}
