-- Add migration script here

CREATE TABLE etf(
   fund_id        CHAR(6) NOT NULL,
   fund_nm        TEXT    NOT NULL,
   index_nm       TEXT    NOT NULL,
   issuer_nm      TEXT    NOT NULL,
   CONSTRAINT etf_pk PRIMARY KEY (fund_id)
);


CREATE TABLE etf_detail(
   fund_id        CHAR(6) NOT NULL,
   hist_dt        CHAR(10) NOT NULL,
   amount         INTEGER NOT NULL,
   amount_incr    INTEGER NOT NULL,
   fund_nav       NUMERIC NOT NULL,
   trade_price    NUMERIC NOT NULL,
   FOREIGN KEY (fund_id) REFERENCES etf (fund_id) ON DELETE CASCADE,
   CONSTRAINT etf_detail_pk PRIMARY KEY (fund_id, hist_dt)
);
