/* Chapter 4. 데이터 조회하기(고급) */

-- 1. 데이터 합치기

-- 1-1. 두 테이블의 데이터 열로 합치기(JOIN)
SELECT
a.chick_no, a.pass_fail, a.raw_weight,
b.order_no, b.customer
FROM
fms.prod_result a 
INNER JOIN fms.ship_result b
ON a.chick_no = b.chick_no;

SELECT
a.chick_no, a.pass_fail, a.raw_weight,
b.order_no, b.customer
FROM
fms.prod_result a,
fms.ship_result b
WHERE
a.chick_no = b.chick_no;

-- ② LEFT OUTER JOIN
SELECT
a.chick_no, a.pass_fail, a.raw_weight,
b.order_no, b.customer
FROM
fms.prod_result a 
LEFT OUTER JOIN fms.ship_result b
ON a.chick_no = b.chick_no;

-- 1-2. 두 테이블의 데이터 행으로 합치기(UNION)
SELECT chick_no, gender, hatchday
FROM fms.chick_info
WHERE farm = 'A' 
AND gender = 'F' 
AND hatchday = '2023-01-03';

(
SELECT chick_no, gender, hatchday 
FROM fms.chick_info
WHERE farm = 'A' 
AND gender = 'F' 
AND hatchday = '2023-01-03'
)
UNION
(
SELECT 'A2300021', 'F', '2023-01-05'
);

-- 2. 서브쿼리와 뷰 테이블

-- 2-1. 쿼리 안에 쿼리 넣기
SELECT avg(egg_weight) FROM fms.chick_info;

SELECT chick_no, egg_weight 
FROM fms.chick_info
WHERE egg_weight > 66.75;

SELECT chick_no, egg_weight 
FROM fms.chick_info
WHERE egg_weight > (SELECT avg(egg_weight) FROM fms.chick_info);

SELECT
a.chick_no, a.breeds,
b.code_desc "breeds_nm"
FROM
fms.chick_info a,
fms.master_code b
WHERE a.breeds = b.code
AND b.column_nm = 'breeds';

SELECT
a.chick_no,
a.breeds,
(
SELECT m.code_desc "breeds_nm" 
FROM fms.master_code m
WHERE m.column_nm = 'breeds'
AND m.code = a.breeds
)
FROM fms.chick_info a;

SELECT
a.chick_no, a.breeds,
b.breeds_nm
FROM fms.chick_info a,
(
SELECT code, code_desc "breeds_nm" 
FROM fms.master_code
WHERE column_nm = 'breeds'
) b
WHERE a.breeds = b.code;

-- 2-2. 나만의 가상 테이블 만들기(VIEW)
CREATE OR REPLACE VIEW fms.breeds_prod
(
prod_date, breeds_nm, total_sum
)
AS
SELECT
a.prod_date,
(
SELECT m.code_desc "breeds_nm"
FROM fms.master_code m
WHERE m.column_nm = 'breeds'
AND m.code = b.breeds
),
sum(a.raw_weight) "total_sum"
FROM
fms.prod_result a,
fms.chick_info b
WHERE
a.chick_no = b.chick_no
AND a.pass_fail = 'P'
GROUP BY a.prod_date, b.breeds;

SELECT * FROM fms.breeds_prod;

-- 3. 테이블 형태 변환

-- 3-1. 행을 열로 바꾸기(PIVOT)
-- ① 부화일자, 성별 기준 마리 수 집계
SELECT hatchday, gender, count(chick_no)::int AS cnt
FROM fms.chick_info
GROUP BY hatchday, gender 
ORDER BY hatchday, gender;

-- ② 부화일자 기준 성별을 열로 변경
SELECT
a.hatchday,
CASE WHEN a.gender = 'M' THEN a.cnt ELSE 0 END "Male",
CASE WHEN a.gender = 'F' THEN a.cnt ELSE 0 END "Female"
FROM
(
SELECT hatchday, gender, count(chick_no)::int AS cnt
FROM fms.chick_info
GROUP BY hatchday, gender
ORDER BY hatchday, gender
) a;

-- ③ 부화일자 기준 마리 수 합계
SELECT
a.hatchday,
SUM(CASE WHEN a.gender = 'M' THEN a.cnt ELSE 0 END) "Male",
SUM(CASE WHEN a.gender = 'F' THEN a.cnt ELSE 0 END) "Female"
FROM
(
SELECT hatchday, gender, count(chick_no)::int AS cnt
FROM fms.chick_info
GROUP BY hatchday, gender 
ORDER BY hatchday, gender
) a
GROUP BY a.hatchday;

CREATE EXTENSION tablefunc;

SELECT * 
FROM crosstab
(
'SELECT hatchday, gender, count(chick_no)::int AS cnt
FROM fms.chick_info
GROUP BY hatchday, gender
ORDER BY hatchday, gender DESC'
)
AS pivot_r(hatchday date, "Male" int, "Female" int);

-- 3-2. 열을 행으로 바꾸기(UNPIVOT)
SELECT chick_no, body_temp, breath_rate, feed_intake
FROM fms.health_cond
WHERE check_date = '2023-01-20' 
AND chick_no LIKE 'A%';

SELECT
a.chick_no, a.health, a.cond
FROM
(
	SELECT chick_no, 'body_temp' AS health, body_temp AS cond
	FROM fms.health_cond
	WHERE check_date = '2023-01-20' AND chick_no LIKE 'A%'
	UNION
	SELECT chick_no, 'breath_rate' AS health, breath_rate AS cond
	FROM fms.health_cond
	WHERE check_date = '2023-01-20' AND chick_no LIKE 'A%'
	UNION
	SELECT chick_no, 'feed_intake' AS health, feed_intake AS cond
	FROM fms.health_cond
	WHERE check_date = '2023-01-20' AND chick_no LIKE 'A%'
) a
ORDER BY a.chick_no, a.health;

SELECT
chick_no,
unnest(array['body_temp', 'breath_rate', 'feed_intake']) AS health,
unnest(array[body_temp, breath_rate, feed_intake]) AS cond
FROM fms.health_cond
WHERE check_date = '2023-01-20' 
AND chick_no LIKE 'A%'
ORDER BY chick_no, health;

