function setup_control_center::host(
  $config,
) {
  include provide_control

  $return = setup_common::host($config)

  # Return dependencies
  #$return

  $return + [{ aggr => 'gurk', config => { val =>5 } }, { aggr => 'gurk', config => {val => 10} }]
}
