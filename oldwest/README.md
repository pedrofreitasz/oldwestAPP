# oldwest — app Flutter

Aplicativo Flutter em português para consultar o cardápio da Lanchonete API, filtrar e pesquisar produtos, montar um carrinho e enviar pedidos. O identificador do projeto/package Flutter é `oldwest`; o nome visual do cardápio continua como Lanche no Fogo.

## Requisitos

- Flutter 3.22 ou superior (Dart 3.3+).
- A API do repositório `Old_West_API-main` em execução e acessível pelo dispositivo.

Este pacote contém a camada Flutter (`lib/`, testes e dependências). Como os wrappers nativos variam conforme o SDK instalado, gere Android e iOS uma vez com o script incluído:

```bash
chmod +x scripts/bootstrap_platforms.sh
./scripts/bootstrap_platforms.sh
flutter pub get
```

O script cria as pastas nativas Android/iOS sem substituir os arquivos Dart e habilita HTTP **somente no debug** para testes locais. Para produção, use HTTPS.

## Executar

No emulador Android:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

`10.0.2.2` é o endereço especial do emulador Android para acessar o `localhost` do computador. Para um aparelho físico, substitua pelo IP local da máquina que está executando a API, por exemplo `http://192.168.1.20:8080`. A API precisa estar na mesma rede e a porta 8080 liberada. No simulador iOS, normalmente use `http://127.0.0.1:8080`.

O app usa `http://10.0.2.2:8080` como padrão. A URL também pode ser alterada em tempo de compilação, sem editar o código:

```bash
flutter run --dart-define=API_BASE_URL=http://SEU_HOST:8080
```

No Flutter Web, o padrão e `http://localhost:8080`, pois `10.0.2.2` so funciona no emulador Android. Se a API estiver em outra maquina, informe o IP acessivel pelo navegador com `--dart-define=API_BASE_URL=http://IP_DA_API:8080`. A API tambem precisa permitir, via CORS, a origem onde o app Web esta sendo servido.

## Fluxo implementado

- `GET /categories` e `GET /products?available=true` para exibir o cardápio.
- Busca por nome/descrição e filtro por categoria.
- Carrinho em memória com alteração de quantidades e subtotal calculado em centavos.
- Checkout de retirada ou entrega, nome, telefone opcional, endereço quando há entrega, observações e pagamento (Pix, dinheiro, cartão de crédito ou débito).
- `POST /orders` com itens e confirmação exibindo o identificador e o total retornado pelo servidor.

## Limitações conhecidas da API original

- O backend exige endereço para entrega, mas não aplica uma taxa automaticamente; este app não inventa uma taxa e exibe o total calculado pela API.
- A rota `POST /orders` grava o pedido com `user_id = null`. Assim, `GET /orders` não consegue listar esses pedidos para uma conta cliente. O app não apresenta um histórico de pedidos fictício.
- A API identifica-se como uma base acadêmica; o README dela recomenda reforçar autenticação e segurança antes de uso em produção.

## Estrutura

```text
lib/
├── main.dart                  # inicialização, tema e dependências
├── app_theme.dart             # paleta e formatação BRL
├── models/                    # produto e categoria
├── screens/                   # cardápio, carrinho e checkout
├── services/api_client.dart   # cliente HTTP e erros da API
├── state/cart_controller.dart # estado e operações do carrinho
└── widgets/product_card.dart  # cartão de produto reutilizável
```

Os testes unitários do carrinho ficam em `test/cart_controller_test.dart` e podem ser executados com `flutter test` após instalar as dependências.
