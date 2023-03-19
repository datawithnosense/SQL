/* Chapter 6. 프로시져와 잡 */

-- 1. 프로시저(Procedure)

-- 1-1. 프로시저란?
SELECT * FROM pg_available_extensions WHERE comment like '%procedural language';

-- 1-3. 프로시저 만들기
INSERT INTO fms.breeds_prod_tbl(prod_date, breeds_nm, total_sum, save_time)
(
SELECT prod_date, breeds_nm, total_sum, CURRENT_TIMESTAMP AS save_time
FROM fms.breeds_prod
WHERE prod_date = '2023-01-31'
);

-- 1-4. 프로시저 실행하기
CALL fms.breeds_prod_proc();

DELETE FROM fms.breeds_prod_tbl;
