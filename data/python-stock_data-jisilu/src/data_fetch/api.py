# -*- coding: utf-8 -*-

import requests
from fake_useragent import UserAgent

ua = UserAgent()
baseUrl = "https://www.jisilu.cn"


def get_etf(keys: tuple = None) -> (list, list):
    """获取指数etf基金列表数据

    参数keys: 过滤输出结果字段，例: ('fund_id','fund_nm','index_nm','issuer_nm','amount','unit_total','unit_incr')

    参考: 这是返回结果其中一个个股的完整信息, json格式。
    ```json
        {
            "id": "159601",
            "cell": {
                "fund_id": "159601",             -- 基金代码
                "fund_nm": "A50",                -- 基金名称
                "index_id": "-",
                "fee": "0.60",
                "m_fee": "0.50",
                "t_fee": "0.10",
                "creation_unit": 260,
                "issuer_nm": "华夏基金",         -- 基金公司
                "urls": "https:\/\/www.chinaamc.com\/fund\/159601\/index.shtml",
                "eval_flg": "Y",
                "ex_dt": null,
                "ex_info": null,
                "amount": 484359,               -- 基金份额(万份)
                "amount_notes": null,
                "unit_total": "39.48",          -- 基金规模(亿元)
                "unit_incr": "-0.04",           -- 基金规模变化(亿元)
                "price": "0.815",               -- 现价
                "volume": "4056.40",            -- 成交额(万元)
                "last_dt": "2023-08-04",
                "last_time": "10:57:21",
                "increase_rt": "0.25",
                "estimate_value": "0.8157",
                "last_est_time": "10:57:22",
                "discount_rt": "0.03",
                "fund_nav": "0.8136",            -- 基金净值
                "nav_dt": "2023-08-03",          -- 净值日期
                "index_nm": "中国A50互联互通",    -- 指数
                "index_increase_rt": "0.28",     -- 指数涨幅%
                "idx_price_dt": "2023-08-04",    -- 指数日期
                "owned": 0,
                "holded": 0,
                "pe": "-",
                "pb": "-"
            }
        }
    ```
    """
    default_keys = (
        "fund_id",  # 基金代码
        "fund_nm",  # 基金名称
        "index_nm",  # 指数
        "issuer_nm",  # 基金公司
        "amount",  # 场内份额(万份)
        "unit_total",  # 基金规模(亿元)
        "unit_incr",  # 基金规模变化(亿元)
        "volume",  # 成交额(万元)
        "idx_price_dt",  # 指数日期
    )
    etf1 = baseUrl + "/data/etf/etf_list/"

    if keys is None:
        keys = default_keys

    r = requests.get(etf1, headers={"User-Agent": ua.random})
    ds = r.json()["rows"]
    ids = [d["id"] for d in ds]
    res = map(lambda d: {key: d["cell"][key] for key in set(keys)}, ds)
    return (ids, list(res))


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
    default_keys = (
        "hist_dt",  # 日期
        "amount",  # 场内份额(万份)
        "amount_incr",  # 场内份额变化(万份)
        "idx_incr_rt",  # 指数涨幅%
        "fund_nav",  # 基金净值
        "trade_price",  # 收盘价
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


def get_qdii(keys: tuple = None) -> (list, list):
    """获取t+0 qdii基金列表数据

    参数keys: 过滤输出结果字段，例: ('fund_id','fund_nm','index_nm','issuer_nm','amount','unit_total','unit_incr')

    参考: 这是返回结果其中一个个股的完整信息, json格式。
    ```json
        {
            "id": "161126",
            "cell": {
                "fund_id": "161126",              -- 基金代码
                "fund_nm": "标普医药",             -- 基金名称
                "qtype": "E",                    -- 查询类型
                "issuer_nm": "易方达",       -- 基金公司
                "urls": "https:\/\/www.efunds.com.cn\/fund\/161126.shtml",
                "asset_ratio": "95.000",
                "lof_type": "QDII",
                "price": "2.146",
                "price_dt": "2023-08-04",
                "increase_rt": "-1.87%",
                "volume": "49.28",           -- 成交额(万元)
                "stock_volume": "22.7783",   -- 股票成交额(万元)
                "last_time": "12:09:36",
                "amount": 391,                -- 基金份额(万份)
                "amount_incr": "0",
                "amount_increase_rt": "0.00",
                "fund_nav": "1.8711",                -- 基金净值
                "nav_dt": "2023-08-02",   -- 净值日期
                "estimate_value": "1.8654",
                "last_est_dt": "2023-08-04",
                "last_est_time": "12:09:36",
                "ref_increase_rt": "-0.50%",
                "est_val_dt": "2023-08-03",
                "est_val_increase_rt": "-0.30%",
                "discount_rt": "15.04%",
                "index_id": "Y",
                "index_nm": "标普500医疗保健等权重指数",       -- 相关标的
                "apply_fee": "1.20%",
                "apply_fee_tips": "M＜100万\t1.20%\n100万≤M＜200万\t0.80%\n200万≤M＜500万\t0.50%\nM≥500万\t按笔收取，1000.00元\/笔",
                "redeem_fee": "1.50%",
                "redeem_fee_tips": "0-6日\t1.50%\n7日及以上\t0.50%",
                "min_amt": null,
                "money_cd": "USD",
                "notes": "",
                "estimate_value2": "-",
                "est_val_dt2": "-",
                "est_val_increase_rt2": "-",
                "discount_rt2": "-",
                "ref_price": "1547.02",
                "ref_increase_rt2": "-",
                "owned": 0,
                "holded": 0,
                "cal_tips": "指数从 2023-08-02 1554.75  到 2023-08-03 1547.02；汇率美元对人民币中间价从 2023-08-02 7.13680  到 2023-08-03 7.14950",
                "cal_index_id": "S5HLTH.SPI",
                "est_val_tm2": "-",
                "ref_price2": "-",
                "apply_redeem_status": "-",
                "amount_incr_tips": "最新份额：391万份；增长：0.00%",
                "turnover_rt": "5.83%",
                "last_est_datetime": "2023-08-04 12:09:36",
                "apply_status": "-",
                "redeem_status": "-",
                "fund_nm_color": "标普医药",
                "est_val_dt_s": "23-08-03",
                "nav_dt_s": "23-08-02"
            }
        }
    ```
    """
    default_keys = (
        "fund_id",  # 基金代码
        "fund_nm",  # 基金名称
        "index_nm",  # 指数
        "issuer_nm",  # 基金公司
        "amount",  # 场内份额(万份)
        "unit_total",  # 基金规模(亿元)
        "unit_incr",  # 基金规模变化(亿元)
        "volume",  # 成交额(万元)
        "stock_volume",  # 股票成交额(万元)
        "idx_price_dt",  # 指数日期
    )
    etf1 = baseUrl + "/data/etf/etf_list/"

    if keys is None:
        keys = default_keys

    r = requests.get(etf1, headers={"User-Agent": ua.random})
    ds = r.json()["rows"]
    ids = [d["id"] for d in ds]
    res = map(lambda d: {key: d["cell"][key] for key in set(keys)}, ds)
    return (ids, list(res))


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
        "hist_dt",  # 日期
        "amount",  # 场内份额(万份)
        "amount_incr",  # 场内份额变化(万份)
        "idx_incr_rt",  # 指数涨幅%
        "fund_nav",  # 基金净值
        "trade_price",  # 收盘价
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


def get_lof(keys: tuple = None) -> (list, list):
    """获取lof基金列表数据

    参数keys: 过滤输出结果字段，例: ('fund_id','fund_nm','index_nm','issuer_nm','amount','unit_total','unit_incr')

    参考: 这是返回结果其中一个个股的完整信息, json格式。
    ```json
        {
            "id": "160105",
            "cell": {
                "fund_id": "160105", -- 基金代码
                "fund_nm": "南方积配",    -- 基金名称
                "price": "1.134",
                "increase_rt": "0.00",
                "volume": "0.00",     -- 成交额(万元)
                "stock_volume": "0.0000",
                "price_dt": "2023-08-04",
                "last_time": "12:39:21",
                "amount": 1320,      -- 基金份额(万份)
                "amount_incr": "0",
                "amount_increase_rt": "0.00",
                "fund_nav": "1.1401",      -- 基金净值
                "nav_dt": "2023-08-03",  -- 净值日期
                "estimate_value": "1.1395",
                "est_val_dt": "2023-08-04",
                "last_est_time": "12:39:21",
                "discount_rt": "-0.48",
                "report_dt": "2023-06-30",
                "stock_ratio": "88.09",
                "stock_amount": "4.96",
                "bond_ratio": "5.33",
                "bond_amount": "0.30",
                "all_amount": "5.63",
                "stock_increase_rt": "-0.05",
                "apply_fee": "1.50%",
                "apply_fee_tips": "M＜100万\t1.50%\n100万≤M＜1000万\t1.20%\n1000万≤M\t每笔1000元",
                "redeem_fee": "1.50%",
                "redeem_fee_tips": "T＜7日\t1.50%\nT≥7天\t0.50%",
                "min_amt": "申购起点：1000元\r\n定投起点：100元\r\n日累计申购限额：无限额\r\n首次购买：1000元\r\n追加购买：1000元",
                "issuer_nm": "南方基金",     -- 基金公司
                "urls": "http:\/\/www.nffund.com\/main\/jjcp\/fundproduct\/160105.shtml",
                "notes": "",
                "owned": 0,
                "holded": 0,
                "index_id": "",
                "ratio_tips": "报告日期：2023-06-30\n总 市 值：5.63亿元\n股票占比：88.09%\n股票市值：4.96亿元\n债券占比：5.33%\n债券市值：0.30亿元",
                "apply_redeem_status": "-",
                "amount_incr_tips": "最新份额：1320万份；增长：0.00%",
                "turnover_rt": "0.00",
                "index_increase_rt": "-",
                "apply_status": "-",
                "redeem_status": "-"
            }
        },
    ```
    """
    default_keys = (
        "fund_id",  # 基金代码
        "fund_nm",  # 基金名称
        "index_nm",  # 指数
        "issuer_nm",  # 基金公司
        "amount",  # 场内份额(万份)
        "unit_total",  # 基金规模(亿元)
        "unit_incr",  # 基金规模变化(亿元)
        "volume",  # 成交额(万元)
        "idx_price_dt",  # 指数日期
    )
    etf1 = baseUrl + "/data/etf/etf_list/"

    if keys is None:
        keys = default_keys

    r = requests.get(etf1, headers={"User-Agent": ua.random})
    ds = r.json()["rows"]
    ids = [d["id"] for d in ds]
    res = map(lambda d: {key: d["cell"][key] for key in set(keys)}, ds)
    return (ids, list(res))


def get_lof_detail(fund: str, keys: tuple = None) -> list:
    """获取lof基金个股明细数据

    参数fund: 基金代码，例: '588080'
    参数keys: 过滤输出结果字段，例: ()

    参考: 这是返回结果其中一个片段的完整信息, json格式。
    ```json
        {
            "id": "2023-08-03",
            "cell": {
                "fund_id": "160106",             -- 基金代码
                "price_dt": "2023-08-03",   -- 价格日期
                "price": "1.432",
                "net_value_dt": "2023-08-03",
                "net_value": "1.4369",
                "est_val_dt": "2023-08-03",
                "est_val": "1.4420",
                "est_val_increase_rt": null,
                "est_error_rt": "0.35",
                "discount_rt": "-0.34",  -- 溢价率%
                "amount": 4599, -- 场内份额(万份)
                "amount_incr": -1, -- 场内份额变化(万份)
                "amount_increase_rt": "-0.020",
                "ref_increase_rt": "0.55" -- 重仓涨幅%
            }
        },
    ```
    """
    default_keys = (
        "hist_dt",  # 日期
        "amount",  # 场内份额(万份)
        "amount_incr",  # 场内份额变化(万份)
        "idx_incr_rt",  # 指数涨幅%
        "fund_nav",  # 基金净值
        "trade_price",  # 收盘价
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
