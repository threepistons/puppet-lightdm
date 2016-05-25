# Class lightdm::params
class lightdm::params {

  case $::osfamily {
    'Debian': {
      $config_file      = '/etc/lightdm/lightdm.conf'
      $config_users_file = '/etc/lightdm/users.conf'
      $package_ensure   = 'installed'
      $service_ensure   = 'running'
      $package_name     = 'lightdm'
      $service_name     = 'display-manager'
      $package_provider = 'apt'

      case $::operatingsystem {
        'Ubuntu' : {
          if (versioncmp($::operatingsystemrelease, '15.04') >= 0) {
            $service_provider = 'systemd'
          } else {
            $service_provider = 'upstart'
          }
        }
        default: {
          if (versioncmp($::operatingsystemmajrelease, '8') >= 0) {
            $service_provider = 'systemd'
          }
        }
      }
    }
    default: {
      fail("The ${module_name} module is not supported on an ${::osfamily} based system.")
    }
  }

  $config       = {}
  $config_users = {}
  $make_default = true

}
