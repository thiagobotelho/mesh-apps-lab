#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
crc
for n in httpbin sleep sleep-denied; do
  for tipo in deployment service serviceaccount; do
    valor=$("${OC[@]}" -n mesh-lab get "$tipo/$n" --ignore-not-found -o jsonpath='{.metadata.name}{" "}{.metadata.labels.laboratorio\.sre\.dev/proprietario}')
    [[ -z "$valor" || "$valor" == "$n mesh-apps-lab" ]] || bloqueado "objeto preexistente sem propriedade do laboratório: $tipo/$n; revisar adoção manual"
  done
done
printf 'PASS: sem colisões de propriedade nos objetos principais\n'
