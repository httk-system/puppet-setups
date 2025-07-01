function setup_gateway::host(
  $config,
) {
      $external_if=$config[external_if]
      $internal_if=$config[internal_if]
      $internal_ip=$config[internal_ip]
      $internal_netbits=$config[internal_netbits]

      class { 'netplan':
        ipforward => true,
        ifs => {
	  $external_if => {
	    'dhcp4' => 'true',
	    'dhcp6' => 'false',
	  },
	  $internal_if => {
	    'dhcp4' => 'false',
	    'dhcp6' => 'false',
	    'addresses' => "[$internal_ip/$internal_netbits]"
	  },
	},
      }

      # Note - default firewall config already accept everyting EASTABLISHED or RELATED

#      if $config[nat_out_redirect] {
#
#      $config[nat_out_redirect].each |$v| {
#        $title=$v.keys[0]
#	$forward_cfg=$v[$title]
#	$ports = $forward_cfg[ports]
#	$proto = $forward_cfg[proto]
#	$source = $forward_cfg[source]
#	$dest = $forward_cfg[dest]
#	$todest = $forward_cfg[todest]
#
#        firewall { "110 nat_redirect $title out":
#          dport   => $ports,
#          proto  => $proto,
# 	  source => $source,
#	  destination => $dest,
#  	  iniface => $internal_if,
#	  ctstate => ['NEW'],
#          jump => 'accept',
#        }
#
#	firewall { "110 nat_redirect $title forward":
#          dport   => $ports,
#          proto  => $proto,
#  	  source => $source,
#  	  iniface => $internal_if,
#	  ctstate => ['NEW','ESTABLISHED','RELATED'],
#	  chain => 'FORWARD',
#          jump => 'accept',
#	}
#
#        firewall { "110 nat_redirect $title in":
#          sport   => $ports,
#          proto  => $proto,
#          outiface => $internal_if,
#	  ctstate => ['ESTABLISHED','RELATED'],
#	  chain => 'FORWARD',
#	  jump => 'accept',
#        }
#
#        firewall { "120 nat_redirect $title dnat preroute":
#          chain    => 'PREROUTING',
#          dport   => $ports,
#          proto  => $proto,
#	  destination => $dest,
#	  iniface => $internal_if,
#          jump => 'DNAT',
#	  todest => $todest,
#	  table => 'nat',
#        }
#
#        firewall { "120 nat_redirect $title snat postroute":
#          chain    => 'POSTROUTING',
#          dport   => $ports,
#          proto  => $proto,
#          outiface => $internal_if,
#  	  source => $dest,
#          jump => 'SNAT',
#	  tosource => $dest,
#	  table => 'nat',
#        }
#
#        firewall { "120 nat_redirect $title dnat output":
#          chain    => 'OUTPUT',
#          dport   => $ports,
#          proto  => $proto,
#          jump => 'DNAT',
#	  todest => $todest,
#	  table => 'nat',
#        }
#
#
#      }
#
#      }

      if $config[nat_out] {

      $config[nat_out].each |$v| {
        $title=$v.keys[0]
	$forward_cfg=$v[$title]
	$ports = $forward_cfg[ports]
	$proto = $forward_cfg[proto]
	$source = $forward_cfg[source]

        firewall { "110 nat_out $title out":
          dport   => $ports,
          proto  => $proto,
	  source => $source,
  	  iniface => $internal_if,
	  ctstate => ['NEW'],
          jump => 'accept',
        }

	firewall { "110 nat_out $title forward":
          dport   => $ports,
          proto  => $proto,
  	  source => $source,
          outiface => $external_if,
  	  iniface => $internal_if,
	  ctstate => ['NEW','ESTABLISHED','RELATED'],
	  chain => 'FORWARD',
          jump => 'accept',
	}

        firewall { "110 nat_out $title in":
          sport   => $ports,
          proto  => $proto,
          outiface => $internal_if,
	  iniface => $external_if,
	  ctstate => ['ESTABLISHED','RELATED'],
	  chain => 'FORWARD',
	  jump => 'accept',
        }

      	firewall { "120 nat_out $title snat":
          chain    => 'POSTROUTING',
          dport   => $ports,
          proto  => $proto,	  
      	  outiface => $external_if,
          jump => 'SNAT',
	  tosource => $config[ext_ip],
      	  table => 'nat',
      	}
      }

      }

      if $config[nat_inout] {

      $config[nat_inout].each |$v| {
        $title=$v.keys[0]
	$forward_cfg=$v[$title]
	$ports = $forward_cfg[ports]
	$proto = $forward_cfg[proto]
	$dest = $forward_cfg[dest]

        firewall { "110 nat_inout $title in":
          dport   => $ports,
          proto  => $proto,
  	  iniface => $external_if,
	  ctstate => ['NEW'],
          jump => 'accept',
        }

	firewall { "110 nat_inout $title forward":
          dport   => $ports,
          proto  => $proto,
          outiface => $internal_if,
  	  iniface => $external_if,
	  ctstate => ['NEW','ESTABLISHED','RELATED'],
	  chain => 'FORWARD',
          jump => 'accept',
	}

        firewall { "110 nat_inout $title out":
          sport   => $ports,
          proto  => $proto,
          outiface => $external_if,
	  iniface => $internal_if,
	  ctstate => ['ESTABLISHED','RELATED'],
	  chain => 'FORWARD',
	  jump => 'accept',
        }

        firewall { "120 nat_inout $title dnat preroute":
          chain    => 'PREROUTING',
          dport   => $ports,
          proto  => $proto,
	  iniface => $external_if,
          jump => 'DNAT',
	  todest => $dest,
	  table => 'nat',
        }

        firewall { "120 nat_inout $title dnat postroute":
          chain    => 'POSTROUTING',
          dport   => $ports,
          proto  => $proto,
          outiface => $internal_if,
  	  destination => $dest,
          jump => 'SNAT',
	  tosource => $config[ip],
	  table => 'nat',
        }

      }

      }

      if $config[nat_in] {

      $config[nat_in].each |$v| {
        $title=$v.keys[0]
	$forward_cfg=$v[$title]
	$ports = $forward_cfg[ports]
	$proto = $forward_cfg[proto]
	$dest = $forward_cfg[dest]

        firewall { "110 nat_in $title in":
          dport   => $ports,
          proto  => $proto,
  	  iniface => $external_if,
	  ctstate => ['NEW'],
          jump => 'accept',
        }

	firewall { "110 nat_in $title forward":
          dport   => $ports,
          proto  => $proto,
          outiface => $internal_if,
  	  iniface => $external_if,
	  ctstate => ['NEW','ESTABLISHED','RELATED'],
	  chain => 'FORWARD',
          jump => 'accept',
	}

        firewall { "110 nat_in $title out":
          sport   => $ports,
          proto  => $proto,
          outiface => $external_if,
	  iniface => $internal_if,
	  ctstate => ['ESTABLISHED','RELATED'],
	  chain => 'FORWARD',
	  jump => 'accept',
        }

        firewall { "120 nat_in $title dnat preroute":
          chain    => 'PREROUTING',
          dport   => $ports,
          proto  => $proto,
	  iniface => $external_if,
          jump => 'DNAT',
	  todest => $dest,
	  table => 'nat',
        }

      }

      }

      
      # Return dependecies
      []
      
}
