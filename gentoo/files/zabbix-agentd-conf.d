# Author:	Abdulbjarov R.
# Description:	Reduce oom_score for zabbix-agentd processes avoid sudden kills by OOMKiller.

start_post() {
        ebegin "adjust OOM score for ${RC_SVCNAME}"

	ewaitfile 5 /var/run/zabbix/zabbix_agentd.pid || return 0

	# Reduce oom_score_adj for master process
        PPID_Z="$(cat /var/run/zabbix/zabbix_agentd.pid)"
        local FILE_OOM_SCORE_ADJ="/proc/${PPID_Z}/oom_score_adj"
        [ -f "${FILE_OOM_SCORE_ADJ}" ] && echo '-1000' > "${FILE_OOM_SCORE_ADJ}"

        # Reduce oom_score_adj for worker processes
        for IPID_Z in $(ps --ppid ${PPID_Z} |grep zabbix |awk '{print $1}'); do
                echo '-1000' > "/proc/${IPID_Z}/oom_score_adj"
        done

        eend $?
        return 0
}
