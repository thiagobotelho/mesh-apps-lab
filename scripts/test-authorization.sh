#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
crc
sem_politicas_rede
proxies
http_esperado 200 sleep GET /get
http_esperado 403 sleep-denied GET /get
http_esperado 403 sleep POST /post
http_esperado 403 sleep GET /headers
