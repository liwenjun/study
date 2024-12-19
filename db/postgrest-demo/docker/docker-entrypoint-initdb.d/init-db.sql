create schema api;

CREATE TABLE api.stock (
    ts_code CHAR(9) PRIMARY KEY,
    name VARCHAR NOT NULL,
    area VARCHAR,
    industry VARCHAR,
    fullname VARCHAR,
    enname VARCHAR,
    market VARCHAR,
    --市场类型 （主板/中小板/创业板/科创板）
    exchange VARCHAR,
    --交易所代码
    curr_type VARCHAR,
    --交易货币
    list_status VARCHAR,
    --上市状态： L上市 D退市 P暂停上市
    list_date VARCHAR,
    --上市日期
    is_hs CHAR(1) --是否沪深港通标的，N否 H沪股通 S深股通
);

-- 日k线
CREATE TABLE api.daily (
    -- id serial primary key,
    ts_code CHAR(9) NOT NULL,
    trade_date CHAR(8) NOT NULL,
    open NUMERIC,
    --开盘价	
    high NUMERIC,
    --最高价	
    low NUMERIC,
    --最低价	
    close NUMERIC,
    --收盘价	
    pre_close NUMERIC,
    --前收盘价
	change NUMERIC,
    pct_chg NUMERIC,
    vol NUMERIC,
    --成交量（累计 单位：股）	
    amount NUMERIC,
    --成交额（单位：人民币元）	
    --涨跌幅（百分比）日涨跌幅=[(指定交易日的收盘价-指定交易日前收盘价)/指定交易日前收盘价]*100%
	CONSTRAINT stock_daily_uniqe UNIQUE(ts_code, trade_date),
	CONSTRAINT fk_daily_stock FOREIGN KEY ( ts_code ) REFERENCES api.stock ( ts_code ) 
);

create role authenticator noinherit login password 'secretpassword';

create role web_anon nologin;
grant usage on schema api to web_anon;
-- grant select on all tables in schema api to web_anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA api GRANT SELECT ON TABLES TO web_anon;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA api TO web_anon;
grant web_anon to authenticator;

create role todo_user nologin;
grant usage on schema api to todo_user;
grant all on all tables in schema api to todo_user;
GRANT usage, SELECT ON ALL SEQUENCES IN SCHEMA api TO todo_user;
-- grant usage, select on sequence api.daily_id_seq to todo_user;
grant todo_user to authenticator;


copy api.stock from '/docker-entrypoint-initdb.d/stock.csv' delimiter ',' csv header;
copy api.daily from '/docker-entrypoint-initdb.d/daily-002123.SZ.csv' delimiter ',' csv header;
copy api.daily from '/docker-entrypoint-initdb.d/daily-002185.SZ.csv' delimiter ',' csv header;
copy api.daily from '/docker-entrypoint-initdb.d/daily-600238.SH.csv' delimiter ',' csv header;
copy api.daily from '/docker-entrypoint-initdb.d/daily-600358.SH.csv' delimiter ',' csv header;
copy api.daily from '/docker-entrypoint-initdb.d/daily-873167.BJ.csv' delimiter ',' csv header;
copy api.daily from '/docker-entrypoint-initdb.d/daily-830779.BJ.csv' delimiter ',' csv header;
