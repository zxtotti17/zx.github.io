---
title: ALC_Sentry
date: 2018-07-24 16:06:55
categories: "开发环境安装"
tags:
	- Sentry
---
1) 安装环境
执行命令创建名为sentry的数据库
createdb -E utf-8 sentry
为sentry项目初始化数据
sentry --config=~/.sentry/sentry.conf.py upgrade
创建新用户
sentry --config=~/.sentry/sentry.conf.py createuser
然后就可以启动服务了
sentry --config=~/.sentry/sentry.conf.py start
另外，还需要启动Worker
sentry --config=~/.sentry/sentry.conf.py celery worker -B
假设web服务器端口是9000，那么访问localhost:9000就能开始使用sentry了！


source /usr/local/vir-sentry/bin/activate 
sentry --config=~/.sentry/sentry.conf.py start >> /usr/local/vir-sentry/logs/sentry.log 2>&1 &
<!-- more -->

2）相关命令
2.1启动 
su - webapp 
source /usr/local/vir-sentry/bin/activate
supervisord -c /etc/supervisord.conf 
supervisorctl start all 
2.2关闭命令 
su - webapp
source /usr/local/vir-sentry/bin/activate
supervisorctl stop all 
killall supervisord

*创建账号 sentry createuser
3)基于node的测试demo
[raven-node-master.zip](/download/raven-node-master.zip)

4.）界面显示
![9E26651338B7EE1345DAFDEF0ADDB9C4](9E26651338B7EE1345DAFDEF0ADDB9C4.jpg)

web 服务器相关配置	
![E4B1DB656739C13A7F75B5578E3CB678](E4B1DB656739C13A7F75B5578E3CB678.jpg)