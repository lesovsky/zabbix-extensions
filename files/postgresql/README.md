pgCayenne
=========

PostgreSQL monitoring with Zabbix.

pgCayenne is a set of UserParameter for PostgreSQL monitoring, which consists of zabbix agent configuration and XML template for web monitoring. pgCayenne is using a built-in PostgreSQL system views and functions. pgCayenne no require redundant package dependencies, only psql - standart PostgreSQL client utility.

#### Features:
- minimalistic configuration for monitored host, zabbix agent and pg_hba access;
- no scripts, no .pgpass, no other redundant entities - only configuration for zabbix agent;
- template-defined macros for configuring triggers and psql connection settings;
- gathering information about connections, transaction time, database and table statistics, streaming replication lag, and more...
- low level discovery for streaming standby servers, databases, tables.

#### Short how-to install and configure:
- download repo with git clone;
- copy postgresql.conf into zabbix agent config directory;
- include postgresql.conf into zabbix agent main configuration (see Include option in zabbix_agentd.conf);
- restart zabbix agent service;
- edit postgresql service pg_hba.conf for allowing connections from zabbix agent;
- import XML template into web monitoring and link template with target host;
- edit tamplate macros parameters (set connections settings and other options);
- add additional items into template if required.

#### Full how-to install and configure:
- download repo with git clone:
```
# git clone https://github.com/lesovsky/zabbix-extensions
```

- copy postgresql.conf into zabbix agent config directory (target directory maybe different in other OS):
```
# mkdir /etc/zabbix/zabbix_agentd.d/
# cp files/postgresql/postgresql.conf /etc/zabbix/zabbix_agentd.d/
```

- include postgresql.conf into zabbix agent main configuration (add or uncomment Include option in zabbix_agentd.conf);
```
# vi /etc/zabbix/zabbix_agentd.conf
Include=/etc/zabbix/zabbix_agentd.d/
```

- restart zabbix agent service:
```
# systemctl restart zabbix-agent.service
```

- edit access rules in postgres [pg_hba.conf](http://www.postgresql.org/docs/9.3/static/auth-pg-hba-conf.html) (example for RHEL-based OS).
```
# vi /var/lib/pgsql/9.3/data/pg_hba.conf
host    db_production   postgres    127.0.0.1/32    trust
```

- after edit postgres service need reload
```
# systemctl reload postgresql.service
```

- and now we can make simple check with zabbix_get
```
# zabbix_get -s 127.0.0.1 -k pgsql.ping['-h 127.0.0.1 -p 5432 -U postgres -d db_production']
```
If all things done correctly, we can see the responce time of postgresql service. Otherwise should check all steps again and zabbix agentd log.

- import XML template into web monitoring and link template with target host;

- edit template macros, go to the template page and open "Macros" tab:
PG_CONNINFO - connection settings for zabbix agent connections to the postgres service;

PG_CONNINFO_STANDBY - connection settings for zabbix agent connections to the postgres service on standby servers, required for streaming replication lag monitoring;

PG_CACHE_HIT_RATIO - shared buffers cache ratio;

PG_CHECKPOINTS_REQ_THRESHOLD - threshold for checkpoints which occured by demand;

PG_CONFLICTS_THRESHOLD - threshold for recovery conflicts trigger;

PG_CONN_IDLE_IN_TRANSACTION - threshold for connections which is idle in transaction state;

PG_CONN_TOTAL_PCT - the percentage of the total number of connections to the maximum allowed (max_connections);

PG_CONN_WAITING - threshold for connections which is in waiting state;

PG_DATABASE_SIZE_THRESHOLD - threshold for database size;

PG_DEADLOCKS_THRESHOLD - threshold for deadlock conflicts trigger;

PG_LONG_QUERY_THRESHOLD - threshold for long transactions trigger;

PG_PING_THRESHOLD_MS - threshold for postgres service response;

PG_SR_LAG_BYTE - threshold in bytes for streaming replication lag between server and discovered standby servers;

PG_SR_LAG_SEC - threshold in seconds for streaming replication lag between server and discovered standby servers;

PG_UPTIME_THRESHOLD - threshold for service uptime.

- add additional items into template if required.

#### Graphs description
- PostgreSQL bgwriter - information about buffers, how much allocated and written.
- PostgreSQL buffers - general information about shared buffers; how much cleaned, dirtied, used and total.
- PostgreSQL checkpoints - checkpoints and write/sync time during chckpoints.
- PostgreSQL connections - connection info (idle, active, waiting, idle in transaction).
- PostgreSQL service response - service response, average query time (pg_stat_statements required).
- PostgreSQL summary db stats: block hit/read - information about how much blocks read from disk or cache.
- PostgreSQL summary db stats: events - commits and rollbacks, recovery conflicts and deadlocks.
- PostgreSQL summary db stats: temp files - information about allocated temporary files.
- PostgreSQL summary db stats: tuples - how much tuples inserted/deleted/updated/fetched/returned.
- PostgreSQL transactions - max execution time for active/idle/waiting/prepared transactions.
- PostgreSQL uptime - cache hit ratio and uptime.
- PostgerSQL write-ahead log - information about amount of WAL write and WAL segments count.
- PostgreSQL database size - per-database graph with database size.
- PostgreSQL table read stat - information about how much block of table or index readden from disk or cache (per-table).
- PostgreSQL table rows - how much tuples inserted/updated/deleted per second (per-table).
- PostgreSQL table scans - sequential/index scans andhow much rows returned by this scans (per-table).
- PostgreSQL table size - table and table's indexes size (per-table).
- PostgreSQL streaming replication lag with standby - streaming replication between master and standby in bytes and seconds (per-standby).

#### Known issues:
- Supported PostgreSQL version is 9.2 and above.
- PostgreSQL version 9.1 and later supported partially (procpid field in pg_stat_activity renamed to pid in 9.2).
- Strongly recommended install pg_buffercache and pg_stat_statements extensions into monitored database.
- Table low-level discovery require manual specifies a list of tables to find, otherwise LLD generate many items (21 item per table).

#### Todo:
- ...
