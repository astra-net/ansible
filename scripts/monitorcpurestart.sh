#! /bin/bash
# monitor and increase tcount when threshold is hit. After the counter limit is hit
# harmony process is restarted

#threshold counter
tcount=0

#threshold counter limit
tclimit=5 #15

#interval in seconds
interval=60 #60

#threshold
threshold=90 #90

# enter your discord webhook here
discord_webhook=""

discord_notify(){
	public_ip=$(curl ifconfig.me)
	message="$public_ip: $@"
	## format to parse to curl
	msg_content=\"$message\"

	## discord webhook
	curl -H "Content-Type: application/json" -X POST -d "{\"content\": $msg_content}" $discord_webhook
}

while true
do
	CPU_USAGE=$(top -b -n2 -p 1 | fgrep "Cpu(s)" | tail -1 | awk -F'id,' -v prefix="$prefix" '{ split($1, vs, ","); v=vs[length(vs)]; 	sub("%", "", v); printf "%s%.1f", prefix, 100 - v }')
	
	if  [ $(echo "$CPU_USAGE>$threshold"|bc) -gt 0 ]; then
		tcount=$((tcount + 1))
	else
		tcount=0
	fi
	
	echo $CPU_USAGE $threshold $tcount
	
	if [ $tcount -eq $tclimit ]; then 
		echo "restarting harmony" 
		sudo service harmony restart
		discord_notify "Harmony Process has been restarted due to $(( tclimit * interval )) sec above ${threshold}% cpu"
	fi	
	sleep $interval
done
