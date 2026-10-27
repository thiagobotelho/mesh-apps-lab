#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
crc
for n in httpbin sleep sleep-denied; do
  "${OC[@]}" -n mesh-lab rollout status "deployment/$n" --timeout=120s
done
sem_politicas_rede
for recurso in peerauthentications.security.istio.io authorizationpolicies.security.istio.io; do
  if "${OC[@]}" api-resources -o name | grep -qx "$recurso"; then
    [[ $("${OC[@]}" -n mesh-lab get "$recurso" -o name) == '' ]] || bloqueado 'retire as políticas do Mesh no baseline'
  fi
done
for n in sleep sleep-denied; do http_esperado 200 "$n" GET /get; done
