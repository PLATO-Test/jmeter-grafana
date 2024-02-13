#!/bin/sh

#can create token only once
token=$(curl -X POST -H "Content-Type: application/json" -d '{"name":"apikeyadmin", "role": "Admin"}' http://admin:admin@localhost:3000/api/auth/keys |jq -r '.key')

echo $token>>./.grafanatoken
