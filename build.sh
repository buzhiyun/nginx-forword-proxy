curl -LO 'https://nginx.org/download/nginx-1.24.0.tar.gz'
curl -LO 'https://github.com/chobits/ngx_http_proxy_connect_module/archive/refs/heads/master.zip'
unzip master.zip
mv ngx_http_proxy_connect_module-master ngx_http_proxy_connect_module
docker build --no-cache --progress=plain -t buzhiyun/http_proxy:v1.24.0-alpine .
