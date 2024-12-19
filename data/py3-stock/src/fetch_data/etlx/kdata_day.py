# -*- coding: utf-8 -*-

import logging
import threading
from datetime import date, datetime, timedelta

import baostock as bs

from stock_utils import dbhelper, helper

from . import get_code_bs, process_stocks_data, save_to_db

logger = logging.getLogger(__name__)


def run(cfg, db):
    """
    """
    logger.info("下载更新日k线行情数据  => %s" %
                datetime.now().strftime("%Y年%m月%d日%H时%M分%S秒"))

    code = get_code_bs(cfg, db)
    bs.login()

    handles = []
    for s in helper.split_list(code, 500):
        data = process_stocks_data(db, bs, s, _get_one_stock_data)
        if data is None: continue
        logger.debug("下载数据 => %d行", len(data))
        if len(data) > 0:
            t = threading.Thread(target=save_to_db,
                                 args=(db, "kdata_day", data))
            t.start()
            handles.append(t)

    for t in handles:
        t.join()


def _get_one_stock_data(db, bs, stock):
    lt = _get_kdata_last_date(db, stock)
    fields = "date,code,open,high,low,close,preclose,volume,amount,adjustflag,turn,tradestatus,pctChg,peTTM,pbMRQ,psTTM,pcfNcfTTM,isST"
    rs = bs.query_history_k_data_plus(stock,
                                      fields,
                                      start_date="1999-01-01" if lt == "" else lt,
                                      end_date="",
                                      frequency="d",
                                      adjustflag="3")
    fields = [x.lower() for x in rs.fields]
    data = [dict(zip(fields, x)) for x in rs.data]
    if data is None: return
    data = [x for x in data if x["date"] > lt]
    if len(data) == 0: return
    for d in data:
        d["code"] = d["code"].split(".")[1]
    return data


def _get_kdata_last_date(db, stock):
    sql = "SELECT max(date) FROM kdata_day WHERE code = %s"
    val = dbhelper.getValue(db, sql, stock.split(".")[1])[0]
    if val is None:
        return ""
    else:
        return val.strftime("%Y-%m-%d")
