# -*- coding: utf-8 -*-

import logging
import sys
import threading
from datetime import date, datetime, time

from pytdx.hq import TdxHq_API

from stock_utils import dbhelper, helper

from . import get_code_all, process_stocks_data, save_to_db

logger = logging.getLogger(__name__)

MAX_COUNT = 2000


def run(cfg, db, flag):
    """
    """
    logger.info("下载更新分笔成交数据  => %s" %
                datetime.now().strftime("%Y年%m月%d日%H时%M分%S秒"))

    table = "transaction_data_" + date.today().strftime("%Y%m%d")
    if not _create_table(db, table):
        if flag:
            _truncate_table(db, table)
        else:
            return

    code = get_code_all(cfg, db)
    api = TdxHq_API()
    api.connect(cfg.get("app").get("server"), int(cfg.get("app").get("port")))

    handles = []
    for s in helper.split_list(code, 1000):
        data = process_stocks_data(db, api, s, _get_one_stock_data)
        if data is None: continue
        logger.debug("下载数据 => %d行", len(data))
        if len(data) > 0:
            t = threading.Thread(target=save_to_db, args=(db, table, data))
            t.start()
            handles.append(t)

    for t in handles:
        t.join()


def _create_table(db, table):
    sql = "create table %s (like transaction_data INCLUDING ALL);" % table
    return dbhelper.execSQL(db, sql)


def _truncate_table(db, table):
    sql = "TRUNCATE %s;" % table
    return dbhelper.execSQL(db, sql)


def _get_one_stock_data(db, api, stock):
    data = []
    for x in range(0, sys.maxsize, MAX_COUNT):
        _data = api.get_transaction_data(stock[0], stock[1], x, MAX_COUNT)
        if _data is None: break
        for d in _data:
            d["code"] = stock[1]
        data = data + _data
    return data
