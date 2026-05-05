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

## 注意

このアプリは学習・ポートフォリオ目的で作成した架空システムです。実在の企業・業務・案件・データとは関係ありません。

テーブル設計、料金体系、サービス名、顧客名、seedデータ、SQLはすべて独自に作成しています。

## 採用技術

- Java 17
- Spring Boot 3.5.14
- Maven
- PostgreSQL 17
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
        resources/
          application.properties
      test/
        java/
          com/example/usageledger/
            UsageLedgerApplicationTests.java
```

## DB起動

```bash
docker compose up -d
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

`docker compose down -v` はDBボリュームを削除します。seedデータや手動で投入した検証データも消えるため、初期構築・検証時のみ使用します。

## テーブル確認

```bash
docker compose exec db psql -U app_user -d usage_ledger -c "\dt"
```

## 月次請求計算SQLの実行

```bash
docker compose exec db psql -U app_user -d usage_ledger -f /docker-entrypoint-initdb.d/04_billing_queries.sql
```

このSQLでは、以下を行います。

- 対象月の利用量を集計する
- 契約期間内の利用量だけを請求対象にする
- 無料枠を差し引く
- 課金対象利用量を算出する
- 基本料金と従量課金額を合算する

## 不整合検知SQLの実行

```bash
docker compose exec db psql -U app_user -d usage_ledger -f /docker-entrypoint-initdb.d/05_integrity_checks.sql
```

このSQLでは、`daily_usages` に記録された利用量について、利用日に有効な契約が存在しないデータを抽出します。

不整合データは自動修正せず、運用上の確認対象として検知する方針です。

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

## 現時点のスコープ

現時点では、以下を実装しています。

- DB設計
- DDL
- seedデータ
- 月次請求計算SQL
- 契約期間外利用の不整合検知SQL
- Spring Boot の初期構成
- ヘルスチェックAPI

## 今後追加予定

今後、以下を追加する予定です。

- Flyway によるマイグレーション管理
- Spring Boot から PostgreSQL への接続
- 月次請求プレビューAPI
- 契約期間外利用の不整合検知API
- 請求作成処理
- JUnit によるテスト
- README / docs のアーキテクチャ説明強化