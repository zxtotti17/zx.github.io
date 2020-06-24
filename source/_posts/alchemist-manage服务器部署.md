---
title: alchemist_manage服务器部署
date: 2018-07-11 16:55:25
categories: "开发环境安装"
tags:
	- Ruby on Rails
	- Capistrano 自动部署工具
---

1. manage服务器代码上传
copy srpg_too 目录到 /var/webapps/alchemist_mnt    (文件所有者必须为webapp)
2. ruby运行环境构建
2.1 检查依赖
-ruby(v2.2.2p95~)
-gem bundle
-Node.js
-npm
-bower
-msyql
-redis
2.1 设置gem源为淘宝源
Gemfile （描述gem之间依赖文件）需要如下修改
source 'https://gems.ruby-china.org/'
2.2  安装gem file
su  - webapp
bundle install
2.2.1 安装bundle 命令不存在，。
gem install bundle
2.2.2 提示gem命令不存在，就执行rbenv global 2.2.2， 如果无法运行就重新安装ruby 2.2.2 版本，流程如下
su - webapp
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
~/.rbenv/bin/rbenv init
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
rbenv install 2.2.2
rbenv global 2.2.2
ruby -v
<!-- more -->
3. Cap环境部署
3.1 配置SSH无密码登录
配置config/deploy/produciton.rb ssh无密码登陆（id_rsa.pub和authorized_keys） 设置authorized_keys，记得chmod 600，否则无法生效）
3.1.1 生成sshkey:
cd ~/.ssh
ssh-keygen
输入公钥名：id_rsa
![AADD68F1E0BFC2CE65796C5F7EEBD67E](AADD68F1E0BFC2CE65796C5F7EEBD67E.jpg)
3.1.2 配置authorized_keys
cat  id_rsa.pub >> authorized_keys
chmod -R 600 authorized_keys
chmod 700 ~/.ssh
备注：如果还是无法实现无密码登录，再清空下~/.ssh/koown_hosts文件（echo "" > ~/.sshown_hosts);
![AADD68F1E0BFC2CE65796C5F7EEBD67E](AADD68F1E0BFC2CE65796C5F7EEBD67E.jpg)
3.1.3执行以下deploy命令：production环境为例
 cd current
  bundle exec cap production mkdir:sockets 
bundle exec cap production bower:install
4.前端bower模块安装
4.1 Node.js 安装bower
npm install -g bower --registry=https://registry.npm.taobao.org   (-g不一定要)
4.2install Bowerfile
  	bundle exec rake bower:install
4.3 manage server DB构建
 bundle exec rake maint:create maint:migrate
 
4.4 添加管理账号
  bundle exec rake maint:seed

4.5  配置crontab 
    缺少crontab 会影响预约奖励发放
    cd 根目录（current/）
    gem install whenever ，检查config/schedule.rb是否存在
    whenever -w（写入到crontab 中）
    查看log/cron_log.log日志是否已生成。
