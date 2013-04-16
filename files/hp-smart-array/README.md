HP Smart Array RAID controller monitoring extension.

Check:
- controller, cache, battery* health;
- logical volumes health;
- physical drives health and temperature**;
- auto-discovery and agentd-side send data procedure.

Installation notes:
Run install.sh for agent-side configuration.
Import template.xml in Zabbix front-end.

Tested on:
- HP Smart Array P410
- HP Smart Array P222

* - cache and battery may NOT shows on P410;
** - some models may not show temperature (Seagate).
