# -*- coding: utf-8 -*-

import logging
from datetime import date, datetime

import tushare as ts

from stock_utils import dbhelper, helper

logger = logging.getLogger(__name__)


def run(cfg, db):
    """返回股票
    """
    logger.info("下载更新股票基础数据 => %s" %
                datetime.now().strftime("%Y年%m月%d日%H时%M分%S秒"))

    (_basic, _company) = _get_basic(cfg, db)

    token = '3eca2d2172110e537cdb74242105a1ba412bee6277a0133d3277a46b'
    pro = ts.pro_api(token)

    # 查询当前所有正常上市交易的股票列表
    basic = pro.stock_basic(
        exchange='',
        list_status='L',
        fields=
        'ts_code,symbol,name,area,industry,fullname,enname,market,exchange,curr_type,list_status,list_date,is_hs'
    ).to_dict(orient='records')
    for d in basic:
        d["code"] = d["ts_code"].split(
            ".")[1].lower() + "." + d["ts_code"].split(".")[0]
    # 排除已有库存数据
    basic = [x for x in basic if x["code"] not in _basic]
    if len(basic) > 0:
        logger.info(
            "入库股票基本信息 => %s, %d行",
            helper.bool_to_str(
                dbhelper.insert_dict_into_table(db, "stock_basic", basic)),
            len(basic))

    code = [x["code"] for x in basic]

    # 上市公司基本信息
    qlist = ['SSE', 'SZSE']
    company = []
    for q in qlist:
        _data = pro.stock_company(
            exchange=q,
            fields=
            'ts_code,exchange,chairman,manager,secretary,reg_capital,setup_date,province,city,introduction,website,email,office,employees,main_business,business_scope'
        ).to_dict(orient='records')
        for d in _data:
            d["code"] = d["ts_code"].split(".")[0]
        company = company + _data

    # 排除已有库存数据
    company = [x for x in company if x["code"] not in _company]
    if len(company) > 0:
        logger.info(
            "入库上市公司信息 => %s, %d行",
            helper.bool_to_str(
                dbhelper.insert_dict_into_table(db, "stock_company", company)),
            len(company))

    return code


def _get_basic(cfg, db):
    """返回股票基本信息
    """
    basic = dbhelper.select_into_dict(db, "SELECT code FROM stock_basic")
    company = dbhelper.select_into_dict(db, "SELECT code FROM stock_company")

    code = [x["code"] for x in basic]
    codec = [x["code"] for x in company]

    logger.debug("库存 basic, company => %d %d" % (len(code), len(codec)))

    return (code, codec)
