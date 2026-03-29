FROM alpine:latest

RUN apk add --no-cache git build-base linux-headers zlib-dev iptables ip6tables \
    luajit-dev bsd-compat-headers libcap-dev libnetfilter_queue-dev libmnl-dev
    
RUN git clone https://github.com/bol-van/zapret2
WORKDIR /zapret2
# Компилируем всё
RUN make
# Указываем путь к nfq2 (это основная программа в zapret2)
CMD ["/zapret2/nfq2/nfq2"]
