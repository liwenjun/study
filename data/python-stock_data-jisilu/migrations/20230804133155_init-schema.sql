-- Add migration script here

CREATE TABLE etf(
   fund_id        CHAR(6) NOT NULL,      -- 基金代码
   fund_nm        TEXT    NOT NULL,      -- 基金名称
   index_nm       TEXT    NOT NULL,      -- 指数
   issuer_nm      TEXT    NOT NULL,      -- 基金公司
   amount         INTEGER,               -- 场内份额(万份)
   unit_total     NUMERIC,               -- 基金规模(亿元)
   unit_incr      NUMERIC,               -- 基金规模变化(亿元)
   volume         NUMERIC,               -- 成交额(万元)
   idx_price_dt   CHAR(10),              -- 指数日期
   CONSTRAINT etf_pk PRIMARY KEY (fund_id)
);

CREATE TABLE etf_detail(
   fund_id        CHAR(6) NOT NULL,      -- 基金代码
   hist_dt        CHAR(10) NOT NULL,     -- 日期
   amount         INTEGER,               -- 场内份额(万份)
   amount_incr    INTEGER,               -- 场内份额变化(万份)
   idx_incr_rt    NUMERIC,               -- 指数涨幅%
   fund_nav       NUMERIC,               -- 基金净值
   trade_price    NUMERIC,               -- 收盘价
   unit_total     NUMERIC,               -- 基金规模(亿元)
   unit_incr      NUMERIC,               -- 基金规模变化(亿元)
   volume         NUMERIC,               -- 成交额(万元)
   FOREIGN KEY (fund_id) REFERENCES etf (fund_id) ON DELETE CASCADE,
   CONSTRAINT etf_detail_pk PRIMARY KEY (fund_id, hist_dt)
);


CREATE TABLE qdii(
   fund_id        CHAR(6) NOT NULL,
   fund_nm        TEXT    NOT NULL,
   index_nm       TEXT    NOT NULL,
   issuer_nm      TEXT    NOT NULL,
   CONSTRAINT qdii_pk PRIMARY KEY (fund_id)
);

CREATE TABLE qdii_detail(
   fund_id        CHAR(6) NOT NULL,
   hist_dt        CHAR(10) NOT NULL,
   amount         INTEGER NOT NULL,
   amount_incr    INTEGER NOT NULL,
   fund_nav       NUMERIC NOT NULL,
   trade_price    NUMERIC NOT NULL,
   FOREIGN KEY (fund_id) REFERENCES qdii (fund_id) ON DELETE CASCADE,
   CONSTRAINT qdii_detail_pk PRIMARY KEY (fund_id, hist_dt)
);


CREATE TABLE lof(
   fund_id        CHAR(6) NOT NULL,
   fund_nm        TEXT    NOT NULL,
   index_nm       TEXT    NOT NULL,
   issuer_nm      TEXT    NOT NULL,
   CONSTRAINT lof_pk PRIMARY KEY (fund_id)
);

CREATE TABLE lof_detail(
   fund_id        CHAR(6) NOT NULL,
   hist_dt        CHAR(10) NOT NULL,
   amount         INTEGER NOT NULL,
   amount_incr    INTEGER NOT NULL,
   fund_nav       NUMERIC NOT NULL,
   trade_price    NUMERIC NOT NULL,
   FOREIGN KEY (fund_id) REFERENCES lof (fund_id) ON DELETE CASCADE,
   CONSTRAINT lof_detail_pk PRIMARY KEY (fund_id, hist_dt)
);
