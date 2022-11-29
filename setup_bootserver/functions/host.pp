function setup_bootserver::host(
  $config,
) {
      include dhcpd

      $bootserver_ip = $config['ip']

      package {[
          # 'isc-dhcp-server', automatically added by puppet dhcp module
          # 'tftpd-hpa', added by tftpd module
          'syslinux',
          'initramfs-tools',
          'dnsmasq',
	  'pxelinux',
        ]:
        ensure => present,
      }

      dhcpd::config{ "bootserver":
            dnsdomains => [
                            $config['domain'],
                            $config['internal_inaddr_domain'],
                            ],
            nameservers => [$bootserver_ip],
            ntpservers => [$bootserver_ip],
            interfaces => [$config['dhcp_if']],
            pxeserver => $bootserver_ip,
            pxefilename => '/usr/lib/PXELINUX/pxelinux.0',
      }

      #  class { 'dhcp':
      #  service_ensure => running,
      #  dnsdomain      => [
      #    $config['domain'],
      #    $config['internal_inaddr_domain'],
      #  ],
      #  nameservers  => [$bootserver_ip],
      #  ntpservers   => [$bootserver_ip],
      #  interfaces   => [$config['dhcp_if']],
      #  pxeserver    => $bootserver_ip,
      #  pxefilename  => '/usr/lib/PXELINUX/pxelinux.0',
      #}

      dhcp::pool{ $config['dhcp_domain']:
        network => $config['dhcp_subnet_ip'],
        mask    => $config['dhcp_netmask'],
        range   => [$config['dhcp_range']],
        gateway => $bootserver_ip,
      }

      class { 'tftpd::server':
            ip => $bootserver_ip,
            port => 69
      }

      # Return dependecies
      []
}
