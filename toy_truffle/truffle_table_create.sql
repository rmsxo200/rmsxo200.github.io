CREATE TABLE travel_main (
	travel_seq int AUTO_INCREMENT PRIMARY KEY COMMENT '여행_PK',
	travel_title	varchar(50)	NULL	COMMENT '여행명',
	start_date	date	NOT NULL	COMMENT '시작일자',
	end_date	date	NOT NULL	COMMENT '종료일자',
	create_user_id	varchar(20)	NULL	COMMENT '생성자',
	create_dttm	datetime DEFAULT CURRENT_TIMESTAMP	COMMENT '생성일시',
	update_dttm	datetime ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시'
);

CREATE TABLE travel_plan (
	plan_seq	int	AUTO_INCREMENT PRIMARY KEY	COMMENT '일정_PK',
	travel_seq	int	NOT NULL	COMMENT '여행_PK',
	place_name	varchar(50)	NULL	COMMENT '장소명',
	plan_date	date	NULL	COMMENT '일정일자',
	plan_time	time	NULL	COMMENT '일정시간',
	memo	varchar(200)	NULL	COMMENT '메모',
	plan_order	int	NULL	COMMENT '정렬순서',
	place_yn	char(1)	NOT NULL	DEFAULT 'Y'	COMMENT '장소여부',
	map_id	varchar(10)	NULL	COMMENT '지도_ID',
	latitude	decimal(10,6)	NULL	COMMENT '지도_위도',
	longitude	decimal(10,6)	NULL	COMMENT '지도_경도',
	file_mapping_seq	int	NOT NULL	COMMENT '첨부파일매핑_PK',
	create_user_id	varchar(20)	NULL	COMMENT '생성자',
	create_dttm	datetime DEFAULT CURRENT_TIMESTAMP	COMMENT '생성일시',
	update_dttm	datetime ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시'
);

CREATE TABLE partner (
	travel_seq	int	NOT NULL	COMMENT '여행_PK',
	user_id	varchar(20)	NOT NULL	COMMENT '사용자ID',
	owner_yn	char(1)	NOT NULL	DEFAULT 'Y'	COMMENT '여행소유자_여부',
	del_yn	char(1)	NOT NULL	DEFAULT 'N'	COMMENT '여행삭제여부'
);

CREATE TABLE destination (
	destination_cd	varchar(5)	NOT NULL	COMMENT '여행지_코드',
	destination_name	varchar(10)	NULL	COMMENT '여행지역명'
);

CREATE TABLE destination_mapping (
	travel_seq	int	NOT NULL	COMMENT '여행_PK',
	destination_cd	varchar(5)	NOT NULL	COMMENT '여행지_코드',
	destination_order	int	NULL	COMMENT '여행지_순번'
);

CREATE TABLE between_distance (
	travel_seq	int	NOT NULL	COMMENT '여행_PK',
	pre_place_order	int	NULL	COMMENT '이전_장소_순서',
	next_place_order	int	NULL	COMMENT '다음_장소_순서',
	distance	double	NULL	COMMENT '거리'
);

CREATE TABLE expense (
	expense_seq	int	AUTO_INCREMENT PRIMARY KEY	COMMENT '비용_PK',
	travel_seq	int	NOT NULL	COMMENT '여행_PK',
	place_name	varchar(50)	NULL	COMMENT '장소명',
	plan_date	date	NOT NULL	COMMENT '여행일자',
	payment_method	enum('현금', '카드', '기타')	NULL	COMMENT '결제수단',
	price	int	NOT NULL	COMMENT '금액',
	expense_name	varchar(50)	NULL	COMMENT '항목명',
	private_yn	char(1)	NOT NULL	DEFAULT 'N'	COMMENT '나만보기_여부',
	map_id	varchar(10)	NULL	COMMENT '지도_ID',
	latitude	decimal(10,6)	NULL	COMMENT '지도_위도',
	longitude	decimal(10,6)	NULL	COMMENT '지도_경도',
	file_mapping_seq	int	NULL	COMMENT '첨부파일매핑_PK',
	create_user_id	varchar(20)	NULL	COMMENT '생성자',
	create_dttm	datetime DEFAULT CURRENT_TIMESTAMP	COMMENT '생성일시',
	update_dttm	datetime ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
	expense_order	int	NOT NULL	COMMENT '정렬순서'
);

CREATE TABLE payment_member (
	expense_seq	int	NOT NULL	COMMENT '비용_PK',
	travel_seq	int	NOT NULL	COMMENT '여행_PK',
	user_id	varchar(20)	NOT NULL	COMMENT '사용자ID',
	payment_yn	char(1)	NOT NULL	DEFAULT 'N'	COMMENT '결제여부',
	repay_yn	char(1)	NOT NULL	DEFAULT 'N'	COMMENT '정산여부'
);

CREATE TABLE expense_category_mapping (
	expense_seq	int	NOT NULL	COMMENT '비용_PK',
	travel_seq	int	NOT NULL	COMMENT '여행_PK',
	category_cd	varchar(10)	NOT NULL	COMMENT '비용_카테고리_코드 (공통코드  테이블사용)'
);

CREATE TABLE file_mapping (
	file_mapping_seq	int	NOT NULL	COMMENT '첨부파일매핑_PK',
	file_seq	int	NOT NULL	COMMENT '첨부파일_PK'
);

CREATE TABLE style_mapping (
	travel_seq	int	NOT NULL	COMMENT '여행_PK',
	style_cd	varchar(10)	NOT NULL	COMMENT '스타일_코드비용 (공통코드  테이블사용)',
	parent_style_cd	varchar(10)	NULL	COMMENT '부모스타일_코드'
);

CREATE TABLE file (
	file_seq	int	AUTO_INCREMENT PRIMARY KEY	COMMENT '첨부파일_PK',
	origin_file_name	varchar(255)	NOT NULL	COMMENT '원본파일명',
	server_file_name	varchar(255)	NOT NULL	COMMENT '저장파일명',
	file_extension	varchar(5)	NOT NULL	COMMENT '파일확장자',
	file_size	int	NOT NULL	COMMENT '파일크기'
);

CREATE TABLE user_table (
	user_id	varchar(20)	NOT NULL	COMMENT '사용자ID',
	email	varchar(100)	NOT NULL	COMMENT '이메일',
	password	varchar(20)	NOT NULL	COMMENT '비밀번호',
	name	varchar(50)	NOT NULL	COMMENT '이름'
);

CREATE TABLE checklist (
	checklist_seq	int	AUTO_INCREMENT PRIMARY KEY	COMMENT '체크리스트_PK',
	travel_seq	int	NOT NULL	COMMENT '여행_PK',
	parent_checklist_seq	int	NULL	COMMENT '부모_체크리스트_PK (JPA 셀프 조인)',
	checklist_name	varchar(50)	NULL	COMMENT '체크리스트 타이틀 혹은  상세',
	description	varchar(100)	NULL	COMMENT '기본설명'
);

CREATE TABLE common_code (
	common_cd	varchar(10)	NOT NULL	COMMENT '공통코드',
	parent_cd	varchar(10)	NULL	COMMENT '부모코드',
	cd_name	varchar(50)	NULL	COMMENT '코드명',
	description	varchar(100)	NULL	COMMENT '설명'
);

