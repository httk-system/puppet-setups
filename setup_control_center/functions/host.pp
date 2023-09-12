function setup_control_center::host(
  $config,
) {
  include provide_control

  $aggr = setup_common::host($config)

  file { "/etc/profile.d/ssh-auth-sock.sh":
    ensure => 'present',
    mode => '644',
    content => "
if command -v gpgconf &>/dev/null; then
    export SSH_AUTH_SOCK=\"\$(gpgconf --list-dir agent-ssh-socket)\"
fi
    ",
  }

  # We do this ALSO in bashrc, to make sure it is re-executed
  # for new shells. However, also good to keep it in profile
  # for other shells than bash.
  file { "/etc/bash.bashrc.d/ssh-auth-sock.sh":
    ensure => 'present',
    mode => '644',
    content => "
if command -v gpgconf &>/dev/null; then
    export SSH_AUTH_SOCK=\"\$(gpgconf --list-dir agent-ssh-socket)\"
fi
    ",
    require => File['/etc/bash.bashrc.d'],
  }

  # Return aggregators
  $aggr
}
