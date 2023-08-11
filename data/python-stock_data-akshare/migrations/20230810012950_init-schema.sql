-- Add migration script here

CREATE TABLE stock(
   证券代码      CHAR(6) NOT NULL,
   证券简称      TEXT    NOT NULL, 
   交易所        CHAR(2) NOT NULL,  -- SH/SZ/BJ
   板块          TEXT,
   上市日期      CHAR(10),
   CONSTRAINT stock_pk PRIMARY KEY (证券代码)
);

CREATE TABLE fund(
   证券代码  CHAR(6) NOT NULL,
   名称      TEXT    NOT NULL, 
   类别      TEXT,    -- ETF / LOF
   流通市值  INTEGER,
   总市值    INTEGER,
   CONSTRAINT fund_pk PRIMARY KEY (证券代码)
);

CREATE TABLE daily(
   证券代码   CHAR(6)  NOT NULL,
   日期       CHAR(10) NOT NULL,
   开盘       NUMERIC,  -- 开盘价
   收盘       NUMERIC,  -- 收盘价       
   最高       NUMERIC,  -- 最高价       
   最低       NUMERIC,  -- 最低价       
   成交量     INTEGER,  -- 注意单位: 手 
   成交额     NUMERIC,  -- 注意单位: 元 
   振幅       NUMERIC,  -- 注意单位: %  
   涨跌幅     NUMERIC,  -- 注意单位: %  
   涨跌额     NUMERIC,  -- 注意单位: 元 
   换手率     NUMERIC,  -- 注意单位: %  
   CONSTRAINT daily_pk PRIMARY KEY (证券代码, 日期)
);



CREATE TABLE etf(
   基金代码  CHAR(6) NOT NULL,
   基金简称  TEXT    NOT NULL, 
   类型     TEXT,
   CONSTRAINT etf_pk PRIMARY KEY (基金代码)
);

CREATE TABLE etf_netvalue(
   基金代码  CHAR(6)  NOT NULL,
   净值日期  CHAR(10) NOT NULL,
   单位净值  NUMERIC,
   累计净值  NUMERIC,
   日增长率  NUMERIC,  -- 注意单位: %
   FOREIGN KEY (基金代码) REFERENCES etf (基金代码) ON DELETE CASCADE,
   CONSTRAINT etf_netvalue_pk PRIMARY KEY (基金代码, 净值日期)
);
