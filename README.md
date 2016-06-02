# lightdm

#### Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with lightdm](#setup)
    * [What lightdm affects](#what-lightdm-affects)
    * [Beginning with lightdm](#beginning-with-lightdm)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

## Overview

This is a simple Puppet module for managing the lightdm display-manager and
setting lightdm as the system-wide display-manager for systemd systems.

## Setup

### What lightdm affects

* Installs lightdm package
* Manages /etc/lightdm/lightdm.conf
* Manages /etc/lightdm/users.conf
* Manages /etc/X11/default-display-manager

### Beginning with lightdm

```puppet
include '::lightdm'
```

## Usage

Typical usage will involve installing lightdm and setting it as the default
display-manager for the machine. We can also use the module to write out a
lightdm.conf for configuring lightdm.

```puppet
class { '::lightdm':
  config => {
    'Seat:*' => {
      'greeter-show-manual-login': 'true'
    }
}
```
## Reference

### Parameters

####`config`

Hash of configuration sections and keys/values to apply to lightdm.conf

####`config_users`

Hash of configuration sections and keys/values to apply to users.conf

####`greeter`

Which greeter to install and configure as the default.

####`make_default`

Boolean. If true the module will set lightdm as the default X11 display-manager
and update the systemd display-manager.service symlink to point to lightdm.

####`service_manage`

Boolean. If true the module will restart lightdm after config changes.

## Limitations

This module has been built on and tested against Puppet 3.x.

This module has been tested on:

* Ubuntu 16.04
