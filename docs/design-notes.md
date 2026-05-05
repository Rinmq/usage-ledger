# 設計メモ

## PostgreSQLを採用した理由

請求処理では、契約期間、対象月、無料枠、従量課金、請求重複防止など、データ整合性が重要になる。

PostgreSQLは、日付処理、CHECK制約、外部キー制約、UNIQUE制約、CTE、VIEW、トランザクションを扱いやすく、業務データの整合性をDB側でも担保しやすいため採用した。

## daily_usages に subscription_id を持たせない理由

daily_usages は、顧客が特定サービスを特定日に利用した事実データとして扱う。

そのため、契約そのものを表す subscription_id ではなく、customer_id、service_id、usage_date、usage_amount を保持する。

請求処理時には、daily_usages と subscriptions / plans を突き合わせ、利用日が契約期間内かどうかを判定する。

この設計により、契約期間外に記録された利用量を不整合データとして検知できる。

## subscriptions に service_id を持たせない理由

契約対象のサービスは、subscriptions.plan_id から plans.service_id を通じて参照できる。

subscriptions に service_id も持たせると、plans.service_id との不一致が発生する可能性があるため、初期設計では冗長性を避けた。

## invoices に UNIQUE(customer_id, billing_month) を設定する理由

月次請求処理は再実行される可能性がある。

同一顧客・同一請求月の請求データが重複作成されると重大な不整合になるため、アプリケーション側だけでなくDB制約でも二重作成を防ぐ。

## 不整合検知SQLを用意した理由

請求処理では、契約期間内の利用量のみを請求対象とする。

ただし、契約期間外の利用量を単に除外するだけでは、データ登録ミスや契約情報の不備を見落とす可能性がある。

そのため、契約期間外に記録された利用量を不整合データとして検知するSQLを用意した。

なお、このSQLは不整合を自動修正するものではなく、運用上の確認対象を抽出する目的で使用する。
