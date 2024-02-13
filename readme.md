# Introduction

Welcome to the jmeter repository! 
This repository uses a docker compose file to orchestrate the starting of `influxdb`, `grafana`, `grafana-renderer` and `jmeter` containers.  

## Start the stack

```sh
docker compose up -d --wait --pull always
```

## Run a test

The .jmx file must be placed in the [jmx subfolder](/jmx)
For the dashboard to work, each Thread Group in the test must have the same `InfluxDB Listener` and `Simple Data Writer` as the [example.jmx](/jmx/example.jmx)
The [jmeter.sh script](/jmeter.sh) takes a single parameter, the jmx filename without the `.jmx` extension.
For example:

```sh
./run.sh example
```

this project copied dashboard ID 5496 and made changes to it
