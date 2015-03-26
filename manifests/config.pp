# == Class proftpd::config
#
class proftpd::config {

  # Should we manage the configuration at all?
  if ( $::proftpd::manage_config_file == true ) {

    # check if anonymous access should be enabled
    if ( $::proftpd::anonymous_enable == true ) {
      $real_defaults = deep_merge($::proftpd::default_options,
                                  $::proftpd::anonymous_options)

    }
    # do not include options for anonymous access
    else { $real_defaults = $::proftpd::default_options }

    # check if defaults should be included
    if ( $::proftpd::default_config == true ) {
      $real_options = deep_merge($real_defaults, $::proftpd::options)
    }
    # do not include defaults
    else { $real_options = $::proftpd::options }

    # required variables
    $base_dir     = $::proftpd::base_dir
    $load_modules = $::proftpd::load_modules

    File {
      ensure  => present,
      require => Class['::proftpd::install'],
      notify  => Service[$::proftpd::service_name],
    }

    file {
      $::proftpd::base_dir:
        ensure => directory,
        owner  => $::proftpd::config_user,
        group  => $::proftpd::config_group;

      $::proftpd::log_dir:
        ensure => directory,
        owner  => $::proftpd::config_user,
        group  => $::proftpd::config_group;

      $::proftpd::run_dir:
        ensure => directory,
        owner  => $::proftpd::config_user,
        group  => $::proftpd::config_group;

      $::proftpd::config:
        ensure       => file,
        mode         => $::proftpd::config_mode,
        content      => template($::proftpd::config_template),
        validate_cmd => "${::proftpd::prefix_bin}/proftpd -t -c %",
        owner        => $::proftpd::config_user,
        group        => $::proftpd::config_group;
    }

    concat { "${::proftpd::base_dir}/modules.conf":
      owner  => $::proftpd::config_user,
      group  => $::proftpd::config_group,
      # modules may be required for validate_cmd to succeed
      before => File[$::proftpd::config],
    }

    concat::fragment { 'proftp_modules_header':
      ensure  => present,
      target  => "${::proftpd::base_dir}/modules.conf",
      content => "# File is managed by Puppet\n",
      order   => '01',
    }

  }

}