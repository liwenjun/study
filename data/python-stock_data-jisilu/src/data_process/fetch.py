# -*- coding: utf-8 -*-

import logging
import sqlite3
from contextlib import closing
from functools import reduce

from tqdm import tqdm

from data_fetch import (
    get_etf,
    get_etf_detail,
    get_lof,
    get_lof_detail,
    get_qdii,
    get_qdii_detail,
)

logger = logging.getLogger(__name__)


def fetch_etf():
    """获取etf数据"""
    SQL = """INSERT INTO etf (
                    fund_id,
                    fund_nm,
                    index_nm,
                    issuer_nm,
                    amount,
                    unit_total,
                    unit_incr,
                    volume,
                    idx_price_dt
                )
                VALUES (
                    :fund_id,
                    :fund_nm,
                    :index_nm,
                    :issuer_nm,
                    :amount,
                    :unit_total,
                    :unit_incr,
                    :volume,
                    :idx_price_dt
                )
            ON CONFLICT DO UPDATE SET
                amount = :amount,
                unit_total = :unit_total,
                unit_incr = :unit_incr,
                volume = :volume,
                idx_price_dt = :idx_price_dt
    """
    SQLd = """INSERT INTO etf_detail (
                           fund_id,
                           hist_dt,
                           amount,
                           amount_incr,
                           idx_incr_rt,
                           fund_nav,
                           trade_price
                       )
                       VALUES (
                           :fund_id,
                           :hist_dt,
                           :amount,
                           :amount_incr,
                           :idx_incr_rt,
                           :fund_nav,
                           :trade_price
                       )
                    ON CONFLICT DO UPDATE SET
                        amount = :amount,
                        amount_incr = :amount_incr,
                        idx_incr_rt = :idx_incr_rt,
                        fund_nav = :fund_nav,
                        trade_price = :trade_price
    """
    SQLa = """INSERT INTO etf_detail (
                           fund_id,
                           hist_dt,
                           unit_total,
                           unit_incr,
                           volume
                       )
                       VALUES (
                           :fund_id,
                           :idx_price_dt,
                           :unit_total,
                           :unit_incr,
                           :volume
                       )
                    ON CONFLICT DO UPDATE SET
                        unit_total = :unit_total,
                        unit_incr = :unit_incr,
                        volume = :volume
    """
    DB = "data.sqlite"
    (ids, data) = get_etf()
    dat = reduce(
        lambda x, id: x + get_etf_detail(id), tqdm(ids[:10], desc="抓取etf数据"), []
    )

    with sqlite3.connect(DB) as conn:
        with closing(conn.cursor()) as cur:
            cur.executemany(SQL, data)
            print("写入 %d 行etf数据" % (cur.rowcount,))
            cur.executemany(SQLd, dat)
            print("写入 %d 行etf明细数据" % (cur.rowcount,))
            fdata = filter(lambda d: d['idx_price_dt'] is not None, data)
            cur.executemany(SQLa, fdata)
            print("更新 %d 行etf明细数据" % (cur.rowcount,))
            # conn.commit()


def fetch_qdii():
    """获取qdii数据"""
    SQL = """INSERT INTO qdii (
                     fund_id,
                     fund_nm,
                     index_nm,
                     issuer_nm,
                     qtype,
                     amount,
                     volume,
                     stock_volume,
                     price_dt
                 )
                 VALUES (
                     :fund_id,
                     :fund_nm,
                     :index_nm,
                     :issuer_nm,
                     :qtype,
                     :amount,
                     :volume,
                     :stock_volume,
                     :price_dt
                 )
            ON CONFLICT DO UPDATE SET
                amount = :amount,
                volume = :volume,
                stock_volume = :stock_volume,
                price_dt = :price_dt
    """
    SQLd = """INSERT INTO qdii_detail (
                            fund_id,
                            price_dt,
                            price,
                            net_value_dt,
                            net_value,
                            discount_rt,
                            amount,
                            amount_incr,
                            ref_increase_rt
                        )
                        VALUES (
                            :fund_id,
                            :price_dt,
                            :price,
                            :net_value_dt,
                            :net_value,
                            :discount_rt,
                            :amount,
                            :amount_incr,
                            :ref_increase_rt
                        )
                    ON CONFLICT DO UPDATE SET
                        price = :price,
                        net_value_dt = :net_value_dt,
                        net_value = :net_value,
                        discount_rt = :discount_rt,
                        amount = :amount,
                        amount_incr = :amount_incr,
                        ref_increase_rt = :ref_increase_rt
    """
    SQLa = """INSERT INTO qdii_detail (
                            fund_id,
                            price_dt,
                            volume,
                            stock_volume
                        )
                        VALUES (
                            :fund_id,
                            :price_dt,
                            :volume,
                            :stock_volume
                        )
                    ON CONFLICT DO UPDATE SET
                        volume = :volume,
                        stock_volume = :stock_volume
    """
    DB = "data.sqlite"
    (ids, data) = get_qdii()
    dat = reduce(
        lambda x, id: x + get_qdii_detail(id), tqdm(ids[:10], desc="抓取qdii数据"), []
    )

    with sqlite3.connect(DB, isolation_level=None) as conn:
        with closing(conn.cursor()) as cur:
            cur.executemany(SQL, data)
            print("写入 %d 行qdii数据" % (cur.rowcount,))
            cur.executemany(SQLd, dat)
            print("写入 %d 行qdii明细数据" % (cur.rowcount,))
            cur.executemany(SQLa, data)
            print("更新 %d 行qdii明细数据" % (cur.rowcount,))
            # conn.commit()


def fetch_lof():
    """获取lof数据"""
