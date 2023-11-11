function setup_workstation::host(
  $config,
) {

  $package_list = [
    'git',
    'puppet',
    'less',
    'nano',
    'gpg',
    'scdaemon',

    'bind9-dnsutils',
    'vim',
    'bzip2',
    'unison',
    'rsync',
    'screen',
    'emacs',

    'python3',
    'python3-docutils',
    'python3-pytest',
    'python3-matplotlib',
    'python3-numpy',
    'python3-scipy',
    'python3-ase',

    'ubuntu-gnome-desktop',
    'thunderbird',
    'cheese',
    'gnome-tweaks',
    'gnome-shell-extension-manager',
    'ttf-mscorefonts-installer',
    'sshfs',
    'elpa-yaml-mode',
    'elpa-puppet-mode',
    'gparted',
    'blender',
    'typecatcher',
    'autokey-gtk',
    'obs-studio',
    'pdftk',
    'ghostscript',
    'ttf-mscorefonts-installer'

    'texlive-full',
    'gimp',
    'rawtherapee',
    'inkscape',
    'libreoffice',
    'libreoffice-i10n-sv',
  ]

  manage::packages::present($package_list)

  class { 'anaconda':
    flavor => "Mambaforge",
    version => "4.14.0-0"
  }

  # Dependencies
  []
}
