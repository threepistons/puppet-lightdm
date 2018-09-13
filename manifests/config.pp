# Class lightdm::config
class lightdm::config (
  $ddir                = $lightdm::ddir,
  $config_path         = $lightdm::config_path,
  $config_file         = $lightdm::config_file,
  $config              = $lightdm::_config,
  $config_dir          = $lightdm::config_dir,
  $config_users_file   = $lightdm::config_users_file,
  $config_users        = $lightdm::config_users,
  $config_users_dir    = $lightdm::config_users_dir,
  $config_greeter_dir  = $lightdm::config_greeter_dir,
  $config_greeter      = $lightdm::config_greeter,
  $config_greeter_file = $lightdm::config_greeter_file

) {

  file { $config_path :
    ensure  => directory,
    recurse => true,
    purge   => true
  }


  if $ddir == false {
    if $config != {} {
      file { 'lightdm.conf':
        ensure  => 'file',
        path    => $config_file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("${module_name}/lightdm.conf.erb"),
        notify  => Class['lightdm::service']
      }
    }

    if $config_users != {} {
      file { 'users.conf':
        ensure  => 'file',
        path    => $config_users_file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("${module_name}/users.conf.erb"),
        notify  => Class['lightdm::service']
      }
    }

    if $config_greeter != {} {
      file { "lightdm-${lightdm::greeter}-greeter.conf":
        ensure  => 'file',
        path    => $config_greeter_file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("${module_name}/greeter.conf.erb"),
        notify  => Class['lightdm::service']
      }
    }
  } else {
    # create the .d directories and pop files into them
    if $config != {} {
      file { 'lightdm.conf.d':
        ensure => directory,
        path   => $config_dir,
        owner  => 'root',
        group  => 'root',
        mode   => '0755'
      }

      $config.each | String $filename, Hash $stub | {
        file { $filename:
          ensure  => file,
          path    => "${config_dir}/${filename}",
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template("${module_name}/stub.erb"),
          notify  => Class['lightdm::service']
        }
      }
    }

    if $config_users != {} {
      file { 'users.conf.d':
        ensure => directory,
        path   => $config_users_dir,
        owner  => 'root',
        group  => 'root',
        mode   => '0755'
      }

      $config.each | String $filename, Hash $stub | {
        file { $filename:
          ensure  => file,
          path    => "${config_users_dir}/${filename}",
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template("${module_name}/stub.erb"),
          notify  => Class['lightdm::service']
        }
      }
    }

    if $config_greeter != {} {
      file { "lightdm-${lightdm::greeter}-greeter.conf.d":
        ensure => directory,
        path   => $config_greeter_dir,
        owner  => 'root',
        group  => 'root',
        mode   => '0755'
      }

      $config.each | String $filename, Hash $stub | {
        file { $filename:
          ensure  => file,
          path    => "${config_greeter_dir}/${filename}",
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template("${module_name}/stub.erb"),
          notify  => Class['lightdm::service']
        }
      }
    }
  }
}
