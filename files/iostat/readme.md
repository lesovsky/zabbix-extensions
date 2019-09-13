For editional monitoring functionality of HDD there is usefull unilit iostat.
It is allows to collect important metrics like:
- coefficient of disc capacity "utilization"
- average operations processing time "await"
- average capacity of queue length of operations to disk deal with "average queue size"
- other metrics of iostat: rrqm/s, wrqm/s, r/s, w/s, rkB/s, wkB/s, avgrq-sz, r_await, w_await, svctm

This is step by step instrucion of start collect this iostat metric in zabbix monitoring system.

1. install iostat utility wich is part of sysstat library
> \#for CentOS <br>
> yum install sysstat

2. copy file iostat.conf in /etc/zabbix/zabbix_agent.d on server

3. copy file ./scripts/iostat-collect.sh in /usr/libexec/zabbix-extensions/scripts/ on server

4. give file iostat-collect.sh permissions to be executable
>> chmod +x iostat-collect.sh

5. register crontask to grab summary iostat metrics per minute
>\* \* \* \* \* /usr/libexec/zabbix-extensions/scripts/iostat-collect.sh /tmp/iostat-cron.out 59 >/dev/null 2>&1

6. after waiting a minute do test working new cron job by looking in output file
> tail -f /tmp/iostat-cron.out

7. reboot zabbix agent on server
>service zabbix-agent restart

8. test working auto discovery zabix item for discovering new hdd partitions on server
> zabbix_get -s 127.0.0.1 -k iostat.discovery

9. test aveilablility collecting iostat metrics on existing hdd partition
> zabbix_get -s 127.0.0.1 -k iostat.summary[sda]

10. register zabbix template iostat-disk-utilization-template.xml, set it for host "Zabbix server"
(some not important items will be disable for default - you can change it for your own vision)

11. for host "Zabbix server" execute discovery rule "Disks discovery" (instead of whaiting for a new hour)

12. looking for host "Zabbix server" in group "iostat" - there will be created new discovered and postpocessed items for each HDD partition: utilization, await, average queue size.

13. looking for last data of discovered items in "Last data" tab

14. add custom graphic chart on main dashboard of zabbix server health with items like cpu iowait, utilization items for system disc and disc of database (if it is not the same disk).