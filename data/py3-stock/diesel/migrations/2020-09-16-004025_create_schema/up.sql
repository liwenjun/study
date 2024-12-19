-- 数据结构定义
-- 股票基本信息
CREATE TABLE stock_basic (
    code VARCHAR PRIMARY KEY,
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
    --delist_date VARCHAR,
    --退市日期
    is_hs CHAR(1) --是否沪深港通标的，N否 H沪股通 S深股通
);

-- 上市公司信息
CREATE TABLE stock_company (
    code VARCHAR PRIMARY KEY,
    exchange VARCHAR,
    --交易所代码 ，SSE上交所 SZSE深交所
    chairman VARCHAR,
    --法人代表
    manager VARCHAR,
    --总经理
    secretary VARCHAR,
    --董秘
    reg_capital NUMERIC,
    --注册资本
    setup_date VARCHAR,
    --注册日期
    province VARCHAR,
    city VARCHAR,
    introduction TEXT,
    website VARCHAR,
    email VARCHAR,
    office VARCHAR,
    employees NUMERIC,
    --员工人数 
    main_business TEXT,
    --主要业务及产品
    business_scope TEXT --经营范围
);

-- 日k线
CREATE TABLE kdata_day (
    date DATE NOT NULL,
    code CHAR(6) NOT NULL,
    open NUMERIC,
    --开盘价	
    high NUMERIC,
    --最高价	
    low NUMERIC,
    --最低价	
    close NUMERIC,
    --收盘价	
    preclose NUMERIC,
    --前收盘价
    volume BIGINT,
    --成交量（累计 单位：股）	
    amount NUMERIC,
    --成交额（单位：人民币元）	
    --adjustflag CHAR(1),
    --复权状态(1：后复权， 2：前复权，3：不复权）	
    turn VARCHAR,
    --换手率	[指定交易日的成交量(股)/指定交易日的股票的流通股总股数(股)]*100%
    tradestatus CHAR(1),
    --交易状态(1：正常交易 0：停牌）	
    pctChg VARCHAR,
    --涨跌幅（百分比）日涨跌幅=[(指定交易日的收盘价-指定交易日前收盘价)/指定交易日前收盘价]*100%
    peTTM VARCHAR,
    --滚动市盈率 (指定交易日的股票收盘价/指定交易日的每股盈余TTM)=(指定交易日的股票收盘价*截至当日公司总股本)/归属母公司股东净利润TTM
    pbMRQ VARCHAR,
    --市净率 (指定交易日的股票收盘价/指定交易日的每股净资产)=总市值/(最近披露的归属母公司股东的权益-其他权益工具)
    psTTM VARCHAR,
    --滚动市销率 (指定交易日的股票收盘价/指定交易日的每股销售额)=(指定交易日的股票收盘价*截至当日公司总股本)/营业总收入TTM
    pcfNcfTTM VARCHAR,
    --滚动市现率 (指定交易日的股票收盘价/指定交易日的每股现金流TTM)=(指定交易日的股票收盘价*截至当日公司总股本)/现金以及现金等价物净增加额TTM
    isST BOOLEAN,
    --是否ST股，1是，0否
    CONSTRAINT pk_kdata_day_primary_date_code primary key(date, code)
) PARTITION BY RANGE (code);

-- 深圳
CREATE TABLE kdata_day_sz1 PARTITION OF kdata_day FOR
VALUES
FROM
    ('000001') TO ('002000');

CREATE TABLE kdata_day_sz2 PARTITION OF kdata_day FOR
VALUES
FROM
    ('002000') TO ('009999');

CREATE TABLE kdata_day_sz3 PARTITION OF kdata_day FOR
VALUES
FROM
    ('300000') TO ('309999');

-- 上海
CREATE TABLE kdata_day_sh1 PARTITION OF kdata_day FOR
VALUES
FROM
    ('600000') TO ('609999');

CREATE TABLE kdata_day_sh2 PARTITION OF kdata_day FOR
VALUES
FROM
    ('688000') TO ('689999');

CREATE TABLE kdata_day_default PARTITION OF kdata_day DEFAULT;

-- 1分钟线 分区表
CREATE TABLE kdata_min (
    code CHAR(6) NOT NULL,
    datetime timestamp NOT NULL,
    high NUMERIC,
    low NUMERIC,
    --open NUMERIC,
    --close NUMERIC,
    vol INTEGER,
    amount INTEGER,
    CONSTRAINT unique_kdata_min_datetime_code UNIQUE(datetime, code)
) PARTITION BY RANGE (code);

-- 深圳主板 455
CREATE TABLE kdata_min_sz_zb1 PARTITION OF kdata_min FOR
VALUES
FROM
    ('000001') TO ('000700');

CREATE TABLE kdata_min_sz_zb2 PARTITION OF kdata_min FOR
VALUES
FROM
    ('000700') TO ('002000');

-- 深圳中小板 962
CREATE TABLE kdata_min_sz_zxb1 PARTITION OF kdata_min FOR
VALUES
FROM
    ('002000') TO ('002220');

CREATE TABLE kdata_min_sz_zxb2 PARTITION OF kdata_min FOR
VALUES
FROM
    ('002220') TO ('002440');

CREATE TABLE kdata_min_sz_zxb3 PARTITION OF kdata_min FOR
VALUES
FROM
    ('002440') TO ('002670');

CREATE TABLE kdata_min_sz_zxb4 PARTITION OF kdata_min FOR
VALUES
FROM
    ('002670') TO ('002900');

CREATE TABLE kdata_min_sz_zxb5 PARTITION OF kdata_min FOR
VALUES
FROM
    ('002900') TO ('009999');

-- 深圳创业板1 855
CREATE TABLE kdata_min_sz_cyb1 PARTITION OF kdata_min FOR
VALUES
FROM
    ('300001') TO ('300220');

CREATE TABLE kdata_min_sz_cyb2 PARTITION OF kdata_min FOR
VALUES
FROM
    ('300220') TO ('300440');

CREATE TABLE kdata_min_sz_cyb3 PARTITION OF kdata_min FOR
VALUES
FROM
    ('300440') TO ('300660');

CREATE TABLE kdata_min_sz_cyb4 PARTITION OF kdata_min FOR
VALUES
FROM
    ('300660') TO ('300890');

CREATE TABLE kdata_min_sz_cyb5 PARTITION OF kdata_min FOR
VALUES
FROM
    ('300890') TO ('301999');

-- 上海主板1 1528
CREATE TABLE kdata_min_sh_zb1 PARTITION OF kdata_min FOR
VALUES
FROM
    ('600000') TO ('600260');

CREATE TABLE kdata_min_sh_zb2 PARTITION OF kdata_min FOR
VALUES
FROM
    ('600260') TO ('600540');

CREATE TABLE kdata_min_sh_zb3 PARTITION OF kdata_min FOR
VALUES
FROM
    ('600540') TO ('600780');

CREATE TABLE kdata_min_sh_zb4 PARTITION OF kdata_min FOR
VALUES
FROM
    ('600780') TO ('601170');

CREATE TABLE kdata_min_sh_zb5 PARTITION OF kdata_min FOR
VALUES
FROM
    ('601170') TO ('603080');

CREATE TABLE kdata_min_sh_zb6 PARTITION OF kdata_min FOR
VALUES
FROM
    ('603080') TO ('603560');

CREATE TABLE kdata_min_sh_zb7 PARTITION OF kdata_min FOR
VALUES
FROM
    ('603560') TO ('603960');

CREATE TABLE kdata_min_sh_zb8 PARTITION OF kdata_min FOR
VALUES
FROM
    ('603960') TO ('606000');

-- 上海科创板 174
CREATE TABLE kdata_min_sh_kcb1 PARTITION OF kdata_min FOR
VALUES
FROM
    ('688001') TO ('688900');

CREATE TABLE kdata_min_sh_kcb2 PARTITION OF kdata_min FOR
VALUES
FROM
    ('688900') TO ('689999');

CREATE TABLE kdata_min_default PARTITION OF kdata_min DEFAULT;

-- 分笔成交数据  分表
CREATE TABLE transaction_data (
    code CHAR(6) NOT NULL,
    time CHAR(5) NOT NULL,
    price NUMERIC,
    vol INTEGER,
    num INTEGER DEFAULT 0,
    buyorsell CHAR(1)
);
