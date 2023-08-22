# coding: utf-8

import datetime
import logging
import sqlite3
from datetime import timedelta
from contextlib import closing
from multiprocessing.pool import Pool

import akshare as ak
import pandas as pd
from tqdm import tqdm

logger = logging.getLogger(__name__)


# 进程数
PNUM = 6
TMAX = 500

defaultDB = "./data/data.sqlite"


def split_list_by_n(list_collection, n):
    """
    将集合均分，每份n个元素
    :param list_collection:
    :param n:
    :return:返回的结果为评分后的每份可迭代对象
    """
    for i in range(0, len(list_collection), n):
        yield list_collection[i : i + n]


def _get_latest_day(sql, db=None):
    """获取本地存储日数据每支股票的最近日期"""
    db = defaultDB if db is None else db
    with sqlite3.connect(db) as conn:
        df = pd.read_sql(sql, conn)

    # TODO 日期+1，推迟一天。
    ds = pd.to_datetime(df["最近日期"], format="%Y-%m-%d", errors="ignore")
    df["最近日期"] = (ds + timedelta(days=1)).dt.strftime("%Y%m%d")
    return df


def _get_etf_ids():
    """"""
    SQL = """SELECT etf.基金代码, max(etf_netvalue.净值日期) as 最近日期
            FROM etf
            LEFT JOIN etf_netvalue ON etf.基金代码 = etf_netvalue.基金代码
            GROUP BY etf.基金代码
        """
    df = _get_latest_day(SQL)
    df = df.where(df.notnull(), None)
    ids = df.apply(lambda x: tuple(x), axis=1).values.tolist()
    ids = list(
        map(lambda x: (x[0], None if x[1] is None else x[1]), ids)
    )

    return ids


def _get_fund_ids(item):
    """"""
    SQL = """SELECT fund.证券代码, max(daily.日期) as 最近日期
            FROM fund
            LEFT JOIN daily ON fund.证券代码 = daily.证券代码
            WHERE fund.类别 = "%s"
            GROUP BY fund.证券代码
        """ % (
        item,
    )
    df = _get_latest_day(SQL)
    df = df.where(df.notnull(), None)
    ids = df.apply(lambda x: tuple(x), axis=1).values.tolist()
    ids = list(
        map(lambda x: (x[0], None if x[1] is None else x[1]), ids)
    )

    return ids


def _get_stock_ids():
    """"""
    SQL = """SELECT stock.证券代码, max(daily.日期) as 最近日期
            FROM stock
            LEFT JOIN daily ON stock.证券代码 = daily.证券代码
            GROUP BY stock.证券代码
        """
    df = _get_latest_day(SQL)
    df = df.where(df.notnull(), None)
    ids = df.apply(lambda x: tuple(x), axis=1).values.tolist()
    ids = list(
        map(lambda x: (x[0], None if x[1] is None else x[1]), ids)
    )

    return ids


def _save2sqlite(data, sql: str, db: str = None):
    """存储数据到本地数据库

    参数: data - 待保存数据。Pandas.DataFrame
    参数: sql - 保存列表数据sql语句。
    参数: db - 数据库名，可缺省。
    """
    db = defaultDB if db is None else db
    len = data.shape[0]
    with sqlite3.connect(db) as conn:
        with closing(conn.cursor()) as cur:
            cur.executemany(sql, data.to_dict(orient="records"))
            print("共 %d 行，写入 %d 行数据" % (len, cur.rowcount))
            # conn.commit()


def _update_stock_daily_one(ids):
    """更新stock日数据"""
    p = Pool(processes=PNUM)
    data = p.map(_get_stock_daily, tqdm(ids))
    p.close()
    p.join()
    data = pd.concat(data, ignore_index=True)

    SQL = """INSERT INTO daily (
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
    _save2sqlite(data, SQL)


def _update_etf_daily_one(ids):
    """更新etf日数据"""
    p = Pool(processes=PNUM)
    data = p.map(_get_etf_netvalue, tqdm(ids))
    p.close()
    p.join()
    data = pd.concat(data, ignore_index=True)

    SQL = """INSERT INTO etf_netvalue (
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
    _save2sqlite(data, SQL)


def _update_fund_etf_daily_one(ids):
    """更新fund日数据"""
    p = Pool(processes=PNUM)
    data = p.map(_get_etf_daily, tqdm(ids))
    p.close()
    p.join()
    data = pd.concat(data, ignore_index=True)

    SQL = """INSERT INTO daily (
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
    _save2sqlite(data, SQL)


def _update_fund_lof_daily_one(ids):
    """更新fund日数据"""
    p = Pool(processes=PNUM)
    data = p.map(_get_lof_daily, tqdm(ids))
    p.close()
    p.join()
    data = pd.concat(data, ignore_index=True)

    SQL = """INSERT INTO daily (
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
    _save2sqlite(data, SQL)


def update_fund_daily():
    """更新fund日数据"""
    logger.info("更新fund-etf日数据")
    ids = _get_fund_ids("ETF")
    for x in split_list_by_n(ids, TMAX):
        _update_fund_etf_daily_one(x)

    logger.info("更新fund-lof日数据")
    ids = _get_fund_ids("LOF")
    for x in split_list_by_n(ids, TMAX):
        _update_fund_lof_daily_one(x)


def update_stock_daily():
    """更新stock日数据"""
    ids = _get_stock_ids()
    i = 0
    for x in split_list_by_n(ids, TMAX):
        logger.info("更新Stock日数据 - %d" % (i,))
        i = i + 1
        _update_stock_daily_one(x)


def update_fund_list():
    """更新fund列表数据"""
    logger.info("更新fund列表数据")
    Flist = [_get_fund_etf, _get_fund_lof]
    data = map(lambda x: x(), tqdm(Flist))
    data = pd.concat(data, ignore_index=True)

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
    _save2sqlite(data, SQL)


def update_stock_list():
    """更新stock列表数据"""
    logger.info("更新stock列表数据")
    Flist = [_get_sh_kc, _get_sh_zb, _get_sz, _get_bj]
    data = map(lambda x: x(), tqdm(Flist))
    data = pd.concat(data, ignore_index=True)

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
    _save2sqlite(data, SQL)


def update_etf_list():
    """更新etf列表数据"""
    logger.info("更新etf列表数据")
    data = _get_etf()

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
    _save2sqlite(data, SQL)


def update_etf_daily():
    """更新fund日数据"""
    logger.info("更新etf日数据")
    ids = _get_etf_ids()
    for x in split_list_by_n(ids, TMAX):
        _update_etf_daily_one(x)


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
