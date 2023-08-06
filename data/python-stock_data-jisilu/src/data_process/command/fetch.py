# -*- coding: utf-8 -*-

import logging
import sqlite3
from contextlib import closing
from functools import reduce

from cleo.commands.command import Command
from cleo.helpers import argument, option
from tqdm import tqdm

from data_fetch import get_etf, get_etf_detail

logger = logging.getLogger(__name__)


class FetchCommand(Command):
    name = "fetch"
    description = "抓取股票列表数据"
    arguments = []
    options = []

    def handle(self):
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

        if self.option("show"):
            # logger.info("%s" % (data,))
            print(ids)
