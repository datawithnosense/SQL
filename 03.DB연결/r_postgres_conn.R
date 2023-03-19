# Posgresql DB 연결을 위한 패키지 
install.packages("RPostgres")
library(RPostgres)

# R에서 SQL을 사용할 수 있게 해주는 패키지
install.packages("sqldf")
library(sqldf)

# DB 연동 객체 생성
conn <- dbConnect(dbDriver("Postgres"), 
                  dbname = "postgres", 
                  host = "localhost",
                  port = 5432,
                  user = "postgres",
                  password = "1111")

# conn 실행
conn

# DB user_info 테이블에 전체 데이터 조회하기(SELECT)
qry_s <- "SELECT * FROM public.user_info;"
sqldf(qry_s, connection = conn)

# DB user_info 테이블에 데이터 입력하기(INSERT)
qry_i <- "INSERT INTO public.user_info VALUES ('leeseo06','이서','0702214000006','LG','01066666666');"
sqldf(qry_i, connection = conn)
sqldf(qry_s, connection = conn)

# DB 연결 해제
dbDisconnect(conn)
conn
