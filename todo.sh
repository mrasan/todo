#!/bin/bash
# Shell run on Linux/Mac OS X
#@author jianfeng.zheng
#@email jianfeng.zheng@definesys.com
data_file="data.td"
output_file="output.td"
tmp_file="tmp.td"
function help(){
	echo "usage:todo [insert|todo|done|show|find|help]"
	echo "      insert xxxxx 插入待办"
	echo "      insert 20170304 xxxxx 插入待办时间为20170304"
	echo "      insert 0304 xxxxx 插入待办默认年份为当前年"
	echo "      todo 列出当天待办"
	echo "      todo all 列出所有待办"
	echo "      todo 20170304 列出20170304后所有待办"
	echo "      done xxxx 插入一条已完成任务,时间为当天"
	echo "      done line_num 插入一条已完成任务,line_num为待办编号"
	echo "      done line_num 插入一条已完成任务,line_num为待办编号"
	echo "      show 列出当天所有任务"
	echo "      show all 列出所有任务"
	echo "      show 20170304 列出20170304后所有任务"
	echo "      find xxxxx 找出关键字xxxx任务"
	echo "      help 帮助信息"
}
function init(){
	if [ ! -f ${data_file} ];then
		touch $data_file
	fi
}
function rp(){
	printf '%s' '+'
	for (( i=0; i<$2; i++)); do
		printf "%s" $1
	done
}
function get_line_num(){
	line_num=`cat ${data_file} |wc -l`
	line_num=$[line_num+1]
	line_num=`printf %06d ${line_num}`
	echo ${line_num}
}
function print_header(){
	rp '-' 8
	rp '-' 8
	rp '-' 10
	rp '-' 70
	printf '\n'
	printf "|%-10s|%-10s|%-12s|%-56s\n" "编号" "状态" "时间" "事项"
	rp '-' 8
	rp '-' 8
	rp '-' 10
	rp '-' 70
	printf '\n'
}
function show(){
	sort -t '-' -n -k 1 -k 2 -k 3 ${output_file} -o ${output_file}
	print_header
	while read line; do
		f1=`echo $line |cut -d - -f 1`
		f2=`echo $line |cut -d - -f 2`
		f3=`echo $line |cut -d - -f 3`
		f4=`echo $line |cut -d - -f 4`
		#f2=$[f2+0]
		printf "|%-8s|%-8s|%-10s|%-72s\n" ${f2} ${f3} ${f1} ${f4}
	done < ${output_file}
	rp '-' 8
	rp '-' 8
	rp '-' 10
	rp '-' 70
	printf '\n'
}
#print_header
#show
#exit 1
cmd=$1
if [ "${cmd}" = "" ]; then
	help
	exit 0
fi
init
if [ "${cmd}" = "insert" ]; then
	todo_date=`date +%Y%m%d`
	if [ "${#2}" = "8" ]; then
		if [ "${2}" -gt "0" ] 2>/dev/null ;then
			todo_date=$2;
			todo_item=$3;
		else
			todo_item=$2;
		fi
	elif [ "${#2}" = "4" ]; then
		if [ "${2}" -gt "0" ] 2>/dev/null ;then
			todo_date=`date +%Y`
			todo_date="${todo_date}${2}"
			todo_item=$3;
		else
			todo_item=$2;
		fi
	else
		todo_item=$2;
	fi
	if [ "${todo_item}" = "" ]; then
		echo "todo is null"
		exit
	fi
	line_num=`get_line_num`
	echo "${todo_date}-${line_num}-OPEN-${todo_item}" >> $data_file
fi

if [ "${cmd}" = "todo" ]; then
	todo_option=${2}
	todo_date=`date +%Y%m%d`
	if [ "${todo_option}" = "" ]; then
		cat ${data_file}|grep OPEN|grep ${todo_date} >${output_file}
	elif [ "${todo_option}" = "all" ]; then
		cat ${data_file}|grep OPEN >${output_file}
	else
		cat ${data_file}|grep OPEN >${tmp_file}
		rm -rf ${output_file}
		while read line; do
			d1=`echo $line |cut -d - -f 1`
			if [ "${d1}" -ge "${todo_option}" ];then
				echo ${line} >>${output_file}
			fi
		done < ${tmp_file}
	fi
	show
fi

if [ "${cmd}" = "done" ]; then
	done_option=${2}
	if [ "${done_option}" -gt "0" ] 2>/dev/null ;then
		line_num=`printf %06d ${done_option}`
		sed "s/${line_num}-OPEN/${line_num}-CLOSE/g" ${data_file} >${tmp_file}
		cp -fr ${tmp_file} ${data_file}
	else
		todo_date=`date +%Y%m%d`
		line_num=`get_line_num`
		echo "${todo_date}-${line_num}-CLOSE-${done_option}" >> ${data_file}
	fi
fi

if [ "${cmd}" = "show" ]; then
	todo_option=${2}
	todo_date=`date +%Y%m%d`
	if [ "${todo_option}" = "" ]; then
		cat ${data_file}|grep ${todo_date} >${output_file}
	elif [ "${todo_option}" = "all" ]; then
		cat ${data_file} >${output_file}
	else
		cat ${data_file} >${tmp_file}
		echo "" >${output_file}
		while read line; do
			d1=`echo $line |cut -d - -f 1`
			if [ "${d1}" -ge "${todo_option}" ]; then
				echo ${line} >>${output_file}
			fi
		done < ${tmp_file}
	fi
	show
fi
if [ "${cmd}" = "find" ]; then
	todo_option=${2}
	cat ${data_file}|grep ${todo_option} >${output_file}
	show
fi
if [ "${cmd}" = "help" ]; then
	help
fi


