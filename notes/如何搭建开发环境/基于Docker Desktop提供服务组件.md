
软件下载请点[这里](https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe?utm_source=docker&utm_medium=webreferral&utm_campaign=dd-smartbutton&utm_location=module)，安装。

可以提供 Oracle、Postgresql 数据库服务，Zabbix开发环境， Jupyter开发环境。

## 提供Oracle服务

编辑配置文件名 oracle.yaml
```yaml
version: "3"

services:
  oracle-xdb-server:
    image: datagrip/oracle:11.2
    volumes:
      - oracle_data_volume:/u01/app/oracle
    ports:
      - 1521:1521
      - 8082:8080

volumes:
  oracle_data_volume:
```

拉取 docker image
```bash
docker compose -f oracle.yaml pull
```

启动服务
```bash
docker compose -f oracle.yaml up -d
```

关闭服务
```bash
docker compose -f oracle.yaml down
```

Oracle数据库信息
```
hostname: 127.0.0.1
port: 1521
sid: xe
username: system 或 sys
password: oracle
```

Oracle web 管理页面
```
http://127.0.0.1:8082/apex

workspace: INTERNAL
user: ADMIN
password: oracle
```

创建开发用户
```sql
create user dev identified by password;
grant connect to dev;
grant resource to dev;
```

开发机按 [[Oracle客户端配置 ]]。

## 提供postgresql服务

编辑配置文件名 pgsql.yaml
```yaml
version: "3"

services:
  postgres-server:
    image: postgres:15-alpine
    volumes:
      - postgresql_data_volume:/var/lib/postgresql/data/
    ports:
      - 5432:5432
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=devdb
      - DB_SERVER_PORT=5432

volumes:
  postgresql_data_volume:
```

拉取 docker image
```bash
docker compose -f pgsql.yaml pull
```

启动服务
```bash
docker compose -f pgsql.yaml up -d
```

关闭服务
```bash
docker compose -f pgsql.yaml down
```

PostgreSQL数据库信息
```
hostname: 127.0.0.1
port: 5432
db: devdb
username: user
password: password
```

提供 pgAdmin4 图形化管理界面

## 提供 Postgrest 开发环境

创建目录
```
mkdir postgrest
cd postgrest
mkdir docker-entrypoint-initdb.d
```

编辑配置文件名 docker-compose.yaml
```yaml
version: "3"

services:
  swagger:
    image: swaggerapi/swagger-ui
    ports:
      - "8080:8080"
    expose:
      - "8080"
    environment:
      API_URL: http://localhost:3000/
    depends_on:
      - server

  server:
    image: postgrest/postgrest
    ports:
      - "3000:3000"
    environment:
      PGRST_DB_URI: postgres://authenticator:secretpassword@db:5432/postgres
      PGRST_DB_SCHEMA: api
      PGRST_DB_ANON_ROLE: web_anon #In production this role should not be the same as the one used for the connection
      PGRST_OPENAPI_SERVER_PROXY_URI: http://localhost:3000
      PGRST_JWT_SECRET: 5rmZEf1uIYJj88VfEFPH3bMw9wvPfJL9
    depends_on:
      - db

  db:
    image: postgres:15-alpine
    volumes:
      - pgsql_data_volume:/var/lib/postgresql/data/
      - ./docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d:ro
    ports:
      - "5432:5432"
    environment:
      # POSTGRES_DB: postgres
      # POSTGRES_USER: app_user
      POSTGRES_PASSWORD: mysecretpassword

volumes:
  pgsql_data_volume:
```

初始化数据库脚本 `docker-entrypoint-initdb.d/init-db.sql`
```sql
create schema api;

create role authenticator noinherit login password 'secretpassword';

create role web_anon nologin;
grant usage on schema api to web_anon;
-- grant select on all tables in schema api to web_anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA api GRANT SELECT ON TABLES TO web_anon;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA api TO web_anon;
grant web_anon to authenticator;

create role todo_user nologin;
grant usage on schema api to todo_user;
grant all on all tables in schema api to todo_user;
GRANT usage, SELECT ON ALL SEQUENCES IN SCHEMA api TO todo_user;
-- grant usage, select on sequence api.daily_id_seq to todo_user;
grant todo_user to authenticator;
```

拉取 docker image
```bash
docker compose pull
```

启动服务
```bash
docker compose -up -d
```

关闭服务
```bash
docker compose -down
```

访问信息
```
# Postgrest 接口
http://localhost:3000

# Swagger 页面
http://localhost:8080

# 数据库信息
postgres://postgres:mysecretpassword@localhost:5432/postgres
```

## 提供Zabbix开发环境

TODO

## 提供 Jupyter 开发环境

TODO
