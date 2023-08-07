# -*- coding: utf-8 -*-

import requests
from fake_useragent import UserAgent

ua = UserAgent()
baseUrl = "https://www.jisilu.cn"


def _get_etf_(url: str, keys: tuple = None) -> (list, list):
    """获取etf基金数据

    参数url: API地址url
    参数keys: 过滤输出结果字段
    """
    default_keys = (
        "fund_id",  # 基金代码
        "fund_nm",  # 基金名称
        "index_nm",  # 指数
        "issuer_nm",  # 基金公司
        "fund_nav",  #  基金净值
        "nav_dt",  # 净值日期
        "price",  # 现价/收盘价
        "amount",  # 场内份额(万份)
        "volume",  # 成交额(万元)
        "unit_total",  # 基金规模(亿元)
        "index_increase_rt",  # 指数/重仓涨幅%
    )

    if keys is None:
        keys = default_keys

    r = requests.get(url, headers={"User-Agent": ua.random})
    ds = r.json()["rows"]
    ids = [d["id"] for d in ds]
    res = map(lambda d: {key: d["cell"][key] for key in set(keys)}, ds)
    return (ids, list(res))


def get_etf(keys: tuple = None) -> (list, list):
    """获取指数etf基金列表数据

    参数keys: 过滤输出结果字段
    """
    etf = baseUrl + "/data/etf/etf_list/"
    return _get_etf_(etf, keys)


def get_etf_gold(keys: tuple = None) -> (list, list):
    """获取黄金etf基金列表数据

    参数keys: 过滤输出结果字段
    """
    etf = baseUrl + "/data/etf/gold_list/"
    return _get_etf_(etf, keys)


def get_etf_detail(fund: str, keys: tuple = None) -> list:
    """获取etf基金个股明细数据

    参数fund: 基金代码，例: '588080'
    参数keys: 过滤输出结果字段
    """
    default_keys = (
        "hist_dt",  # 日期
        "trade_price",  # 收盘价
        "fund_nav",  # 基金净值
        "amount",  # 场内份额(万份)
        "amount_incr",  # 场内份额变化(万份)
        "idx_incr_rt",  # 指数涨幅%
        "discount_rt",  # 溢价率%
    )
    etf1d = baseUrl + "/data/etf/detail_hists/"

    if keys is None:
        keys = default_keys

    data = {"is_search": 1, "fund_id": fund}
    r = requests.post(etf1d, headers={"User-Agent": ua.random}, data=data)
    ds = r.json()["rows"]

    def lba(d):
        r = {key: d["cell"][key] for key in set(keys)}
        r["fund_id"] = fund
        return r

    # res = map(lambda d: {key: d["cell"][key] for key in set(keys)}, ds)
    res = map(lba, ds)
    return list(res)


def _get_qdii_(url: str, keys: tuple = None) -> (list, list):
    """获取t+0 qdii基金数据

    参数url: API地址url
    参数keys: 过滤输出结果字段
    """
    default_keys = (
        "fund_id",  # 基金代码
        "fund_nm",  # 基金名称
        "index_nm",  # 指数
        "issuer_nm",  # 基金公司
        "fund_nav",  #  基金净值
        "nav_dt",  # 净值日期
        "price",  # 现价/收盘价
        "amount",  # 场内份额(万份)
        "volume",  # 成交额(万元)
        "ref_increase_rt",  # 指数/重仓涨幅%
    )

    if keys is None:
        keys = default_keys

    r = requests.get(url, headers={"User-Agent": ua.random})
    ds = r.json()["rows"]
    ids = [d["id"] for d in ds]
    res = map(lambda d: {key: d["cell"][key] for key in set(keys)}, ds)
    return (ids, list(res))


def get_qdii_e(keys: tuple = None) -> (list, list):
    """获取t+0 qdii基金欧美数据

    参数keys: 过滤输出结果字段
    """
    qdii = baseUrl + "/data/qdii/qdii_list/E"
    return _get_qdii_(qdii, keys)


def get_qdii_c(keys: tuple = None) -> (list, list):
    """获取t+0 qdii基金欧美商品数据

    参数keys: 过滤输出结果字段
    """
    qdii = baseUrl + "/data/qdii/qdii_list/C"
    return _get_qdii_(qdii, keys)


def get_qdii_a(keys: tuple = None) -> (list, list):
    """获取t+0 qdii基金亚洲数据

    参数keys: 过滤输出结果字段
    """
    qdii = baseUrl + "/data/qdii/qdii_list/A"
    return _get_qdii_(qdii, keys)


def get_qdii_detail(fund: str, keys: tuple = None) -> list:
    """获取t+0 qdii基金个股明细数据

    参数fund: 基金代码，例: '588080'
    参数keys: 过滤输出结果字段，例: ()

    参考: 这是返回结果其中一个片段的完整信息, json格式。
    ```json
        {
            "id": "2023-08-03",
            "cell": {
                "fund_id": "513030",
                "price_dt": "2023-08-03",        -- 价格日期
                "price": "1.234",                -- 收盘价
                "net_value_dt": "2023-08-02",    -- 净值日期
                "net_value": "1.2400",           -- 净值
                "est_val_dt": "2023-08-02",      -- 估值日期
                "est_val": "1.2401",             -- 估值
                "est_val_increase_rt": "-1.03",
                "est_error_rt": "0.01",          -- 估值误差%
                "discount_rt": "-0.48",          -- 溢价率%
                "amount": 40628,                 -- 场内份额(万份)
                "amount_incr": 200,              -- 场内份额变化(万份)
                "amount_increase_rt": "0.490",
                "ref_increase_rt": "-1.36"       -- 指数涨幅%
            }
        }
    ```
    """
    default_keys = (
        "fund_id",  # 基金代码
        "price_dt",  # 日期
        "price",  # 收盘价
        "amount",  # 场内份额(万份)
        "amount_incr",  # 场内份额变化(万份)
        "net_value_dt",  # 净值日期
        "net_value",  # 净值
        "discount_rt",  # 溢价率%
        "ref_increase_rt",  # 指数涨幅%
    )
    qdiid = baseUrl + "/data/qdii/detail_hists/"

    if keys is None:
        keys = default_keys

    data = {"is_search": 1, "fund_id": fund}
    r = requests.post(qdiid, headers={"User-Agent": ua.random}, data=data)
    ds = r.json()["rows"]

    res = map(lambda d: {key: d["cell"][key] for key in set(keys)}, ds)
    return list(res)


def _get_lof_(url: str, keys: tuple) -> (list, list):
    """获取lof基金数据

    参数url: API地址url
    参数keys: 过滤输出结果字段
    """
    r = requests.get(url, headers={"User-Agent": ua.random})
    ds = r.json()["rows"]
    ids = [d["id"] for d in ds]
    res = map(lambda d: {key: d["cell"][key] for key in set(keys)}, ds)
    return (ids, list(res))


def get_lof_s(keys: tuple = None) -> (list, list):
    """获取lof股票基金数据

    参数keys: 过滤输出结果字段
    """
    default_keys = (
        "fund_id",  # 基金代码
        "fund_nm",  # 基金名称
        "issuer_nm",  # 基金公司
        "fund_nav",  #  基金净值
        "nav_dt",  # 净值日期
        "price",  # 现价/收盘价
        "amount",  # 场内份额(万份)
        "volume",  # 成交额(万元)
        "stock_increase_rt",  # 重仓涨幅%
    )
    url = baseUrl + "/data/lof/stock_lof_list/"

    return _get_lof_(url, default_keys)


def get_lof_i(keys: tuple = None) -> (list, list):
    """获取lof指数基金数据

    参数keys: 过滤输出结果字段
    """
    default_keys = (
        "fund_id",  # 基金代码
        "fund_nm",  # 基金名称
        "index_nm",  # 指数
        "issuer_nm",  # 基金公司
        "fund_nav",  #  基金净值
        "nav_dt",  # 净值日期
        "price",  # 现价/收盘价
        "amount",  # 场内份额(万份)
        "volume",  # 成交额(万元)
        "index_increase_rt",  # 指数涨幅%
    )
    url = baseUrl + "/data/lof/index_lof_list/"

    return _get_lof_(url, default_keys)


def get_lof_detail(fund: str, keys: tuple = None) -> list:
    """获取lof基金个股明细数据

    参数fund: 基金代码，例: '588080'
    参数keys: 过滤输出结果字段，例: ()
    """
    default_keys = (
        "fund_id",  # 基金代码
        "price_dt",  # 日期
        "price",  # 收盘价
        "amount",  # 场内份额(万份)
        "amount_incr",  # 场内份额变化(万份)
        "net_value_dt",  # 净值日期
        "net_value",  # 净值
        "discount_rt",  # 溢价率%
        "ref_increase_rt",  # 指数涨幅%
    )

    url = baseUrl + "/data/lof/hist_list/" + fund

    if keys is None:
        keys = default_keys

    r = requests.post(url, headers={"User-Agent": ua.random})
    ds = r.json()["rows"]

    res = map(lambda d: {key: d["cell"][key] for key in set(keys)}, ds)
    return list(res)
