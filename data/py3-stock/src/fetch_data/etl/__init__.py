# -*- coding: utf-8 -*-

import logging
from datetime import date, datetime

from stock_utils import dbhelper, helper

logger = logging.getLogger(__name__)


def get_code_bs(cfg, db):
    """返回股票基本信息, 用于baostock
    """
    _data = dbhelper.select_into_dict(db, "SELECT code FROM stock_basic")
    return [x["code"] for x in _data]


def get_code_all(cfg, db):
    """返回股票代码
    """
    main = _get_code_inner(cfg, db, "主板")
    zxb = _get_code_inner(cfg, db, "中小板")
    cyb = _get_code_inner(cfg, db, "创业板")
    kcb = _get_code_inner(cfg, db, "科创板")

    return cyb + kcb + zxb + main


def get_code(cfg, db):
    """返回股票代码
    """
    main = _get_code_inner(cfg, db, "主板")
    zxb = _get_code_inner(cfg, db, "中小板")
    cyb = _get_code_inner(cfg, db, "创业板")
    kcb = _get_code_inner(cfg, db, "科创板")

    return (main, zxb, cyb, kcb)


def _get_code_inner(cfg, db, market):
    """返回股票基本信息
    """
    sql = "SELECT code FROM stock_basic WHERE market = %s"
    _data = dbhelper.select_into_dict(db, sql, market)
    return [(0 if x["code"].split(".")[0] == "sz" else 1, x["code"].split(".")[1]) for x in _data]
