function setup_managed::host(
  $config,
) {
  include provide_managed

  # firewall config
  class { 'network_firewall::setup':
    whitelist => $config['firewall_whitelist'],
    rate_limit_ssh => $config['rate_limit_ssh'],
    rate_limit_ssh_forward => $config['rate_limit_ssh_forward'],
    ssh_ports => $config['ssh_port'],
    ssh_forward_ports => $config['ssh_forward_ports'],
    ssh_exclude => $config['ssh_exclude'],
    ssh_forward_exclude => $config['ssh_forward_exclude'],
  }

  # sshd config
  class { 'ssh::server':
    port => $config['ssh_port'],
    password_auth => $config['ssh_passwords'],
    fail2ban_exclude => $config['fail2ban_exclude'],
  }

  $return = setup_common::host($config)

  # Return dependencies
  $return

}
