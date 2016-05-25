# Class lightdm::service
class lightdm::service (
  $service_ensure   = $lightdm::service_ensure,
  $service_name     = $lightdm::service_name,
  $service_provider = $lightdm::service_provider,
) {

  service { 'display-manager':
    name     => $service_name,
    ensure   => $service_ensure,
    provider => $service_provider,
  }

}
