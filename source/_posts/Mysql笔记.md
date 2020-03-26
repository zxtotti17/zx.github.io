---
title: Mysql笔记
date: 2018-10-31 15:04:42
categories: "数据库"
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


