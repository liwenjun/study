# -*- coding: utf-8 -*-

"""数据抓取模块

通过request抓取集思录网站提供的股票数据。
"""

__author__ = "李文军"
__email__ = "liwenjun@21cn.cn"


from .api import (
    get_etf,
    get_etf_gold,
    get_etf_detail,
    get_qdii_e,
    get_qdii_c,
    get_qdii_a,
    get_qdii_detail,
    get_lof_s,
    get_lof_i,
    get_lof_detail,
)
