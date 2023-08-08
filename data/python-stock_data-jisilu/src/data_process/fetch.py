# -*- coding: utf-8 -*-

import logging
import sqlite3
from contextlib import closing
from functools import reduce

from tqdm import tqdm

from data_fetch import (
    get_etf,
    get_etf_detail,
    get_etf_gold,
    get_lof_detail,
    get_lof_i,
    get_lof_s,
    get_qdii_a,
    get_qdii_c,
    get_qdii_detail,
    get_qdii_e,
)

logger = logging.getLogger(__name__)


def _save2sqlite3_(data: list, datad: list, sql: str, sqld: str, db: str = None):
    """存储数据到本地数据库

    参数: data - 待保存列表数据。
    参数: datad - 待保存明细数据。
    参数: sql - 保存列表数据sql语句。
    参数: sqld - 保存明细数据sql语句。
    参数: db - 数据库名，可缺省。
    """
    defaultDB = "data.sqlite"

    if db is None:
        db = defaultDB

    with sqlite3.connect(db) as conn:
        with closing(conn.cursor()) as cur:
            cur.executemany(sql, data)
            print("写入 %d 行列表数据" % (cur.rowcount,))
            cur.executemany(sqld, datad)
            print("写入 %d 行明细数据" % (cur.rowcount,))
            # conn.commit()


def fetch_etf():
    """获取etf数据"""

    (ids1, data1) = get_etf()
    (ids2, data2) = get_etf_gold()

    ids = ids1 + ids2
    dat = reduce(lambda x, id: x + get_etf_detail(id), tqdm(ids, desc="抓取etf数据"), [])
    for x in dat:
        x["idx_incr_rt"] = (
            x["idx_incr_rt"].removesuffix("%") if x["idx_incr_rt"] is not None else "-"
        )
        x["discount_rt"] = (
            x["discount_rt"].removesuffix("%") if x["discount_rt"] is not None else "-"
        )

    for x in data1:
        x["fund_type"] = "ei"
    for x in data2:
        x["fund_type"] = "eg"
    data = data1 + data2

    nd = data[0]["nav_dt"]
    dat = list(filter(lambda x: x["hist_dt"] <= nd, dat))

    SQL = """INSERT INTO fund (
                fund_id,
                fund_name,
                index_name,
                issuer_name,
                fund_type,
                fund_nav,
                fund_nav_date,
                price,
                amount,
                volume,
                total,
                idx_incr_rt
            )
            VALUES (
                :fund_id,
                :fund_nm,
                :index_nm,
                :issuer_nm,
                :fund_type,
                :fund_nav,
                :nav_dt,
                :price,
                :amount,
                :volume,
                :unit_total,
                :index_increase_rt
            )
            ON CONFLICT DO UPDATE SET
                fund_nav = :fund_nav,
                fund_nav_date = :nav_dt,
                price = :price,
                amount = :amount,
                volume = :volume,
                total = :unit_total,
                idx_incr_rt = :index_increase_rt
    """
    SQLd = """INSERT INTO fund_detail (
                fund_id,
                fund_date,
                price,
                fund_nav,
                amount,
                amount_incr,
                idx_incr_rt,
                discount_rt
            )
            VALUES (
                :fund_id,
                :hist_dt,
                :trade_price,
                :fund_nav,
                :amount,
                :amount_incr,
                :idx_incr_rt,
                :discount_rt
            )
            ON CONFLICT DO NOTHING
    """
    _save2sqlite3_(data, dat, SQL, SQLd)


def fetch_qdii():
    """获取qdii数据"""
    (idse, datae) = get_qdii_e()
    (idsc, datac) = get_qdii_c()
    (idsa, dataa) = get_qdii_a()

    ids = idsa + idsc + idse
    dat = reduce(lambda x, id: x + get_qdii_detail(id), tqdm(ids, desc="抓取qdii数据"), [])

    for x in dataa:
        x["fund_type"] = "qa"
    for x in datac:
        x["fund_type"] = "qc"
    for x in datae:
        x["fund_type"] = "qe"
    data = dataa + datac + datae
    for x in data:
        x["ref_increase_rt"] = (
            x["ref_increase_rt"].removesuffix("%")
            if x["ref_increase_rt"] is not None
            else "-"
        )

    SQL = """INSERT INTO fund (
                fund_id,
                fund_name,
                index_name,
                issuer_name,
                fund_type,
                fund_nav,
                fund_nav_date,
                price,
                amount,
                volume,
                idx_incr_rt
            )
            VALUES (
                :fund_id,
                :fund_nm,
                :index_nm,
                :issuer_nm,
                :fund_type,
                :fund_nav,
                :nav_dt,
                :price,
                :amount,
                :volume,
                :ref_increase_rt
            )
            ON CONFLICT DO UPDATE SET
                fund_nav = :fund_nav,
                fund_nav_date = :nav_dt,
                price = :price,
                amount = :amount,
                volume = :volume,
                idx_incr_rt = :ref_increase_rt
    """
    SQLd = """INSERT INTO fund_detail (
                fund_id,
                fund_date,
                price,
                fund_nav,
                amount,
                amount_incr,
                idx_incr_rt,
                discount_rt
            )
            VALUES (
                :fund_id,
                :price_dt,
                :price,
                :net_value,
                :amount,
                :amount_incr,
                :ref_increase_rt,
                :discount_rt
            )
            ON CONFLICT DO NOTHING
    """
    _save2sqlite3_(data, dat, SQL, SQLd)


def fetch_lof():
    """获取lof数据"""
    (idsi, datai) = get_lof_i()
    (idss, datas) = get_lof_s()

    ids = idsi + idss
    dat = reduce(lambda x, id: x + get_lof_detail(id), tqdm(ids, desc="抓取lof数据"), [])

    for x in datai:
        x["fund_type"] = "li"
    for x in datas:
        x["fund_type"] = "ls"
        x["index_increase_rt"] = x["stock_increase_rt"]
        x["index_nm"] = "-"
    data = datai + datas

    SQL = """INSERT INTO fund (
                fund_id,
                fund_name,
                index_name,
                issuer_name,
                fund_type,
                fund_nav,
                fund_nav_date,
                price,
                amount,
                volume,
                idx_incr_rt
            )
            VALUES (
                :fund_id,
                :fund_nm,
                :index_nm,
                :issuer_nm,
                :fund_type,
                :fund_nav,
                :nav_dt,
                :price,
                :amount,
                :volume,
                :index_increase_rt
            )
            ON CONFLICT DO UPDATE SET
                fund_nav = :fund_nav,
                fund_nav_date = :nav_dt,
                price = :price,
                amount = :amount,
                volume = :volume,
                idx_incr_rt = :index_increase_rt
    """
    SQLd = """INSERT INTO fund_detail (
                fund_id,
                fund_date,
                price,
                fund_nav,
                amount,
                amount_incr,
                idx_incr_rt,
                discount_rt
            )
            VALUES (
                :fund_id,
                :price_dt,
                :price,
                :net_value,
                :amount,
                :amount_incr,
                :ref_increase_rt,
                :discount_rt
            )
            ON CONFLICT DO NOTHING
    """
    _save2sqlite3_(data, dat, SQL, SQLd)
