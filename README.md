# mesh-apps-lab

Workloads oficiais httpbin e sleep, segundo cliente sleep-denied e seis cenários independentes de rede, mTLS e autorização.

Exemplos e infraestrutura declarativos para estudar rede, segurança e observabilidade no OpenShift Local.

## Início rápido

1. Ler [instalação](docs/INSTALACAO-CRC.md) e [requisitos](docs/REQUISITOS.md).
2. Conferir contexto e recursos com `bash scripts/preflight.sh` (somente leitura).
3. Validar fontes com `bash scripts/validate.sh` (kubectl, Python/PyYAML/jsonschema, Kubeconform 0.7.0 e ShellCheck).
4. Cadastrar as Applications e sincronizar Operator, plano de controle e cenários na sequência descrita no guia.

## Cenários

| Caminho | Controle |
|---|---|
| scenarios/01-baseline | dois clientes HTTP 200; sem Mesh/políticas |
| scenarios/02-networkpolicy | sleep permitido; sleep-denied bloqueado por OVN |
| scenarios/03-mesh | proxies e conectividade, sem políticas de segurança |
| scenarios/04-mtls-strict | destino STRICT e cliente plaintext negativo |
| scenarios/05-authorization | somente SA sleep, GET /get; negativos HTTP 403 |
| scenarios/06-defense-in-depth | NetworkPolicy + STRICT + autorização L7 |

Apenas um cenário por vez, no mesmo Application e com prune revisado. `vendor/` guarda os originais; `base/` aplica adaptações explícitas de segurança, capacidade e imagens fixas. Clientes não recebem RBAC nem SCC privilegiada. [Procedência](docs/PROCEDENCIA.md).

## Guias

- [Arquitetura e Mermaid](docs/ARQUITETURA.md)
- [Primeiro teste manual](docs/01-primeiro-teste.md)
- [Exercícios e resultados esperados](docs/EXERCICIOS.md)
- [NetworkPolicy e Service Mesh](docs/NETWORKPOLICY-VS-SERVICE-MESH.md)
- [Métricas, PromQL e Grafana](docs/GRAFANA.md)
- [Diagnóstico](docs/TROUBLESHOOTING.md)
- [Rollback e limpeza](docs/ROLLBACK-E-CLEANUP.md)
- [Plano de testes](docs/PLANO-DE-TESTES.md)
- [Operação](docs/OPERACAO.md)
- [Evolução de PKI](docs/ROADMAP-VAULT.md)

Documentação operacional em Markdown/português. YAML, shell, JSON e testes mantêm extensões funcionais. Nenhuma credencial deve ser inserida nos exemplos, relatórios ou commits. Licença Apache 2.0, com avisos originais preservados.

