-- 分时数据  分区表
CREATE TABLE time_data (
    code VARCHAR NOT NULL,
    datetime timestamp NOT NULL,
    price NUMERIC,
    vol INTEGER,
    CONSTRAINT unique_time_data_datetime_code UNIQUE(datetime, code)
) PARTITION BY RANGE (code);
