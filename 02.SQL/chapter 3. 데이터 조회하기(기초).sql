/* Chapter 3. 데이터 조회하기(기초)*/

-- 1. 데이터 조회 및 정렬

-- 1-2. 전체 데이터 조회하기
SELECT * FROM fms.chick_info;

-- 1-3. 전체 데이터 개수 출력하기
SELECT count(*) FROM fms.chick_info;

-- 1-4. 원하는 열만 조회하기
SELECT chick_no, hatchday, egg_weight FROM fms.chick_info;

-- 1-5. 열 이름 바꿔 조회하기
SELECT chick_no as cn, hatchday “부화일자” FROM fms.chick_info;

-- 1-6. 데이터 정렬하기(ORDER BY)
SELECT chick_no, hatchday, egg_weight FROM fms.chick_info ORDER BY egg_weight;

SELECT chick_no, hatchday, egg_weight FROM fms.chick_info ORDER BY egg_weight DESC;

SELECT chick_no, hatchday, egg_weight FROM fms.chick_info

ORDER BY egg_weight DESC, hatchday ASC, chick_no ASC;

-- 1-7. 원하는 개수의 데이터만 조회하기(LIMIT, OFFSET)
SELECT chick_no, hatchday, egg_weight FROM fms.chick_info
ORDER BY egg_weight DESC, hatchday ASC, chick_no ASC
LIMIT 5;

SELECT chick_no, hatchday, egg_weight FROM fms.chick_info
ORDER BY egg_weight DESC, hatchday ASC, chick_no ASC
LIMIT 4 OFFSET 1;

-- 1-8. 중복된 결과 제거하기(DISTINCT)
SELECT DISTINCT(hatchday) FROM fms.chick_info;

-- 1-9. 원하는 조건의 데이터만 조회하기(WHERE)
-- ① 육계정보 테이블에서 성별이 M인 대상 조회하기
SELECT * FROM fms.chick_info WHERE gender = 'M';
-- ② 육계정보 테이블에서 종란무게가 70g 이상인 대상 조회
SELECT * FROM fms.chick_info WHERE egg_weight >= 70;
-- ③ 육계정보 테이블에서 부화일자가 2023-01-01 ~ 2023-01-02 사이인 대상 조회
SELECT * FROM fms.chick_info 
WHERE hatchday BETWEEN '2023-01-01' AND '2023-01-02';
-- ④ 육계정보 테이블에서 종란무게가 69g 보다 크거나 62g 보다 작거나 같은 대상 조회
SELECT * FROM fms.chick_info WHERE egg_weight > 69 OR egg_weight <= 62;
-- ⑤ 육계정보 테이블에서 품종이 D로 시작하는 대상 조회
SELECT * FROM fms.chick_info WHERE breeds LIKE 'D%';
-- ⑥ 출하실적 테이블에서 도착지가 부산, 울산인 대상 조회
SELECT * FROM fms.ship_result WHERE destination IN ('부산','울산');
-- ⑦ 사육환경 테이블에서 습도가 측정되지 않은 날짜 조회
SELECT * FROM fms.env_cond WHERE humid IS NULL;
-- ⑧ 건강상태 테이블에서 노트가 입력된 대상 조회
SELECT * FROM fms.health_cond WHERE note IS NOT NULL;

-- 1-10. 원하는 문자만 가져오기(SUBSTRING)
SELECT chick_no, LEFT(chick_no,1), SUBSTRING(chick_no,2,3), RIGHT(chick_no,4)
FROM fms.chick_info LIMIT 5;

-- 1-11. 기타 문자열 함수
-- ① 육계정보 테이블에서 육계번호의 글자수 확인하기
SELECT LENGTH(chick_no) FROM fms.chick_info LIMIT 5;
-- ② 육계정보 테이블에서 농장, 성별, 품종 열의 데이터를 하나로 합치기
SELECT farm||gender||breeds AS fgb FROM fms.chick_info LIMIT 5;
-- ③ 육계정보 테이블에서 성별을 소문자로 변환하기
SELECT LOWER(gender) FROM fms.chick_info LIMIT 5;
-- ④ 육계정보 테이블에서 성별 M을 Male로 변환하기
SELECT REPLACE(gender,'M','Male') FROM fms.chick_info LIMIT 5;


-- 2. 데이터 집계

-- 2-1. 데이터 집계하기(GROUP BY)
-- ① 생산실적 테이블에서 생산일자별 생닭중량 합계 조회하기
SELECT prod_date, sum(raw_weight) AS prod 
FROM fms.prod_result
GROUP BY prod_date;
-- ② 출하실적 테이블에서 고객사별 출하 마릿수 조회하기
SELECT customer, count(chick_no) AS cnt 
FROM fms.ship_result
GROUP BY customer;

-- 2-2. 원하는 조건으로 데이터 집계하기(HAVING)
SELECT customer, count (chick_no) AS cnt 
FROM fms.ship_result
GROUP BY customer HAVING count(chick_no) >= 10;

-- 3. 데이터 변환 및 조건문
-- 3-1. 데이터 타입 변환하기(TO_CHAR)
SELECT hatchday, TO_CHAR(hatchday,'Mon') FROM fms.chick_info LIMIT 5;

-- 3-2. NULL 변환(COALESCE, NULLIF)
SELECT farm, date, humid, COALESCE(humid, 60) 
FROM fms.env_cond
WHERE date BETWEEN '2023-01-23' AND '2023-01-27'
AND farm = 'A';

SELECT farm, date, humid, NULLIF(humid, 60) 
FROM fms.env_cond
WHERE date BETWEEN '2023-01-23' AND '2023-01-27'
AND farm = 'A';

-- 3-3. 원하는 조건으로 항목 추가하기(CASE)
SELECT
chick_no,
egg_weight,
CASE
WHEN egg_weight > 69 THEN 'H'
WHEN egg_weight > 65 THEN 'M'
ELSE 'L'
END "w_grade"
FROM fms.chick_info LIMIT 10;

