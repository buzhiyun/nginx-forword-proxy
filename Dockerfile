FROM alpine:3.20 AS build 

ADD . /build
WORKDIR /build

RUN sed -i 's#dl-cdn.alpinelinux.org#mirrors.tencent.com#g' /etc/apk/repositories && apk add --no-cache --virtual .build-deps gcc libc-dev make openssl-dev pcre2-dev zlib-dev linux-headers bash alpine-sdk findutils tar patch curl && \
    curl -LO 'https://nginx.org/download/nginx-1.24.0.tar.gz' && \
    curl -LO 'https://github.com/chobits/ngx_http_proxy_connect_module/archive/refs/heads/master.zip' && \
    unzip master.zip && mv ngx_http_proxy_connect_module-master ngx_http_proxy_connect_module && \
    tar -zxvf nginx-1.24.0.tar.gz && cd nginx-1.24.0 && \
    patch -p1 < /build/ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_102101.patch \
    && ./configure --prefix=/nginx  --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-Os -fomit-frame-pointer' --with-ld-opt=-Wl,--as-needed --add-module=/build/ngx_http_proxy_connect_module  \
    && make -j4 && make install \
    && ln -sf /dev/stdout /nginx/logs/access.log \
    && ln -sf /dev/stderr /nginx/logs/error.log && \
    mv /nginx/conf/nginx.conf /nginx/conf/nginx.conf.bak && cp /build/etc/nginx/nginx.conf /nginx/conf/nginx.conf && cp -r /build/etc/nginx/conf.d /nginx/conf/ && \
    rm -rf /build && apk del --no-network .build-deps curl && \
    apk add pcre2-dev 

WORKDIR /nginx

EXPOSE 7777 7777

STOPSIGNAL SIGTERM

CMD ["/nginx/sbin/nginx", "-g", "daemon off;"]
