IOstat
======

This template allows monitoring of device input/output statistics and utilization.

It's based on the iostat utility, which is part of the **sysstat**[1] package.


Overview
========

Use this template to monitor block device items like

* thoughput in terms of reads/s or writes/s
* size of the queues
* device utilization as percentage over time
* other metrics collected by _iostat_


Requirements
------------

* iostat version with support for JSON output (added in sysstat v11.5.1)
* Zabbix 5.0 LTS or newer
* crontab support on host
* proper time set on Zabbix server and host


Installation
============

1. Have the files of this folder[2] available.

2. Install **iostat** (part of sysstat) utility on host.

       # for CentOS
       yum install sysstat

       # for Debian/Ubuntu
       apt-get install sysstat

3. Adjust crontab on the host to collect iostat data by adding the line of
   the enclosed sample `crontab` file.

   After a minute you should see statistics in a temporary file:

       cat /tmp/iostat-cron.out

4. Copy `iostat.conf` to /etc/zabbix/zabbix_agent.d on host. Restart Zabbix
   agent to activate the change.

       service zabbix-agent restart
       # or
       systemctl restart zabbix-agent.service

5. On Zabbix server confirm that agent knows the newly created keys:

       zabbix_get -s www.example.com -k iostat.discovery

       # in case you configured TLS/PSK, you have to supply the needed properties
       zabbix_get -s www.example.com  --tls-psk-identity "Zabbix PSK" --tls-psk-file /etc/zabbix/zabbix_agent_pskfile.psk --tls-connect psk -k iostat.discovery

   This should return the results from device discovery and list block devices available on the host.

   Example:

   ```
   {
           "data":[
                   {
                           "{#HARDDISK}":"md0"},
                   {
                           "{#HARDDISK}":"md1"},
                   {
                           "{#HARDDISK}":"md2"},
                   {
                           "{#HARDDISK}":"nvme0n1"},
                   {
                           "{#HARDDISK}":"nvme1n1"}]}
   ```


6. Add the template to Zabbix by importing the file `iostat-disk-utilization-template.xml`.

   Assign the **IOstat** template to the hosts you want to monitor. You can "Execute now"
   the discovery to have items created immediately on the host.


7. Double-check that Zabbix created items for the host and that values are available in "Last data".

8. _Optional_: Adjust the discovery filter to your needs. Enable/Disable items you want to monitor.

9. _Optional_: Add graphs to your dashboard


Note:
This template will monitor the timestamp of incoming data and trigger an alert in case
the timestamp of the incoming data is off for more than 5 minutes. In this case
check the execution of the cronjob or for drift in system clock.


[1]: https://github.com/sysstat/sysstat
[2]: https://github.com/lesovsky/zabbix-extensions/tree/master/files/iostat
