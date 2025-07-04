function setup_user_accounts::host(
  $config,
) {

      $home = $config['home']

      if $config['nobackup_homes'] {
        file { "/nobackup":
          ensure => 'directory',
          owner  => root,
          group  => root,
          mode   => '0755',
        }    
      }
  
      if 'managehome' in $config {
        $managehome = $config['managehome']
      } else {
        $managehome = false
      }

      $gid_to_groupname = $config['groups'].reduce({}) |$acc, $pair| {
        $groupname = $pair[0]
        $groupparams = $pair[1]
        $acc + {
          $groupparams['gid'] => $groupname
        }
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

           $gid = $groupparams['gid']

           group { $groupname:
	     ensure => $present,
	     gid => $gid,
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
           $uid = $userparams['uid']
           $gid = $userparams['gid']

           user { $username:
	     ensure => $present,
	     comment => "$name,,,",
	     gid => $userparams['gid'],
	     home => "$home/$username",
	     shell => '/bin/bash',
	     uid => $uid,
             managehome => $managehome,
	   }

           if $userparams['subgids'] {

             $subgid_start = $userparams['subgids']

             file_line { "subgid_${username}":
               ensure => $present,
               path   => '/etc/subgid',
               line   => "${username}:${subgid_start}:65536",
               match  => "^${regexpescape($name)}:",
             }
           }

           if $userparams['subuids'] {

             $subuid_start = $userparams['subuids']

             file_line { "subuid_${username}":
               ensure => $present,
               path   => '/etc/subuid',
               line   => "${username}:${subuid_start}:65536",
               match   => "^${regexpescape($name)}:",
             }
           }

           if $config['nobackup_homes'] {
             file { "/nobackup/${username}":
               ensure => 'directory',
               owner  => $username,
               group  => $gid_to_groupname[$gid],
               mode   => '0700',
               require => File['/nobackup'],
             }
           }
      }

      # Return dependencies
      []
}
