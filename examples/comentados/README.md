# Aprender com manifests comentados

Estes arquivos são exemplos didáticos. Não há Kustomization nem Application apontando para esta pasta. Os três primeiros preservam a configuração dos componentes correspondentes em mesh-apps-lab; o quarto demonstra RBAC com um grupo sintético. Nenhum exemplo instala workloads, injeta proxies ou configura autenticação automaticamente.

| Arquivo | Pergunta que responde | Camada |
| --- | --- | --- |
| [01-networkpolicy.yaml](01-networkpolicy.yaml) | Quais pods podem chegar à porta do destino? | Rede L3/L4 |
| [02-mtls.yaml](02-mtls.yaml) | A conexão precisa ter mTLS? | Transporte e autenticação entre workloads |
| [03-authorizationpolicy.yaml](03-authorizationpolicy.yaml) | Qual identidade pode executar qual operação HTTP? | Autorização L7 |
| [04-rbac-leitura.yaml](04-rbac-leitura.yaml) | Quem pode consultar pods na API Kubernetes? | RBAC da plataforma |

## Como estudar

Leia primeiro o manifesto comentado e compare seus selectors com labels e ServiceAccounts dos workloads. Para testar os três primeiros, use os cenários independentes de mesh-apps-lab e siga docs/APLICACAO-MANUAL.md. Não aplique todos ao mesmo tempo para tentar isolar suas camadas.

| Cenário | Positivo esperado | Negativo esperado |
| --- | --- | --- |
| NetworkPolicy isolada | sleep alcança httpbin em TCP/8080 | sleep-denied sofre bloqueio de transporte |
| mTLS isolado | cliente com proxy comunica por mTLS | cliente plaintext não estabelece comunicação com destino STRICT |
| AuthorizationPolicy, com mTLS | SA sleep executa GET /get | outra SA, POST /get ou GET em caminho não permitido recebe 403 se a requisição chegar ao proxy |
| RBAC | grupo leitores-exemplo pode get pods em mesh-lab | grupo não recebe permissão de delete pods por esta Role |

O resultado RBAC efetivo depende da soma de todos os vínculos existentes. Um teste negativo de autorização deve considerar outras policies e papéis. As respostas dependem também da aplicação e da rede; registrar falhas observadas sem presumir sua causa.

Antes de qualquer aplicação real, renderize o cenário, confira o contexto e faça dry-run no servidor. As CRDs Istio precisam existir. Para reverter, remova apenas os recursos que tiver aplicado; não exclua namespaces nem use cleanup genérico. Os guias dos cenários descrevem as transições entre fases.

## Padrão recomendado para os repositórios

Cada guia deve apresentar objetivo, arquitetura, pré-requisitos, exemplo mínimo comentado, campos ajustáveis, efeito de segurança, teste positivo, teste negativo, resultado esperado e reversão. Os comentários explicam escolhas e comportamento, sem incluir valores secretos ou relatos de execução pessoal.

Nos manifests de instalação, comentar selectors, portas, identidades, RBAC, TLS, armazenamento, limites, política de atualização, sync waves e decisões que possam causar impacto. Manter uma fonte principal e validar automaticamente que a versão comentada não diverge dela.

## Referências

- [NetworkPolicy Kubernetes](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [PeerAuthentication Istio](https://istio.io/latest/docs/reference/config/security/peer_authentication/)
- [AuthorizationPolicy Istio](https://istio.io/latest/docs/reference/config/security/authorization-policy/)
- [RBAC Kubernetes](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
