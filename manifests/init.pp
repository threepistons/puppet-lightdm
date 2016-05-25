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
# * `make_default`
# Should lightdm be made the default display-manager?
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
  $config_file       = $lightdm::params::config_file,
  $config_users_file = $lightdm::params::config_users_file,
  $config            = $lightdm::params::config,
  $config_users      = $lightdm::params::config_users,
  $make_default      = $lightdm::params::make_default,
  $package_ensure    = $lightdm::params::package_ensure,
  $package_name      = $lightdm::params::package_name,
  $package_provider  = $lightdm::params::package_provider,
  $service_ensure    = $lightdm::params::service_ensure,
  $service_name      = $lightdm::params::service_name,
  $service_provider  = $lightdm::params::service_provider,

) inherits lightdm::params {

  validate_absolute_path($config_file)
  validate_absolute_path($config_users_file)
  validate_hash($config)
  validate_hash($config_users)
  validate_bool($make_default)
  validate_string($package_ensure)
  validate_string($package_name)
  validate_string($package_provider)
  validate_string($service_ensure)
  validate_string($service_name)
  validate_string($service_provider)

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
