# Class lightdm::service
class lightdm::service (
  $service_ensure   = $lightdm::service_ensure,
  $service_manage   = $lightdm::service_manage,
  $service_name     = $lightdm::service_name,
) {

  if $service_manage {
    service { 'display-manager':
      ensure => $service_ensure,
      name   => $service_name,
    }
  }

}
