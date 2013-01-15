#
# Regular cron jobs for the ambition package
#
0 4	* * *	root	[ -x /usr/bin/ambition_maintenance ] && /usr/bin/ambition_maintenance
