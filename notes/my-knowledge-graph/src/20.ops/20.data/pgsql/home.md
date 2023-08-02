# PostgreSQL数据库

PostgreSQL 是一个功能强大的开源数据库系统。经过长达15年以上的积极开发和不断改进，PostgreSQL已在可靠性、稳定性、数据一致性等获得了业内极高的声誉。目前PostgreSQL可以运行在所有主流操作系统上，包括Linux、Unix和Windows。

PostgreSQL 是完全的事务安全性数据库，支持丰富的数据类型（如JSON和JSONB类型、数组类型）和自定义类型。PostgreSQL数据库提供了丰富的接口，可以很方便地扩展它的功能，如可以在GiST框架下实现自己的索引类型，支持使用C语言写自定义函数、触发器，也支持使用流行的编程语言写自定义函数。PL/Perl提供了使用Perl语言写自定义函数的功能，当然还有PL/Python、PL/Java、PL/Tcl等。

作为一种企业级数据库，PostgreSQL以它所具有的各种高级功能而自豪，像多版本并发控制( MVCC )、按时间点恢复(PITR)、表空间、异步复制、嵌套事务、在线热备、复杂查询的规划和优化以及为容错而进行的预写日志等。它支持国际字符集、多字节编码并支持使用当地语言进行排序、大小写处理和格式化等操作。它也在所能管理的大数据量和所允许的大用户量并发访问时间具有完全的高伸缩性。


**官网**

- 官网地址：https://www.postgresql.org
- 下载地址：https://www.postgresql.org/download/
- 安装工具：https://www.pgadmin.org/download/

  

**参考手册：**

- [官方文档PostgreSQL: Documentation](https://www.postgresql.org/docs/)
- [社区中文翻译手册](http://www.postgres.cn/docs/12/index.html)



**知识要点：**

1. [PostgreSQL 基础入门](./01.md)
2. [PostgreSQL 常用管理命令](./02.md)
3. [PostgreSQL 几个重要概念](./03.md)
4. [PostgreSQL 日常运维管理](./04.md)
5. [PostgreSQL 备份与恢复](./05.md)

