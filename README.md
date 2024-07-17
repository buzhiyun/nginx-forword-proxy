## NGINX 的正向代理


### 构建
`主要是之前编译的太大了，这次换alpine减小镜像大小，顺便升级下nginx`

docker build 的目录结构大致如下

```shell
.
├── Dockerfile
├── README.md
├── build.sh
└── etc
    └── nginx
        ├── conf.d
        │   └── proxy.conf
        └── nginx.conf

```

### 快速使用
```shell
docker run --rm -d -p 7777:7777 buzhiyun/http-proxy:v1.24.0-alpine
```

### 配置
基本不用配置，直接容器启动后监听 7777 端口, 客户端执行
```shell
export http_proxy=http://xx.xx.xxx.xx:7777
export https_proxy=http://xx.xx.xxx.xx:7777
```
就可以连接了 ， 浏览器用SwitchyOmega 插件设置http代理。

如果需要修改设置代理白名单，只允许或者限制某些域名，映射一个proxy.conf 到容器的 /nginx/conf/conf.d/proxy.conf ，设置文件中的map段，允许的映射为1，不允许的设置成 非 1 的值即可
```nginx
map $host $name {
    # 需要限制的时候把 default 改成 0
    default      0;

    "~(.*).douyin.com" 1;
    "~(.*).alipay.com" 1;
}

server {
     listen  7777;
     if ( $name != 1) {
         return 401;
     }

     # dns resolver used by forward proxying
     resolver  114.114.114.119 ipv6=off;

     # forward proxy for CONNECT request
     proxy_connect;
     proxy_connect_allow            443;
     proxy_connect_connect_timeout  10s;
     proxy_connect_read_timeout     60s;
     proxy_connect_send_timeout     60s;

     # forward proxy for non-CONNECT request
     location / {
         proxy_pass $scheme://$http_host$request_uri;
         proxy_set_header Host $http_host;

         proxy_buffers 256 4k;
         proxy_max_temp_file_size 0k;
         proxy_connect_timeout 30;
         proxy_send_timeout 60;
         proxy_read_timeout 60;

     }
 }
```
