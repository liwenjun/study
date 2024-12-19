# -*- coding: utf-8 -*-

import logging
import os
import sqlite3
import sys

from .helper import lasterror, time_from, yesterday_str

logger = logging.getLogger(__name__)

# == Postgresql =========================


def getValue(db, sql: str, *args):
    """返回一个值
    """
    c = db.cursor()
    try:
        c.execute(sql, args)
        return c.fetchone()
    except:
        db.rollback()
        logger.warn("getValue => 错误%s" % lasterror())
        return None


def execSQL(db, sql: str, *args):
    """
    """
    c = db.cursor()
    try:
        c.execute(sql, args)
        db.commit()
        return True
    except:
        db.rollback()
        logger.warn("execSQL => 错误%s" % lasterror())
        return False

def select_into_dict(db, sql: str, *args):
    """返回列表[字典]类型的查询结果
    """
    c = db.cursor()
    try:
        c.execute(sql, args)
        colname_list = [tup[0] for tup in c.description]
        data = c.fetchall()
        return [dict(zip(colname_list, x)) for x in data]
    except:
        db.rollback()
        logger.warn("select_into_dict => 错误%s" % lasterror())
        return None


def select_table_into_dict(db, table: str, vid: int = None):
    """返回列表[字典]类型的查询结果，如有vid，则按vid过滤
    """
    c = db.cursor()
    sql = "SELECT * FROM {}".format(
        table) if vid is None else "SELECT * FROM {} WHERE vid = {}".format(
            table, vid)
    try:
        c.execute(sql)
        colname_list = [tup[0] for tup in c.description]
        data = c.fetchall()
        return [dict(zip(colname_list, x)) for x in data]
    except:
        db.rollback()
        logger.warn("select_table_into_dict => 错误%s" % lasterror())
        return None


def insert_dict_into_table(db, table: str, data: list, v=None) -> bool:
    """将列表[字典]类型数据data插入到数据库db的表table中，
    如果存在v，则自动在Insert语句中加入vid列。
    """
    if (data is None) or (len(data) == 0):
        logger.warn("insert_dict_into_table 无数据调用 => %s" % table)
        return False

    # 获取表的列名
    c = db.cursor()
    try:
        c.execute("SELECT * FROM {}".format(table))
        col_name_list = [tup[0] for tup in c.description]
        keys = [x for x in col_name_list if x in data[0].keys()]
        #logger.debug("keys => %s" % keys)
    except:
        db.rollback()
        logger.warn("insert_dict_into_table 表不存在 => %s" % table)
        return False

    # 转换表列数据为元组格式
    values = [tuple(x[k] for k in keys) for x in data]
    #logger.debug("values => %s" % values)

    # 检查添加vid列和数据
    if v is not None:
        keys.append('vid')
        values = [x + (v[0], ) for x in values]
        #logger.debug("values => %s" % values)

    # 生成Insert语句
    sql = "INSERT INTO {} ({}) VALUES ({})".format(
        table, ",".join(keys), ",".join(["%s"] * len(keys)))
    logger.debug("生成SQL语句 => %s" % sql)

    # 执行数据库操作
    try:
        c.executemany(sql, values)
        db.commit()
        return True
    except:
        logger.error("insert_dict_into_table 执行数据库操作出错%s" % lasterror())
        db.rollback()
        return False


# == SQLite3  =========================


def sqlite_execSQL(db: sqlite3.Connection, sql: str, *args):
    """
    """
    c = db.cursor()
    try:
        c.execute(sql, args)
        db.commit()
    except:
        db.rollback()
        logger.warn("execSQL => 错误%s" % lasterror())


def sqlite_select_into_dict(db: sqlite3.Connection, sql: str, *args):
    """返回列表[字典]类型的查询结果
    """
    c = db.cursor()
    try:
        c.execute(sql, args)
        return [dict(row) for row in c.fetchall()]
    except:
        db.rollback()
        logger.warn("select_into_dict => 错误%s" % lasterror())
        return None


def sqlite_select_table_into_dict(db: sqlite3.Connection, table: str):
    """返回列表[字典]类型的查询结果
    """
    c = db.cursor()
    try:
        c.execute("SELECT * FROM {}".format(table))
        return [dict(row) for row in c.fetchall()]
    except:
        db.rollback()
        logger.warn("select_table_into_dict => 错误%s" % lasterror())
        return None


def sqlite_insert_dict_into_table(db: sqlite3.Connection, table: str,
                                  data: list):
    """将列表[字典]类型数据data插入到数据库db的表table中
    """
    if (data is None) or (len(data) == 0):
        logger.warn("sqlite_insert_dict_into_table 无数据调用 => %s" % table)
        return False

    c = db.cursor()
    try:
        c.execute("SELECT * FROM {}".format(table))
        col_name_list = [tup[0] for tup in c.description]
        my_keys = [x for x in col_name_list if x in data[0].keys()]
    except:
        db.rollback()
        logger.warn("insert_dict_into_table 表不存在 => %s" % table)
        return False

    values = [tuple(x[k] for k in my_keys) for x in data]

    sql = "INSERT INTO {} ({}) VALUES ({})".format(
        table, ",".join(my_keys), ",".join(["?"] * len(my_keys)))
    logger.debug("sql => %s" % sql)

    # 执行数据库操作
    try:
        c.executemany(sql, values)
        db.commit()
        return True
    except:
        logger.error("insert_dict_into_table 执行数据库操作出错%s" % lasterror())
        db.rollback()
        return False


def openMemSQLite(scripts: str,
                  create: bool = False,
                  test: bool = False) -> sqlite3.Connection:
    """打开内存数据库
	"""
    if test:
        conn = sqlite3.connect("/tmp/test_mem.db")
    else:
        conn = sqlite3.connect(":memory:")
        conn.isolation_level = None

    if create:
        #_createMemSQLiteDB(conn)
        c = conn.cursor()
        try:
            c.executescript(scripts)
            conn.commit()
        except:
            conn.rollback()
        logger.debug("Created Memory SQLite")

    conn.row_factory = sqlite3.Row
    return conn


def _createMemSQLiteDB(conn: sqlite3.Connection):
    c = conn.cursor()
    c.executescript(load_script("sqlite3.mem.sql"))
    conn.commit()
    logger.debug("Created Memory SQLite")


def load_script(f: str) -> str:
    """加载数据库脚本
    """
    import zabbix_etl
    fp = os.path.join(os.path.dirname(zabbix_etl.__file__), f)
    return open(fp, 'rt').read()
