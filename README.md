# Desafio Técnico: Clube do Valor (Engenharia de Dados)

### Introdução

O projeto tem como foco cumprir com o desafio técnico para a vaga de Analytics Engineering, cujo enunciado principal pedia:

> Você recebeu dois arquivos de uma corretora fictícia. Sua missão é criar um projeto dbt funcional que transforme esses dados brutos em modelos analíticos confiáveis com estrutura de camadas, testes e documentação. O critério principal é simples: o projeto roda limpo com dbt run && dbt test.

Além disso, o desafio exigia o cumprimento de alguns requisitos específicos:

* **Modelagem em 3 camadas**: Staging (limpeza/tipagem), Intermediate (regras de negócio) e Marts (consumo final).
* **Testes de Qualidade**: Implementação de testes genéricos e um teste singular obrigatório para identificar posições negativas de clientes.
* **Funcionalidades Avançadas**: Criação de um modelo incremental e o desenvolvimento de uma macro Jinja reutilizável.
* **Documentação**: Descrição completa de colunas e modelos via `schema.yml`.

##### Vídeo de Apresentação do Projeto

[https://www.youtube.com/watch?v=Ruck0QxwL30](https://www.youtube.com/watch?v=Ruck0QxwL30)

##### Observação:

Sobre a execução do projeto, acho importante ressaltar o seguinte:

* **Erros Intencionais nos Dados**: Conforme alertado no descritivo do teste, os arquivos `seeds` contêm problemas de qualidade inseridos de propósito. **Os testes do dbt vão falhar nestas anomalias.** Isso não é um erro do código, mas sim o comportamento esperado (e exigido) da ferramenta de qualidade de dados. Não realizei a limpeza manual para mascarar esses problemas, provando a eficácia dos testes implementados.

### Soluções Desenvolvidas

Para garantir que o projeto atenda aos requisitos de negócio e técnicos (e facilite a vida do avaliador ao testar o repositório), tomei algumas decisões arquiteturais:

* **Abordagem com DuckDB (Fricção Zero)**: Para não obrigar o avaliador a subir containers Docker com PostgreSQL ou configurar credenciais de cloud (Snowflake/BigQuery), escolhi o **DuckDB**. Ele roda de forma embarcada (serverless) direto no Python, criando o banco de dados em um arquivo local `.duckdb` na raiz do projeto instantaneamente.
* **Macro `calc_net_value**`: Criei uma macro em Jinja que centraliza a regra matemática de transformar compras (BUY) em valores positivos e vendas (SELL) em valores negativos, garantindo DRY (Don't Repeat Yourself).
* **Carga Incremental (`fact_transactions`)**: A tabela fato foi materializada como incremental utilizando a `transaction_date` como chave de controle, simulando um ambiente real onde processamos apenas o delta de novos dados diariamente.

### Tecnologias Utilizadas

* **Python (3.9+)**: Base para o ambiente de execução.
* **dbt-core**: Framework principal de transformação de dados.
* **dbt-duckdb**: Adapter oficial do dbt para comunicar e compilar SQL para o DuckDB.
* **DuckDB**: Motor de banco de dados analítico embutido (OLAP).

---

### Configurações do Ambiente

Abaixo está o passo-a-passo para clonar o projeto, criar o ambiente virtual e configurar a conexão.

**1° Clonar o Repositório**:

```bash
git clone git@github.com:VicourtBitt/data_engineering_challenge_clube_valor.git
cd data_engineering_challenge_clube_valor

```

**2° Criar e Ativar o Ambiente Virtual**:
Isso permite isolarmos as dependências deste teste do restante do seu sistema operacional.

```bash
# Crie o ambiente virtual
python3 -m venv .venv

# Ative o ambiente (Linux/macOS)
source .venv/bin/activate

# Ative o ambiente (Windows)
.\.venv\Scripts\activate 

```

**3° Instalar as Dependências**:

```bash
pip install -r requirements.txt
```

**4° Configurar o Banco de Dados (profiles.yml)**:
Para fazer com que o DBT criasse um arquivo do banco dentro do próprio projeto, eu criei o `profiles.yml` que direcionaesse comportamento.

```yaml
challenge_clube_do_valor:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: challenge.duckdb
      threads: 4
```

---

### Como Executar os Códigos

Com o ambiente ativo, execute os comandos do dbt passando a flag `--profiles-dir .` para que ele leia a configuração do banco local.

Execute na seguinte ordem:

```bash
# Caso esteja na pasta do repositorio (raiz) e não na target real
cd challenge_clube_do_valor/

# 1. Carregar os CSVs brutos para dentro do DuckDB
dbt seed

# 2. Executar as transformações de dados (construir todas as camadas)
dbt run

# 3. Rodar a suíte de testes de qualidade e negócio
dbt test
```

### O que esperar da execução (Validação)

Ao rodar os comandos, você notará os seguintes comportamentos:

* `dbt seed` e `dbt run`: **Passarão com 100% de sucesso**. As tabelas `stg_clients`, `stg_transactions`, `int_transactions`, `dim_clients`, `fact_transactions` e `mart_client_portfolio` serão criadas com sucesso.
* `dbt test`: **Apresentará falhas intencionais**.
* O teste genérico `unique` em `stg_clients` falhará pois os clientes "Ana Souza" (C1) e "Felipe Nunes" (C6) estão duplicados na base.
* O teste genérico `not_null` em `stg_transactions` falhará pois existe uma transação sem `client_id`.
* O teste singular `assert_no_negative_position` **falhará e retornará os clientes que operaram descobertos**, como o cliente C5 que ficou com uma posição líquida de -400 no ativo BBDC4.
