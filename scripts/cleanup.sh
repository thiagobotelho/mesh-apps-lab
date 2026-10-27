#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
[[ ${1:-} == --confirmar-mesh-lab && $# == 1 ]] || bloqueado 'uso: cleanup.sh --confirmar-mesh-lab; remova primeiro a Application opcional sem cascata'
crc
apps=$("${OC[@]}" get applications.argoproj.io -A -o jsonpath='{.items[*].spec.source.repoURL}')
[[ "$apps" != *'/mesh-apps-lab'* ]] || bloqueado 'Application ainda reconcilia o laboratório'
"${OC[@]}" -n mesh-lab delete deployments,services,serviceaccounts,networkpolicies -l laboratorio.sre.dev/proprietario=mesh-apps-lab --ignore-not-found
for recurso in peerauthentications.security.istio.io authorizationpolicies.security.istio.io; do
  if "${OC[@]}" api-resources -o name | grep -qx "$recurso"; then
    "${OC[@]}" -n mesh-lab delete "$recurso" -l laboratorio.sre.dev/proprietario=mesh-apps-lab --ignore-not-found
  fi
done
printf 'PASS: objetos próprios removidos; namespace e plataformas preservados\n'
