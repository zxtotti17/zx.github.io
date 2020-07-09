---
title: mysql笔记
date: 2020-07-06 16:40:36
tags:
	- mysql
---


第1章 SQL基础
1.数据分为DDL(数据定义语言)，DML(数据操纵语言)，DCL(数据控制语言)
	1.1 DDL语句
	``` bash
	mysql -uroot -p
	create database test1;
	use test1;
	show tables;   								#查看所有表
	drop database test1;
	create table emp(ename varchar(10),hiredate date,sal decimal(2,10),deptno int(2));
	desc emp;									#查看表信息
	show create table emp \G;					#\G使得记录能够按照字段竖向排列 以便显示更长内容
	drop table emp;
	alter table emp modify ename varchar(20);	#修改表字段
	alter table emp add column age int(3);		#添加字段
	alter table emp drop colum age				#删除字段
	alter table emp change age age123 int(4);	#字段改名同时修改类型
	alter table emp add birth date after ename;	#修改字段排列顺序
	alter table emp rename emp1;
	```

<!-- more -->
	1.2 DML语句 增删改查
	``` bash
	insert into emp (ename,sal) values('dony',1000);
	delete from emp where ename = 'xxx';
	select distinct age from emp1;												#查询的内容去重
	select * from emp order by age,deptno desc;									#根据某个字段排序
 	select age,count(1) from emp group by age with rollup;						#分类统计计数及总数
 	select age,count(1) from emp group by age having count(1)>1;
 	select ename,deptname from emp,dept where emp.age = dept.age;				#联查,内链接
 	select ename,deptname from emp left jion dept on emp.deptno = dept.deptno;	#表链接很多情况下优于子查询
 	select * from dept union all select * from emp;								#集合显示不去重
 	select * from dept union select * from emp;									#集合显示去重
	```
	You can't specify target table ' for update in FROM clause
	Mysql不让对查询到的目标语句进行更新
	``` bash
	DELETE FROM playeritems WHERE id IN(SELECT mid FROM (SELECT min(id) as mid FROM playeritems WHERE uid = '1300200112870961' GROUP BY iname HAVING count(iname) > 1 )as tmp);
	```

	1.3 DCL语句
	``` bash
	grant select,insert on sakila.* to 'z1@localhost' identified by '123'; 		#赋予用户权限
	revoke insert on sakila.* from 'z1@localhost';								#回收权限
	```

2.常用函数
	``` bash
	select NOW();									#xxxx-xx-xx xx:xx:xx
	select UNIX_TIMESTAMP(now());					#时间戳
	select FROM_UNIXTIME(时间戳);					#xxxx-xx-xx xx:xx:xx
	IF(value,t,f)									#如果value为真，返回t,否则返回f
	select if(a > 2000, 'high','low') from B
	IFNULL(value1,value2)							#如果value1不为空，返回value1,否则返回value2
	select ifnull(a , 0) from B
	CASE WHEN value THEN res1 ... ELSE def END		#如果value1真，返回res1,否则返回def
	select case when a<2000 then 'low' else 'high' end from B
	CASE exp WHEN value THEN res1 ... ELSE def END	#如果exp = value1真，返回res1,否则返回def
	select case a when 1000 then 'low' when 2000 then 'mid' else 'high' end from B
	```

第2章 存储引擎
1.mysql的存储引擎有好多种，这边记录2种
	1.1 MyISAM 不支持事务、不支持外键、速度快、表锁
	1.2 InnoDB 支持提交、回滚、奔溃恢复能力的事务安全，行锁

2.myssql事务
``` bash
start transaction;
sql 操作
commit and chain;
```

3.防止sql注入
``` bash
$re = "/(|\'|(\%27)|\;|(\%3b)|\=|(\%3d)|\(|(\%28)|\)|(\%29)|(\/*) |(\%2f%2a)|(\ */)|(\%2a%2f)|\+|(\%2b)|\<|(\%3c)|\>|(\%3e)|\(--))|\[|\%5b|\]|\%5d)/";

if(preg_match($re, $aa) >0){
	echo("参数不对");
	return 0;
}
```

4.SQL MODE
ANSI 使语法行为更符合sql
STRICT_TRANS_TABLES 试用于事务，严格模式，报错不警告,不允许非法日期
TRADITIONAL 严格模式，适用于事务非事务，不警告直接报错

5.sql分区
RANGE分区：基于一个给定连续区间范围，把数据分配到不同分区
LIST分区：类似RANGE
HASH分区：基于给定的分区个数，把数据分配到不同分区
KEY分区：类似于HASH分区
RANGE\LIST\HASH分区键必须INT型

好处4点
存储更多数据、优化查询、快速删除数据、获得更大查询吞吐量
Range分区利用取值范围将数据分成分区
``` bash
CREATE TABLE emp(
id INT NOT NULL,
NAME VARCHAR(20),
age INT
)
PARTITION BY RANGE(ID)(
PARTITION p0 VALUES LESS THAN (6),
PARTITION p1 VALUES LESS THAN (11),
PARTITION pmax VALUES LESS THAN maxvalue
);
```
LIST分区是建立离散的之列表告诉数据库特定值在哪个分区
``` bash
CREATE TABLE expense(
expense_date DATE NOT NULL,
category INT,
amount DECIMAL (10,3)
)
PARTITION BY LIST(category)(
PARTITION p0 VALUES IN(3,5),#可字符串在5.5版本后
PARTITION p1 VALUES IN(1,10),
PARTITION p2 VALUES IN(4,9),
PARTITION p3 VALUES IN(2),
PARTITION p4 VALUES IN(6)
);
```
Columns分区可分为 RANGE Columns和LIST Columns分区都支持int\date\string,还支持多列
``` bash
CREATE TABLE expense(
a INT,
b INT
)
PARTITION BY RANGE COLUMS(a,b)(
PARTITION p0 VALUES IN(0,10),#可字符串在5.5版本后
PARTITION p1 VALUES IN(10,10),
PARTITION p2 VALUES IN(10,29)
);
```
HASH分区用来分散热点读，确保数据在预留分区平均分布，有常规分区和线性分区
``` bash
#常规 平衡不方便
CREATE TABLE emp(
id INT NOT NULL,
NAME VARCHAR(20),
age INT
)
PARTITION BY HASH(ID) PARTITIONS 4;
#线性 快速不平衡
CREATE TABLE emp(
id INT NOT NULL,
NAME VARCHAR(20),
age INT
)
PARTITION BY LINEAR HASH(ID) PARTITIONS 4;
```
key分区
类似HASH分区，数据类型除TEXThe BLOB以外都可以

RANGE&LIST 分区管理 分区被删除了分区中的数据也被删除了
``` bash
alter table xxx drop partition p2; #删
alter table xxx add partition (partiton p5 values less than (2025)) #增  不能添加一个包含现有分区值列表中的任意值分区
alter table xxx reorganize partition p3 into (
	partition p2 values less than (2005),
	partition p3 values less than (2015)
);			#拆分
alter table xxx reorganize partition p1,p2,p3 into (
	partition p1 values less than (2015)
);		#合并
```

HASH&KEY 分区管理
``` bash
alter table xxx coalesce partition 2; #原4删2
alter table xxx coalesce partition 8; #原4加8
```

6.SQL优化
1. 通过慢查询日志定位效率低的sql,在查询过程中出现的情况可以用show processlist命令查看mysql进程，看锁表及进程状态
2. 将慢的sql提取做explain分析，type的性能如下
	ALL,全表扫瞄
	index,索引全扫描
	range,索引范围扫描 常见<\<=\>\>=\between
	ref,使用非唯一索引扫描或者唯一索引前缀扫描（联合索引）
	eq_ref,使用唯一索引
	const/system,单表中最多有一个匹配行
	NULL，不查表直接得到结果
	自上而下效率越来越高
3. 通过show profile分析sql
``` bash
	select @@have_profiling;	#查询是否支持
	select @@profiling;		#查询是否开启
	set profiling=1;		#开启
	show profiles;			#显示sql的执行排列
	show profile for query 4;	#查找具体某一条的状态
	show profile cpu for query 4;	#查询莫一条在具体（all\cpu\block io\context\switch\page faults）
```

mac或者linux当mysql连接不上的时候加
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';

7.mysql配置优化
在mysqld下

<label style="color:red">为所有线程打开的表的数量。增加这个值会增加mysqld需要的文件描述符的数量。因此，您必须确保在[mysqld_safe]节中的变量“open-files-limit”中将允许打开的文件数量至少设置为4096</label>
table_open_cache=2000

<label style="color:red">内部(内存)临时表的最大大小。如果一个表比这个值大，那么它将自动转换为基于磁盘的表。可以有很多。</label>
tmp_table_size=94M

<label style="color:red">我们应该在缓存中保留多少线程以供重用。当客户机断开连接时，如果之前的线程数不超过thread_cache_size，则将客户机的线程放入缓存。如果您有很多新连接，这将大大减少所需的线程创建量(通常，如果您有一个良好的线程实现，这不会带来显著的性能改进)。</label>
thread_cache_size=10

<label style="color:red">如果用于快速创建索引的临时文件比这里指定的使用键缓存的文件大，则首选键缓存方法。这主要用于强制大型表中的长字符键使用较慢的键缓存方法来创建索引。</label>
key_buffer_size=8M

<label style="color:red">用于对MyISAM表执行全表扫描的缓冲区的大小。如果需要完整的扫描，则为每个线程分配。</label>
read_buffer_size=16M
read_rnd_buffer_size=32M

<label style="color:red">如果在SHOW GLOBAL STATUS输出中每秒看到许多sort_merge_passes，可以考虑增加sort_buffer_size值，以加快ORDER BY或GROUP BY操作的速度，这些操作无法通过查询优化或改进索引来改进。</label>
sort_buffer_size=16M

<label style="color:red">InnoDB用于缓冲日志数据的缓冲区大小。一旦它满了，InnoDB就必须将它刷新到磁盘。由于它无论如何每秒刷新一次，所以将它设置为非常大的值是没有意义的(即使是长事务)。</label>
innodb_log_buffer_size=5M

<label style="color:red">与MyISAM不同，InnoDB使用缓冲池来缓存索引和行数据。设置的值越大，访问表中的数据所需的磁盘I/O就越少。在专用数据库服务器上，可以将该参数设置为机器物理内存大小的80%。但是，不要将它设置得太大，因为物理内存的竞争可能会导致操作系统中的分页。注意，在32位系统上，每个进程的用户级内存可能被限制在2-3.5G，所以不要设置得太高。</label>
innodb_buffer_pool_size=20M

<label style="color:red">ORDER BY 或者GROUP BY 操作的buffer缓存大小</label>
innodb_sort_buffer_size = 64M

<label style="color:red">为了提升扩展性和刷脏效率，在5.7.4版本里引入了多个page cleaner线程。从而达到并行刷脏的效果
在该版本中，Page cleaner并未和buffer pool绑定，其模型为一个协调线程 + 多个工作线程，协调线程本身也是工作线程。因此如果innodb_page_cleaners设置为8，那么就是一个协调线程，加7个工作线程</label>
innodb_page_cleaners = 4

<label style="color:red">mysql客户端连接数据库是交互式连接，通过jdbc连接数据库是非交互式连接</label>
interactive_timeout = 100 # 交互式连接超时
wait_timeout = 100 # 非交互连接超时

8.mysql索引背后的数据结构及算法
# B-Tree
为了描述B-Tree，首先定义一条数据记录为一个二元组[key, data]，key为记录的键值，对于不同数据记录，key是互不相同的；data为数据记录除key外的数据。那么B-Tree是满足下列条件的数据结构：
d为大于1的一个正整数，称为B-Tree的度。
h为一个正整数，称为B-Tree的高度。
每个非叶子节点由n-1个key和n个指针组成，其中d<=n<=2d。
每个叶子节点最少包含一个key和两个指针，最多包含2d-1个key和2d个指针，叶节点的指针均为null 。
所有叶节点具有相同的深度，等于树高h。
key和指针互相间隔，节点两端是指针。
一个节点中的key从左到右非递减排列。
所有节点组成树结构。
每个指针要么为null，要么指向另外一个节点。
如果某个指针在节点node最左边且不为null，则其指向节点的所有key小于\(v(key_1)\)，其中\(v(key_1)\)为node的第一个key的值。
如果某个指针在节点node最右边且不为null，则其指向节点的所有key大于\(v(key_m)\)，其中\(v(key_m)\)为node的最后一个key的值。
如果某个指针在节点node的左右相邻key分别是\(key_i\)和\(key_{i+1}\)且不为null，则其指向节点的所有key小于\(v(key_{i+1})\)且大于\(v(key_i)\)。
图2是一个d=2的B-Tree示意图。
![图2](1594024645933.jpg)

由于B-Tree的特性，在B-Tree中按key检索数据的算法非常直观：首先从根节点进行二分查找，如果找到则返回对应节点的data，否则对相应区间的指针指向的节点递归进行查找，直到找到节点或找到null指针，前者查找成功，后者查找失败。B-Tree上查找算法的伪代码如下：
```bash
BTree_Search(node, key) {
    if(node == null) return null;
    foreach(node.key)
    {
        if(node.key[i] == key) return node.data[i];
            if(node.key[i] > key) return BTree_Search(point[i]->node);
    }
    return BTree_Search(point[i+1]->node);
}
```
data = BTree_Search(root, my_key);
关于B-Tree有一系列有趣的性质，例如一个度为d的B-Tree，设其索引N个key，则其树高h的上限为\(log_d((N+1)/2)\)，检索一个key，其查找节点个数的渐进复杂度为\(O(log_dN)\)。从这点可以看出，B-Tree是一个非常有效率的索引数据结构。

# B+Tree
MySQL就普遍使用B+Tree实现其索引结构
与B-Tree相比，B+Tree有以下不同点：
每个节点的指针上限为2d而不是2d+1。
内节点不存储data，只存储key；叶子节点不存储指针。
图3是一个简单的B+Tree示意。
![图3](1594091073360.jpg)

一般在数据库系统或文件系统中使用的B+Tree结构都在经典B+Tree的基础上进行了优化，增加了顺序访问指针

# MyISAM索引
使用的是B+Tree作为索引结构，叶节点的data域存放的是数据记录的地址
![图4](1594103060655.jpg)

# InnoDB索引
InnoDB也使用B+Tree作为索引结构
第一重大区别是InnoDB的数据文件本身就是索引文件，InnoDB表数据文件本身就是主索引
![图5](1594103257328.jpg)
因为InnoDB的数据文件本身要按主键聚集，所以InnoDB要求表必须有主键（MyISAM可以没有）如果没有显式指定，则MySQL系统会自动选择一个可以唯一标识数据记录的列作为主键，如果不存在这种列，则MySQL自动为InnoDB表生成一个隐含字段作为主键，这个字段长度为6个字节，类型为长整形
第二个与MyISAM索引的不同是InnoDB的辅助索引data域存储相应记录主键的值而不是地址
![图6](1594103590868.jpg)
聚集索引这种实现方式使得按主键的搜索十分高效，但是辅助索引搜索需要检索两遍索引：首先检索辅助索引获得主键，然后用主键到主索引中检索获得记录
<label style="color:red">因为InnoDB数据文件本身是一颗B+Tree，非单调的主键会造成在插入新记录时数据文件为了维持B+Tree的特性而频繁的分裂调整，十分低效，而使用自增字段作为主键则是一个很好的选择</label>

# InnoDB的主键选择与插入优化
在使用InnoDB存储引擎时，如果没有特别的需要，请永远使用一个与业务无关的自增字段作为主键 （百万条以下的数据看不出来多大区别）



9.mysql 调优过程中的常用命令
ps -es|grep mysql
# 当启动不了或者报错的时候，版本低的mysql Password字段是authentication_string,配置太多会报错启动用
/usr/local/mysql/bin/mysqld --user=mysql 
# 刷新数据库 进mysql后
flush privileges
# Access denied for user 'root@localhost'报错
update mysql.user set authentication_string='123' where user='root'; 有Password用Password

