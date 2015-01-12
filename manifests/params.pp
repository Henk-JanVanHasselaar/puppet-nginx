# Class: nginx::params
#
# This class defines default parameters used by the main module class nginx
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to nginx class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class nginx::params {

  ### Application related parameters

  $package = $::operatingsystem ? {
    default => 'nginx',
  }

  $service = $::operatingsystem ? {
    default => 'nginx',
  }

  $service_status = $::operatingsystem ? {
    default => true,
  }

  $service_restart = $::operatingsystem ? {
    default => true,
  }

  $process = $::operatingsystem ? {
    default => 'nginx',
  }

  $config_dir = $::operatingsystem ? {
    default => '/etc/nginx',
  }

  $config_file = $::operatingsystem ? {
    default => '/etc/nginx/nginx.conf',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_init = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => '/etc/default/nginx',
    default                   => '/etc/sysconfig/nginx',
  }

  $pid_file = $::operatingsystem ? {
    default => '/var/run/nginx.pid',
  }

  $data_dir = $::operatingsystem ? {
    default => '/usr/share/nginx/html',
  }

  $log_dir = $::operatingsystem ? {
    default => '/var/log/nginx',
  }

  $log_file = $::operatingsystem ? {
    default => [ '/var/log/nginx/access.log' , '/var/log/nginx/error.log' ]
  }

  $port = '80'
  $protocol = 'tcp'

  # General Settings
  $config_file_default_purge = false
  $template = ''
  $options = ''
  $service_autorestart = true
  $version = 'present'
  $absent = false

}
