# = Class: nginx
#
# This is the main nginx class
#
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*template*]
#   Sets the path to the template to use as content for main configuration file
#   If defined, nginx main config file has: content => content("$template")
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#   Can be defined also by the (top scope) variable $nginx_options
#
# [*service_autorestart*]
#   Automatically restarts the nginx service when there is a change in
#   configuration files. Default: true, Set to false if you don't want to
#   automatically restart the service.
#
# [*version*]
#   The package version, used in the ensure parameter of package type.
#   Default: present. Can be 'latest' or a specific version number.
#   Note that if the argument absent (see below) is set to true, the
#   package is removed, whatever the value of version parameter.
#
# [*absent*]
#   Set to 'true' to remove package(s) installed by module
#   Can be defined also by the (top scope) variable $nginx_absent
#
# [*disable*]
#   Set to 'true' to disable service(s) managed by module
#   Can be defined also by the (top scope) variable $nginx_disable
#
# [*disableboot*]
#   Set to 'true' to disable service(s) at boot, without checks if it's running
#   Use this when the service is managed by a tool like a cluster software
#   Can be defined also by the (top scope) variable $nginx_disableboot
#
# Default class params - As defined in nginx::params.
# Note that these variables are mostly defined and used in the module itself,
# overriding the default values might not affected all the involved components.
# Set and override them only if you know what you're doing.
# Note also that you can't override/set them via top scope variables.
#
# [*package*]
#   The name of nginx package
#
# [*service*]
#   The name of nginx service
#
# [*service_status*]
#   If the nginx service init script supports status argument
#
# [*service_restart*]
#   If the nginx service init script supports restart argument. Default is true
#
# [*process*]
#   The name of nginx process
#
# [*config_dir*]
#   Main configuration directory. Used by puppi
#
# [*config_file*]
#   Main configuration file path
#
# [*config_file_mode*]
#   Main configuration file path mode
#
# [*config_file_owner*]
#   Main configuration file path owner
#
# [*config_file_group*]
#   Main configuration file path group
#
# [*config_file_init*]
#   Path of configuration file sourced by init script
#
# [*config_file_default_purge*]
#   Set to 'true' to purge the default configuration file
#
# == Examples
#
# You can use this class in 2 ways:
# - Set variables (at top scope level on in a ENC) and "include nginx"
# - Call nginx as a parametrized class
#
# See README for details.
#
#
# == Author
#   Alessandro Franceschi <al@lab42.it/>
#
class nginx (
  $template            = $nginx::params::template,
  $service_autorestart = $nginx::params::service_autorestart,
  $options             = $nginx::params::options,
  $version             = $nginx::params::version,
  $absent              = $nginx::params::absent,
  $disable             = $nginx::params::disable,
  $disableboot         = $nginx::params::disableboot,
  $package             = $nginx::params::package,
  $service             = $nginx::params::service,
  $service_status      = $nginx::params::service_status,
  $service_restart     = $nginx::params::service_restart,
  $process             = $nginx::params::process,
  $config_dir          = $nginx::params::config_dir,
  $config_file         = $nginx::params::config_file,
  $config_file_mode    = $nginx::params::config_file_mode,
  $config_file_owner   = $nginx::params::config_file_owner,
  $config_file_group   = $nginx::params::config_file_group,
  $config_file_init    = $nginx::params::config_file_init,
  $config_file_default_purge = $nginx::params::config_file_default_purge,
  ) inherits nginx::params {

  $bool_service_autorestart=str2bool($service_autorestart)
  $bool_absent=str2bool($absent)

  ### Calculation of variables that dependes on arguments
  $path = "${nginx::config_dir}/conf.d"

  ### Definition of some variables used in the module
  $manage_package = $nginx::bool_absent ? {
    true  => 'absent',
    false => $nginx::version,
  }

  $manage_service_enable = true
  $manage_service_ensure = 'running'

  $manage_service_autorestart = $nginx::bool_service_autorestart ? {
    true    => 'Service[nginx]',
    false   => undef,
  }

  $manage_file = $nginx::bool_absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_file_content = template($nginx::template)

  ### Managed resources
  $distro = downcase($::operatingsystem)

  Exec['apt_update'] -> Package['nginx']
  apt::source { 'nginx':
    location   => "http://nginx.org/packages/${distro}",
    repos      => 'nginx',
    key        => '7BD9BF62',
    key_source => 'http://nginx.org/keys/nginx_signing.key',
  }

  package { 'nginx':
    ensure => $nginx::version,
    name   => $nginx::package,
  }

  service { 'nginx':
    ensure     => $nginx::manage_service_ensure,
    name       => $nginx::service,
    enable     => $nginx::manage_service_enable,
    hasstatus  => $nginx::service_status,
    hasrestart => $nginx::service_restart,
    pattern    => $nginx::process,
    require    => Package['nginx'],
  }

  file { $nginx::config_file:
    ensure  => $nginx::manage_file,
    path    => $config_file,
    mode    => $nginx::config_file_mode,
    owner   => $nginx::config_file_owner,
    group   => $nginx::config_file_group,
    require => Package['nginx'],
    notify  => $nginx::manage_service_autorestart,
    source  => $nginx::manage_file_source,
    content => $nginx::manage_file_content,
    replace => $nginx::manage_file_replace,
  }

  # Purge default vhost configuration
  if $nginx::config_file_default_purge {
    file { "${nginx::path}/default.conf":
      ensure  => absent,
      require => Package[$nginx::package],
      notify  => Service[$nginx::service],
    }
    file { "${nginx::path}/example_ssl.conf":
      ensure  => absent,
      require => Package[$nginx::package],
      notify  => Service[$nginx::service],
    }
  }
}
