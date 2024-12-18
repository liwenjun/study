# 说明

执行下列命令启动本机`Zabbix`测试环境

```bash
docker-compose up -d
```

还提供了oracle数据库供开发测试用

```bash
docker-compose up -f oracle.yaml -d
```


首次使用前，需要先清除原有模板和主机，再导入模板`zbx_export_templates.xml`和主机`zbx_export_hosts.xml`数据。  


*导入数据前请先创建如下代理*：
现数据已清除代理，可直接导入，不必创建代理！

```
NETWORK
PROXY-YDCJ-242.61
ZYCJK
```

导入后，立即将全部主机禁用！！！


## 同时将pgsql数据库用作开发

在 pgsql docker 初始化时创建一个新用户和数据库：

```sql
CREATE USER dev;
CREATE DATABASE devdb;
GRANT ALL PRIVILEGES ON DATABASE devdb TO dev;
ALTER ROLE dev WITH PASSWORD 'password';
```


```bash
docker-compose run --rm python39 /bin/bash
docker-compose run --rm python38 /bin/bash
docker-compose run --rm python36 /bin/bash

pip3 download --no-cache-dir -r req.txt
```