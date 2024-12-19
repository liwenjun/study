# -*- coding: utf-8 -*-

import logging
import sys

from datetime import date, datetime
from stock_utils import helper, dbhelper, setting

from .etlx import (basic, kdata_min, kdata_day, transaction_data)

logger = logging.getLogger(__name__)


def run(cfg: setting.SETTING):
    """主函数入口
    """
    db = get_dbconn(cfg)
    code = basic.run(cfg, db)
    db.close()


def run_kdata(cfg: setting.SETTING):
    """主函数入口
    """
    db = get_dbconn(cfg)
    kdata_day.run(cfg, db)
    db.close()


def run_minute(cfg: setting.SETTING):
    db = get_dbconn(cfg)
    kdata_min.run(cfg, db)
    db.close()


def run_transaction(cfg: setting.SETTING, flag):
    db = get_dbconn(cfg)
    transaction_data.run(cfg, db, flag)
    db.close()


def get_dbconn(cfg):
    """获取数据库连接
    """
    import psycopg2
    try:
        conn = psycopg2.connect(cfg.get("app").get("db_url"))
        return conn
    except:
        logger.error("连接数据库出错，程序退出！%s" % helper.lasterror())
        sys.exit(1)
