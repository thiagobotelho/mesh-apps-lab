# Políticas por camada


Veja examples/comentados/README.md. NetworkPolicy seleciona pods e portas; PeerAuthentication exige mTLS; AuthorizationPolicy limita identidade/operação; Role/RoleBinding controlam a API Kubernetes. Teste cada camada separadamente antes de combiná-las. Labels de pods e ServiceAccounts têm papéis diferentes.

## Confirmar o resultado

Valide o cliente permitido imediatamente antes do caso negativo. Timeout de transporte, rejeição mTLS e HTTP 403 são resultados diferentes: correlacione com OVN e logs do Envoy. O nome sleep-denied não concede nem nega acesso; quem decide são seletores, ServiceAccount e políticas do cenário aplicado.
