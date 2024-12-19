# 基于`api`抓取股市数据

股市数据获取与分析

## 代码结构

```bash
py3-stock
 ┬
 ├── conf
 ├── docs
 ├── jupyter
 └── src    # <- (python源代码)
       ┬
       ├── 
       └──
```

## 获取数据

```python
# 注意， tushare版本需大于1.2.10
import tushare as ts

# 此方法只需要在第一次或者token失效后调用，完成调取tushare数据凭证的设置，正常情况下不需要重复设置。
# 也可以忽略此步骤，直接用pro_api('your token')完成初始化
#ts.set_token('your-token')

# 初始化pro接口
pro = ts.pro_api()

# 如果上一步骤ts.set_token('your token')无效或不想保存token到本地，也可以在初始化接口里直接设置token
pro = ts.pro_api('your-token')

# 数据调取
# 以获取交易日历信息为例：

df = pro.trade_cal(exchange='', start_date='20180901', end_date='20181001', fields='exchange,cal_date,is_open,pretrade_date', is_open='0')

# 或者

df = pro.query('trade_cal', exchange='', start_date='20180901', end_date='20181001', fields='exchange,cal_date,is_open,pretrade_date', is_open='0')
```

### HTTP API说明

Tushare HTTP数据获取的方式，我们采用了post的机制，通过提交JSON body参数，就可以获得您想要的数据。具体参数说明如下：

**输入参数

- api_name：接口名称，比如stock_basic
- token ：用户唯一标识，可通过登录pro网站获取
- params：接口参数，如daily接口中start_date和end_date
- fields：字段列表，用于接口获取指定的字段，以逗号分隔，如"open,high,low,close"

token的获取，请参与之前公众号文章《开启Pro体验的正确打开方式》，如需注册用户，可直接点击“阅读原文”完成。

**输出参数

- code： 接口返回码，2002表示权限问题。
- msg：错误信息，比如“系统内部错误”，“没有权限”等
- data：数据，data里包含fields和items字段，分别为字段和数据内容

** 代码快速检测

有的程序员可能更喜欢用代码的方式来检查API的效果，更加直接，简单，高效。我们可以借助cURL工具来实现通过命令行方式来检测。

```bash
curl -X POST -d '{"api_name": "stock_basic", "token": "xxxxxxxx", "params": {"list_stauts":"L"}, "fields": "ts_code,name,area,industry,list_date"}' http://api.waditu.com
```

在控制台执行后，我们就可以看到如下数据效果。

```json
{
    "code": 0,
    "msg": null,
    "data": {
        "fields": [
            "ts_code",
            "name",
            "area",
            "industry",
            "list_date"
        ],
        "items": [
            [
                "000001.SZ",
                "平安银行",
                "深圳",
                "银行",
                "19910403"
            ],
            [
                "000002.SZ",
                "万科A",
                "深圳",
                "全国地产",
                "19910129"
            ],
            [
                "000004.SZ",
                "国农科技",
                "深圳",
                "生物制药",
                "19910114"
            ],
            [
                "000005.SZ",
                "世纪星源",
                "深圳",
                "房产服务",
                "19901210"
            ],
            [
                "000006.SZ",
                "深振业A",
                "深圳",
                "区域地产",
                "19920427"
            ],
            [
                "000007.SZ",
                "全新好",
                "深圳",
                "酒店餐饮",
                "19920413"
            ],
            [
                "000008.SZ",
                "神州高铁",
                "北京",
                "运输设备",
                "19920507"
            ]
            ...
      }
}
```

** Python调取示例

前面已经提到,http restful API的好处就是跟编程语言无关，基本上所有编程语言都可以调取。

由于编程环境太多，这里只拿Python作为示例，其他语言的实现，请各位用户自行查找网络资源完成，相信绝大多数会编程的用户都能轻松搞定。

其实Tushare Pro新版的SDK，正是利用http方式来获取数据的，虽然我们也提供了tcp的方式，但是http目前运行良好，稳定性已经得到了验证。

以下就是相关的核心代码，有兴趣的朋友可以访问Tushare 的Github下载完整代码。

```python
def req_http_api(self, req_params):
    req = Request(
        self.__http_url,
        json.dumps(req_params).encode('utf-8'),
        method='POST'
    )

    res = urlopen(req)
    result = json.loads(res.read().decode('utf-8'))

    if result['code'] != 0:
        raise Exception(result['msg'])

    return result['data']


def query(self, api_name, fields='', **kwargs):
    req_params = {
        'api_name': api_name,
        'token': self.__token,
        'params': kwargs,
        'fields': fields
    }

    if self.__protocol == 'tcp':
        data = self.req_zmq_api(req_params)
    elif self.__protocol == 'http':
        data = self.req_http_api(req_params)
    else:
        raise Warning('{} is unsupported protocol'.format(self.__protocol))

    columns = data['fields']
    items = data['items']

    return pd.DataFrame(items, columns=columns)
```
