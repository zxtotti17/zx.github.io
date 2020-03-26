---
title: redis笔记
date: 2018-08-01 16:52:31
categories: "数据库"
tags:
	- redis
---

1. Redis是什么、特点、优势
redis是Key-Value数据库,数据包含各种数据 字符串String、字典Hash、列表List、集合Set、有序集合SortedSet等
  redis支持数据持久化，重启再次加载,支持数据备份(支持分布式),Redis是单进程单线程的
Redis的优势
  性能高 读速度110000/s 写速度81000/s
  丰富的数据类型

2. redis安装（Linux）、启动、退出、设置密码、远程连接
2.1 安装redis
下载redis安装包（如：redis-2.8.17.tar.gz）
``` bash
tar -zxvf redis-2.8.17.tar.gz
cd redis-2.8.17
make
sudo make install
```
2.2 后台启动服务端
``` bash
nohup redis-server &
```
2.3 启动客户端、验证
``` bash
cd /usr/local/bin
redis-cli
set var "hello world"
get var
```
<!-- more -->

3. Reis key
序号	Redis keys命令及描述
1	DEL key
该命令用于在 key 存在是删除 key。
2	DUMP key 
序列化给定 key ，并返回被序列化的值。
3	EXISTS key 
检查给定 key 是否存在。
4	EXPIRE key seconds
为给定 key 设置过期时间。
5	EXPIREAT key timestamp 
EXPIREAT 的作用和 EXPIRE 类似，都用于为 key 设置过期时间。 不同在于 EXPIREAT 命令接受的时间参数是 UNIX 时间戳(unix timestamp)。
6	PEXPIRE key milliseconds 
设置 key 的过期时间亿以毫秒计。
7	PEXPIREAT key milliseconds-timestamp 
设置 key 过期时间的时间戳(unix timestamp) 以毫秒计
8	KEYS pattern 
查找所有符合给定模式( pattern)的 key 。例如keys * 返回所有的key
9	MOVE key db 
将当前数据库的 key 移动到给定的数据库 db 当中。
10	PERSIST key 
移除 key 的过期时间，key 将持久保持。
11	PTTL key 
以毫秒为单位返回 key 的剩余的过期时间。
12	TTL key 
以秒为单位，返回给定 key 的剩余生存时间(TTL, time to live)。
13	RANDOMKEY 
从当前数据库中随机返回一个 key 。
14	RENAME key newkey 
修改 key 的名称
15	RENAMENX key newkey 
仅当 newkey 不存在时，将 key 改名为 newkey 。
16	TYPE key 
返回 key 所储存的值的类型。
...
[中文文档](http://redisdoc.com)

4. Redis 发布订阅
占时没用过，看起来跟微信公众号一样,Pub/Sub做延时队列可以用在玩家登录排队上

5. Redis事务
一个事务从开始到结束经过以下三个阶段：

开始事务
命令入队
执行事务
例子

``` bash
localhost:6379> MULTI
OK
localhost:6379> set name jihite
QUEUED
localhost:6379> get name
QUEUED
localhost:6379> sadd language "c++" "python" "java"
QUEUED
localhost:6379> smembers language
QUEUED
localhost:6379> exec
```
说明：事务以MULTI开始，以EXEC结束

6. 关闭持久化与持久化
(RDB)bgsave做镜像全量持久化，aof做增量持久化
RDB相当于快照，是fork一个子进程，快照成功后替换
aof相当于日志，cow，copy and write,一条一条的数据

这是redis与其他缓存服务的比较明显的特点,如memcache
修改配置文件，改完后重启。
``` bash
#save 900 1  
#save 300 10  
#save 60 10000  
```
或执行操作命令
``` bash
CONFIG SET save ""
```

7. redis相比memcached有哪些优势？

(1) memcached所有的值均是简单的字符串，redis作为其替代者，支持更为丰富的数据类型
(2) redis的速度比memcached快很多
(3) redis可以持久化其数据

8. redis常见性能问题和解决方案：

(1) Master最好不要做任何持久化工作，如RDB内存快照和AOF日志文件
(2) 如果数据比较重要，某个Slave开启AOF备份数据，策略设置为每秒同步一次
(3) 为了主从复制的速度和连接的稳定性，Master和Slave最好在同一个局域网内
(4) 尽量避免在压力很大的主库上增加从库
(5) 主从复制不要用图状结构，用单向链表结构更为稳定，即：Master <- Slave1 <- Slave2 <- Slave3...

这样的结构方便解决单点故障问题，实现Slave对Master的替换。如果Master挂了，可以立刻启用Slave1做Master，其他不变。

9. Redis 常见的性能问题都有哪些？如何解决？
1).Master写内存快照，save命令调度rdbSave函数，会阻塞主线程的工作，当快照比较大时对性能影响是非常大的，会间断性暂停服务，所以Master最好不要写内存快照。
2).Master AOF持久化，如果不重写AOF文件，这个持久化方式对性能的影响是最小的，但是AOF文件会不断增大，AOF文件过大会影响Master重启的恢复速度。Master最好不要做任何持久化工作，包括内存快照和AOF日志文件，特别是不要启用内存快照做持久化,如果数据比较关键，某个Slave开启AOF备份数据，策略为每秒同步一次。
3).Master调用BGREWRITEAOF重写AOF文件，AOF在重写的时候会占大量的CPU和内存资源，导致服务load过高，出现短暂服务暂停现象。
4). Redis主从复制的性能问题，为了主从复制的速度和连接的稳定性，Slave和Master最好在同一个局域网内

10. Redis分布式锁
拿setnx来争抢锁，抢到之后，再用expire给锁加一个过期时间防止锁忘记了释放。

11. Redis做异步队列
一般使用list结构作为队列，rpush生产消息，lpop消费消息。当lpop没有消息的时候，要适当sleep一会再重试。
