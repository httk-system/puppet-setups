function setups::apply() {
  $global_config = lookup("global")

  if $facts["system_id"] {
    $sysid = $facts["system_id"]
  } else {
    $sysid = $facts["hostname"]
  }

  if $sysid in lookup("systems") {
    $system_config = lookup("systems")[$sysid]
    notice("==== Eval of setups for system id: ${sysid}")
  } else {
    $system_config = {}
    notice("==== Eval of setups for system id: ${sysid} (note: no system-specific stanza)")
  }

  $all_aggrs = lookup("setups").reduce([]) |$aggr, $setup| {
    $setup_name=$setup.keys[0]
    $setup_config=$setup[$setup_name]
    if "config" in $setup_config and $setup_config["config"] =~ Hash {
      $setup_config_config = $setup_config["config"]
   } else {
      $setup_config_config = {}
    }
    $role_aggr = $setup_config[roles].reduce([]) |$role_aggr, $role_val| {
      $role_name = $role_val[0]
      $role_systems = $role_val[1]

      $role_sys_aggr = $role_systems.reduce([]) |$role_sys_aggr, $role_system| {
        if $role_system =~ Hash {
          $role_system_name=$role_system.keys[0]
          if $role_system_name in $role_system and $role_system[$role_system_name] =~ Hash {
            $role_system_config=$role_system[$role_system_name]
          } else {
            $role_system_config={}
          }
        } elsif $role_system =~ String {
          $role_system_name=$role_system
          $role_system_config={}
        } else {
          fail("Setup hierarchy error, expected Hash or String here: Setup:${setup_name} -> role:${role_name} -> system:${role_system}, got: ${role_type}")
        }
        if $role_system_name == $sysid {

          if $system_config =~ Hash {
            $config1 = $system_config
          } else {
            $config1 = {}
          }

          if $setup_config_config =~ Hash {
            $config2 = $setup_config_config
          } else {
            $config2 = {}
          }

          if $role_system_config =~ Hash {
            $config3 = $role_system_config
          } else {
            $config3 = {}
          }
          $config = $global_config + $config1 + $config2 + $config3
          if defined("setup_${setup_name}::${role_name}::meta") {
            notice("Applying setup function declared by setup_${setup_name}::${role_name}::meta : $config")
            include "setup_${setup_name}::${role_name}::meta"
            $paramlist = getvar("setup_${setup_name}::${role_name}::meta::paramlist")
            $setuptype = getvar("setup_${setup_name}::${role_name}::meta::setuptype")
            $callargs = $paramlist.map |$param| {
              if $config.has_key($param) {
                $config[$param]
              } else {
                undef
              }
            }
            $role_sys_aggr_new = call("setup_${setup_name}::${role_name}", *$callargs)
          } else {
            notice("Applying meta-less role function: setup_$setup_name::$role_name : $config")
            $role_sys_aggr_new = call("setup_${setup_name}::${role_name}", $config)
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

  # Here is a format example of how to return, e.g., two aggregators:
  # [{ func => 'setup_example', config => $config, vals => { val =>5 } }, { func => 'setup_example', config => $config, vals => {val => 10} }]

  $grouped_aggrs = $all_aggrs.reduce({}) |$grouped_aggr, $aggr| {
    $func = $aggr['func']
    if $func in $grouped_aggr {
      $new_config = $grouped_aggr[$func]['config'] + $aggr['config']
      $new = $aggr['vals'].reduce($grouped_aggr[$func]['aggr']) |$grouped_aggr_red, $itm| {
        $key=$itm[0]
        $val=$itm[1]
        if $key in $grouped_aggr_red {
          $grouped_aggr_red + {$key => $grouped_aggr_red[$key] + $val}
        } else {
          $grouped_aggr_red + {$itm[0] => $itm[1]}
        }
      }
      $grouped_aggr_new = $grouped_aggr + {$func => {config => $new_config, aggr => $new}}
    } else {
      $grouped_aggr_new = $grouped_aggr + {$func => {config => $aggr['config'], aggr => $aggr['vals']}}
    }
    $grouped_aggr_new
  }

  notice("==== Eval of collected aggregators")
  $grouped_aggrs.each() |$func, $val| {
    $config = $val['config'] + $val['aggr']
    notice("== Call to ${func} with config: ${config}")
    call($func, $config)
  }

}
