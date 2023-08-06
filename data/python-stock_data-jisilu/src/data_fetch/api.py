# -*- coding: utf-8 -*-

import requests
from fake_useragent import UserAgent

ua = UserAgent()
baseUrl = "https://www.jisilu.cn"


def get_etf_detail(fund: str, keys: tuple = None) -> list:
    """获取etf基金个股明细数据

    参数fund: 基金代码，例: '588080'
    参数keys: 过滤输出结果字段，例: ()

    参考: 这是返回结果其中一个片段的完整信息, json格式。
    ```json
        {
            "id": "2023-08-04",
            "cell": {
                "hist_dt": "2023-08-04",        -- 日期
                "estimate_value": "0.9939",
                "estimate_diff": "-0.01",
                "trade_price": "0.9940",        -- 收盘价
                "fund_nav": "0.9938",           -- 净值
                "discount_rt": "0.02%",         -- 溢价率%
                "idx_incr_rt": "0.20%",         -- 指数涨幅%
                "amount": 2616463,              -- 场内份额(万份)
                "amount_incr": 21300,           -- 场内份额变化(万份)
                "increase_rt": "0.82",          -- 份额涨幅%
                "notes": null,
                "idx_pb": "-",
                "idx_pe": "-"
            }
        }
    ```
    """
    default_keys = ("hist_dt", "amount", "amount_incr", "fund_nav", "trade_price")
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


def get_etf(keys: tuple = None) -> (list, list):
    """获取指数etf基金列表数据

    参数keys: 过滤输出结果字段，例: ('fund_id','fund_nm','index_nm','issuer_nm','amount','unit_total','unit_incr')

    参考: 这是返回结果其中一个个股的完整信息, json格式。
    ```json
        {
            "id": "159601",
            "cell": {
                "fund_id": "159601",      -- 基金代码
                "fund_nm": "A50",         -- 基金名称
                "index_id": "-",
                "fee": "0.60",
                "m_fee": "0.50",
                "t_fee": "0.10",
                "creation_unit": 260,
                "issuer_nm": "华夏基金",  -- 基金公司
                "urls": "https:\/\/www.chinaamc.com\/fund\/159601\/index.shtml",
                "eval_flg": "Y",
                "ex_dt": null,
                "ex_info": null,
                "amount": 484359,               -- 基金份额(万份)
                "amount_notes": null,
                "unit_total": "39.48",          -- 基金规模(亿元)
                "unit_incr": "-0.04",           -- 基金规模变化(亿元)
                "price": "0.815",
                "volume": "4056.40",
                "last_dt": "2023-08-04",
                "last_time": "10:57:21",
                "increase_rt": "0.25",
                "estimate_value": "0.8157",
                "last_est_time": "10:57:22",
                "discount_rt": "0.03",
                "fund_nav": "0.8136",            -- 基金净值
                "nav_dt": "2023-08-03",          -- 净值日期
                "index_nm": "中国A50互联互通",    -- 指数
                "index_increase_rt": "0.28",
                "idx_price_dt": "2023-08-04",
                "owned": 0,
                "holded": 0,
                "pe": "-",
                "pb": "-"
            }
        }
    ```
    """
    default_keys = (
        "fund_id",
        "fund_nm",
        "index_nm",
        "issuer_nm",
        "amount",
        "unit_total",
        "unit_incr",
    )
    etf1 = baseUrl + "/data/etf/etf_list/"

    if keys is None:
        keys = default_keys

    r = requests.get(etf1, headers={"User-Agent": ua.random})
    ds = r.json()["rows"]
    ids = [d["id"] for d in ds]
    res = map(lambda d: {key: d["cell"][key] for key in set(keys)}, ds)
    return (ids, list(res))
