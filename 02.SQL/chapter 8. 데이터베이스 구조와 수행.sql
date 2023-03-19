/* Chapter 8. 데이터베이스 구조와 수행 */

-- 1. SQL 수행 구조

-- 1-3. 연산 및 절 우선순위
SELECT
b.destination, sum(a.raw_weight) "prod_sum"
FROM 
fms.prod_result a 
INNER JOIN fms.ship_result b
ON a.chick_no = b.chick_no
WHERE a.disease_yn = 'N' AND a.size_stand >= 11
GROUP BY b.destination
HAVING (sum(a.raw_weight)/1000) >= 5
ORDER BY sum(a.raw_weight) DESC
LIMIT 3;

-- 2. 인덱스(Index)와 조인(Join)

-- 2-3. 인덱스 실습
CREATE TABLE IF NOT EXISTS public.bank
(
    client_no integer NOT NULL,
    age smallint,
    gender character(1),
    edu character varying(13),
    marital character varying(8),
    card_type character varying(8),
    CONSTRAINT bank_pkey PRIMARY KEY (client_no)
);

EXPLAIN SELECT * FROM public.bank;

EXPLAIN ANALYZE SELECT * FROM public.bank;

EXPLAIN ANALYZE 
SELECT * FROM public.bank WHERE client_no BETWEEN '850' AND '855';

EXPLAIN ANALYZE 
SELECT * FROM public.bank WHERE gender = 'F' AND age BETWEEN 66 AND 67;

CREATE INDEX IF NOT EXISTS bank_idx
    ON public.bank USING btree
    (gender COLLATE pg_catalog."default" ASC NULLS LAST, age ASC NULLS LAST)
    TABLESPACE pg_default;

COMMENT ON INDEX public.bank_idx
    IS '성별과 나이를 이용한 인덱스';

EXPLAIN ANALYZE 
SELECT * FROM public.bank WHERE gender = 'F' AND age BETWEEN 66 AND 67;

EXPLAIN (ANALYZE, FORMAT JSON)
SELECT * FROM public.bank WHERE gender = 'F' AND age BETWEEN 66 AND 67;

-- 2-4. 조인 방법
EXPLAIN ANALYZE
SELECT
a.chick_no, a.pass_fail, a.raw_weight,
b.order_no, b.customer
FROM
fms.prod_result a 
INNER JOIN fms.ship_result b
ON a.chick_no = b.chick_no;
