# UsageLedger

UsageLedger は、架空SaaSのAPI利用量を日別に記録し、月次請求・請求明細作成・不整合データ検知を行うSQL中心の業務システムポートフォリオです。

## 目的

このプロジェクトでは、単なるCRUDではなく、業務システムで発生しやすい以下の設計・SQL処理を扱います。

- 契約期間を考慮した利用量集計
- 無料枠を考慮した請求金額計算
- 月次請求データの二重作成防止
- 契約期間外利用などの不整合データ検知
- DB制約とアプリケーションロジックの責務分離

## 注意

このアプリは学習・ポートフォリオ目的で作成した架空システムです。実在の企業・業務・案件・データとは関係ありません。

## 採用技術

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
```

## 起動方法

```bash
docker compose up -d
```

## DB接続

```bash
docker compose exec db psql -U app_user -d usage_ledger
```

## 初期化し直す場合

```bash
docker compose down -v
docker compose up -d
```

## テーブル確認

```bash
docker compose exec db psql -U app_user -d usage_ledger -c "\dt"
```

## 月次請求計算SQLの実行

```bash
docker compose exec db psql -U app_user -d usage_ledger -f /docker-entrypoint-initdb.d/04_billing_queries.sql
```

## 不整合検知SQLの実行

```bash
docker compose exec db psql -U app_user -d usage_ledger -f /docker-entrypoint-initdb.d/05_integrity_checks.sql
```

## 現時点のスコープ

現時点では、DB設計、DDL、seedデータ、月次請求計算SQL、不整合検知SQLまでを実装しています。

今後、Java / Spring Boot によるAPI化、Flywayによるマイグレーション管理、JUnitによるテストを追加する予定です。