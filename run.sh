#!/bin/sh
test=$1
time=$(date +%s%3N)

docker exec influxdb influx -execute "CREATE DATABASE ${test}_${time}"

sed "s/%%DATASOURCE%%/${test}_${time}/g" datasource_influxdb.json >temp_datasource_influxdb_${test}_${time}.json
uid_influxdb=$(curl -X POST --insecure -H "Authorization: Bearer `cat .grafanatoken`" -H "Content-Type: application/json" -d "@temp_datasource_influxdb_${test}_${time}.json"  http://localhost:3000/api/datasources | jq -r '.datasource.uid')
rm -f temp_datasource_influxdb_${test}_${time}.json

sed "s/%%DATASOURCE%%/${test}_${time}/g" datasource_csv.json >temp_datasource_csv_${test}_${time}.json
uid_csv=$(curl -X POST --insecure -H "Authorization: Bearer `cat .grafanatoken`" -H "Content-Type: application/json" -d "@temp_datasource_csv_${test}_${time}.json"  http://localhost:3000/api/datasources | jq -r '.datasource.uid')
rm -f temp_datasource_csv_${test}_${time}.json

sed "s/%%DASHBOARD%%/${test}_${time}/g" dashboard.json >temp_dashboard_${test}_${time}.json
sed -i "s/%%UID_INFLUXDB%%/${uid_influxdb}/g" temp_dashboard_${test}_${time}.json
sed -i "s/%%UID_CSV%%/${uid_csv}/g" temp_dashboard_${test}_${time}.json
sed -i "s/%%NAME_INFLUXDB%%/InfluxDB-${test}_${time}/g" temp_dashboard_${test}_${time}.json

path=$(curl -X POST --insecure -H "Authorization: Bearer `cat .grafanatoken`" -H "Content-Type: application/json" -d "@temp_dashboard_${test}_${time}.json" http://localhost:3000/api/dashboards/db | jq -r '.url')
echo "dashboard url is http://localhost:3000$path"
rm -f temp_dashboard_${test}_${time}.json

docker exec -e TEST_NAME=${test} -e START_TIME=${time} jmeter jmeter.sh -n -t /opt/jmx/${test}.jmx -e -l /opt/report/${test}_${time}/output.csv -o /opt/report/${test}_${time}

numtrans=$(docker exec influxdb influx -execute "select sum(\"count\") from ${test}_${time}..jmeter where \"application\"='example' and \"transaction\"='all'" | sed -n 4p | awk '{print $2}')
echo "transactions total is ${numtrans}"

errorrate=$(docker exec influxdb influx -execute "select sum(\"error\") / sum(\"all\") from (select sum(\"count\") AS \"all\" from ${test}_${time}..jmeter where \"transaction\" = 'all'), (select sum(\"countError\") as \"error\" from ${test}_${time}..jmeter where \"transaction\" = 'all')" | sed -n 4p | awk '{print $2}')
echo "error rate is ${errorrate}%"

pct99=$(docker exec influxdb influx -execute "select last(\"pct99.0\") from ${test}_${time}..jmeter where \"application\"='example' and \"statut\"='ok' and \"transaction\"='HTTP Request'" | sed -n 4p | awk '{print $2}')
echo "99th percentile is ${pct99}"

mean=$(docker exec influxdb influx -execute "select last(\"avg\") from ${test}_${time}..jmeter where \"application\"='example' and \"statut\"='ok' and \"transaction\"='HTTP Request'" | sed -n 4p | awk '{print $2}')
echo "mean duration is ${mean}"

curl -X GET --insecure -H "Authorization: Bearer `cat .grafanatoken`" "http://localhost:3000/render/d-solo/${test}_${time}/${test}-${time}?orgId=1&panelId=39&width=2000&height=500" >scatter_${test}_${time}.png

echo "scatterplot render is scatter_${test}_${time}.png"
