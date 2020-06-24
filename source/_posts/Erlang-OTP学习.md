---
title: Erlang OTP学习
date: 2019-04-09 16:50:32
tags:
	- Erlang
---

1.-behaviour(gen_server) 
它表示让编译器检查，当前module是否实现了gen_server指定的所有回调接口

2.gen_server:start_link(ServerName, Module, Args, Options) -> Result 
这个方法用来启动一个server，其中： 
参数ServerName指定了服务名 
参数Module指定了该server的callback模块 
参数Args将作为服务初始化的启动参数（服务初始化时会调用：Module:init([Args])） 
参数Options指定了一些特性参数，通常可以直接使用[] 

如果服务启动成功，返回{ok, Pid} 

3.Module:init([Args]) 
这个方法会在服务初始化时被回调，参数Args就是gen_server:start_link中倒数第二个参数，若初始化成功，该方法放回{ok, State},其中State将作为启动服务的State 

4.gen_server:call(ServerRef, Request) 
这个方法供callback模块向ServerRef代表的服务发送Request请求（callback模块通常会在之上再封装一层接口供客户端调用，譬如这里的add，find方法），注意该方法是一个同步调用，它会一直等待服务器返回一个响应消息（除非等待超时，默认5s） 

5.Module:handle_call(Request, From, State) -> Result 
这是一个回调方法，用来处理gen_server:call(ServerRef, Request)发出的请求，其中： 
Request，表示客户端请求 
From，表示请求来自哪个客户端 
State，表示当前服务器状态 

Result为handle_call 请求处理结果，它有以下几种类型 
{reply,Reply,NewState} 
{reply,Reply,NewState,Timeout} 
{reply,Reply,NewState,hibernate} 
{noreply,NewState} 
{noreply,NewState,Timeout} 
{noreply,NewState,hibernate} 
{stop,Reason,Reply,NewState} | {stop,Reason,NewState} 

这几种返回值有什么区别呢？ 
如果返回的是以reply开头，那么Reply将会作为响应返回给客户端 
如果返回的是以noreply开头，那么服务器将不会返回任何消息给客户端（这会导致客户端阻塞，因为客户端调用的gen_server:call方法是一个同步调用，当它发出请求后，会一直等待服务器发送响应消息，除非等待超时） 

6.gen_server:cast(ServerRef, Request) 
这个方法同gen_server:call(ServerRef, Request)，但它最大的区别就是该调用是异步的，它不需要等待服务器返回任何处理结果 

7.Module:handle_cast(Request, State) -> Result 
这个方法用来处理gen_server:cast(ServerRef, Request)发出的请求，由于不会返回结果给客户端，所以参数列表中也没有From 

8.检查进程是否加载
``` bash
erlang:whereis(?MODULE).
```

9.查看进程的信息
``` bash
erlang:process_info(pid(0,PID,0)).
```