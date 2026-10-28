# Exercitar PKI Vault no mesh

Pré-requisito: [integração Vault/Issuer/istio-csr](https://github.com/thiagobotelho/cert-manager-gitops/blob/main/docs/INTEGRACAO-MESH.md), Istio mesh-vault saudável e tag vault-stable reconciliada. O cenário usa um namespace diferente de mesh-lab e não migra a CA do mesh original.

```bash
oc apply -k scenarios/07-vault-pki
oc -n mesh-vault-lab rollout status deployment/httpbin --timeout=180s
oc -n mesh-vault-lab rollout status deployment/sleep --timeout=180s
```

Namespace istio.io/rev=vault-stable seleciona injeção. istio-discovery=mesh-vault seleciona descoberta pelo novo plano de controle. sleep-denied sobrescreve a injeção com false para o caso plaintext. As labels version=v1 permitem agrupar workloads no Kiali.

O cenário configura STRICT, AuthorizationPolicy que aceita somente sleep/GET /get e isolamento de ingress. A NetworkPolicy permite chegada à porta HTTP do destino no namespace para que a diferença entre certificado ausente e autorização HTTP possa ser observada. Ela não concede autorização HTTP.

```bash
oc -n mesh-vault-lab exec deployment/sleep -c sleep -- \
  curl --noproxy '*' --max-time 6 -sS -o /dev/null -w 'HTTP %{http_code}\n' http://httpbin:8000/get
oc -n mesh-vault-lab exec deployment/sleep -c sleep -- \
  curl --noproxy '*' --max-time 6 -sS -X POST -o /dev/null -w 'HTTP %{http_code}\n' http://httpbin:8000/post
oc -n mesh-vault-lab exec deployment/sleep-denied -c sleep -- \
  curl --noproxy '*' --max-time 6 -sS -o /dev/null -w 'HTTP %{http_code}\n' http://httpbin:8000/get
```

Critérios esperados: GET permitido retorna 200; POST retorna 403; cliente plaintext falha antes de obter resposta HTTP. Confirme o motivo nos logs do proxy. Execute scripts/verify-certificates.py no cert-manager-gitops para verificar a cadeia Vault e SAN SPIFFE: HTTP 200 sozinho não identifica a CA.

No Kiali, selecione mesh-vault-lab; o perfil opcional de descoberta deve estar ativo. No Grafana, filtre métricas/logs pelo namespace. O monitor de proxies é mantido pelo perfil optional/vault-lab de service-mesh-gitops. Nos logs do Vault, autenticação e assinatura aparecem com dados sensíveis protegidos por HMAC.

Para encerrar o exercício, remova somente os objetos desse cenário após revisar o namespace. Não exclua Vault, CA ou Operator enquanto houver consumidores. Evidências e resultados pessoais não pertencem a este guia.
