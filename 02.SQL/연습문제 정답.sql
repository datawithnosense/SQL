/* 연습문제 정답 */

-- Chapter 3.

--3.
SELECT DISTINCT(customer) FROM fms.ship_result;

--4. 
SELECT chick_no, prod_date, raw_weight, disease_yn 
FROM fms.prod_result
WHERE disease_yn = 'N'
ORDER BY raw_weight DESC LIMIT 5;

--5. 
SELECT size_stand, round(avg(raw_weight),2), sum(raw_weight)
FROM fms.prod_result
WHERE TO_CHAR(prod_date,'MM') = '02'
GROUP BY size_stand 
ORDER BY size_stand;

-- Chapter 4.
 
-- 1. 
SELECT
a.chick_no,
a.gender,
b.code_desc AS gender_nm
FROM
fms.chick_info a 
INNER JOIN fms.master_code b
ON a.gender = b.code
WHERE
b.column_nm = 'gender';

-- 2.
SELECT
a.chick_no,
a.gender,
(
	SELECT m.code_desc "gender_nm" 
	FROM fms.master_code m
	WHERE m.column_nm = 'gender' 
	AND m.code = a.gender
),
a.vaccination1,
(
	SELECT m.code_desc "vac1_yn" 
	FROM fms.master_code m
	WHERE m.column_nm = 'vaccination1' 
	AND TO_NUMBER(m.code,'9') = a.vaccination1
)
FROM
fms.chick_info a;

--3.
SELECT
a.prod_date,
sum(CASE WHEN a.size_stand = 10 THEN a.cnt ELSE 0 END) "10",
sum(CASE WHEN a.size_stand = 11 THEN a.cnt ELSE 0 END) "11",
sum(CASE WHEN a.size_stand = 12 THEN a.cnt ELSE 0 END) "12"
FROM
(
	SELECT prod_date, size_stand, count(chick_no) AS cnt
	FROM fms.prod_result
	GROUP BY prod_date, size_stand 
	ORDER BY prod_date, size_stand
) a
GROUP BY a.prod_date;


