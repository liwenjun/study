# -*- coding: utf-8 -*-

import logging
import sys
from datetime import date, datetime, timedelta

from pytdx.hq import TdxHq_API
from pytdx.params import TDXParams

from stock_utils import dbhelper, helper

from . import get_code_all

logger = logging.getLogger(__name__)

MAX_COUNT = 800


def run(cfg, db):
    """
    """
    logger.info("下载更新1分钟行情数据  => %s" %
                datetime.now().strftime("%Y年%m月%d日%H时%M分%S秒"))

    code = get_code_all(cfg, db)

    api = TdxHq_API()
    api.connect('47.103.48.45', 7709)
    for s in code:
        data = _kdata(db, api, s)
        if len(data) == 0: continue
        logger.info(
            "%s => %s, %d行", s,
            helper.bool_to_str(
                dbhelper.insert_dict_into_table(db, "kdata_min", data)),
            len(data))


# category-> 0 5分钟K线 1 15分钟K线 2 30分钟K线 3 1小时K线 4 日K线 5 周K线 6 月K线
#            7 1分钟 8 1分钟K线 9 日K线 10 季K线 11 年K线
# market -> 市场代码 0:深圳，1:上海
# stockcode -> 证券代码;
# start -> 指定的范围开始位置;
# count -> 用户要请求的 K 线数目，最大值为 800
def _kdata(db, api, stock):
    lt = _get_kdata_last_datetime(db, stock)
    data = []
    for x in range(0, sys.maxsize, MAX_COUNT):
        _data = api.get_security_bars(7, stock[0], stock[1], x, MAX_COUNT)
        if _data is None: break
        # 过滤已有数据
        _data = [x for x in _data if x["datetime"] > lt]
        if len(_data) == 0: break
        data = data + _data
    if len(data) > 0:
        for d in data:
            d["code"] = stock[1]
    return data


def _get_kdata_last_datetime(db, stock):
    sql = "SELECT max(datetime) FROM kdata_min WHERE code = %s"
    val = dbhelper.getValue(db, sql, stock[1])[0]
    if val is None:
        return ""
    else:
        return val.strftime("%Y-%m-%d %H:%M")
