# Requests 一个简单而优雅的HTTP库

[Requests: HTTP for Humans™](https://requests.readthedocs.io)



## 基本用法

```python
import requests

Url = 'https://www.****'

r = requests.get(Url)
r.status_code

    200

r.headers['content-type']

    'application/json; charset=utf-8'

r.headers

    {'Server': 'nginx', 'Date': 'Wed, 09 Aug 2023 00:48:57 GMT', 'Content-Type': 'application/json; charset=utf-8', 'Transfer-Encoding': 'chunked', 'Connection': 'keep-alive', 'Set-Cookie': 'kbzw__Session=bovi6jkfcq40unlprh798f0464; path=/', 'Expires': 'Mon, 26 Jul 1997 05:00:00 GMT', 'Last-Modified': 'Wed, 09 Aug 2023 00:48:55 GMT', 'Cache-Control': 'no-cache, must-revalidate', 'Pragma': 'no-cache', 'Content-Encoding': 'gzip'}

r.encoding

    'utf-8'

r.text

    '{"page":1,"rows":[{"id":"159601","cell":{"fund_id":"159601","fund_nm":"A50","index_id":"-","fee":"0.60","m_fee":"0.50","t_fee":"0.10","creation_unit":260,"issuer_nm":"华夏基金","urls":"https:\\/\\/www.chinaamc.com\\/fund\\/159601\\/index.shtml","eval_flg":"Y","ex_dt":null,"ex_info":null,"amount":484879,"amount_notes":null,"unit_total":"39.37","unit_incr":"0.00","price":"0.812","volume":"5836.47","last_dt":"2023-08-08","last_time":"15:14:57","increase_rt":"0.00","estimate_value":"0.8122","last_est_time":"06:50:01","discount_rt":"-0.02","fund_nav":"0.8122","nav_dt":"2023-08-08","index_nm":"中国A50互联互通","index_increase_rt":"0.05","idx_price_dt":"2023-08-08","owned":0,"holded":0,"pe":"-","pb":"-"}},{"id":"588460","cell":{"fund_id":"588460","fund_nm":"科创50增强ETF","index_id":"000688","fee":"1.10","m_fee":"1.00","t_fee":"0.10","creation_unit":150,"issuer_nm":"鹏华基金","urls":"https:\\/\\/www.phfund.com.cn\\/web\\/FUND_588460","eval_flg":"Y","ex_dt":null,"ex_info":null,"amount":76351,"amount_notes":null,"unit_total":"7.44","unit_incr":"0.00","price":"0.974","volume":"3992.68","last_dt":"2023-08-08","last_time":"14:59:55","increase_rt":"-0.31","estimate_value":"0.9746","last_est_time":"06:50:04","discount_rt":"-0.04","fund_nav":"0.9744","nav_dt":"2023-08-08","index_nm":"科创50","index_increase_rt":"-0.35","idx_price_dt":"2023-08-08","owned":0,"holded":0,"pe":"-","pb":"-"}}]}'


r.json()

    {'page': 1,
     'rows': [{'id': '159601',
       'cell': {'fund_id': '159601',
        'fund_nm': 'A50',
        'index_id': '-',
        'fee': '0.60',
        'm_fee': '0.50',
        't_fee': '0.10',
        'creation_unit': 260,
        'issuer_nm': '华夏基金',
        'urls': 'https://www.chinaamc.com/fund/159601/index.shtml',
        'eval_flg': 'Y',
        'ex_dt': None,
        'ex_info': None,
        'amount': 484879,
        'amount_notes': None,
        'unit_total': '39.37',
        'unit_incr': '0.00',
        'price': '0.812',
        'volume': '5836.47',
        'last_dt': '2023-08-08',
        'last_time': '15:14:57',
        'increase_rt': '0.00',
        'estimate_value': '0.8122',
        'last_est_time': '06:50:01',
        'discount_rt': '-0.02',
        'fund_nav': '0.8122',
        'nav_dt': '2023-08-08',
        'index_nm': '中国A50互联互通',
        'index_increase_rt': '0.05',
        'idx_price_dt': '2023-08-08',
        'owned': 0,
        'holded': 0,
        'pe': '-',
        'pb': '-'}},
    ......
      {'id': '588460',
       'cell': {'fund_id': '588460',
        'fund_nm': '科创50增强ETF',
        'index_id': '000688',
        'fee': '1.10',
        'm_fee': '1.00',
        't_fee': '0.10',
        'creation_unit': 150,
        'issuer_nm': '鹏华基金',
        'urls': 'https://www.phfund.com.cn/web/FUND_588460',
        'eval_flg': 'Y',
        'ex_dt': None,
        'ex_info': None,
        'amount': 76351,
        'amount_notes': None,
        'unit_total': '7.44',
        'unit_incr': '0.00',
        'price': '0.974',
        'volume': '3992.68',
        'last_dt': '2023-08-08',
        'last_time': '14:59:55',
        'increase_rt': '-0.31',
        'estimate_value': '0.9746',
        'last_est_time': '06:50:04',
        'discount_rt': '-0.04',
        'fund_nav': '0.9744',
        'nav_dt': '2023-08-08',
        'index_nm': '科创50',
        'index_increase_rt': '-0.35',
        'idx_price_dt': '2023-08-08',
        'owned': 0,
        'holded': 0,
        'pe': '-',
        'pb': '-'}}]}
```