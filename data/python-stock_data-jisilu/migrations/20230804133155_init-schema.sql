-- Add migration script here

CREATE TABLE etf(
   fund_id        CHAR(6) PRIMARY KEY     NOT NULL,
   fund_nm        TEXT    NOT NULL,
   index_nm       TEXT    NOT NULL,
   issuer_nm      TEXT    NOT NULL
);


CREATE TABLE etf_detail(
   fund_id        CHAR(6) NOT NULL,
   hist_dt        CHAR(10) NOT NULL,
   amount         INTEGER NOT NULL,
   amount_incr    INTEGER NOT NULL,
   fund_nav       NUMERIC NOT NULL,
   trade_price    NUMERIC NOT NULL,
   CONSTRAINT etf_detail_pk PRIMARY KEY (fund_id, hist_dt)    
);
