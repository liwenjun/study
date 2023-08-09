# Pandas 基础



## 读取数据

```python
import pandas as pd
import sqlite3

conn = sqlite3.connect('../data/fund.sqlite')

df = pd.read_sql_query('select * from fund limit 100', conn)
```

得到如下数据：

| | fund_id | fund_name | index_name |     issuer_name | fund_type | fund_nav | fund_nav_date |      price | amount | volume |   total | idx_incr_rt | 
| ------: | --------: | ---------: | --------------: | --------: | -------: | ------------: | ---------: | -----: | -----: | ------: | ----------: | ----- |
|       0 |    159601 |        A50 | 中国A50互联互通 |  华夏基金 |       ei |        0.8122 | 2023-08-08 |  0.810 | 484879 | 1125.24 |       39.28 | -0.19 |
|       1 |    159602 |    中国A50 | 中国A50互联互通 |  南方基金 |       ei |        0.8106 | 2023-08-08 |  0.808 | 196054 |  503.81 |       15.84 | -0.19 |
|       2 |    159603 |   双创天弘 |      科创创业50 |  天弘基金 |       ei |        0.8671 | 2023-08-08 |  0.868 | 232907 |   46.37 |       20.22 | 0.13  |
|       3 |    159606 |    500成长 |         500质量 |    易方达 |       ei |        0.8153 | 2023-08-08 |  0.811 |  61522 |   61.37 |        4.99 | -0.50 |
|       4 |    159608 |   稀有金属 |        CS稀金属 |  广发基金 |       ei |        0.6736 | 2023-08-08 |  0.670 |  36001 |  148.09 |        2.41 | -0.47 |
|     ... |       ... |        ... |             ... |       ... |      ... |           ... |        ... |    ... |    ... |     ... |         ... | ...   |
|      95 |    159766 |    旅游ETF |        中证旅游 |  富国基金 |       ei |        0.9333 | 2023-08-08 |  0.926 | 354114 | 3836.69 |       32.79 | -0.79 |
|      96 |    159767 |   电池龙头 |        新能电池 |  兴银基金 |       ei |        0.6646 | 2023-08-08 |  0.660 |  24987 |   32.98 |        1.65 | -0.43 |
|      97 |    159768 |   地产龙头 |        内地地产 |  银华基金 |       ei |        0.7928 | 2023-08-08 |  0.798 |  57045 | 2449.92 |        4.55 | 0.81  |
|      98 |    159769 |   电子消费 |        消费电子 |  银华基金 |       ei |        0.7829 | 2023-08-08 |  0.774 |   4845 |    2.87 |        0.38 | -1.14 |
|      99 |    159770 |   机器人AI |          机器人 |  天弘基金 |       ei |        0.8485 | 2023-08-08 |  0.840 |  21409 |  262.83 |        1.80 | -0.95 |

100 rows × 12 columns



## 查验数据

```python
df.head() # 查看前5条，括号里可以写明你想看的条数
df.tail() # 查看尾部5条 
df.sample(5) # 随机查看5行

df.shape # 查看行数和列数
	(100,11)

df.info() # 查看索引、数据类型和内存信息
    <class 'pandas.core.frame.DataFrame'>
    Index: 100 entries, 159601 to 159770
    Data columns (total 11 columns):
     #   Column         Non-Null Count  Dtype  
    ---  ------         --------------  -----  
     0   fund_name      100 non-null    object 
     1   index_name     100 non-null    object 
     2   issuer_name    100 non-null    object 
     3   fund_type      100 non-null    object 
     4   fund_nav       100 non-null    float64
     5   fund_nav_date  100 non-null    object 
     6   price          100 non-null    float64
     7   amount         100 non-null    int64  
     8   volume         100 non-null    float64
     9   total          100 non-null    float64
     10  idx_incr_rt    100 non-null    float64
    dtypes: float64(5), int64(1), object(5)
    memory usage: 13.4+ KB

df.describe() # 查看数值型列的汇总统计，会计算出各数字字段的总数(count)、平均数(mean)、标准差(std)、最小值(min)、四分位数和最大值(max)
         fund_nav	 price	amount	volume	total	idx_incr_rt
    count	100.000000	100.000000	100.000000	100.000000	100.000000	100.000000
    mean	0.902476	0.898850	70759.100000	1551.286900	6.956600	-0.344400
    std	0.278993	0.276736	126575.648777	4879.083504	13.671492	0.721889
    min	0.612800	0.625000	1397.000000	0.000000	0.140000	-1.850000
    25%	0.770650	0.764750	8841.750000	58.852500	0.702500	-0.692500
    50%	0.866100	0.868000	24093.000000	376.625000	1.850000	-0.470000
    75%	0.961075	0.956250	55265.250000	1272.415000	4.807500	-0.160000
    max	2.600800	2.586000	692165.000000	39172.970000	68.140000	2.430000

df.dtypes # 查看各字段类型
    fund_name         object
    index_name        object
    issuer_name       object
    fund_type         object
    fund_nav         float64
    fund_nav_date     object
    price            float64
    amount             int64
    volume           float64
    total            float64
    idx_incr_rt      float64
    dtype: object

df.axes # 显示数据行和列名
    [RangeIndex(start=0, stop=100, step=1),
     Index(['fund_id', 'fund_name', 'index_name', 'issuer_name', 'fund_type',
            'fund_nav', 'fund_nav_date', 'price', 'amount', 'volume', 'total',
            'idx_incr_rt'],
           dtype='object')]

df.columns # 列名
    Index(['fund_name', 'index_name', 'issuer_name', 'fund_type', 'fund_nav',
           'fund_nav_date', 'price', 'amount', 'volume', 'total', 'idx_incr_rt'],
          dtype='object')
```



## 选取数据

```python
# 建立索引并生效，就没有从0开始的数字索引了。可以和前面的数据集比较。
df.set_index('fund_id', inplace=True) 
```

| fund_name | index_name |     issuer_name | fund_type | fund_nav | fund_nav_date |      price | amount | volume |   total | idx_incr_rt |       |
| --------: | ---------: | --------------: | --------: | -------: | ------------: | ---------: | -----: | -----: | ------: | ----------: | ----: |
|   fund_id |            |                 |           |          |               |            |        |        |         |             |       |
|    159601 |        A50 | 中国A50互联互通 |  华夏基金 |       ei |        0.8122 | 2023-08-08 |  0.810 | 484879 | 1125.24 |       39.28 | -0.19 |
|    159602 |    中国A50 | 中国A50互联互通 |  南方基金 |       ei |        0.8106 | 2023-08-08 |  0.808 | 196054 |  503.81 |       15.84 | -0.19 |
|    159603 |   双创天弘 |      科创创业50 |  天弘基金 |       ei |        0.8671 | 2023-08-08 |  0.868 | 232907 |   46.37 |       20.22 |  0.13 |
|    159606 |    500成长 |         500质量 |    易方达 |       ei |        0.8153 | 2023-08-08 |  0.811 |  61522 |   61.37 |        4.99 | -0.50 |
|    159608 |   稀有金属 |        CS稀金属 |  广发基金 |       ei |        0.6736 | 2023-08-08 |  0.670 |  36001 |  148.09 |        2.41 | -0.47 |
|       ... |        ... |             ... |       ... |      ... |           ... |        ... |    ... |    ... |     ... |         ... |   ... |
|    159766 |    旅游ETF |        中证旅游 |  富国基金 |       ei |        0.9333 | 2023-08-08 |  0.926 | 354114 | 3836.69 |       32.79 | -0.79 |
|    159767 |   电池龙头 |        新能电池 |  兴银基金 |       ei |        0.6646 | 2023-08-08 |  0.660 |  24987 |   32.98 |        1.65 | -0.43 |
|    159768 |   地产龙头 |        内地地产 |  银华基金 |       ei |        0.7928 | 2023-08-08 |  0.798 |  57045 | 2449.92 |        4.55 |  0.81 |
|    159769 |   电子消费 |        消费电子 |  银华基金 |       ei |        0.7829 | 2023-08-08 |  0.774 |   4845 |    2.87 |        0.38 | -1.14 |
|    159770 |   机器人AI |          机器人 |  天弘基金 |       ei |        0.8485 | 2023-08-08 |  0.840 |  21409 |  262.83 |        1.80 | -0.95 |

100 rows × 11 columns



### 按列选取

```python
df['fund_name']  # 单列，返回Series类型数据
    fund_id
    159601      A50
    159602    中国A50
    159603     双创天弘
    159606    500成长
    159608     稀有金属
              ...  
    159766    旅游ETF
    159767     电池龙头
    159768     地产龙头
    159769     电子消费
    159770    机器人AI
    Name: fund_name, Length: 100, dtype: object

df[['fund_name', 'total']] # 多列，返回DataFrame类型数据
        fund_name	total
    fund_id		
    159601	A50	39.28
    159602	中国A50	15.84
    159603	双创天弘	20.22
    159606	500成长	4.99
    159608	稀有金属	2.41
    ...	...	...
    159766	旅游ETF	32.79
    159767	电池龙头	1.65
    159768	地产龙头	4.55
    159769	电子消费	0.38
    159770	机器人AI	1.80
    100 rows × 2 columns
```



### 按行选取

```python
# 用指定索引选取
df[df.index == '159681'] # 指定索引

# 用自然索引选择，类似列表的切片
df[0:3] # 取前三行
df[0:10:2] # 在前10个中每两个取一个
df.iloc[:10,:] # 前10个
```



### 指定行、列

**重点介绍`loc`方法**

> df.loc[x, y]是一个非常强大的数据选择函数，其中x代表行，y代表 列，行和列都支持条件表达式，也支持类似列表那样的切片（如果要用 自然索引，需要用df.iloc[]）。

```python
df.loc['159680':'159705', 'fund_name':'fund_nav']
```



|        | fund_name | index_name | issuer_name | fund_type | fund_nav | 
| --------: | ---------: | ----------: | --------: | -------: | -----: |
|   fund_id |            |             |           |          |        |
|    159680 |   1000指增 |    中证1000 |  招商基金 |       ei | 1.0385 |
|    159681 |    创50ETF |    创业板50 |  鹏华基金 |       ei | 0.9276 |
|    159682 |   创业五零 |    创业板50 |  景顺长城 |       ei | 0.9188 |
|    159683 |    运输ETF |    内地运输 |  嘉实基金 |       ei | 0.9700 |
|    159685 |   1000策略 |    中证1000 |  天弘基金 |       ei | 0.9723 |
|    159689 |     消费NF |    中证消费 |  南方基金 |       ei | 0.9337 |
|    159701 |     物联50 |    CS物联网 |  招商基金 |       ei | 0.7800 |
|    159703 |     新材料 |      新材料 |  天弘基金 |       ei | 0.8017 |



### 条件选取

```python
# 单一条件
df[df.total > 10] 
df[df.fund_type == 'qc']
df[df.index == '159703']

# 组合条件
df[(df['total'] > 10) & (df['fund_type'] == 'ei')] # and关系
df[df['fund_type'] == 'ei'].loc[df.total>10] # 多重筛选
```

显示结果：

|     | fund_name |      index_name |     issuer_name | fund_type | fund_nav | fund_nav_date |      price | amount | volume |   total | idx_incr_rt |
| --------: | --------------: | --------------: | --------: | -------: | ------------: | ---------: | -----: | -----: | ------: | ----------: | ----: |
|   fund_id |                 |                 |           |          |               |            |        |        |         |             |       |
|    159601 |             A50 | 中国A50互联互通 |  华夏基金 |       ei |        0.8122 | 2023-08-08 |  0.810 | 484879 | 1125.24 |       39.28 | -0.19 |
|    159602 |         中国A50 | 中国A50互联互通 |  南方基金 |       ei |        0.8106 | 2023-08-08 |  0.808 | 196054 |  503.81 |       15.84 | -0.19 |
|    159603 |        双创天弘 |      科创创业50 |  天弘基金 |       ei |        0.8671 | 2023-08-08 |  0.868 | 232907 |   46.37 |       20.22 |  0.13 |
|    159611 |         电力ETF |        电力指数 |  广发基金 |       ei |        0.9343 | 2023-08-08 |  0.920 | 291436 | 5120.81 |       26.81 |  -1.3 |
|    159623 |         成渝ETF |      成渝经济圈 |  博时基金 |       ei |        0.8922 | 2023-08-08 |  0.887 | 391927 |  668.71 |       34.76 |  -0.6 |
|       ... |             ... |             ... |       ... |      ... |           ... |        ... |    ... |    ... |     ... |         ... |   ... |
|    588290 | 科创芯片ETF华安 |        科创芯片 |  华安基金 |       ei |        1.1641 | 2023-08-08 |  1.152 | 110390 | 2860.75 |       12.72 | -0.88 |
|    588300 |         双创ETF |      科创创业50 |  招商基金 |       ei |        0.5757 | 2023-08-08 |  0.575 | 294121 | 1140.86 |       16.91 |  0.13 |
|    588350 |   双创50ETF基金 |      科创创业50 |  鹏扬基金 |       ei |        0.8706 | 2023-08-08 |  0.870 | 195055 |  357.42 |       16.97 |  0.13 |
|    588380 |         创50ETF |      科创创业50 |  富国基金 |       ei |        0.5754 | 2023-08-08 |  0.575 | 362377 | 3512.86 |       20.84 |  0.13 |
|    588400 |       双创50ETF |      科创创业50 |  嘉实基金 |       ei |        0.5723 | 2023-08-08 |  0.572 | 332160 | 2199.94 |       19.00 |  0.13 |

183 rows × 11 columns



## 排序

```python
df.sort_values(by='total') # 按total列数据升序排列
df.sort_values(by='total', ascending=False) # 降序
df.sort_values(['fund_name', 'total'], ascending=[True, False]) # fund_name升序，total降序
```



## 分组聚合

```python
df.groupby('issuer_name').sum() # 按团队分组对应列相加
df.groupby('issuer_name').mean() # 按团队分组对应列求平均

# 不同列不同的计算方法
df.groupby('issuer_name').agg({'total': sum, # 总和
    'fund_name': 'count', # 总数
    'fund_nav':'mean', # 平均
    'price': max}) # 最大值
```

结果显示

|       |       total | fund_name | fund_nav |    price |
| ----------: | --------: | -------: | -------: | ----: |
| issuer_name |           |          |          |       |
|    万家基金 |     12.71 |        7 | 1.553229 | 2.646 |
|    上投摩根 |      5.13 |        5 | 0.939960 | 1.164 |
|    东方资管 |      0.00 |        3 | 1.515133 | 1.834 |
|    东海基金 |      0.00 |        1 | 1.014300 | 1.003 |
|    中信保诚 |      0.00 |        5 | 2.075560 | 4.860 |
|         ... |       ... |      ... |      ... |   ... |
|    长信基金 |      0.00 |        1 | 1.339000 | 1.335 |
|    长城基金 |      0.00 |        1 | 1.367100 | 1.359 |
|    长盛基金 |      0.00 |        8 | 1.276400 | 1.858 |
|    鹏华基金 |    344.37 |       49 | 1.023439 | 1.886 |
|    鹏扬基金 |     39.58 |        3 | 0.818300 | 0.870 |

79 rows × 4 columns



## 数据转置

```python
df.groupby('issuer_name').agg({'total': sum, 'fund_name': 'count', 'fund_nav':'mean', 'price': max}).T
```

结果

| issuer_name |  万家基金 | 上投摩根 | 东方资管 | 东海基金 | 中信保诚 | 中信建投 | 中欧基金 | 中融基金 | 中金基金 | 中银国际 |  ... | 西部利得 | 诺安基金 | 财通基金 |   银华基金 | 银河基金 | 长信基金 | 长城基金 | 长盛基金 |   鹏华基金 | 鹏扬基金 |
| ----------: | --------: | -------: | -------: | -------: | -------: | -------: | -------: | -------: | -------: | -------: | ---: | -------: | -------: | -------: | ---------: | -------: | -------: | -------: | -------: | ---------: | -------: |
|       total | 12.710000 |  5.13000 | 0.000000 |   0.0000 |  0.00000 |   0.9600 | 0.000000 | 1.250000 |   3.3000 |   0.2300 |  ... | 6.630000 |    0.000 |   0.0000 | 215.570000 |   0.0000 |    0.000 |   0.0000 |   0.0000 | 344.370000 |  39.5800 |
|   fund_name |  7.000000 |  5.00000 | 3.000000 |   1.0000 |  5.00000 |   1.0000 | 7.000000 | 4.000000 |   3.0000 |   2.0000 |  ... | 4.000000 |    1.000 |   6.0000 |  42.000000 |   1.0000 |    1.000 |   1.0000 |   8.0000 |  49.000000 |   3.0000 |
|    fund_nav |  1.553229 |  0.93996 | 1.515133 |   1.0143 |  2.07556 |   0.4578 | 1.580614 | 1.362875 |   0.9817 |   0.7677 |  ... | 1.186025 |    1.074 |   1.2166 |   1.028645 |   0.9618 |    1.339 |   1.3671 |   1.2764 |   1.023439 |   0.8183 |
|       price |  2.646000 |  1.16400 | 1.834000 |   1.0030 |  4.86000 |   0.4590 | 3.035000 | 1.633000 |   1.4110 |   0.8180 |  ... | 1.885000 |    1.076 |   1.5100 |   2.736000 |   0.9680 |    1.335 |   1.3590 |   1.8580 |   1.886000 |   0.8700 |

4 rows × 79 columns



## 增加列

```python
df['one'] = 1 # 增加一个固定值的列
df['new_total'] = df.price * df.amount

# 将计算得来的结果赋值给新列
df['new_total'] = df.loc[:,'Q1':'Q4'].apply(lambda x:sum(x), axis=1)
df['new_total'] = df.sum(axis=1) # 可以把所有为数字的列相加
```



## 绘图

```python
df[df.fund_type == 'ei']['total'].plot() 
```



![img](data:image/png;base64,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WLBAxMfHi8DAQBESEiL++c9/ivj4eDFt2jQhhBBvvvmmACBWrlxp26awsFAEBASIFStWCCGEuPPOO8Xo0aNl75WVlSUAiAMHDjiUo6mrkOx5c1yktmzZIgCIHTt2OH2PKVOmiLZt28rSnFZGo1EcOXJE7NixQ4wfP160a9dOZGVlqf+QHvLlMXnnnXdEVFSUCAwMFBEREWLq1KkCgFi8eLHDezirOsjKyhKJiYli+vTpYs+ePWLFihWiV69e4oknnvD6M6tx4cIFERUV5ZDmd1Yt8Oabb4orrrjCYT/t27cXc+bMEUIIcebMGdG1a1cxbtw4sXPnTrFhwwZx6623ioEDBwqLxSKEUPd5g4ODxcKFC2XvM3v2bBEXF6fFR3fJ0+Oi5LPPPhNBQUGiurraYZmaKiSl6+f06dMCgNiyZYts3XHjxonrrrvObZkawtNjsmDBAgFAfPTRR7bXqqurRbt27cTcuXMd9u/sntK1a1cxZcoU2Ws//fSTACAqKyt1c0w2b94sAIgJEybI1unVq5cYP368w7bOqpCEcH9PUfP8acrrRystLgNj79JLL0W7du1w9OhR22uPPPII8vPzcfr0aZw/fx6TJk3C2bNncemllwIAEhMTAUCWEWjfvj3atWtnSxcmJCSgoKBA9l7W333dYFcL3hwXqU8//RR9+vRBv379FPcvhMDnn3+ORx99VJbmtAoJCcHll1+Ofv36YerUqejduzfef/997T6gF7w9Ji+88AKKi4uRk5ODc+fOYciQIbb9qTV16lTceOONGDduHK6++mqkpaVhzpw5+Pzzzz3K5HgqJiYGV1xxhewzu5KQkODQMLK2thZFRUW283727NmIjo7G9OnT0bdvX9xyyy346quvsGbNGls1k5rP6+waa4zry9PjomTAgAGora116H2lhrPrp127dggMDGyS4+LpMVG6j4aGhuLSSy9VrIpydk9xdh5ERUUhPDxcN8dE6fMCQI8ePTyujnR3T1Hz/GnK60crLT6AOXXqFM6fP287uaTi4+PRunVrfP311wgLC8Odd94JoC69DQCHDh2yrVtUVIRz587Z6qJTUlKwceNGmEwm2zqrV69Gt27d0KZNG19+JE14c1ysysvL8c0332DUqFFO979hwwYcPXrU5TpSFosFRqPRsw+hsYYcE4PBgKSkJISHh2PRokVITk7GNddco/q9KysrZW1tACAwMBBA3cPMV8rLy3Hs2DHFz6wkJSUFxcXFsvY9a9euhcViwYABAwC4/iwWi8XtOtbPm5KSgjVr1sjWWb16daO0lfL0uCjZvXs3AgICHKrc1HB2/YSEhKBfv36y42KxWLBmzRqfHxdPj0m/fv0QGhoqu4+aTCacOHHCoU2cq3uKu/NAL8ekc+fOSEpKkn1eADh8+LDTNoCuuLqnqHn+NOX1o5mmTQBpr6ysTOzatUvs2rVLABDvvvuu2LVrlzh58qQoKysT//znP0V6errIzs4Wv/76q7jmmmtE165dZWncDz74QGRmZopDhw6J//znPyI8PFy8//77svcZMmSIuPLKK8XmzZvFvn37xL333it69uxp60VRXFws4uPjxaOPPir2798vFi9eLCIiImTpUqPRaCtrYmKi+Oc//yl27drltFePPxwXIYT49NNPRVhYmMs0+p/+9CcxYMAAxWXjx48XGzZsENnZ2WLv3r1i/PjxwmAwiFWrVjX4OEg11jGZPn262Lt3r9i/f7+YPHmyCA4OdqiuysrKErt27RL33XefuO2222zlspo3b54ICgoSc+bMEceOHRObNm0S/fv31zwF/o9//EOsX79eZGdni82bN4vU1FTRrl07UVhYKISoq/7ZtWuX+OSTTwQAsXHjRrFr1y5x/vx52z4GDRok+vbtKzIyMsSmTZtE165dxcMPP2xbvmbNGmEwGMRrr70mDh8+LDIzM0VaWpro1KmTqKysVP15N2/eLIKCgsTbb78tDh48KF599VURHBws9u3bp+kx0eK4bNmyRbz33nti9+7d4tixY+Krr74S7du3F3/+859l7+PuPLBydf0sXrxYhIaGivnz54sDBw6I0aNHi5iYGJGfn6+rYyKEEM8++6zo0KGDWLlypfj999/FqFGjRFxcnCgqKpK9l6t7yvHjx0VERIQYN26cOHjwoJg9e7YIDAy0Vefr6Zi89957IioqSixZskQcOXJEvPzyyyIsLEwcPXrUto+TJ0+KXbt2iddee020bt3adg6UlZXZ1nF3T1Hz/GnM68dXml0AY61vtf8ZOXKkqKysFHfddZdo3769CA4OFp06dRJPPvmkw0n86KOPitjYWBESEiKuvvpqxW7AJSUl4oknnhAxMTEiNjZW/OEPfxA5OTmydfbs2SNuuukmERoaKjp06ODQViQ7O1uxrLfeeqvfHhchhEhJSRGPPPKI07IUFxeL8PBw8fHHHysuf+KJJ0SnTp1ESEiIaN++vRg4cKDmwYsQjXdMbr/9dhEdHS3CwsLEgAEDxM8//+ywTqdOnRTLIjVr1izRs2dPER4eLhITE8WIESPEqVOnND0mw4cPF4mJiSIkJER06NBBDB8+XHZzffXVVxXLOW/ePNs658+fFw8//LBo3bq1iIqKEo8//rjs5iuEEIsWLRJ9+/YVrVq1Eu3btxf/93//Jw4ePOjx5/3mm2/EFVdcIUJCQsSVV14pfvrpJ02Ph1VDj0tmZqYYMGCA7Tzo0aOHmDJlikP7FzXngbvrR4i6wPqSSy4RISEh4rrrrhNbt27V7mBcpMW5UlNTI/7xj3+IuLg4ERkZKVJTU8X+/fsd3svdPWXdunWiT58+IiQkRFx66aWy97DSwzERQoipU6eKjh07ioiICJGSkiJ+++032fKRI0cqHrd169bZ1lFzT3H3/BGi8a4fX+Fs1EREROR3WnwbGCIiIvI/DGCIiIjI7zCAISIiIr/DAIaIiIj8DgMYIiIi8jsMYIiIiMjvMIAhIiIiv8MAhoiIiPwOAxgi8gkhBEaPHo3Y2FgYDAbs3r3bJ++zfv16GAwGFBcXu113/vz5iImJcbnOpEmT0KdPH03KRkS+wwCGiHxixYoVmD9/PpYvX44zZ87gqquuauoiYfjw4Th8+HBTF4OINBDU1AUgoubJOgvvDTfc0NRFsQkPD0d4eHhTF4OINMAMDBFp7rHHHsMzzzyDnJwcGAwGdO7cGZ07d8bMmTNl6/Xp0weTJk2y/W4wGPDpp5/iD3/4AyIiItC1a1csW7ZMts3PP/+MK664AuHh4bj99ttx4sQJ1eVSqkKaNm0a4uPjERkZiVGjRqG6utrDT0tETYEBDBFp7v3338fkyZPRsWNHnDlzBtu3b1e97WuvvYYHH3wQe/fuxT333IMRI0agqKgIAJCbm4v7778f9913H3bv3o2//OUvGD9+vNfl/OabbzBp0iRMmTIFO3bsQGJiIubMmeP1/oio8TCAISLNRUdHIzIyEoGBgUhISED79u1Vb/vYY4/h4YcfxuWXX44pU6agvLwc27ZtAwB8+OGHuOyyy/DOO++gW7duGDFiBB577DGvyzlz5kyMGjUKo0aNQrdu3fDGG2+gZ8+eXu+PiBoPAxgi0pWrr77a9v9WrVohKioKhYWFAICDBw9iwIABsvVTUlK8fi+t90dEjYcBDBE1ioCAAAghZK+ZTCaH9YKDg2W/GwwGWCwWn5aNiPwPAxgiahTt27fHmTNnbL+XlpYiOzvbo3306NHDVp1ktXXrVq/L1KNHD2RkZGi2PyJqPAxgiKhR3HHHHfjvf/+L3377Dfv27cPIkSMRGBjo0T7++te/4siRIxg3bhwOHTqEhQsXYv78+V6X6dlnn8Xnn3+OefPm4fDhw3j11VeRlZXl9f6IqPEwgCGiRjFhwgTceuutuPfeezF48GAMHToUl112mUf7uOSSS/Ddd9/hhx9+QO/evTF37lxMmTLF6zINHz4cr7zyCl588UX069cPJ0+exNNPP+31/oio8RiEfaU0ERERkc4xA0NERER+hwEMETUbd999N1q3bq3405CqJiLSH1YhEVGzcfr0aVRVVSkui42NRWxsbCOXiIh8hQEMERER+R1WIREREZHfYQBDREREfocBDBEREfkdBjBERETkdxjAEBERkd9hAENERER+hwEMERER+R0GMEREROR3/h/tvvj9L9lSLgAAAABJRU5ErkJggg==)





## 导出

```python
df.to_excel('demo.xlsx') # 导出 Excel文件
df.to_csv('demo.csv') # 导出 CSV文件
```

