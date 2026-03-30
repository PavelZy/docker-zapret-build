FROM alpine:latest AS builder
RUN apk add --no-cache git build-base linux-headers zlib-dev iptables ip6tables \
    luajit-dev bsd-compat-headers libcap-dev libnetfilter_queue-dev libmnl-dev

RUN git clone https://github.com/bol-van/zapret2

# ХАК: Правим sec.c для работы под Root на MikroTik (ищем в обоих возможных местах)
RUN sed -i '/bool droproot(uid_t uid, const char \*user, const gid_t \*gid, int gid_count)/!b;n;c{ return true;' src/nfq2/sec.c || \
    sed -i '/bool droproot(uid_t uid, const char \*user, const gid_t \*gid, int gid_count)/!b;n;c{ return true;' nfq2/sec.c || true

# Собираем все компоненты по новым путям
RUN cd src/nfq2 && make || cd nfq2 && make
RUN cd src/tpws && make || cd tpws && make

FROM alpine:latest
RUN apk add --no-cache luajit iptables ip6tables libnetfilter_queue libmnl libcap zlib
COPY --from=builder /zapret2 /zapret2

# Создаем симлинки на бинарники (пробуем оба пути)
RUN ln -s /zapret2/src/nfq2/nfqws2 /usr/bin/nfqws2 || ln -s /zapret2/nfq2/nfqws2 /usr/bin/nfqws2 || true
RUN ln -s /zapret2/src/tpws/tpws /usr/bin/tpws || ln -s /zapret2/tpws/tpws /usr/bin/tpws || true

WORKDIR /zapret2
CMD ["sleep", "1800"]
