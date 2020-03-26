---
title: pomelo学习笔记
date: 2018-10-23 19:34:45
categories: "服务端框架"
tags:
	- node.js
---

环境
``` bash
getBase()	 Application.getBase(); 获取应用程序的基本路径
set(setting, val, attach);	 Application.set();  setting:应用程序的配置；val:需要设置的值；attach:是否将设配置应用到程序。设置或返回配置的值。
get(setting)	 Application.get(); setting:应用程序的配置。获取配置的值
enabled(setting)	 Application.enabled(); setting:应用程序的配置。检查配置是否启用
disabled(setting)	 Application.disabled(); setting:应用程序的配置。检查配置是否禁用
enbale(setting)	 Application.enbale(); setting:应用程序的配置。启用配置
disable(setting)	 Application.disabled(); setting:应用程序的配置。禁用配置
configure(env,fn,type)	Application.configure();env:应用环境;fn:回调函数;type:服务类型.
```
初始化

``` bash
start()	 Application.start(); 启动应用程序。它会加载默认的组件和启动所有加载的组件。
registerAdmin(moduleId,module,opts)	 Application.registerAdmin();  moduleId:(可选参数)模块id或者有modeule提供的模块Id;module:模块对象或者模块的工程函数;opts:模块构造函数的参数。
filter(filter)	 Application.filter(); filter:provide before and after filter method。add a filter to before and after filter
before(bf)	 Application.before(); bf:before filter。Add before filter
after(af)	 Application.after(); af:after filter。Add after filter
load(name, component, opts)	 Application.load(); name:组件的名称（可选）；component：组件的实例或者组件的工厂函数；opts：组件构造函数的参数（可选）。加载组件
loadConfig(key,val)	 Application.loadConfig(); key:环境配置的关键字;val:环境配置的值。导入json文件来配置环境。
```
<!-- more -->
组件相关

``` bash
route(serverType, routeFunc)	
 Application.route(); serverType:服务类型;routeFunc:路由功能函数,如：routeFunc(session, msg, app, cb)

未指定的服务类型设置路由功能。如：

app.route('area', routeFunc);

var routeFunc = function(session, msg, app, cb) {

　　// all request to area would be route to the first area server

　　var areas = app.getServersByType('area');

　　cb(null, areas[0].id);

}
```
获取相关配置，组件方法

``` bash
getMaster()	Application.getMaster() 获得Maseter服务的信息
getCurServer()	Application.getCurServer() 获得当前服务的信息
getServerId()	Application.getServerId() 获得当前服务的ID
getServerType()	Application.getServerType() 获得当前服务的类型
getServers()	Application.getServers() 获得所有当前服务的信息
getServersFromConfig()	Application.getServersFromConfig() 从server.json中获得所有服务的信息
getServerTypes()	Application.getServerTypes() 获得所有服务的类型
getServerById(serverId)	Application.getServerById() 根据服务ID从服务集群中获得服务的信息
getServerFromConfig(serverId)	Application.getServerFromConfig() 根据服务ID从server.json中获得服务的信息
getServersByType(serverType)	Application.getServersByType() 根据服务类型获取服务信息
isFrontend(server)	Application.isFrontend() 检查服务是否是一个前端服务
isBackend(server)	Application.isBackend() 检查服务是否是一个后端服务
isMaster()	Application.isMaster() 检查当前服务是否是主服务
addServers(servers)	Application.addServers() servers：新服务信息列表。添加新服务信息到正在运行的应用程序中
removerServers(ids)	Application.removerServers() ids：服务id列表。从当前运行的应用程序中删除服务信息。
```
创建和维护本地服务的信道。

``` bash
createChannel(name)	ChannelService.prototype.createChannel() 根据信道名称创建信道，如果该信道已存在则返回已存在的信道
getChannel(name,create)	ChannelService.prototype.getChannel() name:信道名称，create:如果为true，并且信道不存在时，则创建新的信道。根据信道名称获取信道
destroyChannel(name)	ChannelService.prototype.destroyChannel() 根据信道名称，删除信道
pushMessageByUids(route, msg, uids, cb)	ChannelService.prototype.pushMessageByUids() route：消息路由；msg：发送到客户端的消息；uids：接收消息的客户端列表，格式 [{uid: userId, sid: frontendServerId}]；cb：回调函数 cb(err)。根据uids将消息推送给客户端，如果uids中的sid未指定，则忽略相应的客户端
broadcast(stype,route, msg, opts, cb)	ChannelService.prototype.broadcast() stype：前端服务的类型;route：路由;msg：消息;opts：广播参数;cb：回调函数。广播消息到所有连接的客户端。
```
Channel

``` bash
add(uid,sid)	Channel.prototype.add() uid:用户编号；sid：用户连接到的前端服务id。添加指定用户到信道。
leave(uid,sid)	Channel.prototype.leave() uid:用户编号；sid：用户连接到的前端服务id。从信道中移除用户。
getMembers()	Channel.prototype.getMembers() 获得信道中的成员
getMember(uid)	Channel.prototype.getMember() 根据uid获取成员信息
destroy()	Channel.prototype.destroy() 销毁信道
pushMessage(route,msg,cb)	Channel.prototype.pushMessage()  route：消息路由，msg：要推送的消息，cb：回调函数。将消息推送给信道的所有成员。
```
GlobalChannelService

``` bash
destroyChannel(name,cb)	GlobalChannelService.prototype.destroyChannel() uid:用户编号；sid：用户连接到的前端服务id。添加指定用户到信道。
add(name,uid,sid,cb)	
GlobalChannelService.prototype.add() name:信道名称；uid：用户id；sid：前端服务id；cb：回调函数。

添加成员到信道。

leave(name,uid,sid,cb)	GlobalChannelService.prototype.leave() 
name:信道名称；uid：用户id；sid：前端服务id；cb：回调函数。

从信道中移除成员。

pushMessage()	
GlobalChannelService.prototype.pushMessage(serverType, route, msg,channelName, opts, cb)

serverType：前端服务的类型, route：路由, msg：需要推送的消息,channelName：信道名称, opts：参数, cb：回调函数

通过全局信道发送消息
```
LocalSessionService

``` bash
get(frontendId,sid,cb)	LocalSeesionService.prototype.get() frontendId:会话链接的前端服务id,sid:会话Id,cb:回调函数。根据前端服务和会话id获得本地会话
getByUid(name,uid,sid,cb)	
LocalSeesionService.prototype.getByUid()  frontendId:会话链接的前端服务id,uid：绑定到会话的用户id，cb：回调函数。args: cb(err, localSessions)。根据前端服务和用户id获取本地会话。

kickBySid(name,uid,sid,cb)	LocalSeesionService.prototype.kickBySid() frontendId:会话链接的前端服务id,sid:会话Id,cb:回调函数。根据会话id踢掉该会话。
kickByUid()	
LocalSeesionService.prototype.kickByUid() frontendId:会话链接的前端服务id,uid：用户id,cb:回调函数。根据用户id踢掉该会话。
```
LocalSession

``` bash
bind(uid,cb)	LocalSeesion.prototype.bind() uid:用户编号;cb:回调函数。callfunction(err)。绑定当前会话，用于前端服务的推送和全局会话的绑定。
unbind(uid,cb)	
LocalSeesion.prototype.unbind() uid:用户编号;cb:回调函数。callfunction(err)。取消绑定。

set(key,value)	LocalSeesion.prototype.set() 将key/value添加到本地会话中
get(key)	
LocalSeesion.prototype.get() 根据key从本地会话中获取值。

push(key,cb)	
LocalSeesion.prototype.push() 将本地会话中的key/value添加到全局会话中

pushAll(cb)	LocalSeesion.prototype.pushAll() 将本地会话中的所有key/value添加到全会话中
```
SessionService

``` bash
kick(uid,cb)	SeesionService.prototype.kick() 踢掉该用户的所有离线会话
kickBySession(sid,cb)	
SeesionService.prototype.kickBySession() sid:会话编号;cb:回调函数。根据会话id踢掉一个在线用户

sendMessage(sid,msg)	SeesionService.prototype.sendMessage()根据会话id向客户端发送消息
sendMessageByUid(uid,msg)	
SeesionService.prototype.sendMessageByUid() 根据用户id向客户端发送消息
```
Pomelo

``` bash
createApp(opts)	Pomelo.create() 创建一个Pomelo 应用程序



