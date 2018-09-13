# Class lightdm::install
class lightdm::install (
  $greeter          = $lightdm::greeter,
  $make_default     = $lightdm::make_default,
  $package_ensure   = $lightdm::package_ensure,
  $package_name     = $lightdm::package_name,
) {

  if $make_default {

    file { 'default-display-manager':
      ensure  => 'file',
      path    => '/etc/X11/default-display-manager',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "/usr/sbin/lightdm\n"
    }

    # Stop current display-manager before we install lightdm
    exec { 'stop other display-manager':
      command => 'systemctl stop display-manager',
      onlyif  => 'test "$(readlink /etc/systemd/system/display-manager.service)" != "/lib/systemd/system/lightdm.service"',
      path    => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
      user    => 'root',
      before  => Package['lightdm'],
      notify  => Exec['set shared/default-x-display-manager']
    }

    # Set prefered display-manager to lightdm
    exec { 'set shared/default-x-display-manager':
      command     => 'echo lightdm shared/default-x-display-manager select lightdm | debconf-set-selections',
      path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
      user        => 'root',
      refreshonly => true,
      notify      => Exec['dpkg-reconfigure lightdm'],
      require     => Package['lightdm']
    }

    # We need to dpkg-reconfigure lightdm after setting default-x-display-manager
    # to rebuild the display-manager.service symlink for systemd
    exec { 'dpkg-reconfigure lightdm':
      command     => 'dpkg-reconfigure lightdm',
      path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
      user        => 'root',
      refreshonly => true,
      notify      => Class['lightdm::service'],
      require     => [Exec['set shared/default-x-display-manager'], File['default-display-manager']]
    }

    package { 'lightdm':
      ensure => $package_ensure,
      name   => $package_name,
      before => File['default-display-manager'],
      notify => Exec['set shared/default-x-display-manager']
    }

  } else {

    package { 'lightdm':
      ensure => $package_ensure,
      name   => $package_name,
    }

  }

  # Install greeter
  if $greeter {
    package {'lightdm-greeter':
      ensure => $package_ensure,
      name   => $greeter,
    }
  }


}
