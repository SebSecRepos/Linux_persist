#!/bin/bash
(
chattr -i /usr/bin/${1}.sh /lib/systemd/system/${1}.service /etc/cron.d/${1}
rm /usr/bin/${1}.sh /lib/systemd/system/${1}.service /etc/cron.d/${1}
) &>/dev/null