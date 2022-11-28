include 'provide_managed'

class { 'gssh':
  path => '/usr/control/gssh',
  require => File['/usr/control'],
}
