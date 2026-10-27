#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
[[ ${1:-} == --confirmar-mesh-lab && $# == 1 ]] || bloqueado 'uso: cleanup.sh --confirmar-mesh-lab; remova primeiro a Application opcional sem cascata'
crc
command -v python3 >/dev/null || bloqueado 'python3 não está disponível'
# Applications podem declarar source ou sources; consultar ambas antes da limpeza.
apps=$("${OC[@]}" get applications.argoproj.io -A -o json)
printf '%s' "$apps" | python3 -c '
import json,sys
for app in json.load(sys.stdin).get("items",[]):
    spec=app.get("spec",{})
    sources=[spec.get("source",{})]+spec.get("sources",[])
    if any("/mesh-apps-lab" in source.get("repoURL","") for source in sources):
        sys.exit(2)
' || bloqueado 'Application ainda reconcilia o laboratório; conferir source e sources'
"${OC[@]}" -n mesh-lab delete deployments,services,serviceaccounts,networkpolicies -l laboratorio.sre.dev/proprietario=mesh-apps-lab --ignore-not-found
for recurso in peerauthentications.security.istio.io authorizationpolicies.security.istio.io; do
  if "${OC[@]}" api-resources -o name | grep -qx "$recurso"; then
    "${OC[@]}" -n mesh-lab delete "$recurso" -l laboratorio.sre.dev/proprietario=mesh-apps-lab --ignore-not-found
  fi
done
printf 'PASS: objetos próprios removidos; namespace e plataformas preservados\n'
