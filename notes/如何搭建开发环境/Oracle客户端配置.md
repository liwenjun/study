
下载 Oracle Instant Client 点 [这里](https://www.oracle.com/cn/database/technologies/instant-client.html)

`Rust`有2个包可用于开发`Oracle`应用 [sibyl](https://crates.io/crates/sibyl) 和 [oracle](https://crates.io/crates/oracle)

## 配置 tnsnames.ora

```
orcl =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 127.0.0.1)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = orcl)
    )
  )
```

## Windows环境下的配置

将下载的软件包解压缩到`D:\App`文件夹，设置环境变量

```INI
Path=D:\App\instantclient_12_2;
TNS_ADMIN=D:\App\instantclient_12_2\network
NLS_LANG=SIMPLIFIED CHINESE_CHINA.ZHS16GBK
ORACLE_HOME=D:\App\instantclient_12_2
```

如果不清楚远程数据库的ORACLE 语言，可以到远程机器，用命令行连接到数据库，查看NLS_LANGUAGE 的值。

```sql
select * from nls_instance_parameters;
```

## Linux 环境下的安装配置

### CentOS （rpm包安装）

使用命令安装
```
sudo yum install -y libaio
sudo rpm -ivh oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm
sudo rpm -ivh oracle-instantclient12.2-jdbc-12.2.0.1.0-1.x86_64.rpm
sudo rpm -ivh oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm
sudo rpm -ivh oracle-instantclient12.2-devel-12.2.0.1.0-1.x86_64.rpm
sudo rpm -ivh oracle-instantclient12.2-tools-12.2.0.1.0-1.x86_64.rpm
```
环境变量配置： 
```
sudo mkdir -p /usr/lib/oracle/12.2/client64/network/admin
vi ~/.bash_profile
```
添加以下内容：
```
# .bash_profile
...
export ORACLE_VERSION=12.2
export ORACLE_HOME=/usr/lib/oracle/$ORACLE_VERSION/client64
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export TNS_ADMIN=$ORACLE_HOME/network/admin
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
# export NLS_LANG="Simplified Chinese_china".ZHS16GBK
export PATH=$PATH:$ORACLE_HOME/bin
```
配置TNS：
```
/usr/lib/oracle/12.2/client64/network/admin/tnsnames.ora
```




