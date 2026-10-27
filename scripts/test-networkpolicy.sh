#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
crc
[[ $("${OC[@]}" -n mesh-lab get networkpolicies -o jsonpath='{.items[*].metadata.name}') == httpbin-somente-sleep ]] || bloqueado 'cenário 02 exige somente a política httpbin-somente-sleep'
http_esperado 200 sleep GET /get
# Código 6 (DNS) não é aceito como bloqueio pela rede.
sem_http '7 28' sleep-denied GET /get
# Qualquer HTTP do serviço Kubernetes comprova resolução e conectividade básica.
"${OC[@]}" -n mesh-lab exec deployment/sleep-denied -c sleep -- curl --noproxy '*' -k -sS --max-time 5 -o /dev/null https://kubernetes.default.svc
printf 'PASS: DNS e serviço Kubernetes acessíveis ao cliente bloqueado\n'
