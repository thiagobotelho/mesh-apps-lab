#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
crc
sem_politicas_rede
proxies
[[ $("${OC[@]}" -n mesh-lab get peerauthentication httpbin-strict -o jsonpath='{.spec.mtls.mode}') == STRICT ]] || bloqueado 'STRICT ausente'
[[ $("${OC[@]}" -n mesh-lab get authorizationpolicies -o name) == '' ]] || bloqueado 'AuthorizationPolicy pode mascarar teste mTLS'
[[ $("${OC[@]}" -n mesh-lab get deployment sleep-plain -o jsonpath='{.spec.template.metadata.annotations.sidecar\.istio\.io/inject}') == false ]] || falhar 'cliente plaintext deve excluir injeção'
"${OC[@]}" -n mesh-lab rollout status deployment/sleep-plain --timeout=120s
[[ $("${OC[@]}" -n mesh-lab get pods -l app=sleep-plain -o jsonpath='{.items[*].spec.containers[*].name}') == sleep ]] || falhar 'cliente plaintext possui proxy'
http_esperado 200 sleep GET /get
http_esperado 200 sleep-denied GET /get
sem_http '35 52 56' sleep-plain GET /get
printf 'PASS: tráfego entre proxies aceito e plaintext recusado; confirme mutual_tls nas métricas\n'
