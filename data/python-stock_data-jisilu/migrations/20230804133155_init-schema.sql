-- Add migration script here

-- 基金类型说明：
-- eft基金： ei-指数/eg-黄金/em-货币
-- qdii基金：qe-欧美指数/qc-欧美商品/qa-亚洲指数
-- lof基金：ls-股票/li-指数
CREATE TABLE fund(
   fund_id        CHAR(6) NOT NULL,      -- 基金代码
   fund_name      TEXT    NOT NULL,      -- 基金名称
   index_name     TEXT    NOT NULL,      -- 指数/相关标的
   issuer_name    TEXT    NOT NULL,      -- 基金公司
   fund_type      CHAR(2) NOT NULL,      -- 基金类型：ei,eg,em,qa,qe,qc,ls,li
   fund_nav       NUMERIC,               -- 基金净值
   fund_nav_date  CHAR(10),              -- 净值日期
   price          NUMERIC,               -- 现价/收盘价
   amount         INTEGER,               -- 份额(万份)
   volume         NUMERIC,               -- 成交额(万元)
   total          NUMERIC,               -- 规模(亿元)
   idx_incr_rt    NUMERIC,               -- 指数/重仓涨幅%
   CONSTRAINT fund_pk PRIMARY KEY (fund_id)
);

CREATE TABLE fund_detail(
   fund_id        CHAR(6) NOT NULL,      -- 基金代码
   fund_date      CHAR(10) NOT NULL,     -- 基金日期
   price          NUMERIC,               -- 收盘价
   fund_nav       NUMERIC,               -- 基金净值
   amount         INTEGER,               -- 场内份额(万份)
   amount_incr    INTEGER,               -- 场内份额变化(万份)
   idx_incr_rt    NUMERIC,               -- 指数/重仓涨幅%
   discount_rt    NUMERIC,               -- 溢价率%
   FOREIGN KEY (fund_id) REFERENCES fund (fund_id) ON DELETE CASCADE,
   CONSTRAINT fund_detail_pk PRIMARY KEY (fund_id, fund_date)
);
