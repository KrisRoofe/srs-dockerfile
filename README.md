# srs-dockerfile
srs stream server

-------
//使用 SRS 在 Ubuntu 上搭建视频直播服务器

1.  下载源码
    git clone https://github.com/ossrs/srs
    cd srs/trunk

2.  修改配置文件

    a). 使用支持flv的配置文件，默认配置文件只支持rtmp的拉流

        修改 etc/init.d/srs 中 CONFIG="./conf/srs.conf" 为 CONFIG="./conf/http.flv.live.conf"

    b). 启用http_api， 提供流服务器信息查询的功能

        将 conf/http.flv.live.conf 文件内容修改为：

            # the config for srs to remux rtmp to flv live stream.
            # @see https://github.com/ossrs/srs/wiki/v2_CN_DeliveryHttpStream
            # @see full.conf for detail config.

            listen              1935;
            max_connections     1000;
            daemon              on;
            srs_log_tank        console;
            http_server {
                enabled         on;
                listen          8080;
                dir             ./objs/nginx/html;
            }
            vhost __defaultVhost__ {
                http_remux {
                    enabled     on;
                    mount       [vhost]/[app]/[stream].flv;
                    hstrs       on;
                }
            }

            #open http_api support
            http_api {
                # whether http api is enabled.
                # default: off
                enabled         on;
                # the http api listen entry is <[ip:]port>
                # for example, 192.168.1.100:1985
                # where the ip is optional, default to 0.0.0.0, that is 1985 equals to 0.0.0.0:1985
                # default: 1985
                listen          1985;
                # whether enable crossdomain request.
                # default: on
                crossdomain     on;
            }

    c). 修改源码，设置 flv 视频流的跨域访问

        在src/app/srs_app_http_stream.cpp如下代码后,

            int SrsLiveStream::serve_http(ISrsHttpResponseWriter* w, ISrsHttpMessage* r)
            {
                int ret = ERROR_SUCCESS;

                ISrsStreamEncoder* enc = NULL;

                srs_assert(entry);
                if (srs_string_ends_with(entry->pattern, ".flv")) {
                    w->header()->set_content_type("video/x-flv");

            添加：(486行   commit fe7c1a3e719e7ff385ba573d45436628d73bf98a)
                //Add Access-Control-Allow-Origin for flv stream
                w->header()->set("Access-Control-Allow-Origin", "*");

            注：此处的 * 可以根据允许访问的域名具体设置。

3.  编译安装SRS

    ./configure --prefix=/usr/local/srs --with-http-api
    make && sudo make install

4.  添加系统服务

    sudo ln -sf /usr/local/srs/etc/init.d/srs /etc/init.d/srs  
    sudo update-rc.d srs defaults

5.  启动SRS

    sudo /etc/init.d/srs start


