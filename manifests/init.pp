# Class lightdm
# ===========================
#
# Puppet module for installing and managing lightdm
#
# Parameters
# ----------
#
# * `config`
# Hash of config to apply in /etc/lightdm/lightdm.conf.
# See below for example.
#
# * `config_users`
# Hash of config to apply in /etc/lightdm/users.conf
# See below for example.
#
# * `greeter`
# Which greeter to install and configure as the default.
#
# * `make_default`
# Should lightdm be made the default display-manager?
#
# * `service_manage`
# Should we restart lightdm service on config file changes?
#
# Examples
# --------
#
# @example
#    class { 'lightdm':
#      config => {
#        'Seat:*' => {
#          'greeter-show-manual-login': 'true'
#        }
#      },
#      config_users => {
#        'UserList' => {
#          'minimum-uid': '50'
#        }
#      },
#      make_default => true
#    }
#
# Authors
# -------
#
# Brad Cowie <brad@wand.net.nz>
#
# Copyright
# ---------
#
# Copyright 2016 Brad Cowie, unless otherwise noted.
#
class lightdm (

  $config_file,
  $config_users_file,
  $config_greeter_file,
  $config,
  $config_users,
  $greeter,
  $make_default,
  $package_ensure,
  $package_name,
  $package_provider,
  $service_ensure,
  $service_manage,
  $service_name,
  $service_provider

) {

  validate_absolute_path($config_file)
  validate_absolute_path($config_users_file)
  validate_hash($config)
  validate_hash($config_users)
  validate_string($greeter)
  validate_bool($make_default)
  validate_string($package_ensure)
  validate_string($package_name)
  validate_string($package_provider)
  validate_string($service_ensure)
  validate_bool($service_manage)
  validate_string($service_name)
  validate_string($service_provider)

  # Merge greeter choice into main config
  if $greeter {
    $greeter_config = {
      'Seat:*'        => {
        'greeter-session' => $greeter
      }
    }
    $_config = deep_merge($greeter_config, $config)
  } else {
    $_config = $config
  }

  include '::lightdm::install'
  include '::lightdm::config'
  include '::lightdm::service'

  # Anchor this as per #8040 - this ensures that classes won't float off and
  # mess everything up.  You can read about this at:
  # http://docs.puppetlabs.com/puppet/2.7/reference/lang_containment.html#known-issues
  anchor { 'lightdm::begin': }
  anchor { 'lightdm::end': }

  Anchor['lightdm::begin'] -> Class['::lightdm::install']
    -> Class['::lightdm::config'] ~> Class['::lightdm::service']
    -> Anchor['lightdm::end']

}
