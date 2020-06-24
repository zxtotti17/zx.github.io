---
title: hexo 常用笔记
date: 2018-07-03 17:39:12
categories: "开发环境安装"
tags:
	- node.js
	- hexo
---
建站的过程网上一大把就不记录了，主要写下遇到的几个问题
1. github上的项目名称一定要和自己在github上的用户名一致，否则会生成静态文件后点开会白屏
2. 多看看官方手册上面有详细记录https://hexo.io/zh-cn/docs

hexo g -d
hexo clean
hexo s
hexo目录下执行这样一句话npm install hexo-asset-image --save，这是下载安装一个可以上传本地图片的插件,再运行hexo n "xxxx"来生成md博文

npm install hexo-generator-json-content --save

index_generator:
  per_page: 9 ##首页默认9篇文章标题 如果值为0不分页
archive_generator:
    per_page: 100 ##归档页面默认100篇文章标题
    yearly: true  ##生成年视图
    monthly: true ##生成月视图
tag_generator:
    per_page: 100 ##标签分类页面默认100篇文章
category_generator: 
    per_page: 100 ###分类页面默认100篇文章