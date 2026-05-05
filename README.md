# UsageLedger

UsageLedger は、架空SaaSのAPI利用量を日別に記録し、月次請求・請求明細作成・不整合データ検知を行う業務システムポートフォリオです。

## 目的

このプロジェクトでは、単なるCRUDではなく、業務システムで発生しやすい以下の設計・処理を扱います。

- 契約期間を考慮した利用量集計
- 無料枠を考慮した請求金額計算
- 月次請求データの二重作成防止
- 契約期間外利用などの不整合データ検知
- DB制約とアプリケーションロジックの責務分離
- Java / Spring Boot によるAPI化
- Flyway によるDB変更履歴管理

## 注意

このアプリは学習・ポートフォリオ目的で作成した架空システムです。実在の企業・業務・案件・データとは関係ありません。

テーブル設計、料金体系、サービス名、顧客名、seedデータ、SQLはすべて独自に作成しています。

## 採用技術

- Java 17
- Spring Boot 3.5.14
- Maven
- PostgreSQL 17
- Flyway
- Docker / Docker Compose
- SQL
- Mermaid

## ディレクトリ構成

```text
usage-ledger/
  README.md
  docker-compose.yml
  docs/
    requirements.md
    er-diagram.md
    table-responsibility.md
    design-notes.md
  db/
    01_schema.sql
    02_seed_master.sql
    03_seed_transactions.sql
    04_billing_queries.sql
    05_integrity_checks.sql
  app/
    pom.xml
    mvnw
    mvnw.cmd
    src/
      main/
        java/
          com/example/usageledger/
            UsageLedgerApplication.java
            controller/
              HealthController.java
              IntegrityCheckController.java
            service/
              IntegrityCheckService.java
            repository/
              IntegrityCheckRepository.java
            dto/
              OutOfContractUsageResponse.java
        resources/
          application.properties
          db/
            migration/
              V1__flyway_baseline.sql
              V2__create_tables.sql
              V3__insert_master_data.sql
              V4__insert_sample_transactions.sql
      test/
        java/
          com/example/usageledger/
            UsageLedgerApplicationTests.java
```

## DB起動

```bash
docker compose up -d
```

## Spring Boot アプリの起動

```bash
cd app
./mvnw spring-boot:run
```

Windows PowerShell の場合:

```powershell
cd app
.\mvnw.cmd spring-boot:run
```

このプロジェクトでは、ローカル環境で8080番ポートが使用中のケースを考慮し、Spring Bootアプリは8081番ポートで起動するように設定しています。

ヘルスチェック確認:

```powershell
curl.exe http://localhost:8081/health
```

期待結果:

```json
{"status":"ok"}
```

## DB接続

```bash
docker compose exec db psql -U app_user -d usage_ledger
```

## DBを初期化し直す場合

```bash
docker compose down -v
docker compose up -d
```

`docker compose down -v` はDBボリュームを削除します。

このプロジェクトでは、DBスキーマ作成とseed投入をFlyway migrationで管理しているため、DBを初期化し直した後は Spring Boot アプリケーションを起動することで migration が実行されます。

```powershell
cd app
.\mvnw.cmd spring-boot:run
```

## テーブル確認

```bash
docker compose exec db psql -U app_user -d usage_ledger -c "\dt"
```

期待されるテーブルは以下です。

```text
customers
services
plans
subscriptions
daily_usages
invoices
invoice_items
flyway_schema_history
```

## seedデータ確認

```bash
docker compose exec db psql -U app_user -d usage_ledger -c "SELECT COUNT(*) FROM services;"
docker compose exec db psql -U app_user -d usage_ledger -c "SELECT COUNT(*) FROM plans;"
docker compose exec db psql -U app_user -d usage_ledger -c "SELECT COUNT(*) FROM customers;"
docker compose exec db psql -U app_user -d usage_ledger -c "SELECT COUNT(*) FROM subscriptions;"
docker compose exec db psql -U app_user -d usage_ledger -c "SELECT COUNT(*) FROM daily_usages;"
```

期待値は以下です。

```text
services: 3
plans: 4
customers: 3
subscriptions: 4
daily_usages: 8
```

## 月次請求計算SQLの実行

2026年4月の利用量を顧客・サービス単位で集計し、契約期間内の利用だけを請求対象として抽出します。

Windows PowerShell の場合:

```powershell
Get-Content db/04_billing_queries.sql | docker compose exec -T db psql -U app_user -d usage_ledger
```

このSQLでは、以下を行います。

- 対象月の利用量を集計する
- 契約期間内の利用量だけを請求対象にする
- 無料枠を差し引く
- 課金対象利用量を算出する
- 基本料金と従量課金額を合算する

## 不整合検知SQLの実行

契約期間外に記録された利用量を検知します。

Windows PowerShell の場合:

```powershell
Get-Content db/05_integrity_checks.sql | docker compose exec -T db psql -U app_user -d usage_ledger
```

このSQLでは、`daily_usages` に記録された利用量について、利用日に有効な契約が存在しないデータを抽出します。

不整合データは自動修正せず、運用上の確認対象として検知する方針です。

## 契約期間外利用の不整合検知API

契約期間外に記録された利用量を、Spring Boot API から確認できます。

```powershell
curl.exe "http://localhost:8081/integrity-checks/out-of-contract-usages?month=2026-04"
```

期待結果:

```json
[
  {
    "dailyUsageId": 8,
    "customerId": 3,
    "customerName": "Gamma Studio",
    "serviceId": 3,
    "serviceName": "Analytics API",
    "usageDate": "2026-04-05",
    "usageAmount": 2000
  }
]
```

このAPIでは、`daily_usages` に記録された利用量について、利用日に有効な契約が存在しないデータを抽出します。

## Flyway によるDB変更管理

このプロジェクトでは、Spring Boot アプリケーション側でDB変更履歴を管理するために Flyway を導入しています。

Flyway は、`app/src/main/resources/db/migration/` 配下の migration ファイルを読み取り、未適用のDB変更だけを順番に適用します。適用履歴は PostgreSQL 上の `flyway_schema_history` テーブルに記録されます。

現在は、DBスキーマ作成とseedデータ投入を以下のmigrationで管理しています。

- `V1__flyway_baseline.sql`
- `V2__create_tables.sql`
- `V3__insert_master_data.sql`
- `V4__insert_sample_transactions.sql`

これにより、`docker compose down -v` でDBボリュームを削除した後でも、Spring Bootアプリケーション起動時にFlywayがDBを再構築できます。

### Flyway履歴テーブルの確認

```bash
docker compose exec db psql -U app_user -d usage_ledger -c "\dt flyway_schema_history"
```

### Flyway適用履歴の確認

```bash
docker compose exec db psql -U app_user -d usage_ledger -c "SELECT installed_rank, version, description, type, success FROM flyway_schema_history ORDER BY installed_rank;"
```

期待結果の例:

```text
 installed_rank | version |        description         | type | success
----------------+---------+----------------------------+------+---------
              1 | 1       | flyway baseline            | SQL  | t
              2 | 2       | create tables              | SQL  | t
              3 | 3       | insert master data         | SQL  | t
              4 | 4       | insert sample transactions | SQL  | t
```

## 現時点のスコープ

現時点では、以下を実装しています。

- DB設計
- DDL
- seedデータ
- 月次請求計算SQL
- 契約期間外利用の不整合検知SQL
- Spring Boot の初期構成
- ヘルスチェックAPI
- 契約期間外利用の不整合検知API
- Spring Boot から PostgreSQL への接続
- Flyway migration によるDBスキーマ作成
- Flyway migration によるseedデータ投入
- Docker初期化SQLからFlyway migrationへの移行

## 今後追加予定

今後、以下を追加する予定です。

- 月次請求プレビューAPI
- 請求作成処理
- JUnit によるテスト
- README / docs のアーキテクチャ説明強化
