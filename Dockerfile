FROM alpine:latest AS builder
RUN apk add --no-cache git build-base linux-headers zlib-dev iptables ip6tables \
    luajit-dev bsd-compat-headers libcap-dev libnetfilter_queue-dev libmnl-dev

RUN git clone https://github.com/bol-van/zapret2
WORKDIR /zapret2

# ХАК: Отключаем сброс прав в nfq2 (теперь путь src/nfq2/sec.c)
RUN sed -i '/bool droproot(uid_t uid, const char \*user, const gid_t \*gid, int gid_count)/!b;n;c{ return true;' src/nfq2/sec.c

# Собираем всё через главный Makefile (он должен подхватить src/*)
RUN make

# Если главный make не соберет tpws, собираем его принудительно по новому пути
RUN cd src/tpws && make && cp tpws /zapret2/tpws/tpws || true

FROM alpine:latest
RUN apk add --no-cache luajit iptables ip6tables libnetfilter_queue libmnl libcap zlib
COPY --from=builder /zapret2 /zapret2

# Создаем симлинки
RUN ln -s /zapret2/src/nfq2/nfqws2 /usr/bin/nfqws2 || true
RUN ln -s /zapret2/src/tpws/tpws /usr/bin/tpws || true

WORKDIR /zapret2
CMD ["sleep", "1800"]
