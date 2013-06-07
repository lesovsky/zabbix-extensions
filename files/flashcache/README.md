нужен установленный модуль flashcache
для zabbix нужно разрешение выполнять dmsetup через sudo
статистика собирается из 
    /proc/flashcache/<volname>/flashcache_errors 
    /proc/flashcache/<volname>/flashcache_stats
    dmsetup table <dm-name>
есть авто-обнаружение томов
