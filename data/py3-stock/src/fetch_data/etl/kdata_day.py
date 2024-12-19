# -*- coding: utf-8 -*-

import logging
from datetime import date, datetime, timedelta

import baostock as bs

from stock_utils import dbhelper, helper

from . import get_code_bs

logger = logging.getLogger(__name__)


def run(cfg, db):
    """
    """
    logger.info("下载更新日k线行情数据  => %s" %
                datetime.now().strftime("%Y年%m月%d日%H时%M分%S秒"))

    bs.login()
    for s in get_code_bs(cfg, db):
        data = _kdata(db, bs, s)
        if data is None: continue
        logger.info(
            "%s => %s, %d行", s,
            helper.bool_to_str(
                dbhelper.insert_dict_into_table(db, "kdata_day", data)),
            len(data))


def _kdata(db, bs, stock):
    lt = _get_kdata_last_date(db, stock)
    fields = "date,code,open,high,low,close,preclose,volume,amount,adjustflag,turn,tradestatus,pctChg,peTTM,pbMRQ,psTTM,pcfNcfTTM,isST"
    rs = bs.query_history_k_data_plus(stock,
                                      fields,
                                      start_date="1999-01-01",
                                      end_date="",
                                      frequency="d",
                                      adjustflag="3")
    fields = [x.lower() for x in rs.fields]
    data = [dict(zip(fields, x)) for x in rs.data]
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
