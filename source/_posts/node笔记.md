---
title: node笔记
date: 2018-08-21 17:04:37
categories: "开发语言"
tags:
	- node.js
---

第一章 node简介
1.1 node的特点
	1.1.1 异步I/O 绝大多数操作以异步方式进行调用
	1.1.2 事件与回调函数
	1.1.3 单线程，但是可以用WebWorkers的方式解决单线程的问题（子进程），用Master-Worker用master统一管理子进程
	1.1.4 跨平台
	1.1.5 c++速度大约是node的2.5倍

1.2 模块机制
	1.2.1 分为核心模块和文件模块，require没带路径的为核心模块，直接加载进内存，带路径的为文件模块,核心模块中有c++和javascript两部分，其中buffer、crypto、evals、fs、os、等都是c++部分的 
	1.2.2 npm安装的核心模块插件在package.json中定义

1.3 异步I/O
	1.3.1 操作系统内核对I/O只有：阻塞I/O和非阻塞I/O，node中的异步I/O模型由事件循环、观察者、请求对象、I/O线程池
	整个系统可以理解为事件循环相当于厨子，不停的询问是否有新的订单，观察者相当于收银员，收到用户的订单将订单分给厨子，而订单相当于请求对象，参数、方法、回调函数斗封装在请求对象中,
	以上是异步I/O的第一步，io线程池相当于放订单的桌子，  请求对象->I/O线程池->观察者->事件循环
	1.3.2 非异步的I/O主要是setTimeout(),setInterval(),setImmediate(),process.nextTick()

<!-- more -->
1.4 异步编程
	1.4.1 异步编程的解决方案分为3个：
		1）事件发布/订阅模式
		2）Promise/Deferred模式
		3）流程控制库
	1.4.2 事件发布/订阅模式
	``` bash
	//订阅
	emitter.on("event1",function(message){
		console.log(message);
	});
	//发布
	emitter.on('event1',"I Love you");
	```
	1）继承events模块
	``` bash
	var events = require('events');

	function Stream(){
		events.EventEmitter.call(this);
	}
	util.inherits(Stream,events.EventEmitter);
	```
	2)利用事件队列解决崩溃问题
	事件发布/订阅模式中一般只有一个once()方法，用一个『状态锁』或者『事件队列』防止崩溃
	状态锁
	``` bash
	var status = "ready";
	var select = function(callback){
		if(status == "ready" ){
			status = "pending";
			db.select("SQL", function(results){
				status = "ready";
				callback(results);
			});
		}
	};
	```
	事件队列
	``` bash
	var proxy = new events.EventEmitter();
	var status = function (callback) 
		proxy.once("selected", callback);
		if(status === "ready"){
			status = "pending";
			db.select("SQL", function(result){
				proxy.emit("selected",result);
				status = "ready";
			});
		}
	}
	```
	3）多异步之间的协作方案
	借组一个第三方函数和第三方变量来处理异步协作的结果
	``` bash
	var after = function (times,callback){
		var count = 0, results = {};
		return function (key, value){
			result[key] = value;
			count++;
			if(count === times){
				callback(results);
			}
		}
	}

	var done = after(times, render);
	```
	1.4.3 Promise/Deferred模式
	Promise是高级接口，事件是低级接口，Promise更像链表
	1.4.4 async流程控制模块
	1）async的series()方法实现串行（不传参）
	``` bash
	async.series([
		function (callback){
			fs.readFile('file1.txt','utf-8',calback);
		},
		function (callback){
			fs.readFile('file2.txt','utf-8',calback);
		}
	],function (err,result){
		//result = [file1.txt,file2.txt]等价于先处理file1.txt，在处理file2.txt，错误回调
	});
	```
	2）async的parallel()方法实现并行
	``` bash
	async.parallel([
		function (callback){
			fs.readFile('file1.txt','utf-8',calback);
		},
		function (callback){
			fs.readFile('file2.txt','utf-8',calback);
		}
	],function (err,result){
		//result = [file1.txt,file2.txt]等价于并行处理file1.txt，在处理file2.txt，错误回调
	});
	```
	3）async的waterfall()方法实现串行（传参）
	略
	4）async.auto()可以根据依赖关系自动分析，以最佳顺序执行
	略
	1.4.5 流程控制模块Step
	1)Step接受任意数量任务，所有任务传行执行
	``` bash
	Step(
		function (callback){
			fs.readFile('file1.txt','utf-8',this);
		},
		function (callback){
			fs.readFile('file2.txt','utf-8',this);
		},
		function done(err, content) {
			 console.log(content);
		}
	);
	```
	2)Step实现异步任务并行执行要用this的parallel()
	``` bash
	Step(
		function (callback){
			fs.readFile('file1.txt','utf-8',this.parallel());
		},
		function (callback){
			fs.readFile('file2.txt','utf-8',this.parallel());
		},
		function done(err, content) {
			 console.log(arguments);
		}
	);
	```
	1.4.6流程控制模块wind
	1)wind的$await()方法实现异步等待
	2）wind的whenAll()处理并发

1.5 异步并发控制
	1.5.1 bagpipe解决办法（API添加过载保护，用队列控制并发）
	``` bash
	var Bagpipe = require('bagpipe');
	//设定最大并发数为10
	var bagpipe = new Bagpipe(10);
	for(var i = 0; i< 100;i++){
		bagpipe.push(async, function (){

		});
	}
	bagpipe.on('full',function (length){
		console.warn('底层系统处理不及时');
	});
	```
	1.5.2 拒绝模式
	``` bash
	var bagpipe = new Bagpipe(10,{
		refuse: true
	});
	```
	1.5.3 超时控制
	``` bash
	var bagpipe = new Bagpipe(10, {
		timeout: 3000
	});
	```

1.6 内存管理
	1.6.1 v8内存分为新生代和老生代的
	node --max-old-space-size 2048 xxx.js 调整内存大小执行某个脚本
	v8堆内存64位系统是1.4G,32位系统是0.7G
	新生代内存的回收机制是将堆内存一分为2，使用中的是From，空的是to，进行垃圾回收时，是将from中的存活对象复制到to中，然后释放非存活的，同时from和to对换，缺点是只能使用一半的内存空间
	老生带内存的回收机制是将from中的使用的标记，回收未使用的	
	1.6.2 外部访问内部的变量的方法叫闭包   还有的说是内部变量无法被外部访问的过程叫闭包
	1.6.3 查看内存使用process.memoryUsage() os.totalmem os.freemem 

1.7 Buffer
	1.7.1 Buffer与字符串转换
	``` bash
	new Buffer(str, [encoding]);
	buf.write(string, [offset], [length], [encodeing]);
	buf.tostring([encoding], [start], [end]);
	```
1.8 网络
	1.8.1 tcp协议中的osi模型（分为 物理层、数据链路层、网络层、传输层、会话层、表示层、应用层）
	server
	``` bash
	var net = require('net');
	var server = net.createServer(function(socket){
		server.on('data',function(data){
		});
		server.on('end',function(data){
		});
		server.on('error',function(data){
		});
		server.write('data');
	});

	server.listen(port,function(){
	})
	```
	client
	``` bash
	var net = require('net');
	var client = net.connect({port: 8124},function(socket){
		client.on('data',function(data){
		});
		client.on('end',function(data){
		});
		client.on('error',function(data){
		});
		client.write('data');
	});
	```
	1.8.2 UDP是用户数据包协议，一个套接字可以与多个UDP通信
	server
	``` bash
	var dgrm = require("dgrm");
	var server = dgrm.createSocket("udp4");
	server.on("message", function (msg, rinfo){
		console.log("xxx");
	});
	server.on("listening", function() {
		var address = server.address();
		console.log("xxx");
	});
	server.bind(41234);
	```
	client
	``` bash
	var dgram = require('dgram');
	var messgae = new Buffer("xxxx");
	var client = dgram.createSocket("udp4");
	clinet.send(message, 0, message.length, 41234, "localhost", function(err,bytes){
		client.close();
	});
	```
	1.8.3 HTTP是构建在TCP之上属于应用层协议
	``` bash
	https_request : function(host, path, post_data, cb){
	    var reqdata = JSON.stringify(post_data);
		var options = {
		    hostname: host,
		    port: 443,
		    method: 'POST',
		    path: path,
		    headers: {
		        'Content-Type': 'application/json'
		    }
		};

		var req_time_out = setTimeout(function() {
	    		req.abort();
	    		cb(400, {code:400,message:'请求超时'});
	    		logger.n.info('Got Request Timeout.');
		}, 10000);

		var req = https.request(options, function (res) {
			clearTimeout(req_time_out);
			//等待响应60秒超时
			var res_time_out = setTimeout(function() {
				res.destroy();
				cb(400, {code:400,message:'响应超时'});
				logger.n.info('Got Response Timeout.');
			}, 60000);
			var status_code = res.statusCode;
			var body = null;
			logger.n.info("Got status_code: " + status_code);
			res.on('data',function(data){
	            body = JSON.parse(data);
	        }).on('end', function(){
	        	clearTimeout(res_time_out);
	        	cb(status_code, body);
	        });
		}).on('error', function(e) {
			cb(400, {code:400,message:e.message});
			logger.n.info("Got error: " + e.message);
	    });
		req.write(reqdata);
		req.end();
    }
    ```
    1.8.4 WebSocket
    client
    ``` bash
    var client= new net.Socket();
	var flag = true;
	var port = 0;

	client.on('connect',function (){
	    //正常连接
	    flag = true;
	    logger.boot.info('socket Connection succeed');
	});
	client.on('end', function() {
	    //flag=false;
	    logger.n.warn('!!!!!tcp_client disconnected');
	    setTimeout(Fight_Service.tcp_reconnect, 1000);
	});
	client.on('data',function(data){
	    //得到服务端返回来的数据
	    Fight_Service.processResp(data);
	});
	client.on('error',function(error){
	    //错误出现之后关闭连接
	    flag = false;
	    logger.n.error('socket error:' + error);
	    client.destroy();
	    setTimeout(Fight_Service.tcp_reconnect, 1000);
	});
	client.on('close',function(){
	    //正常关闭连接
	    flag = false;
	    logger.n.warn('socket Connection closed');
	    client.destroy();
	});

	Fight_Service.tcp_reconnect = function(worker_id){
    //创建socket客户端
    client.setEncoding('binary');

    if (port == 0 ){
        //连接到服务端115.159.186.60 8400
        // logger.boot.info("socket process_work_id:" + worker_id);
        worker_id = worker_id % 8;
        port = 8400 + worker_id;
    }else{
        logger.boot.info("socket tcp_reconnect");
    }

    logger.boot.info("socket_port_id:" + port);

    client.connect(port,"10.96.71.91");
	}
	```

1.9 多进程
	1.9.1 child_process模块
	1）spawn()启动一个子进程执行命令，无回调，无超时
	2）exec()启动一个子进程执行命令，有回调，有超时
	3）execFile()启动一个子进程执行可执行文件
	4）fork()启动node子进程执行js文件模块
	``` bash
	var fork = require('child_process').fork;
	var cpus = require('os').cpus();
	for(var i = 0; i < cpus.length; i++){
		fork('./worker.js');
	}
	```
	1.9.2 进程间通信IPC，主线程与工作线程之间通过onmessage()和postMessage()进行通信，子进程对象则由send()方法实现主进程向子进程发送数据
	1.9.3 句柄是一种用来标识资源的引用，用来拓展有限的文件描述符
	``` bash
	child.send(message,[sandHandle])如（child.send('server',server)）;
	子进程代码
	process.on('message',function(m, server){
		if(m == 'server'){
		xxxxx
	}
	})
	```
	1.9.4 父进程可以通过kill()方法给子进程发送一个SIGTERM信号杀进程
	``` bash
	chid.kill([signal]);
	process.kill(pid, [signal]);
	``` 
	在退出中加入自动重启可能会有新用户进来请求丢失的情况，工作进程在得知退出时，向主进程发送一个自杀信号（达到先创建在退出进程）
	``` bash
	/**
	 * cluster mode
	 */
	if (   opts.get('cluster')
	    || config.APP_CLUSTER.ENABLE) {
	    var cluster = require('cluster');
	    if (cluster.isMaster) {
	        console.log('[CLUSTER MODE] MASTER');

	        for (var i=0; i<config.APP_CLUSTER.NUM; i++) {
	            cluster.fork();
	        }

	        cluster.on('exit', function(worker, code, signal) {
	            console.log('worker ' + worker.process.pid + ' died');
	            cluster.fork();
	        });
	        return;
	    }
	    console.log('[CLUSTER MODE] WORKER');
	}
	```

1.10 插件
	1.10.1 Sequelizejs  此插件在option索引的位置千万不能写错，写错有大几率导致db堵塞
	``` bash
	Model.findAll({
  		attributes: ['foo', ['bar', 'baz']]
	});
	SELECT foo, bar AS baz ...

	Model.findAll({
	  attributes: [[sequelize.fn('COUNT', sequelize.col('hats')), 'no_hats']]
	});
	SELECT COUNT(hats) AS no_hats ...

	Post.findAll({
	  where: {
	    [Op.or]: [{authorId: 12}, {authorId: 13}]
	  }
	});
	SELECT * FROM post WHERE authorId = 12 OR authorId = 13;

	Order.findAll({attributes:['name', [sequelize.fn('SUM', sequelize.col('price')), 'sum']], group:'name', having:['COUNT(?)>?', 'name', 1], raw:true}).then(function(result){
	 console.log(result);
	})
	SELECT `name`, sum(`price`) AS `sum` FROM `orders` AS `Orders` GROUP BY name HAVING COUNT('name')>1;
	```

	1.10.2 Lodashjs
	[文档](https://www.lodashjs.com/docs/4.17.5.html)
	
	_.indexOf(array, value, [fromIndex=0])
	number): Returns the index of the matched value, else -1.
	``` bash
	_.indexOf([1, 2, 1, 2], 2);
	// => 1
	 
	// Search from the `fromIndex`.
	_.indexOf([1, 2, 1, 2], 2, 2);
	// => 3
	```
	_.dropRight(array, [n=1])
	(Array): Returns the slice of array.
	``` bash
	_.dropRight([1, 2, 3]);
	// => [1, 2]
	 
	_.dropRight([1, 2, 3], 2);
	// => [1]

	_.dropRight([1, 2, 3], 0);
	// => [1, 2, 3]
	```
	_.filter(collection, [predicate=_.identity])
	(Array): Returns the new filtered array.
	``` bash
	var users = [
	  { 'user': 'barney', 'age': 36, 'active': true },
	  { 'user': 'fred',   'age': 40, 'active': false }
	];
	 
	_.filter(users, function(o) { return !o.active; });
	// => objects for ['fred']
	```
	_.find(collection, [predicate=_.identity], [fromIndex=0])
	(*): Returns the matched element, else undefined.
	``` bash
		var users = [
	  { 'user': 'barney',  'age': 36, 'active': true },
	  { 'user': 'fred',    'age': 40, 'active': false },
	  { 'user': 'pebbles', 'age': 1,  'active': true }
	];
	 
	_.find(users, function(o) { return o.age < 40; });
	// => object for 'barney'
	```
	_.forEach(collection, [iteratee=_.identity])
	``` bash
	_.forEach([1, 2], function(value) {
	  console.log(value);
	});
	// => Logs `1` then `2`.
	 
	_.forEach({ 'a': 1, 'b': 2 }, function(value, key) {
	  console.log(key);
	});
	```
	_.groupBy(collection, [iteratee=_.identity])
	(Object): Returns the composed aggregate object.
	``` bash
	_.groupBy([6.1, 4.2, 6.3], Math.floor);
	// => { '4': [4.2], '6': [6.1, 6.3] }
	 
	// The `_.property` iteratee shorthand.
	_.groupBy(['one', 'two', 'three'], 'length');
	// => { '3': ['one', 'two'], '5': ['three'] }
	```
	#Promise.map Promise.all 相当于事务 
	_.map(collection, [iteratee=_.identity])
	(Array): Returns the new mapped array.
	``` bash
	function square(n) {
	  return n * n;
	}
	
	_.map([4, 8], square);
	// => [16, 64]
	 
	_.map({ 'a': 4, 'b': 8 }, square);
	// => [16, 64] (iteration order is not guaranteed)
	```
	#Promise.reduce是顺序执行
	_.reduce(collection, [iteratee=_.identity], [accumulator])  -
	(*): Returns the accumulated value.
	``` bash
	f_.reduce([1, 2], function(sum, n) {
	  return sum + n;
	}, 0);
	// => 3
	```
	_.isEmpty(value)
	(boolean): Returns true if value is empty, else false.
	``` bash
	_.isEmpty(null);
	// => true
	 
	_.isEmpty(true);
	// => true
	 
	_.isEmpty(1);
	// => true
	 
	_.isEmpty([1, 2, 3]);
	// => false
	 
	_.isEmpty({ 'a': 1 });
	// => false
	```
	项目案例 略

	1.10.3 Moment.js
	[文档](http://momentjs.cn)
	案例使用
	``` bash
	moment(event.start_time).startOf('day')/1000;
	moment.unix(moment().startOf('month')/1000).utcOffset(config.TIME_ZONE_DIFF).format("YYYY-MM-DD HH:mm:ss");
	```

