#!/bin/bash

cpu_t_max=-1
cpu_s_max=-1
cpu_u_max=-1
cpu_t=0
mem_max=-1
format=0

# Abort if empty argument
if [ -z "$1" ]; then
        echo -e "\nusage #1:\ntop_analyzer.sh <end_line>\n"
		echo -e "usage #2:\ntop_analyzer.sh <start_line> <end_line>\n"
	exit 0
fi

# Abort if no top.log file
if [ ! -f top.log ]; then
		echo -e "\nERROR - file top.log missing !\n"
	exit 0
fi

# Set value for first interval [start - end]
if [ -z "$2" ]; then
        start=1
		end=$1	
else 
		start=$1
		end=$2
fi

#reset usage.log
echo >usage.log
echo 

#check the top.log format
if [ "$(cat top.log | grep CPU: | sed -n 1,1p | cut -d: -f1)" == "CPU" ]; then
	format=1
	else
	format=2
fi

# Collect CPU & RAM data to usage.log every 1 second during $1 seconds
for (( i=start; i<=end; i++ ))
do
        #format 1
		if [ $format -eq 1 ]; then
			cpu_u=$(cat top.log | grep CPU: | sed -n $i,$i'p' | cut -d% -f1 | cut -d: -f2)
			cpu_s=$(cat top.log | grep CPU: | sed -n $i,$i'p' | cut -d% -f2 | cut -dr -f2)			
			mem=$(cat top.log | grep Mem: | sed -n $i,$i'p' | cut -dK -f1 | cut -d: -f2)
		else
			#format 2
			cpu_u=$(cat top.log | grep Cpu | sed -n $i,$i'p' | cut -d% -f1 | cut -d: -f2)
			cpu_s=$(cat top.log | grep Cpu | sed -n $i,$i'p' | cut -d% -f2 | cut -d, -f2)
			mem=$(cat top.log | grep Mem: | sed -n $i,$i'p' | cut -d, -f2 | cut -dk -f1)
		fi
				
		#top=$(cat top.log | grep top | sed -n $i,$i'p' | cut -d% -f2)
		
		if [ -z "$cpu_u" ]
		then 
		break
		fi
		
		#int=${float/.*}
		#cpu_s=$((cpu_s-$top))
		cpu_u=${cpu_u/.*}
		cpu_s=${cpu_s/.*}
		cpu_t=$((cpu_u+$cpu_s))				
		cpu_s=$((cpu_s))
		mem=$((mem))
		
		printf "%4d. CPU_user:%3d%%\tCPU_sys:%3d%%\tMem:%7dK\n" $i $cpu_u $cpu_s $mem>>usage.log
		printf "%4d. CPU_user:%3d%%\tCPU_sys:%3d%%\tMem:%7dK\n" $i $cpu_u $cpu_s $mem
		if [ $cpu_t -gt $cpu_t_max ]
		then
		cpu_t_max=$cpu_t
		cpu_s_max=$cpu_s
		cpu_u_max=$cpu_u
		fi

		if [ $mem -gt $mem_max ]
		then
		mem_max=$mem
		fi	
			
done

# No max values
if [ $cpu_t_max -lt 0 ]
	then 
	exit
fi
		
echo>>usage.log
echo
printf "max_CPU_user:%d%%  max_CPU_sys:%d%%  max_Mem:%dK\n" $cpu_u_max $cpu_s_max $mem_max>>usage.log
printf "max_CPU_user:%d%%  max_CPU_sys:%d%%  max_Mem:%dK\n" $cpu_u_max $cpu_s_max $mem_max
echo>>usage.log
echo
