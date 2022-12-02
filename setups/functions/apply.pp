function setups::apply() {

  $global_config = lookup("global")

  if $facts["system_id"] {
    $sysid = $facts["system_id"]
  } else {
    $sysid = $facts["hostname"]
  }

  if has_key(lookup("systems"),$sysid) {
    $system_config = lookup("systems")[$sysid]
    notice("System id: ${sysid}")
  } else {
    $system_config = {}
    notice("System id: ${sysid} (does not have system-specific stanza)")
  }

  $all_aggrs = lookup("setups").reduce([]) |$aggr, $setup| {
    $setup_name=$setup.keys[0]
    $setup_config=$setup[$setup_name]
    $setup_config_config = $setup_config[config]
    $role_aggr = $setup_config[roles].reduce([]) |$role_aggr, $role_val| {
      $role_name = $role_val[0]
      $role_systems = $role_val[1]
      $role_sys_aggr = $role_systems.reduce([]) |$role_sys_aggr, $role_system| {
        $role_type = type($role_system)
        if $role_type =~ Type[Hash] {
          $role_system_name=$role_system.keys[0]
          $role_system_config=$role_system[$role_system_name]
        } elsif $role_type =~ Type[String] {
          $role_system_name=$role_system
          $role_system_config={}
        } else {
          fail("Setup hierarchy error, expected Hash or String here: Setup:${setup_name} -> role:${role_name} -> system:${role_system}, got: ${role_type}")
        }
        if $role_system_name == $sysid {

          if $system_config =~ Type[Hash] {
            $config1 = $system_config
          } else {
            $config1 = {}
          }

          if $setup_config_config =~ Type[Hash] {
            $config2 = $setup_config_config
          } else {
            $config2 = {}
          }

          if $role_system_config =~ Type[Hash] {
            $config3 = $role_system_config
          } else {
            $config3 = {}
          }
          $config = $global_config + $config1 + $config2 + $config3
          notice("Applying role: $setup_name::$role_name : $config")

          $new_aggr = call("setup_$setup_name::$role_name", $config)
          if $new_aggr {
            $role_sys_aggr_new = $new_aggr
          } else {
            $role_sys_aggr_new = []
          }
        } else {
          $role_sys_aggr_new = []
        }
        $role_sys_aggr + $role_sys_aggr_new
      }
      $role_aggr + $role_sys_aggr
    }
    $aggr + $role_aggr
  }

  notice($all_aggrs)
  $grouped_aggrs = $all_aggrs.reduce({}) |$grouped_aggr, $aggr| {
    $func = $aggr['aggr']
    if $func in $grouped_aggr {
      $new = $aggr['config'].reduce($grouped_aggr[$func]) |$grouped_aggr_red, $itm| {
        $key=$itm[0]
        $val=$itm[1]
        if $key in $grouped_aggr_red {
          $grouped_aggr_red + {$key => $grouped_aggr_red[$key] + $val}
        } else {
          $grouped_aggr_red + {$itm[0] => $itm[1]}
        }
      }
      $grouped_aggr_new = $grouped_aggr + {$func => $new}
    } else {
      $grouped_aggr_new = $grouped_aggr + {$func => $aggr['config']}
    }
    $grouped_aggr_new
  }

  # TODO: Actually resolve aggreators
  notice("Resolving aggregators: $grouped_aggrs")

  #lookup('classes', {merge => unique}).include

}
