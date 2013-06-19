# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils git-2

DESCRIPTION="Zabbix additional monitoring modules"
HOMEPAGE="https://github.com/lesovsky/zabbix-extensions"
EGIT_REPO_URI="https://github.com/lesovsky/zabbix-extensions.git"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="flashcache glusterfs-client memcached pgbouncer postgres redis skytools unicorn"

HWRAID="smartarray"

for name in $HWRAID; do
	IUSE="${IUSE} hwraid_${name}"
done

DEPEND=">=net-analyzer/zabbix-2.0.0
		pgbouncer? ( dev-db/postgresql-base )
		postgres? ( dev-db/postgresql-base )
		skytools? ( dev-db/postgresql-base )
		redis? ( dev-db/redis )
		hwraid_smartarray? ( sys-block/hpacucli )
		unicorn? ( net-misc/curl )"
RDEPEND="${DEPEND}"

src_install() {
	dodir \
		/etc/zabbix/zabbix_agentd.d \
		/etc/zabbix/scripts

	fowners zabbix:zabbix \
			/etc/zabbix/scripts \
			/etc/zabbix/zabbix_agentd.d
	fperms 0750 \
			/etc/zabbix/scripts \
			/etc/zabbix/zabbix_agentd.d

	insinto /etc/zabbix/zabbix_agentd.d
	doins "files/linux/linux-extended.conf"
	insinto /etc/zabbix/scripts/
	doins \
		"files/linux/scripts/check-open-descriptors.sh" \
		"files/linux/scripts/mem-usage.sh" \
		"files/linux/scripts/swap.discovery.sh"

	if use redis; then 
		insinto /etc/zabbix/zabbix_agentd.d
	    doins "files/redis/redis.conf"
	fi

	if use memcached; then 
		insinto /etc/zabbix/zabbix_agentd.d
	    doins "files/memcached/memcached.conf"
	fi

	if use pgbouncer; then
		insinto /etc/zabbix/zabbix_agentd.d
		doins "files/pgbouncer/pgbouncer.conf"
		insinto /etc/zabbix/scripts/
		doins \
			"files/pgbouncer/scripts/pgbouncer.pool.discovery.sh" \
			"files/pgbouncer/scripts/pgbouncer.stat.sh"
	fi

	if use postgres; then
		insinto /etc/zabbix/zabbix_agentd.d
		doins "files/postgresql/postgresql.conf"
		insinto /etc/zabbix/scripts/
		doins \
			"files/postgresql/scripts/pgsql.autovacuum.freeze.sh" \
			"files/postgresql/scripts/pgsql.buffercache.sh" \
			"files/postgresql/scripts/pgsql.connections.sh" \
			"files/postgresql/scripts/pgsql.db.discovery.sh" \
			"files/postgresql/scripts/pgsql.db.size.sh" \
			"files/postgresql/scripts/pgsql.dbstat.sh" \
			"files/postgresql/scripts/pgsql.indexes.size.sh" \
			"files/postgresql/scripts/pgsql.pgqd.lag.sh" \
			"files/postgresql/scripts/pgsql.ping.sh" \
			"files/postgresql/scripts/pgsql.relation.size.sh" \
			"files/postgresql/scripts/pgsql.relation.stat.sh" \
			"files/postgresql/scripts/pgsql.relation.tuples.sh" \
			"files/postgresql/scripts/pgsql.streaming.lag.sh" \
			"files/postgresql/scripts/pgsql.transactions.sh" \
			"files/postgresql/scripts/pgsql.uptime.sh" \
			"files/postgresql/scripts/pgsql.trigger.sh" \
			"files/postgresql/scripts/pgsql.wal.write.sh"
	fi

	if use glusterfs-client; then
		insinto /etc/zabbix/zabbix_agentd.d
        doins "files/glusterfs-client/glusterfs.conf"
        insinto /etc/zabbix/scripts/
        doins \
            "files/glusterfs-client/scripts/glusterfs.discovery.sh"
	fi

	if use flashcache; then
		insinto /etc/zabbix/zabbix_agentd.d
        doins "files/flashcache/flashcache.conf"
        insinto /etc/zabbix/scripts/
        doins \
            "files/flashcache/scripts/flashcache.dm.discovery.sh" \
			"files/flashcache/scripts/flashcache.vol.discovery.sh"
    fi

	if use hwraid_smartarray; then
		insinto /etc/zabbix/zabbix_agentd.d
		doins "${S}/files/hp-smart-array/hp-raid-smart-array.conf"
		insinto /etc/zabbix/scripts/
	    doins \
			"files/hp-smart-array/scripts/hp-raid-data-processor.sh" \
			"files/hp-smart-array/scripts/hp-raid-ctrl-discovery.sh" \
			"files/hp-smart-array/scripts/hp-raid-ld-discovery.sh" \
			"files/hp-smart-array/scripts/hp-raid-pd-discovery.sh"
	fi

	if use skytools; then
		insinto /etc/zabbix/zabbix_agentd.d
        doins "files/skytools/skytools.conf"
        insinto /etc/zabbix/scripts/
        doins \
            "files/skytools/scripts/skytools.pgqd.sh" \
			"files/skytools/scripts/skytools.pgqd.queue.discovery.sh"
    fi

	if use unicorn; then
		insinto /etc/zabbix/zabbix_agentd.d
        doins "files/unicorn/unicorn.conf"
    fi
}

pkg_postinst() {
	chown -R zabbix:zabbix \
		"${ROOT}"/etc/zabbix/scripts/*.sh
	chmod 0750 \
		"${ROOT}"/etc/zabbix/scripts/*.sh

	if use postgres; then
		elog 
		elog "For PostgreSQL monitoring need setup md5 auth with .pgpass for zabbix user."
		elog "For example:"
		elog "# echo 'localhost:5432:app_db:app_role:app_pass' > ~zabbix/.pgpass"
		elog "# chown zabbix:zabbix ~zabbix/.pgpass"
		elog "# chmod 600 ~zabbix/.pgpass"
		elog
		elog "More explained: http://www.thislinux.org/2012/10/postgresql-monitoring-via-zabbix.html"
		elog
	fi

	if use hwraid_smartarray; then
		elog
		elog "SmartArray monitoring extension uses hpacucli, zabbix-sender, and cron task."
		elog "Install following crontask into root crontab manually:"
		elog "*/10 * * * * /etc/zabbix/scripts/hp-raid-data-processor.sh"
		elog
	fi

	elog
	elog "After installation and before restart zabbix agent,"
	elog "make sure that the following option enabled in zabbix_agentd.conf:"
	elog "Include=/etc/zabbix/zabbix_agentd.d/"
	elog
}
