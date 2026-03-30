FROM alpine:latest AS builder
RUN apk add --no-cache git build-base linux-headers zlib-dev iptables ip6tables \
    luajit-dev bsd-compat-headers libcap-dev libnetfilter_queue-dev libmnl-dev

RUN git clone https://github.com/bol-van/zapret2
WORKDIR /zapret2

# 1. Исправляем droproot (уже проверено, это нужно)
RUN sed -i '/bool droproot(uid_t uid, const char \*user, const gid_t \*gid, int gid_count)/!b;n;c{ return true;' nfq2/sec.c || true

# 2. Ищем все папки с Makefile и пытаемся собрать их
RUN find . -maxdepth 2 -name "Makefile" -exec sh -c 'cd $(dirname {}) && make' \; || true

# 3. Выводим список всех исполняемых файлов, которые удалось собрать
RUN find . -maxdepth 3 -executable -type f

FROM alpine:latest
RUN apk add --no-cache luajit iptables ip6tables libnetfilter_queue libmnl libcap zlib
COPY --from=builder /zapret2 /zapret2

# Пытаемся создать ссылки на всё, что нашли
RUN find /zapret2 -name nfqws2 -type f -exec ln -s {} /usr/bin/nfqws2 \; || true
RUN find /zapret2 -name tpws -type f -exec ln -s {} /usr/bin/tpws \; || true

WORKDIR /zapret2
CMD ["sleep", "1800"]
