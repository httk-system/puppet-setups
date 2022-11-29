class admins(
  $admin_users,
) {

      $home = "/home"
  
      $admin_users.each |$username, $userparams| {

           if 'active' in $userparams {
	     if $userparams['active'] {
	       $ensure = 'present'
	     } else {
  	       $ensure = 'absent'
	     }
	   } else {
	     $ensure = 'present'
	   }

	   $name = $userparams['name']
	   
           user { $username:
	     ensure => $ensure,
             managehome => $ensure ? { present => true, default => false, },
	     comment => "$name,,,",
	     gid => $userparams['gid'],
	     home => "$home/$username",
	     shell => '/bin/bash',
	     uid => $userparams['uid'],
	   }
           ->
           file { "${home}/${username}/.ssh":
             ensure => 'directory',
             owner  => $username,
             group  => $username,
             mode   => '0700',
           }
           ->
           file { "${home}/${username}/.ssh/authorized_keys_manage":
             ensure => present,
             source => "/etc/puppet/code/environments/production/security/authorized_keys.${username}",
             owner  => $username,
             group  => $username,
             mode   => '0700',
           }
      }
}
