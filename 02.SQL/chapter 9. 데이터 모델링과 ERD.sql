/* Chapter 9. 데이터 모델링과 ERD */

-- 2. ERD(Entity Relationship Diagram)와 테이블 명세서

-- 2-2. 테이블 명세서 조회
SELECT
 tt.table_type
,isc.table_name
,tc.table_comment
,isc.column_name
,cc.column_comment
,isc.udt_name AS column_type
,CASE WHEN isc.character_maximum_length IS NULL THEN isc.numeric_precision 
 ELSE isc.character_maximum_length END AS length
,isc.is_nullable
,ct.constraint_type
FROM
(
	information_schema.columns isc
	LEFT OUTER JOIN --table_type(tt) join
	(
		SELECT
		 table_schema
		,table_name
		,table_type
		FROM information_schema.tables
	) tt 
	ON isc.table_schema = tt.table_schema
	AND isc.table_name = tt.table_name
	LEFT OUTER JOIN --table_comment(tc) join
	(
		SELECT 
		 pn.nspname AS schema_name
		,pc.relname AS table_name
		,OBJ_DESCRIPTION(pc.oid) AS table_comment
		FROM pg_catalog.pg_class pc
		INNER JOIN pg_catalog.pg_namespace pn
		ON pc.relnamespace = pn.oid 
		WHERE pc.relkind = 'r'
	) tc 
	ON isc.table_schema = tc.schema_name
	AND isc.table_name = tc.table_name
	LEFT OUTER JOIN --column_comment(cc) join
	(
		SELECT
		 ps.schemaname AS schema_name
		,ps.relname AS table_name
		,pa.attname AS column_name
		,pd.description AS column_comment
		FROM 
		pg_stat_all_tables ps,
		pg_catalog.pg_description pd,
		pg_catalog.pg_attribute pa
		WHERE ps.relid = pd.objoid
		AND pd.objsubid != 0
		AND pd.objoid = pa.attrelid
		AND pd.objsubid = pa.attnum
		ORDER BY ps.relname, pd.objsubid
	) cc
	ON isc.table_schema = cc.schema_name
	AND isc.table_name = cc.table_name
	AND isc.column_name = cc.column_name
	LEFT OUTER JOIN --constraint_type(ct) join
	(
		SELECT
		 isccu.table_schema
		,istc.table_name
		,isccu.column_name
		,istc.constraint_type
		,isccu.constraint_name
		FROM
		information_schema.table_constraints istc,
		information_schema.constraint_column_usage isccu
		WHERE istc.table_catalog = isccu.table_catalog
		AND istc.table_schema = isccu.table_schema
		AND istc.constraint_name = isccu.constraint_name
	) ct 
	ON isc.table_schema = ct.table_schema
	AND isc.table_name = ct.table_name
	AND isc.column_name = ct.column_name
)
WHERE isc.table_schema = 'fms'
ORDER BY tt.table_type, isc.table_name, isc.ordinal_position;