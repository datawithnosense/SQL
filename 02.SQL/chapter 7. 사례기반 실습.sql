/* Chapter 7. 사례기반 실습 */

-- 1. 조류독감이 의심되는 닭을 찾아보자

SELECT * FROM fms.health_cond ORDER BY body_temp DESC;

SELECT
b.*,
a.vaccination1, a.vaccination2
FROM
fms.chick_info a,
fms.health_cond b
WHERE a.chick_no = b.chick_no
AND b.check_date = '2023-01-30'
AND (b.body_temp > 41.7 OR b.breath_rate > 70 OR b.feed_intake < 100);

-- 2. 건강상태가 나빠진 원인을 찾아보자

SELECT * FROM fms.env_cond;

SELECT a.*, b.* 
FROM
(
	SELECT date, temp, humid
	FROM fms.env_cond
	WHERE farm = 'B'
) a
LEFT OUTER JOIN
(
	SELECT chick_no, check_date, weight, body_temp, feed_intake
	FROM fms.health_cond
	WHERE chick_no = 'B2300009'
) b
ON a.date = b.check_date;

-- 3. 품종별 가장 무거운 닭 Top 3를 골라보자

SELECT
a.chick_no, a.breeds, b.raw_weight
FROM
fms.chick_info a,
fms.prod_result b
WHERE a.chick_no = b.chick_no;

SELECT
a.chick_no, a.breeds, b.raw_weight
FROM
fms.chick_info a,
fms.prod_result b
WHERE a.chick_no = b.chick_no
AND a.breeds = 'B1'
ORDER BY b.raw_weight DESC
LIMIT 3;

SELECT x.*
FROM
(
	SELECT
	a.chick_no, a.breeds, b.raw_weight,
	ROW_NUMBER() OVER(PARTITION BY a.breeds ORDER BY b.raw_weight DESC) "rn"
	FROM
	fms.chick_info a,
	fms.prod_result b
	WHERE a.chick_no = b.chick_no
) x
WHERE x.rn <= 3;

-- 4. 여러 테이블의 데이터를 연결해 종합실적을 조회해보자

SELECT
a.chick_no, a.breeds, a.egg_weight,
b.body_temp, b.breath_rate,
c.size_stand, c.pass_fail,
d.order_no, d.customer, d.arrival_date, d.destination
FROM
fms.chick_info a 
LEFT OUTER JOIN fms.health_cond b ON a.chick_no = b.chick_no
LEFT OUTER JOIN fms.prod_result c ON a.chick_no = c.chick_no
LEFT OUTER JOIN fms.ship_result d ON a.chick_no = d.chick_no
WHERE b.check_date = '2023-01-30';

SELECT
a.chick_no AS 육계번호,
(
	SELECT m.code_desc AS 품종
	FROM fms.master_code m 
	WHERE m.column_nm = 'breeds'
	AND m.code = a.breeds
)
,a.egg_weight||
(
	SELECT u.unit
	FROM fms.unit u 
	WHERE u.column_nm = 'egg_weight'
) AS 종란무게
,b.body_temp||
(
	SELECT u.unit
	FROM fms.unit u 
	WHERE u.column_nm = 'body_temp'
) AS 체온
,b.breath_rate||
(
	SELECT u.unit 
	FROM fms.unit u 
	WHERE u.column_nm = 'breath_rate'
) AS 호흡수
,(
	SELECT m.code_desc AS 호수 
	FROM fms.master_code m
	WHERE m.column_nm = 'size_stand' 
	AND TO_NUMBER(m.code,'99') = c.size_stand
)
,(
	SELECT m.code_desc AS 부적합여부
	FROM fms.master_code m 
	WHERE m.column_nm = 'pass_fail' 
	AND m.code = c.pass_fail
)
,d.order_no AS 주문번호
,d.customer AS 고객사 
,d.arrival_date AS 도착일
,d.destination AS 도착지
FROM
fms.chick_info a 
LEFT OUTER JOIN fms.health_cond b ON a.chick_no = b.chick_no
LEFT OUTER JOIN fms.prod_result c ON a.chick_no = c.chick_no
LEFT OUTER JOIN fms.ship_result d ON a.chick_no = d.chick_no
WHERE b.check_date = '2023-01-30';

-- 5. 종합실적을 뷰 테이블로 만들어보자

CREATE OR REPLACE VIEW fms.total_result
 AS
 SELECT a.chick_no AS "육계번호",
    ( SELECT m.code_desc AS "품종"
           FROM fms.master_code m
          WHERE m.column_nm::text = 'breeds'::text AND m.code::bpchar = a.breeds) AS "품종",
    a.egg_weight || ((( SELECT u.unit
           FROM fms.unit u
          WHERE u.column_nm::text = 'egg_weight'::text))::text) AS "종란무게",
    b.body_temp || ((( SELECT u.unit
           FROM fms.unit u
          WHERE u.column_nm::text = 'body_temp'::text))::text) AS "체온",
    b.breath_rate || ((( SELECT u.unit
           FROM fms.unit u
          WHERE u.column_nm::text = 'breath_rate'::text))::text) AS "호흡수",
    ( SELECT m.code_desc AS "호수"
           FROM fms.master_code m
          WHERE m.column_nm::text = 'size_stand'::text AND to_number(m.code::text, '99'::text) = c.size_stand::numeric) AS "호수",
    ( SELECT m.code_desc AS "부적합여부"
           FROM fms.master_code m
          WHERE m.column_nm::text = 'pass_fail'::text AND m.code::bpchar = c.pass_fail) AS "부적합여부",
    d.order_no AS "주문번호",
    d.customer AS "고객사",
    d.arrival_date AS "도착일",
    d.destination AS "도착지"
   FROM fms.chick_info a
     LEFT JOIN fms.health_cond b ON a.chick_no = b.chick_no
     LEFT JOIN fms.prod_result c ON a.chick_no = c.chick_no
     LEFT JOIN fms.ship_result d ON a.chick_no = d.chick_no
  WHERE b.check_date = '2023-01-30'::date;

ALTER TABLE fms.total_result
    OWNER TO postgres;
COMMENT ON VIEW fms.total_result
    IS '종합실적';
