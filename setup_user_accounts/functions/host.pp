function setup_user_accounts::host(
  $config,
) {

      $home = $config['home']

      if 'managehome' in $config {
        $managehome = $config['managehome']
      } else {
        $managehome = false
      }
      
      $config['groups'].each |$groupname, $groupparams| {

           if 'active' in $groupparams {
	     if $groupparams['active'] {
	       $present = 'present'
	     } else {
  	       $present = 'absent'
	     }
	   } else {
	     $present = 'present'
	   }

           group { $groupname:
	     ensure => $present,
	     gid => $groupparams['gid'],
	   }
      }

      $config['users'].each |$username, $userparams| {

           if 'active' in $userparams {
	     if $userparams['active'] {
	       $present = 'present'
	     } else {
  	       $present = 'absent'
	     }
	   } else {
	     $present = 'present'
	   }

	   $name = $userparams['name']
	   
           user { $username:
	     ensure => $present,
	     comment => "$name,,,",
	     gid => $userparams['gid'],
	     home => "$home/$username",
	     shell => '/bin/bash',
	     uid => $userparams['uid'],
             managehome => $managehome,
	   }
      }

      # Return dependencies
      []
}
