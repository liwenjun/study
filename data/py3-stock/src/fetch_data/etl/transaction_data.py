# -*- coding: utf-8 -*-

import logging
import sys
from datetime import date, datetime, time

from pytdx.hq import TdxHq_API
from pytdx.params import TDXParams

from stock_utils import dbhelper, helper

from . import get_code_all

logger = logging.getLogger(__name__)

MAX_COUNT = 2000


def run(cfg, db):
    """
    """
    logger.info("下载更新分笔成交数据  => %s" %
                datetime.now().strftime("%Y年%m月%d日%H时%M分%S秒"))

    code = get_code_all(cfg, db)

    table = "transaction_data_" + date.today().strftime("%Y%m%d")
    sql = "create table IF NOT EXISTS %s (like transaction_data INCLUDING ALL);" % table
    dbhelper.execSQL(db, sql)

    api = TdxHq_API()
    api.connect('47.103.48.45', 7709)

    for s in code:
        data = _tdata(db, api, s, table)
        if len(data) == 0: continue
        logger.info(
            "%s => %s, %d行", s,
            helper.bool_to_str(
                dbhelper.insert_dict_into_table(db, table, data)),
            len(data))


#查询分笔成交
#参数：市场代码， 股票代码，起始位置， 数量 如： 0,000001,0,10
#api.get_transaction_data(TDXParams.MARKET_SZ, '000961', 2000, 10000))
def _tdata(db, api, stock, table):
    lt = _get_tdata_last_time(db, stock, table)
    data = []
    for x in range(0, sys.maxsize, MAX_COUNT):
        _data = api.get_transaction_data(stock[0], stock[1], x, MAX_COUNT)
        if _data is None: break
        for d in _data:
            d["code"] = stock[1]
        # 过滤已有数据
        _data = [x for x in _data if x["time"] > lt]
        if len(_data) == 0: break
        data = data + _data
    return data


def _get_tdata_last_time(db, stock, table):
    sql = "SELECT max(time) FROM %s WHERE code = '%s'" % (table, stock[1])
    val = dbhelper.getValue(db, sql)[0]
    if val is None:
        return ""
    else:
        return val
