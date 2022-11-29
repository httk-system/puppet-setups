function setup_dnsserver::host(
  $config,
) {
      class { 'resolved':
        ip => $config['dnsserver_ip']
      }

      # Return dependecies
      []
}
