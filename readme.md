# Introduction

Welcome to the jmeter-grafana repository! 
This repository uses a docker compose file to orchestrate the starting of `influxdb`, `grafana`, `grafana-renderer` and `jmeter` containers.

## Pre-requisites

* x86 architecture (YMMV on a M1 macbook)
* bash shell (windows users should use WSL to run the instructions below from a `bash` prompt)
* docker and jq installed

## Run the example test

```sh
#build a jmeter image with the required configuration
docker build . -f ./Dockerfile.jmeter -t jmeter:local
#start the stack
docker compose up -d --wait
#create the admin user within influxdb
./init_influxdb.sh
#create an API token within grafana
./init_grafana.sh
#run jmeter with the example jmx 
./run.sh example
```
the standard output from the `run.sh` command will print a URL.
navigate to this URL in a browser and enjoy the dashboard!

## Run your own test

* Place your .jmx file in the [jmx subfolder](/jmx)
* For the dashboard to work, each Thread Group in the test must have the same `InfluxDB Listener` and `Simple Data Writer` as the [example.jmx](/jmx/example.jmx)
* The [run.sh script](/run.sh) takes a single parameter, the jmx filename without the `.jmx` extension.
For example, the following works if you placed mytest.jmx within the jmx folder:

```sh
./run.sh mytest
```

## Stop the stack

```sh
docker-compose down
```
The containers can be stopped when not in use. The influxdb and grafana state is maintained in the volume mounts [storage-influx](/storage-influx/) and [storage-grafana](/storage-grafana/), so that test results will not be lost when the stack is stopped.  
To restart the stack another day and run another test, the init steps are skipped:
```sh
docker compose up -d --wait
./run.sh example
```
