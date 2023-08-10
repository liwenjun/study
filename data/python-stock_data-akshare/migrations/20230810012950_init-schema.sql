-- Add migration script here

CREATE TABLE stock(
   证券代码      CHAR(6) NOT NULL,
   证券简称      TEXT    NOT NULL, 
   交易所        CHAR(2) NOT NULL,  -- SH/SZ/BJ
   板块          TEXT,
   上市日期      CHAR(10),
   CONSTRAINT stock_pk PRIMARY KEY (证券代码)
);

CREATE TABLE stock_daily(
   证券代码 CHAR(6)  NOT NULL,
   日期     CHAR(10) NOT NULL,
   开盘     NUMERIC,  -- 开盘价
   收盘     NUMERIC,  -- 收盘价       
   最高     NUMERIC,  -- 最高价       
   最低     NUMERIC,  -- 最低价       
   成交量   INTEGER,  -- 注意单位: 手 
   成交额   NUMERIC,  -- 注意单位: 元 
   振幅     NUMERIC,  -- 注意单位: %  
   涨跌幅   NUMERIC,  -- 注意单位: %  
   涨跌额   NUMERIC,  -- 注意单位: 元 
   换手率   NUMERIC,  -- 注意单位: %  
   FOREIGN KEY (证券代码) REFERENCES stock (证券代码) ON DELETE CASCADE,
   CONSTRAINT stock_daily_pk PRIMARY KEY (证券代码, 日期)
);


CREATE TABLE fund(
   代码     CHAR(6) NOT NULL,
   名称     TEXT    NOT NULL, 
   类别     TEXT,
   类型     TEXT,
   最新价   NUMERIC,
   涨跌额   NUMERIC,
   涨跌幅   NUMERIC,  -- 注意单位: %
   成交量   NUMERIC,
   成交额   NUMERIC,
   开盘价   NUMERIC,
   最高价   NUMERIC,
   最低价   NUMERIC,
   昨收     NUMERIC,
   换手率   NUMERIC,
   流通市值 INTEGER,
   总市值   INTEGER
   CONSTRAINT fund_pk PRIMARY KEY (代码)
);

CREATE TABLE fund_daily(
   代码     CHAR(6)  NOT NULL,
   日期     CHAR(10) NOT NULL,
   开盘     NUMERIC,  -- 开盘价
   收盘     NUMERIC,  -- 收盘价       
   最高     NUMERIC,  -- 最高价       
   最低     NUMERIC,  -- 最低价       
   成交量   INTEGER,  -- 注意单位: 手 
   成交额   NUMERIC,  -- 注意单位: 元 
   振幅     NUMERIC,  -- 注意单位: %  
   涨跌幅   NUMERIC,  -- 注意单位: %  
   涨跌额   NUMERIC,  -- 注意单位: 元 
   换手率   NUMERIC,  -- 注意单位: %  
   单位净值 NUMERIC,
   累计净值 NUMERIC,
   日增长率 NUMERIC,  -- 注意单位: %
   FOREIGN KEY (代码) REFERENCES fund (代码) ON DELETE CASCADE,
   CONSTRAINT fund_daily_pk PRIMARY KEY (代码, 日期)
);
