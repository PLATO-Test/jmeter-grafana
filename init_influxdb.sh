#!/bin/sh
docker exec influxdb influx -execute "CREATE USER admin WITH PASSWORD 'password' WITH ALL PRIVILEGES"