# Svn 轻松上手

SVN是subversion的缩写，是一个开放源代码的版本控制系统，通过采用分支管理系统的高效管理，简而言之就是用于多个人共同开发同一个项目，实现共享资源，实现最终集中式的管理。

## 安装配置服务端

```shell
# Centos
yum install subversion

# 创建SVN版本库目录，为后面创建版本库提供存放位置，也是最后启动SVN服务的根目录。
# 在/usr路径下创建svn目录作为版本库目录。
cd /usr
mkdir svn

# 创建SVN版本库
cd /usr/svn
svnadmin create dev

# 配置文件目录
cd /usr/svn/dev/conf
ls
```

**配置文件**

- authz：权限配置文件，控制读写权限
- passwd：账号密码配置文件
- svnserve.conf：svn服务器配置文件

**修改svnserve.conf文件**

去掉anon-access、auth-access、password-db、authz-db、realm几项前的注释符号“#”。

配置项含义：

- anon-access = none|read|write 决定非授权用户的访问级别。none 表示无访问权限，read 表示只读，write 表示可读可写，默认为 read。
- auth-access = none|read|write 决定授权用户的访问级别，使用与上面相同的访问级别。默认为 write。
- password-db = filename 指定账号密码数据库文件名。filename 是相对仓库中 conf 目录的位置，也可以设置为绝对路径，默认为passwd。
- authz-db = filename 指定权限配置文件名，filename 是相对仓库中 conf 目录的位置，也可以设置为绝对路径，默认为authz。
- realm = realm-name 指定版本库的认证域，即在登录时提示的认证域名称。若两个版本库的认证域相同，建议使用相同的账号密码数据库文件passwd。

**修改passwd文件**

只需在末尾添加账号和密码，格式 `账号 = 密码`，如`user1 = 123456`，可添加多个。

**修改authz文件**

如果想设置其他用户的权限，可以通过`*`设置，如设置除@team1分组外其他用户只读权限：

```text
 [/]
 @team1 = rw
 * = r
```

**启动SVN服务**

执行SVN启动命令，其中参数`-d`表示以守护进程的方式启动， `-r`表示设置的根目录。

```text
 svnserve -d -r /usr/svn/
```

关闭svn命令：

```text
 killall svnserve
```


## 安装客户端

Windows上推荐安装[TortoiseSVN](https://tortoisesvn.net/downloads.html)

