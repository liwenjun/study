# coding: utf-8

import datetime
import logging
import math
import sqlite3
from contextlib import closing
from multiprocessing.pool import Pool

import akshare as ak
import pandas as pd
from tqdm import tqdm

logger = logging.getLogger(__name__)


# 进程数
PNUM = 6

defaultDB = "./data/data.sqlite"


def _get_daily_latest_day(db=None):
    """获取本地存储日数据每支股票的最近日期"""
    sql = """SELECT 证券代码, max(日期) as 最近日期
                FROM daily
                GROUP BY 证券代码;
    """
    if db is None:
        db = defaultDB

    with sqlite3.connect(db) as conn:
        df = pd.read_sql(sql, conn)

    return df


def _get_netvalue_latest_day(db=None):
    """获取本地存储净值数据每支基金的最近日期"""
    sql = """SELECT 基金代码, max(净值日期) as 最近日期
                FROM etf_netvalue
                GROUP BY 基金代码;
    """
    if db is None:
        db = defaultDB

    with sqlite3.connect(db) as conn:
        df = pd.read_sql(sql, conn)

    return df


SDL = _get_daily_latest_day()
EDL = _get_netvalue_latest_day()


def fetch_etf():
    """获取etf净值数据"""
    df = _get_etf()
    ids = _merge_etf_ids(df)
    # logger.debug(ids[:3])
    p = Pool(processes=PNUM)
    dat = p.map(_get_etf_netvalue, tqdm(ids, desc="抓取ETF基金净值数据"))
    p.close()
    p.join()
    dat = pd.concat(dat, ignore_index=True)
    _save_etf(df, dat)


def fetch_stock_fund():
    """获取stock数据"""
    FDlist = [
        # (func_list, func_daily, func_save, desc)
        (_get_sh_kc, _get_stock_daily, _save_stock, "抓取上证科创板数据"),
        (_get_sh_zb, _get_stock_daily, _save_stock, "抓取上证主板数据"),
        (_get_sz, _get_stock_daily, _save_stock, "抓取深证数据"),
        (_get_bj, _get_stock_daily, _save_stock, "抓取北证数据"),
        (_get_fund_etf, _get_etf_daily, _save_fund, "抓取ETF基金数据"),
        (_get_fund_lof, _get_lof_daily, _save_fund, "抓取LOF基金数据"),
    ]
    for f in FDlist:
        _fetch_one(f)


def _fetch_one(f):
    """获取一项股票数据"""
    df = f[0]()
    slice = list(df.groupby(lambda x: math.floor(x / (PNUM * 10))))
    for x in slice:
        _fetch_one_df(x[1], f[1], f[2], f[3])


def _merge_etf_ids(df):
    """合并ETF净值数据最新日期"""
    pp = pd.merge(df, EDL, how="left", on="基金代码")
    pp = pp[["基金代码", "最近日期"]].where(df.notnull(), None)
    ids = pp.apply(lambda x: tuple(x), axis=1).values.tolist()
    ids = list(
        map(lambda x: (x[0], None if x[1] is None else x[1].replace("-", "")), ids)
    )
    return ids


def _merge_stock_ids(df):
    """合并股票日数据最新日期"""
    pp = pd.merge(df, SDL, how="left", on="证券代码")
    pp = pp[["证券代码", "最近日期"]].where(df.notnull(), None)
    ids = pp.apply(lambda x: tuple(x), axis=1).values.tolist()
    ids = list(
        map(lambda x: (x[0], None if x[1] is None else x[1].replace("-", "")), ids)
    )
    return ids


def _fetch_one_df(df, func, save, desc):
    """获取指定片段股票日数据并保存"""
    # ids = df["证券代码"].to_list()
    ids = _merge_stock_ids(df)
    logger.info(ids[:2])
    p = Pool(processes=PNUM)
    dat = p.map(func, tqdm(ids, desc=desc))
    p.close()
    p.join()
    dat = pd.concat(dat, ignore_index=True)
    save(df, dat)


def _save_stock(dlist, daily):
    """保存stock数据"""
    SQL = """INSERT INTO stock (
                    证券代码,
                    证券简称,
                    交易所,
                    板块,
                    上市日期
                )
                VALUES (
                    :证券代码,
                    :证券简称,
                    :交易所,
                    :板块,
                    :上市日期
                )
                ON CONFLICT DO NOTHING
    """
    SQLd = """INSERT INTO daily (
                    证券代码,
                    日期,
                    开盘,
                    收盘,
                    最高,
                    最低,
                    成交量,
                    成交额,
                    振幅,
                    涨跌幅,
                    涨跌额,
                    换手率
                )
                VALUES (
                    :证券代码,
                    :日期,
                    :开盘,
                    :收盘,
                    :最高,
                    :最低,
                    :成交量,
                    :成交额,
                    :振幅,
                    :涨跌幅,
                    :涨跌额,
                    :换手率
                )
                ON CONFLICT DO NOTHING
    """
    _save2sqlite3_(
        dlist.to_dict(orient="records"), daily.to_dict(orient="records"), SQL, SQLd
    )


def _save_fund(dlist, daily):
    """保存fund数据"""
    SQL = """INSERT INTO fund (
                    证券代码,
                    名称,
                    类别,
                    流通市值,
                    总市值
                )
                VALUES (
                    :证券代码,
                    :名称,
                    :类别,
                    :流通市值,
                    :总市值
                )
                ON CONFLICT DO NOTHING
    """
    SQLd = """INSERT INTO daily (
                    证券代码,
                    日期,
                    开盘,
                    收盘,
                    最高,
                    最低,
                    成交量,
                    成交额,
                    振幅,
                    涨跌幅,
                    涨跌额,
                    换手率
                )
                VALUES (
                    :证券代码,
                    :日期,
                    :开盘,
                    :收盘,
                    :最高,
                    :最低,
                    :成交量,
                    :成交额,
                    :振幅,
                    :涨跌幅,
                    :涨跌额,
                    :换手率
                )
                ON CONFLICT DO NOTHING
    """
    _save2sqlite3_(
        dlist.to_dict(orient="records"), daily.to_dict(orient="records"), SQL, SQLd
    )


def _save_etf(dlist, daily):
    """保存etf数据"""
    SQL = """INSERT INTO etf (
                    基金代码,
                    基金简称,
                    类型
                )
                VALUES (
                    :基金代码,
                    :基金简称,
                    :类型
                )
                ON CONFLICT DO NOTHING
    """
    SQLd = """INSERT INTO etf_netvalue (
                    基金代码,
                    净值日期,
                    单位净值,
                    累计净值,
                    日增长率
                )
                VALUES (
                    :基金代码,
                    :净值日期,
                    :单位净值,
                    :累计净值,
                    :日增长率
                )
                ON CONFLICT DO NOTHING
    """
    _save2sqlite3_(
        dlist.to_dict(orient="records"), daily.to_dict(orient="records"), SQL, SQLd
    )


def _save2sqlite3_(data: list, datad: list, sql: str, sqld: str, db: str = None):
    """存储数据到本地数据库

    参数: data - 待保存列表数据。
    参数: datad - 待保存明细数据。
    参数: sql - 保存列表数据sql语句。
    参数: sqld - 保存明细数据sql语句。
    参数: db - 数据库名，可缺省。
    """

    if db is None:
        db = defaultDB

    with sqlite3.connect(db) as conn:
        with closing(conn.cursor()) as cur:
            cur.executemany(sql, data)
            print("写入 %d 行列表数据" % (cur.rowcount,))
            cur.executemany(sqld, datad)
            print("写入 %d 行明细数据" % (cur.rowcount,))
            # conn.commit()


def _get_stock_daily(p):
    """历史行情数据-前复权"""
    start = p[1] if p[1] is not None else "19901201"
    df = ak.stock_zh_a_hist(
        symbol=p[0],  # "000001"
        period="daily",
        start_date=start,  # "19901201"
        end_date=datetime.date.today().strftime("%Y%m%d"),  # 当天
        adjust="qfq",
    )
    df["证券代码"] = p[0]
    return df


def _get_etf_daily(p):
    """etf基金历史行情数据-前复权, 合并净值数据"""
    start = p[1] if p[1] is not None else "19901201"
    df = ak.fund_etf_hist_em(
        symbol=p[0],
        period="daily",
        start_date=start,  # "19901201"
        end_date=datetime.date.today().strftime("%Y%m%d"),  # 当天
        adjust="qfq",
    )
    df["证券代码"] = p[0]
    return df


def _get_lof_daily(p):
    """lof基金历史行情数据-前复权"""
    start = p[1] if p[1] is not None else "19901201"
    df = ak.fund_lof_hist_em(
        symbol=p[0],
        period="daily",
        start_date=start,  # "19901201"
        end_date=datetime.date.today().strftime("%Y%m%d"),  # 当天
        adjust="qfq",
    )
    df["证券代码"] = p[0]
    return df


def _get_sh_zb():
    """获取上证数据 主板"""
    df = ak.stock_info_sh_name_code(symbol="主板A股")
    df.drop(columns="公司全称", inplace=True)
    df["板块"] = "主板"
    df["交易所"] = "SH"

    return df


def _get_sh_kc():
    """获取上证数据 科创板"""
    df = ak.stock_info_sh_name_code(symbol="科创板")
    df.drop(columns="公司全称", inplace=True)
    df["板块"] = "科创板"
    df["交易所"] = "SH"

    return df


def _get_sz():
    """获取深证数据"""
    df = ak.stock_info_sz_name_code(symbol="A股列表")
    df.drop(columns=["A股总股本", "A股流通股本", "所属行业"], inplace=True)
    df["交易所"] = "SZ"
    df = df.rename(columns={"A股代码": "证券代码", "A股简称": "证券简称", "A股上市日期": "上市日期"})

    return df


def _get_bj():
    """获取北证数据"""
    df = ak.stock_info_bj_name_code()
    df.drop(columns=["总股本", "流通股本", "所属行业", "地区", "报告日期"], inplace=True)
    df["交易所"] = "BJ"
    df["板块"] = "新三板"

    return df


def _get_fund_etf():
    """获取ETF基金实时行情-东财"""
    df = ak.fund_etf_spot_em()
    df = df[["代码", "名称", "流通市值", "总市值"]]
    df = df.rename(columns={"代码": "证券代码"})
    df["类别"] = "ETF"

    return df


def _get_fund_lof():
    """获取LOF基金实时行情-东财"""
    df = ak.fund_lof_spot_em()
    df = df[["代码", "名称", "流通市值", "总市值"]]
    df = df.rename(columns={"代码": "证券代码"})
    df["类别"] = "LOF"

    return df


def _get_etf():
    """获取基金实时行情-东财, 合并基金类型"""
    df = ak.fund_etf_fund_daily_em()
    df = df[["基金代码", "基金简称", "类型"]]

    return df


def _get_etf_netvalue(p):
    """etf基金净值数据"""
    start = p[1] if p[1] is not None else "19901201"
    df = ak.fund_etf_fund_info_em(
        fund=p[0], start_date=start, end_date=datetime.date.today().strftime("%Y%m%d")
    )
    df.drop(columns=["申购状态", "赎回状态"], inplace=True)

    df["基金代码"] = p[0]
    return df
