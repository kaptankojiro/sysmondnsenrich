#!/bin/bash
figlet -c -w 100 Sysmon DNS Threat Hunting
echo ""
echo "This scripts requires --> whois,freq.py,Alexa top1-m.csv,figlet,libreoffice,jq"
echo ""
echo "Downloading Alexa Top 1 Million Sites"
echo ""
wget http://s3.amazonaws.com/alexa-static/top-1m.csv.zip
unzip top-1m.csv.zip

rm result.csv
echo DomainName,EntropyResult[1],EntropyResult[2],RegistrationDate,UpdatedDate,AlexaWordCount,IP,Region,City,AlienVault,Talos,ThreatCrowd > result.csv
cat dnsQueries.csv | sort | uniq | grep -v "_" | grep "\b$word\." | grep -v "," > sysmonDNSlist.txt
echo "Query process is started."

input="sysmonDNSlist.txt"
while IFS= read -r line
do
echo Checking ... $line ... OK
output=($(python3 freq.py -m $line freqtable2018.freq))
output2=($(whois $line | grep 'Creation Date' | awk '{print $3}' | grep -v + ))
output3=($(whois $line | grep 'Updated Date' | awk '{print $3}' | grep -v + ))
output4=($(cat top-1m.csv | grep $line | wc -l ))
output5=($(curl -s http://ip-api.com/json/$line| jq '.query' | tr -d '"' ))
output6=($(curl -s http://ip-api.com/json/$line | jq '.region' | tr -d '"' ))
output7=($(curl -s http://ip-api.com/json/$line| jq '.city' | tr -d '"' ))
output8=($(echo https://otx.alienvault.com/indicator/domain/$line ))
output9=($(echo https://talosintelligence.com/reputation_center/lookup?search=$line ))
output10=($(echo https://www.threatcrowd.org/domain.php?domain=$line ))


echo $line,"${output[0]}""${output[1]}","$output2[0]","${output3[0]}","${output4[0]},${output5[0]},${output6[0]},${output7[0]},${output8[0]},${output9[0]},${output10[0]}" |  tr -d ')' | tr -d '(' >> result.csv
done < "$input"
libreoffice result.csv
