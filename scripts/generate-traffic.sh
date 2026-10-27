#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
DURACAO=${1:-30}
RPS=${2:-1}
[[ "$DURACAO" =~ ^[0-9]+$ && "$RPS" =~ ^[0-9]+$ ]] || falhar 'uso: generate-traffic.sh [segundos 1..120] [rps 1..5]'
(( DURACAO >= 1 && DURACAO <= 120 && RPS >= 1 && RPS <= 5 )) || falhar 'limites: 120 segundos e 5 RPS'
crc
# Cada segundo tem no máximo RPS solicitações. Timeout limita cada requisição.
FIM=$((SECONDS + DURACAO))
while (( SECONDS < FIM )); do
  for ((i=0; i<RPS && SECONDS<FIM; i++)); do
    chamar sleep GET /get
    [[ "$RC" == 0 && "$HTTP" == 200 ]] || falhar "tráfego: HTTP $HTTP, curl $RC"
  done
  sleep 1
done
printf 'PASS: geração finita concluída\n'
