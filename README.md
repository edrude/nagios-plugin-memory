# nagios-plugin-memory
Nagios plugin to check available memory on EL6 and EL7 systems

# Requirements
Ruby

On EL6 vm.meminfo_legacy_layout must be set to 0. `sysctl -w vm.mem-info_legacy_layout=0`


# Tested on
* CentOS6 - ruby 1.8.7 (2013-06-27 patchlevel 374) [x86_64-linux]
* CentOS7 - ruby 2.0.0p648 (2015-12-16) [x86_64-linux]
