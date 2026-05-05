-- Flyway migration の開始地点を明示するための no-op migration。
-- 実際のテーブル作成は V2__create_tables.sql で行う。
SELECT 1;
