#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
crc
proxies
[[ $("${OC[@]}" -n mesh-lab get peerauthentication httpbin-strict -o jsonpath='{.spec.mtls.mode}') == STRICT ]] || bloqueado 'STRICT ausente'
[[ $("${OC[@]}" -n mesh-lab get authorizationpolicy httpbin-get-sleep -o jsonpath='{.spec.action}') == ALLOW ]] || bloqueado 'política L7 ausente'
http_esperado 200 sleep GET /get
sem_http '7 28' sleep-denied GET /get
http_esperado 403 sleep POST /post
printf 'PASS: bloqueio L3/L4 para sleep-denied e L7 para POST de sleep\n'
