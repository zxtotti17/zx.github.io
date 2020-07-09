---
title: Es6 js规范
date: 2020-06-09 17:59:15
tags:
---


数组拷贝
``` bash
const itemsCopy = [...items];
```

取值方式
``` bash
const [first, second] = arr;
```

函数初始化
``` bash
function f3(a) {
  const b = a || 1;
  // ...
}

function f4(a = 1) {
  // ...
}
```

输出数组
``` bash
const x = [1, 2, 3, 4, 5];
console.log(...x);

new Date(...[2016, 8, 5]);
```

数组遍历
``` bash
let sum = 0;
numbers.forEach((num) => {
  sum += num;
});
sum === 15;
```

<!-- more -->