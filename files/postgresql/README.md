PostgreSQL
==========

PostgreSQL monitoring with Zabbix.

The Template DB PostgreSQL was formerly known as pgCayenne.

It is a set of `UserParameter` for PostgreSQL monitoring, which consists of Zabbix agent configuration and XML template for web monitoring. It is using built-in PostgreSQL system views and functions. The agent requires the standard `psql` client utility.

## Features
- minimalistic configuration for monitored host, Zabbix agent and pg_hba access
- no scripts, no .pgpass, no other redundant entities - only configuration for Zabbix agent
- template-defined macros for configuring triggers and psql connection settings
- gathering information about connections, transaction time, database and table statistics, streaming replication lag, and more...
- low level discovery for streaming standby servers, databases, tables

## Supported versions
- all upstream supported PostgreSQL versions (9.5 and above)
- Zabbix 3.4, 4.0 LTS, 5.0 LTS (and newer unless breaking with LTS)

## Short how-to install and configure
- download repository with `git clone`
- copy __postgresql.conf__ into Zabbix agent configuration directory
- include __postgresql.conf__ into Zabbix agent main configuration (see `Include` option in __zabbix_agentd.conf__)
- restart Zabbix agent service
- edit PostgreSQL service __pg_hba.conf__ to allow connections from Zabbix agent
- recommended: enable extensions `pg_buffercache` and `pg_stat_statements`
- import XML template into web monitoring and link template with target host
- edit template macros parameters (set connections settings and other options)
- add additional items into template if required

## Full how-to install and configure
- download repository with `git clone`:
```
# git clone https://github.com/lesovsky/zabbix-extensions
```

- copy __postgresql.conf__ into Zabbix agent configuration directory (target directory maybe different in other OS):
```
# mkdir /etc/zabbix/zabbix_agentd.d/
# cp files/postgresql/postgresql.conf /etc/zabbix/zabbix_agentd.d/
```

- include __postgresql.conf__ into Zabbix agent main configuration (add or uncomment `Include` option in __zabbix_agentd.conf__);
```
# vi /etc/zabbix/zabbix_agentd.conf
Include=/etc/zabbix/zabbix_agentd.d/
```

- restart Zabbix agent service:
```
# systemctl restart zabbix-agent.service
```

- edit access rules in PostgreSQL [pg_hba.conf](http://www.postgresql.org/docs/9.3/static/auth-pg-hba-conf.html) (example for RHEL-based OS).
```
# vi /var/lib/pgsql/9.3/data/pg_hba.conf
host    db_production   postgres    127.0.0.1/32    trust
```

- reload PostgreSQL configuration after making changes
```
# systemctl reload postgresql.service
```

- recommended: enable extensions `pg_buffercache` and `pg_stat_statements`

- verify installation with `zabbix_get`
```
# zabbix_get -s 127.0.0.1 -k pgsql.ping['-h 127.0.0.1 -p 5432 -U postgres -d postgres']
```
If all things done correctly, we can see the response time of PostgreSQL service. Otherwise check all steps again and Zabbix agentd log/PostgreSQL log.

- import XML template into web monitoring and link template with target host

- adjust predefined template macros where needed. Either on a per host setting or globally for the template.
 - PG_CONNINFO - connection settings for Zabbix agent connections to the PostgreSQL service
 - PG_CONNINFO_STANDBY - connection settings for Zabbix agent connections to the PostgreSQL service on standby servers, required for streaming replication lag monitoring
 - PG_CACHE_HIT_RATIO - shared buffers cache ratio
 - PG_CHECKPOINTS_REQ_THRESHOLD - threshold for checkpoints which occurred by demand
 - PG_CONFLICTS_THRESHOLD - threshold for recovery conflicts trigger
 - PG_CONN_IDLE_IN_TRANSACTION - threshold for connections which are idle in transaction state
 - PG_CONN_TOTAL_PCT - the percentage of the total number of connections to the maximum allowed (`max_connections`)
 - PG_CONN_WAITING - threshold for connections which are in waiting state
 - PG_DATABASE_SIZE_THRESHOLD - threshold for database size
 - PG_DEADLOCKS_THRESHOLD - threshold for deadlock conflicts trigger
 - PG_LONG_QUERY_THRESHOLD - threshold for long transactions trigger
 - PG_PING_THRESHOLD_MS - threshold for PostgreSQL service response
 - PG_SR_LAG_BYTE - threshold in bytes for streaming replication lag between server and discovered standby servers
 - PG_SR_LAG_SEC - threshold in seconds for streaming replication lag between server and discovered standby servers
 - PG_UPTIME_THRESHOLD - threshold for service uptime
 - PG_PROCESS_NAME - the name of the main PostgreSQL process. Usually `postgres` which is the default value. Change if your system uses a different process name (e.g. the deprecated `postmaster` alias)

- add additional items into template if required

## Graph descriptions
- PostgreSQL bgwriter - information about buffers, how much allocated and written
- PostgreSQL buffers - general information about shared buffers: how much cleaned, dirtied, used and total
- PostgreSQL checkpoints - checkpoints and write/sync time during checkpoints
- PostgreSQL connections - connection info (idle, active, waiting, idle in transaction)
- PostgreSQL service response - service response, average query time (extension `pg_stat_statements` required)
- PostgreSQL summary db stats: block hit/read - information about how much blocks read from disk or cache
- PostgreSQL summary db stats: events - commits and rollbacks, recovery conflicts and deadlocks
- PostgreSQL summary db stats: temp files - information about allocated temporary files
- PostgreSQL summary db stats: tuples - how much tuples inserted/deleted/updated/fetched/returned
- PostgreSQL transactions - max execution time for active/idle/waiting/prepared transactions
- PostgreSQL uptime - cache hit ratio and uptime
- PostgreSQL write-ahead log - information about amount of WAL write and WAL segments count
- PostgreSQL database size - per-database graph with database size
- PostgreSQL table read stat - information about how much block of table or index read from disk or cache (per-table)
- PostgreSQL table rows - how much tuples inserted/updated/deleted per second (per-table)
- PostgreSQL table scans - sequential/index scans and how many rows returned by these scans (per-table)
- PostgreSQL table size - table and table's indexes size (per-table)
- PostgreSQL streaming replication lag with standby - streaming replication between master and standby in bytes and seconds (per-standby)

## Known issues
- Table low-level discovery requires manual specification of a list of tables to find, otherwise LLD generates many items (21 items per table)

## Authors
Modernization and adaption for recent software version by Stephan Knauß.

Based on work by Alexey Lesovsky and PR by various others.
For details see the git version log.
