#!/bin/bash

#chkconfig: 2345 20 20
#description: Auto install Hostguard Agent when first start the os

### BEGIN INIT INFO
# Provides:          HSSInstall
# Required-Start:    $network $local_fs
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Host Security Agent Install
# Description:       Auto install Hostguard Agent.
### END INIT INFO

##########################################################

MASTER_VERSION=hostmgr/version
MASTER_URL=hostmgr/websocket
MASTER_PKT_URL=public/agent/linux/

zone_hcs=(
    #huadong,jinrong hcso
    cn-east-201
    https://100.125.0.60:443
    #huabei,jinrong hcso
    cn-north-219
    https://100.125.0.22:443
)

zone_info=(
    #huanan,guangzhou2
    cn-south-1
    https://100.125.4.16:443
    #huanan,guangzhou1
    cn-south-2b
    https://100.125.4.16:443
    #huanan, shenzhen
    cn-south-2
    https://100.125.0.39:443  
    #xinan,guiyang
    cn-southwest-2
    https://100.125.1.91:443
    #huadong,hangzhou
    cn-east-204
    https://100.125.2.30:443   
    #huadong,shanghai2
    cn-east-2
    https://100.125.4.31:443
    #huadong,shanghai1
    cn-east-3
    https://100.125.2.72:443
    #dongbei,dalian
    cn-northeast-1
    https://100.125.4.102:443
    #huawei,beijing1
    cn-north-1
    https://100.125.4.16:443
    #huawei,beijing4
    cn-north-4
    https://100.125.1.41:443
    #yatai,xianggang
    ap-southeast-1
    https://100.125.0.41:443
    #yatai,mangu
    ap-southeast-2
    https://100.125.1.175:443
    #yatai,xinjiapo
    ap-southeast-3
    https://100.125.3.21:443
    #wulanchabu1
    cn-north-5
    https://100.79.0.161:443
    #wulanchabu2
    cn-north-6
    https://100.79.0.76:443
    #wulanchabu3
    cn-north-7
    https://100.79.0.79:443

)

arch=`arch`
if [ "$arch"x == "x86_64"x ]; then
    RPM_TAR_PACKAGE=hss_linux64_rpm.tar.gz
    DEB_TAR_PACKAGE=hss_linux64_deb.tar.gz
    DEB_TAR_PACKAGE_32=hss_linux32_deb.tar.gz
    TAR_TAR_PACKAGE=hss_linux64_tar.tar.gz
else
    RPM_TAR_PACKAGE=hss_linux_arm64_rpm.tar.gz
    DEB_TAR_PACKAGE=hss_linux_arm64_deb.tar.gz
    #TAR_TAR_PACKAGE=hss_linux_arm64_tar.tar.gz
fi

global_obs_url=https://hostguard-agent.obs.myhuaweicloud.com/linux/
region_obs_url=https://hostguard-agent.obs.myhuaweicloud.com/linux/

# Help
usage()
{
    echo "Usage: sh autoinstall.sh"
    echo ""
}

#logme "error info" "level"
logme()
{
    which logger > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        logger -i -t "HSSInstall" -p local3.$2 "$1"
    #else
    #    echo "HSSInstall: $1"
    fi
    
    #cur_time=$(date "+%Y-%m-%d %H:%M:%S")
    #echo "$cur_time: HSSInstall $1" >> /var/log/install.log
}

# query metadata to check if need to install agent
curl_metadata()
{
    #get metadata
    local meta_json
    
    for i in {1..5}
    do
        wget --version > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            wget -t 1 -T 2 -q --no-check-certificate -O /tmp/hostguard_meta_data.json http://169.254.169.254/openstack/latest/meta_data.json > /dev/null 2>&1
        else
            curl --version > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                curl -s -X GET --connect-timeout 2 http://169.254.169.254/openstack/latest/meta_data.json > /tmp/hostguard_meta_data.json
            fi
        fi
        
        meta_json=$(cat /tmp/hostguard_meta_data.json)
        availability_zone_secure=$(expr "$meta_json" : '.*"availability_zone":\s*"\([^"]*\)".*') 
        availability_zone_secure=$(echo $availability_zone_secure|sed "s/^[ \"]*//g")
        availability_zone_secure=$(echo $availability_zone_secure|sed "s/[ \"]*$//g")
        export availability_zone_secure=$availability_zone_secure
        export availability_zone_name=$(echo $availability_zone_secure|sed "s/[^0-9]*$//g")
        agent_list=$(expr "$meta_json" : '.*"__support_agent_list":\s*"\([^"]*\)".*')
        agent_flag="hss"
        if [[ "${agent_list}" =~ "${agent_flag}" ]]; then
            return 0
        else
            sleep 60
            continue
        fi
    done
    
    return 1
}

gen_zone_obs_url()
{
    region_obs_url="https://hss-agent.${availability_zone_name}.obs.${availability_zone_name}.myhuaweicloud.com/linux/"
}

selectRegion()
{
    local cmd_prefix
    wget --version > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        cmd_prefix="wget -t 1 -T 2 -q --no-check-certificate -O hostguard_version"
    else
        curl --version > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            cmd_prefix="curl -s -k --connect-timeout 2"
        fi
    fi

    idx=0
    for i in ${zone_info[@]}
    do
        if [[ "$availability_zone_secure" == $i* ]]; then
            zone_ip=${zone_info[idx+1]}

            export package_url="${zone_ip}/$MASTER_PKT_URL"
            export hostguard_master_url="${zone_ip}/$MASTER_URL"
            logme "Hit region [$availability_zone_secure]" "info"
            return 0

        fi
        let idx++
    done
    
    idx=0
    for i in ${zone_info[@]}
    do
        if [[ "$i" == https* ]]; then
            zone_ip=${zone_info[idx]}
            ${cmd_prefix} "${zone_ip}/$MASTER_VERSION" > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                export package_url="${zone_ip}/$MASTER_PKT_URL"
                export hostguard_master_url="${zone_ip}/$MASTER_URL"
                logme "Select region [${zone_info[idx - 1]}]" "info"
                return 0
            fi
        fi
        let idx++
    done

    return 1
}

selectHCSORegion()
{
    idx=0
    for i in ${zone_hcs[@]}
    do
        if [[ "$availability_zone_secure" == $i* ]]; then
            zone_ip=${zone_hcs[idx+1]}

            export package_url="${zone_ip}/$MASTER_PKT_URL"
            export hostguard_master_url="${zone_ip}/$MASTER_URL"
            logme "HCSO Hit region [$availability_zone_secure]" "info"
            return 0
        fi
        let idx++
    done

    return 1
}

download_file()
{
    local ret=1
    local cmd
    wget --version > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        cmd="wget -t 1 -T 5 -q --no-check-certificate $1"
    else
        curl --version > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            cmd="curl -s -k --connect-timeout 5 -O $1"
        fi
    fi
    
    for i in {1..3}
    do
        ${cmd}
        if [ $? -ne 0 ]; then
            sleep 5
            continue
        else
            ret=0
            break
        fi
    done
    
    return $ret
}

download_agent()
{
    local url=$1
    local name=$2
    
    download_file $url$name
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    tar -xf ${name} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        logme "Untar intall hss package failed." "err"
        return 1
    fi
    
    return 0
}

installRPM()
{
    url=$1
    package_name="${RPM_TAR_PACKAGE}"
    
	download_agent ${url} ${package_name}
    if [ $? -ne 0 ]; then
        logme "Download rpm install package failed." "err"
        return 1
    fi
	
    rpm -ivh HostGuardAgent_Linux*.rpm > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        logme "Intall hss agent failed, rpm package." "err"
        return 1
    fi
    
    echo "[huaweicloud]" >> /usr/local/hostguard/conf/system.conf
    echo "preinstall=true" >> /usr/local/hostguard/conf/system.conf
    service hostguard restart >/dev/null 2>&1

    return 0
}

installDEB()
{
    url=$1
    local package_name
    ldconfig > /dev/null 2>&1
    if [ "$(getconf WORD_BIT)" = '32' ] && [ "$(getconf LONG_BIT)" = '64' ] ; then
        package_name="${DEB_TAR_PACKAGE}"
    else
        package_name="${DEB_TAR_PACKAGE_32}"
    fi
    
	download_agent ${url} ${package_name}
    if [ $? -ne 0 ]; then
        logme "Download install deb package failed." "err"
        return 1
    fi
	
	dpkg -i HostGuardAgent_Linux*.deb > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		logme "Intall hss agent failed, deb package." "err"
        return 1
	fi
    
    echo "[huaweicloud]" >> /usr/local/hostguard/conf/system.conf
    echo "preinstall=true" >> /usr/local/hostguard/conf/system.conf
    service hostguard restart >/dev/null 2>&1

	return 0
}

installTAR()
{
    url=$1
    if [[ -z "$hostguard_master_url" ]]; then
        logme "The url of package or hss master is NULL." "info"
        return 1
    fi

    package_name="${TAR_TAR_PACKAGE}"
    
    download_agent ${url} ${package_name}
    if [ $? -ne 0 ]; then
        logme "Download tar install package failed." "err"
        return 1
    fi

	tar -xf HostGuardAgent_*.tar.gz -C /usr/local/
	if [ $? -ne 0 ]; then
        logme "Intall hss agent failed, tar package." "err"
		return 1
	fi
    
    sed -i -e "s#master=https.*#master=$hostguard_master_url#g" /usr/local/hostguard/conf/system.conf
    echo "[huaweicloud]" >> /usr/local/hostguard/conf/system.conf
    echo "preinstall=true" >> /usr/local/hostguard/conf/system.conf
    mv /usr/local/hostguard/control /etc/init.d/hostguard
    chmod a+x /etc/init.d/hostguard
    
    if [ -x /sbin/rc-update ]; then
        rc-update add hostguard boot default sysinit > /dev/null 2>&1  || return 1
        rc-service hostguard start >/dev/null 2>&1
    fi

	return 0
}

run_install()
{   
    url=$1
    rpm --version > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		installRPM ${url}
		if [ $? -eq 0 ]; then
            logme "Intall hss agent success." "info"
			return 0
		fi
	fi

	dpkg --version > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		installDEB ${url}
		if [ $? -eq 0 ]; then
            logme "Intall hss agent success." "info"
			return 0
		fi
	fi

	if [ -f "/etc/gentoo-release" ]; then
		installTAR ${url}
		if [ $? -eq 0 ]; then
            logme "Intall hss agent success." "info"
			return 0
		fi
	fi
    
    return 1
}

install_from_obs()
{
    #download install packets from local region obs
    hostguard_master_url=""
    
    gen_zone_obs_url 
    if [[ -z "$region_obs_url" ]]; then
        logme "The url of package or hss master is NULL." "info"
        return 1
    fi
    
    run_install $region_obs_url
    if [ $? -eq 0 ]; then
        # echo "can not get meta data."
        logme "Download install packets from local region obs and install success." "info"
        return 0
	fi
    
    run_install $global_obs_url
    if [ $? -eq 0 ]; then
        # echo "can not get meta data."
        logme "Download install packets from global region obs and install success." "info"
        return 0
	fi
    
    return 1
    
}

install_from_nginx()
{
    selectRegion
    if [ $? -eq 1 ]; then
        logme "Unknown region $availability_zone_secure." "info"
        return 1
    fi

    if [[ -z "$package_url" || -z "$hostguard_master_url" ]]; then
        logme "The url of package or hss master is NULL." "info"
        return 1
    fi
    
    run_install $package_url
    
    return $?
}

install_hcso()
{
    selectHCSORegion
    if [ $? -eq 1 ]; then
        logme "not HCSO region $availability_zone_secure." "info"
        return 2
    fi

    if [[ -z "$package_url" || -z "$hostguard_master_url" ]]; then
        logme "The url of package or hss master is NULL." "info"
        return 1
    fi
    
    run_install $package_url
    
    return $?
}

is_need_install()
{
    #excute after 30s
    sleep 60
    curl_metadata
    if [ $? -ne 0 ]; then
        # echo "can not get meta data."
        logme "Can not get meta data or there is no hss in label __support_agent_list." "err"
        return 0
    fi
    
    rpm -q hostguard > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        logme "HostGuard is running so skip install" "info"
        return 0
    fi
    
    dpkg -l hostguard > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        logme "HostGuard is running so skip install" "info"
        return 0
    fi
    
    return 1
}

install()
{
    install_hcso
    ret = $?
    if [ $ret -ne 2 ]; then
        return $ret
    fi
    
    install_from_obs
    if [ $? -ne 0 ]; then
        install_from_nginx
        if [ $? -ne 0 ]; then
            return 1
        fi
    fi

	return 0
}

# config the script run when start os
config()
{
    cp -f "$0" /etc/init.d/HSSInstall
    chmod +x /etc/init.d/HSSInstall
    
    if [ -x /sbin/chkconfig ]; then
        chkconfig --add HSSInstall > /dev/null 2>&1
    elif [ -x /usr/sbin/update-rc.d ]; then
        update-rc.d HSSInstall defaults > /dev/null 2>&1
    elif [ -x /bin/systemctl ]; then
        systemctl enable HSSInstall > /dev/null 2>&1
    elif [ -x /sbin/rc-update ]; then
        rc-update add HSSInstall boot default sysinit > /dev/null 2>&1
    else
        echo -e "\033[31m Config failed. \033[0m"
        rm -f /etc/init.d/HSSInstall > /dev/null 2>&1
        exit 1
    fi
    
    ls -al /etc/init.d/HSSInstall > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "\033[31m Config failed. \033[0m"
        exit 1
    fi
    
    if [ -x /sbin/chkconfig ]; then
        chkconfig --list|grep HSSInstall > /dev/null 2>&1
    elif [ -x /usr/sbin/sysv-rc-conf ]; then
        sysv-rc-conf --list|grep HSSInstall  > /dev/null 2>&1
    elif [ -x /bin/systemctl ]; then
        systemctl -al|grep HSSInstall > /dev/null 2>&1
    elif [ -x /sbin/rc-update ]; then
        rc-update show|grep HSSInstall > /dev/null 2>&1
    fi
    
    if [ $? -ne 0 ]; then
        echo -e "\033[31m Config failed. \033[0m"
        rm -f /etc/init.d/HSSInstall > /dev/null 2>&1
        exit 1
    fi
    
    echo -e "\033[32m Config OK. \033[0m"
    exit 0
#    rm -rf "$0" > /dev/null 2>&1
}

rm_tmp_files()
{
    rm -f hostguard_setup_config.dat >/dev/null 2>&1
    rm -f hss_linux* > /dev/null 2>&1
    rm -f hss_arm* > /dev/null 2>&1
    rm -f HostGuardAgent_Linux* > /dev/null 2>&1
    rm -f HostGuardAgent_Gentoo* > /dev/null 2>&1
    rm -f /tmp/hostguard_meta_data.json >/dev/null 2>&1
}

# delete the script
clean()
{
    if [ -x /sbin/chkconfig ]; then
        chkconfig --del HSSInstall >/dev/null 2>&1
    elif [ -x /usr/sbin/update-rc.d ]; then
        update-rc.d -f HSSInstall remove >/dev/null 2>&1
    elif [ -x /bin/systemctl ]; then
        systemctl disable HSSInstall >/dev/null 2>&1
        systemctl daemon-reload >/dev/null 2>&1
    elif [ -x /sbin/rc-update ]; then
        rc-update delete HSSInstall >/dev/null 2>&1
    fi
    
    rm -rf /etc/init.d/HSSInstall>/dev/null 2>&1
    
    export package_url=
    export hostguard_master_url=
    export availability_zone_secure=
    
    rm_tmp_files
    
    return 0
}

start()
{
    is_need_install
    if [ $? -eq 0 ]; then
        clean
        return 0
    fi
    
    try_c=1
    while ((1)); do
        install
        ret=$?
        if [ $ret -eq 0 ]; then
            break;
        else
            if [ $try_c -le 2 ]; then
                sleep 1h
                let try_c++
            else
                try_c=1
                cur=`date "+%H"`
                next=24
                diff_t=`expr $next - $cur`
                sleep ${diff_t}h
            fi
            rm_tmp_files
        fi
        
        num=$(date +%s%N)
        sleep $(($num%1800+$600))
    
    done

    clean

}

##########################################################

if [ ! `id -u` = "0" ]; then
    logme "Not root privileges." "info"
    exit 1
fi

case "$1" in
    start)
        start & > /dev/null 2>&1
    ;;

    config)
        config
    ;;

    *)
        echo "Usage: $0 config"
        exit 1
    ;;

esac
