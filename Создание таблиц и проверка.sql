 
SELECT version()


--создала новую БД
CREATE DATABASE "NeoflexProject";
 

--создаю схему
CREATE SCHEMA "DS" 

SELECT schema_name, schema_owner 
FROM information_schema.schemata 
WHERE schema_name = 'DS';
 

--Создаю таблицы

--DS.FT_BALANCE_F

CREATE TABLE "FT_BALANCE_F" (
	on_date DATE not null,
	account_rk BIGINT not null,
	currency_rk BIGINT,
	balance_out DECIMAL,
    CONSTRAINT pk_ft_balance PRIMARY KEY (on_date, account_rk)
);

--DS.FT_POSTING_F
--это таблица проводок (операций) в рабочем дне (поле oper_date),
 --которая состоит из двух частей: счет дебета и счет кредита,
 --которая изменяет баланс на сумму проводки


CREATE TABLE "FT_POSTING_F" (
	oper_date DATE not null,
	credit_account_rk BIGINT not null,
	debet_account_rk BIGINT not null,
	credit_amount DECIMAL,
	debet_amount DECIMAL
);


--Таблицы DS.MD_ACCOUNT_D, DS.MD_CURRENCY_D и DS.MD_EXCHANGE_RATE_D содержат информацию о счетах, валютах и курсах валют соответственно.
-- В данных таблицах есть поля data_actual_date и data_actual_end_date, по которым можно определить какие именно записи актуальны в нужную дату. 
--Идентификаторы записей имеют окончание «_rk» (например, account_rk – идентификатор счета).
--DS.MD_ACCOUNT_D

CREATE TABLE "MD_ACCOUNT_D" (
	data_actual_date DATE not null,
	data_actual_end_date DATE not null,
	account_rk BIGINT not null,
	account_number VARCHAR(20) NOT NULL,
	char_type CHAR(1) NOT NULL,
	currency_rk BIGINT NOT NULL,
	currency_code CHAR(3) NOT NULL,

    CONSTRAINT pk_md_account PRIMARY KEY (data_actual_date, account_rk)
);

--DS.MD_CURRENCY_D

CREATE TABLE "MD_CURRENCY_D" (
	currency_rk BIGINT not null,
	data_actual_date DATE not null,
	data_actual_end_date DATE,
	currency_code CHAR(3),
	code_iso_char CHAR(3),
	
	CONSTRAINT pk_md_currency PRIMARY KEY (currency_rk, data_actual_date)
);

--DS.MD_EXCHANGE_RATE_D

CREATE TABLE "MD_EXCHANGE_RATE_D" (
	data_actual_date DATE not null,
	data_actual_end_date DATE,
	currency_rk BIGINT not null,
	reduced_cource DECIMAL,
	code_iso_num CHAR(3),

	CONSTRAINT pk_md_exchange PRIMARY KEY (data_actual_date, currency_rk)
);

--DS.MD_LEDGER_ACCOUNT_S
--это справочник балансовых счетов. 
--Он регулируется Центральным банком. По нему можно определить к какой 
--главе и к каким разделам относятся счета первого (первые 3 цифры номера счета) и второго (первые 5 цифр номера счета) порядка.

CREATE TABLE "MD_LEDGER_ACCOUNT_S" (
	chapter CHAR(1),
	chapter_name VARCHAR(16),
	section_number INT,
	section_name VARCHAR(22),
	subsection_name VARCHAR(21),
	ledger1_account INT,
	ledger1_account_name VARCHAR(47),
	ledger_account INT not null,
	ledger_account_name VARCHAR(153),
	characteristic CHAR(1),
	is_resident INT,
	is_reserve INT,
	is_reserved INT,
	is_loan INT,
	is_reserved_assets INT, 
	is_overdue INT,
	is_interest INT,
	pair_account CHAR(5),
	start_date DATE not null,
	end_date DATE,
	is_rub_only INT,
	min_term CHAR(1),
	min_term_measure CHAR(1),
	max_term CHAR(1),
	max_term_measure CHAR(1),
	ledger_acc_full_name_translit CHAR(1),
	is_revaluation CHAR(1),
	is_correct CHAR(1),

	CONSTRAINT pk_md_ledger PRIMARY KEY (ledger_account, start_date)
);

SELECT table_name 
FROM information_schema.tables
WHERE table_schema = 'DS'; 

--создаю схему
CREATE SCHEMA "LOGS" 

SELECT schema_name, schema_owner 
FROM information_schema.schemata 
WHERE schema_name = 'LOGS';


CREATE TABLE "ETL_LOG" (
	log_id SERIAL PRIMARY KEY,           -- Уникальный ID записи
	process_name VARCHAR(255) NOT NULL,  -- Имя ETL-процесса/задачи 
	cur_date DATE not null,
	start_time TIMESTAMP,                -- Время начала
	end_time TIMESTAMP,                  -- Время окончания
	duration_sec INTEGER,				 -- Длительность в секундах
	status VARCHAR(20),                  -- Статус: RUNNING, SUCCESS, ERROR
	rows_read INTEGER DEFAULT 0,         -- Кол-во прочитанных строк
	rows_written INTEGER DEFAULT 0,      -- Кол-во записанных строк
	rows_error INTEGER DEFAULT 0,        -- Кол-во ошибок
	error_message TEXT,                  -- Текст ошибки
	source TEXT,						-- Путь к объекту
	user_name VARCHAR(100)               -- Кем запущен процесс
);

SELECT data_actual_date, data_actual_end_date, account_rk, account_number, char_type, currency_rk, currency_code
FROM  "MD_ACCOUNT_D";

SELECT data_actual_date, data_actual_end_date, account_rk, account_number, char_type, currency_rk, currency_code
FROM  "MD_ACCOUNT_D"
where account_rk=36237725;
 
TRUNCATE TABLE "DS"."MD_ACCOUNT_D";
TRUNCATE TABLE "DS"."FT_BALANCE_F";
TRUNCATE TABLE "DS"."FT_POSTING_F";
TRUNCATE TABLE "DS"."MD_CURRENCY_D";
TRUNCATE TABLE "DS"."MD_EXCHANGE_RATE_D";
TRUNCATE TABLE "DS"."MD_LEDGER_ACCOUNT_S";

SELECT * FROM "DS"."MD_ACCOUNT_D";  
SELECT * FROM "DS"."FT_BALANCE_F";
select * from "DS"."FT_POSTING_F";
SELECT * FROM "DS"."MD_CURRENCY_D";
select * from "DS"."MD_EXCHANGE_RATE_D"; --data
select * from "DS"."MD_LEDGER_ACCOUNT_S";

SELECT count(*) FROM "DS"."MD_ACCOUNT_D"; --112
SELECT count(*) FROM "DS"."FT_BALANCE_F"; --114
select count(*) from "DS"."FT_POSTING_F"; --33892
SELECT count(*) FROM "DS"."MD_CURRENCY_D"; --50
select count(*) from "DS"."MD_EXCHANGE_RATE_D"; --460
select count(*) from "DS"."MD_LEDGER_ACCOUNT_S"; --18



SELECT * FROM "LOGS"."ETL_LOG" ORDER BY log_id DESC;

SELECT * FROM "DS"."FT_BALANCE_F" where account_rk=36237725;

SELECT * FROM "DS"."MD_ACCOUNT_D"where account_rk=36237725; 


select * from "DS"."FT_POSTING_F" where debet_account_rk=17436;


