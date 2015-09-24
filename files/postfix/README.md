Just in case - Installation
---------------------------

postfix-minimal-template.xml needs to be installed under:

    Configuration -> Templates -> Import

userparameter_postfix.conf goes to:

    /etc/zabbix/zabbix_agentd.d/

and make sure you restart zabbix-agent service after.


SELinux module needs to compiled into loadable module and installed:

    checkmodule -M -m -o zabbix-postqueue-local.mod zabbix-postqueue-local.te
    semodule_package -o zabbix-postqueue-local.pp -m zabbix-postqueue-local.mod
    semodule -i zabbix-postqueue-local.pp 
  
