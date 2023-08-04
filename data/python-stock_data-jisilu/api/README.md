# 集思录股票数据API

官方网站 [集思录 (jisilu.cn)](https://www.jisilu.cn/)

经分析网站实时数据网页，解析页面源码，剥离取数请求，提取到如下API信息。

[API验证代码](./api.http)

## ETF类数据

### 指数ETF 

```
GET https://www.jisilu.cn/data/etf/etf_list/?___jsl=LST___t=1691116612015&rp=25&page=1
```

实际验证，弃掉后面的查询参数，同样也能返回相同数据

```
GET https://www.jisilu.cn/data/etf/etf_list/
content-type: application/json
```

[返回数据样例](./etf-1-Response.json)

#### 个股数据

```
POST https://www.jisilu.cn/data/etf/detail_hists/?___jsl=LST___t=1691118617015
```

同上，也可弃用查询参数。本调用为POST，需提交formdata数据，经验证，只需提供`fund_id`(基金代码)和`is_search`(固定为1)参数即可。

```
POST https://www.jisilu.cn/data/etf/detail_hists/ HTTP/1.1
Content-Type: application/x-www-form-urlencoded

fund_id=588080
&is_search=1
```

[返回数据样例](./etf-1d-Response.json)

### 黄金ETF

```
GET https://www.jisilu.cn/data/etf/gold_list/?___jsl=LST___t=1691117175419&rp=25&page=1
```

[返回数据样例](./etf-2-Response.json)

#### 个股数据

```
POST https://www.jisilu.cn/data/etf/detail_hists/?___jsl=LST___t=1691121670210
```

```
POST https://www.jisilu.cn/data/etf/detail_hists/ HTTP/1.1
Content-Type: application/x-www-form-urlencoded

fund_id=159812
&is_search=1
```

ETF类个股API是一样的，只是用不同代码调用而已。

[返回数据样例](./etf-2d-Response.json)


### 场内货币ETF

```
GET https://www.jisilu.cn/data/etf/money_list/?___jsl=LST___t=1691117212543&rp=25&page=1
```

[返回数据样例](./etf-3-Response.json)


## T+0 QDII类数据

### 欧美市场指数

```
GET https://www.jisilu.cn/data/qdii/qdii_list/E?___jsl=LST___t=1691117391003&rp=22&page=1
```

[返回数据样例](./etf-4-Response.json)

#### 个股数据

```
POST https://www.jisilu.cn/data/qdii/detail_hists/?___jsl=LST___t=1691119783805
```

```
POST https://www.jisilu.cn/data/qdii/detail_hists/ HTTP/1.1
Content-Type: application/x-www-form-urlencoded

fund_id=513030
&is_search=1
```

[返回数据样例](./etf-4d-Response.json)


### QDII 类数据API是一致的

其他如：欧美市场商品和亚洲市场指数，API是一样的，只是查询类别不同。

这个API可返回全部QDII数据:

```
GET https://www.jisilu.cn/data/qdii/qdii_list/
```

下列的API分别返回相应的数据：

```
GET https://www.jisilu.cn/data/qdii/qdii_list/E #欧美市场指数
GET https://www.jisilu.cn/data/qdii/qdii_list/C #欧美市场商品
GET https://www.jisilu.cn/data/qdii/qdii_list/A #亚洲市场指数
```

个股API也是一样的，只是用不同基金代码去调用而已。


## LOF类数据

### 股票LOF

```
GET https://www.jisilu.cn/data/lof/stock_lof_list/?___jsl=LST___t=1691118392218&rp=25&page=1
```


[返回数据样例](./lof-1-Response.json)


#### 个股数据

```
POST https://www.jisilu.cn/data/lof/hist_list/160106?___jsl=LST___t=1691124065852
```

[返回数据样例](./lof-1d-Response.json)

### 指数LOF

```
GET https://www.jisilu.cn/data/lof/index_lof_list/?___jsl=LST___t=1691118375870&rp=25&page=1
```

[返回数据样例](./lof-2-Response.json)

#### 个股数据

```
POST https://www.jisilu.cn/data/lof/hist_list/161121?___jsl=LST___t=1691124637352
```

LOF类个股API是一样的，只是用不同代码调用而已。

[返回数据样例](./lof-2d-Response.json)
