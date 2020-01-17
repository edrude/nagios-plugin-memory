# nagios-plugin-memory
Nagios Ruby plugin to check available memory on Linux systems

Uses the value of (MemAvailable / MemTotal) from /proc/meminfo to determine current % of memory available.
This seems to make more sense than what some of the other tools I've seen are doing.

From the free command man page MemAvailable is: 
Estimation of how much memory is available for starting new applications, without swapping. Unlike the data provided by the cache or free fields, this field takes into account page cache and also that not all reclaimable memory slabs will be reclaimed due to items being in use 

# Requirements
Ruby

On EL6 vm.meminfo_legacy_layout must be set to 0. `sysctl -w vm.meminfo_legacy_layout=0`

# Tested on
* CentOS6 - ruby 1.8.7 (2013-06-27 patchlevel 374) [x86_64-linux]
* CentOS7 - ruby 2.0.0p648 (2015-12-16) [x86_64-linux]
