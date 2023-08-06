# -*- coding: utf-8 -*-

import logging
import sqlite3
from contextlib import closing
from functools import reduce

from cleo.commands.command import Command
from cleo.helpers import argument, option
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


class FetchCommand(Command):
    name = "fetch"
    description = "抓取股票列表数据"
    arguments = []
    options = []

    def handle(self):
        fetch_etf()
        if self.option("show"):
            """显示"""
            # logger.info("%s" % (data,))
            # print(ids)


def fetch_etf():
    """获取etf数据"""
    SQL = """INSERT INTO etf (
                fund_id,
                fund_nm,
                index_nm,
                issuer_nm
            )
            VALUES (
                :fund_id,
                :fund_nm,
                :index_nm,
                :issuer_nm
            )
            ON CONFLICT DO NOTHING
    """
    SQLd = """INSERT INTO etf_detail (
                        fund_id,
                        hist_dt,
                        amount,
                        amount_incr,
                        fund_nav,
                        trade_price
                    )
                    VALUES (
                        :fund_id,
                        :hist_dt,
                        :amount,
                        :amount_incr,
                        :fund_nav,
                        :trade_price
                    )
                    ON CONFLICT DO NOTHING
    """
    DB = "data.sqlite"
    (ids, data) = get_etf()
    dat = reduce(
        lambda x, id: x + get_etf_detail(id), tqdm(ids, desc="抓取数据", unit="项"), []
    )

    with sqlite3.connect(DB) as conn:
        with closing(conn.cursor()) as cur:
            cur.executemany(SQL, data)
            print("写入 %d 行etf数据" % (cur.rowcount,))
            cur.executemany(SQLd, dat)
            print("写入 %d 行etf明细数据" % (cur.rowcount,))
            # conn.commit()


def fetch_qdii():
    """获取qdii数据"""


def fetch_lof():
    """获取lof数据"""
