FROM openresty/openresty:alpine-fat

RUN opm get bungle/lua-resty-session
RUN opm get ledgetech/lua-resty-http

RUN mkdir -p /var/www/site1;
ADD html/site1.html /var/www/site1/index.html

RUN mkdir -p /var/www/site2
ADD html/site2.html /var/www/site2/index.html

ADD ./auth.lua /etc/nginx/conf.d/auth.lua
ADD ./nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
ADD ./default.conf /etc/nginx/conf.d/default.conf