# coding: utf-8

import datetime
import logging
import sqlite3
from contextlib import closing

import akshare as ak
import pandas as pd

logger = logging.getLogger(__name__)


def _save2sqlite3_(data: list, datad: list, sql: str, sqld: str, db: str = None):
    """存储数据到本地数据库

    参数: data - 待保存列表数据。
    参数: datad - 待保存明细数据。
    参数: sql - 保存列表数据sql语句。
    参数: sqld - 保存明细数据sql语句。
    参数: db - 数据库名，可缺省。
    """
    defaultDB = "./data/data.sqlite"

    if db is None:
        db = defaultDB

    with sqlite3.connect(db) as conn:
        with closing(conn.cursor()) as cur:
            cur.executemany(sql, data)
            print("写入 %d 行列表数据" % (cur.rowcount,))
            cur.executemany(sqld, datad)
            print("写入 %d 行明细数据" % (cur.rowcount,))
            # conn.commit()


def get_stock_list():
    """获取股票列表数据"""

    def _get_sh_():
        """获取上证数据"""
        df_shzb = ak.stock_info_sh_name_code(symbol="主板A股")
        df_shzb["板块"] = "主板"
        df_shkc = ak.stock_info_sh_name_code(symbol="科创板")
        df_shkc["板块"] = "科创板"

        df_sha = pd.concat([df_shzb, df_shkc], ignore_index=True)
        df_sha.drop(columns="公司全称", inplace=True)
        df_sha["交易所"] = "SH"

        return df_sha

    def _get_sz_():
        """获取深证数据"""
        df_sza = ak.stock_info_sz_name_code(symbol="A股列表")
        df_sza.drop(columns=["A股总股本", "A股流通股本", "所属行业"], inplace=True)
        df_sza["交易所"] = "SZ"
        df_sza = df_sza.rename(
            columns={"A股代码": "证券代码", "A股简称": "证券简称", "A股上市日期": "上市日期"}
        )

        return df_sza

    def _get_bj_():
        """获取北证数据"""
        df_bja = ak.stock_info_bj_name_code()
        df_bja.drop(columns=["总股本", "流通股本", "所属行业", "地区", "报告日期"], inplace=True)
        df_bja["交易所"] = "BJ"
        df_bja["板块"] = "新三板"

        return df_bja

    bj = _get_bj_()
    sz = _get_sz_()
    sh = _get_sh_()

    return pd.concat([sh, sz, bj], ignore_index=True)


def get_stock_daily(symbol, start=None):
    """历史行情数据-前复权

    参数: symbol - 证券代码
    参数: start  - 起始日期
    """
    if start is None:
        start = "19901201"

    df = ak.stock_zh_a_hist(
        symbol=symbol,  # "000001"
        period="daily",
        start_date=start,  # "19901201"
        end_date=datetime.date.today().strftime("%Y%m%d"),  # 当天
        adjust="qfq",
    )
    df["证券代码"] = symbol
    return df


def fetch_stock():
    """获取stock数据"""
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
    SQLd = """INSERT INTO stock_daily (
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
    data = get_stock_list().to_dict(orient="records")
    # df.to_dict(orient="records")
    dat = get_stock_daily("300159", "20230101").to_dict(orient="records")

    _save2sqlite3_(data, dat, SQL, SQLd)


def get_etf_daily(symbol, start=None):
    """etf基金历史行情数据-前复权, 合并净值数据

    参数: symbol - 代码
    参数: start  - 起始日期
    """
    if start is None:
        start = "19901201"

    df = ak.fund_etf_hist_em(
        symbol=symbol,  # "000001"
        period="daily",
        start_date=start,  # "19901201"
        end_date=datetime.date.today().strftime("%Y%m%d"),  # 当天
        adjust="qfq",
    )
    df["代码"] = symbol

    df_his = ak.fund_etf_fund_info_em(
        fund=symbol, start_date=start, end_date=datetime.date.today().strftime("%Y%m%d")
    )
    df_his.drop(columns=["申购状态", "赎回状态"], inplace=True)
    df_his = df_his.rename(columns={"净值日期": "日期"})

    df = pd.merge(df, df_his, how="left", on="日期")
    return df


def get_lof_daily(symbol, start=None):
    """lof基金历史行情数据-前复权

    参数: symbol - 代码
    参数: start  - 起始日期
    """
    if start is None:
        start = "19901201"

    df = ak.fund_lof_hist_em(
        symbol=symbol,  # "000001"
        period="daily",
        start_date=start,  # "19901201"
        end_date=datetime.date.today().strftime("%Y%m%d"),  # 当天
        adjust="qfq",
    )
    df["代码"] = symbol
    return df


def get_fund_list():
    """获取基金实时行情-东财, 合并基金类型"""
    df_etf = ak.fund_etf_spot_em()
    df_etf["类别"] = "ETF"
    df_lof = ak.fund_lof_spot_em()
    df_lof["类别"] = "LOF"
    etf = df_etf["代码"].tolist()
    lof = df_lof["代码"].tolist()

    df_fund = pd.concat([df_etf, df_lof], ignore_index=True)
    df_in = ak.fund_etf_fund_daily_em()
    df_in = df_in[["基金代码", "类型"]]
    df_in = df_in.rename(columns={"基金代码": "代码"})

    df = pd.merge(df_fund, df_in, how="left", on="代码")

    return (etf, lof), df
