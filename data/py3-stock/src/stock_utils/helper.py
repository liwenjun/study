# -*- coding: utf-8 -*-

import logging

import sys
import os
import os.path
import traceback
import time
from datetime import date, datetime, timedelta
from pathlib import Path

logger = logging.getLogger(__name__)


# 将一个list尽量均分，前面可以分n个时则每份为n个，直到分不下为止，不限制len(list)
def split_list(listTemp: list, n: int):
    """
    """
    for i in range(0, len(listTemp), n):
        yield listTemp[i:i + n]


# 将一个list尽量均分成n份，限制len(list)==n，份数大于原list内元素个数则分配空list[]
def split_listn(listTemp, n):
    """
    """
    twoList = [[] for i in range(n)]
    for i, e in enumerate(listTemp):
        twoList[i % n].append(e)
    return twoList


def clock_to_time(c) -> str:
    """
    """
    if int(c) == 0:
        return ""
    else:
        return datetime.fromtimestamp(int(c)).strftime("%Y年%m月%d日 %H:%M:%S")


def clock_to_hour(c, tz: int = 0) -> int:
    """tz 时区偏移值
    """
    if int(c) == 0:
        return 0
    else:
        return int(datetime.fromtimestamp(int(c) + tz * 3600).strftime("%H"))


def make_path(base: str, sp: str) -> str:
    """创建子文件夹
    """
    out = os.path.join(base, sp)

    p = Path(out)
    if not p.exists():
        try:
            p.mkdir(parents=True, exist_ok=True)
        except:
            logger.error('创建输出文件夹 %s 出错，程序异常退出！' % out)
            exit(1)

    return out


def make_day_path(base: str, day: str) -> str:
    """创建日期文件夹
    """
    return make_path(base, day.replace("-", ""))


def singleton(cls):
    _instances = {}

    def wrapper(*args, **kwargs):
        if cls not in _instances:
            _instances[cls] = cls(*args, **kwargs)
        return _instances[cls]

    return wrapper


## == 以下可用 ====================


def yesterday() -> date:
    return date.today() - timedelta(days=1)


def yesterday_str(fmt: str = None) -> str:
    return yesterday().strftime(
        "%Y-%m-%d") if fmt is None else yesterday().strftime(fmt)


def lasterror() -> str:
    """记录最近发生的错误日志
    """
    #(type, value, traceback)
    exc_type, exc_value, _ = sys.exc_info()
    return "\n\t类型: %s\n\t信息: %s" % (exc_type, exc_value)


def flat_list_dict(data, dataname, idname):
    """扁平化嵌套列表字典
    """
    result = []
    for h in data:
        for d in h[dataname]:
            d[idname] = h[idname]
        result = result + h[dataname]
    return result


def bool_to_str(b: bool) -> str:
    return "成功" if b else "失败"


def time_from(day: str = None) -> int:
    """一天的起始秒，用于获取历史数据和趋势数据
    """
    if day is None:
        _day = yesterday()
    else:
        # _day = date.fromisoformat(day)  # python-3.6.8不支持
        _day = datetime.strptime(day, "%Y-%m-%d").date()  # python-3.6.8

    #return int(datetime.combine(day, time(0, 0, 0)).timestamp())
    return int(time.mktime(_day.timetuple()))


def startsin(key: str, alist: list) -> bool:
    """判断key的起始串是否在alist中，使用startswith
    """
    for x in alist:
        if key.startswith(x): return True
    return False
