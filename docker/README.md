# Docker应用于测试和开发

在日常学习和开发过程中，经常会使用到数据库或一些其他服务。如果都在本地安装的话，非常麻烦耗时、且可能会污染开发环境。在此引入`docker`。

## 提供数据库服务

这是常见的应用场景。

### Oracle数据库

```bash
# pull images
docker compose -f oracle.yaml pull

# 启动服务
docker compose -f oracle.yaml up -d
```

数据库信息

```ini
hostname: 127.0.0.1
port: 1521
sid: xe
username: system 或 sys
password: oracle
```

管理页面

```
http://127.0.0.1:8082/apex

workspace: INTERNAL
user: ADMIN
password: oracle
```

### Postgresql 数据库

```bash
# pull images
docker compose -f pgsql.yaml pull

# 启动服务
docker compose -f pgsql.yaml up -d
```

数据库信息

```ini
hostname: 127.0.0.1
port: 5432
db: testdb
username: user
password: password
```

## 提供Jupyter开发环境

```
# pull images
docker compose -f jupyter.yaml pull

# 启动服务
docker compose -f jupyter.yaml up -d
```







## API

```sh
#!/bin/bash

repo_url=https://registry.hub.docker.com/v2/repositories/library
image_name=$1

curl -L -s ${repo_url}/${image_name}/tags?page_size=1024 | jq '.results[]["name"]' | sed 's/\"//g' | sort -u

##
# curl -L -s https://registry.hub.docker.com/v2/repositories/library/jupyter/scipy-notebook/tags?page_size=1024
```
