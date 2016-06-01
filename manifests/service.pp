# Class lightdm::service
class lightdm::service (
  $service_ensure   = $lightdm::service_ensure,
  $service_manage   = $lightdm::service_manage,
  $service_name     = $lightdm::service_name,
  $service_provider = $lightdm::service_provider,
) {

  if $service_manage {
    service { 'display-manager':
      name     => $service_name,
      ensure   => $service_ensure,
      provider => $service_provider,
    }
  }

}
