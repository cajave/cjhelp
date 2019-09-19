#!/usr/bin/env bash

set -e


workspacepath=/media/xp/3bdfbcd7-1703-41ed-87e1-c00c764037a8/workspace
ehrlogpath=$workspacepath/xplorer_logs
ehplogpath=$workspacepath/ehp_data_20190909/ehp_data_v3/ehpv3log
logfile=$ehrlogpath/map_manager.INFO
datetime=0
logbackpath=$1

function init_backup_dir(){
	if test ! -z $logbackpath
	then
		if test -d $logbackpath
		then
			mv $logbackpath bak_$logbackpath
		fi
		mkdir $logbackpath -p
		cd $logbackpath	
		logbackpath=`pwd`
	else
		logbackpath=.
	fi
}

function do_ehrlog_backup(){
	if test -e $logfile -o -L $logfile
	then
		logsdir=`stat -L $logfile | grep -i Modify | awk '{print $2 $3}' | cut -d "." -f1 | sed -e 's/-//g' -e 's/://g'`
		if test -d $logsdir
		then
			rm -rf $logsdir
		fi

		mkdir $logsdir
		chmod 777 $logsdir -R
		cp $logfile $logsdir
		datetime=$logsdir
		logbackpath=$logbackpath/$logsdir
	fi
}

function do_ehplog_backup(){
	if test ! -d $ehplogpath
	then
		echo "ehpv3log dir doesn't exist！"
		exit 1
	else
		minus=2000000000
		path=""
		isfind=0

		for i in `ls $ehplogpath`
		do
			logsdir=`stat $ehplogpath/$i | grep -i Modify | awk '{print $2 $3}' | cut -d "." -f1 | sed -e 's/-//g' -e 's/://g'`
			if test $logsdir = $datetime
			then
				isfind=1
				cp $ehplogpath/$i $logbackpath -R
				break
			fi

			tempdir=`echo $i | sed -e 's/-//g;s/h//g;s/m//g;s/s//g'`
			if test $tempdir = $datetime
			then
				isfind=1
				cp $ehplogpath/$i $logbackpath -R
				break
			fi

			tempminus=$[$logsdir-$datetime]
			if test $tempminus -lt 0
			then
				tempminus=$[0 - $tempminus]
			fi
			if test $tempminus -lt $minus
			then
				minus=$tempminus
				path=$ehplogpath/$i
			fi
		done

		if test $isfind -ne 1
		then
			cp $path $logbackpath -R
		fi
	fi
}

function main(){
	init_backup_dir
	do_ehrlog_backup
	do_ehplog_backup
}


main

