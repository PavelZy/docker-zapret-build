FROM alpine:latest AS builder
RUN apk add --no-cache git build-base linux-headers zlib-dev iptables ip6tables \
    luajit-dev bsd-compat-headers libcap-dev libnetfilter_queue-dev libmnl-dev

RUN git clone https://github.com/bol-van/zapret2
WORKDIR /zapret2

# ХАК: Автоматический поиск и правка sec.c, где бы он ни лежал
RUN find . -name "sec.c" -exec sed -i '/bool droproot(uid_t uid, const char \*user, const gid_t \*gid, int gid_count)/!b;n;c{ return true;' {} +

# Собираем всё. Если главный make не соберет tpws, заходим в его папку принудительно
RUN make || true
RUN find . -name "Makefile" -path "*/tpws/*" -execdir make \;

FROM alpine:latest
RUN apk add --no-cache luajit iptables ip6tables libnetfilter_queue libmnl libcap zlib
COPY --from=builder /zapret2 /zapret2

# Создаем симлинки, находя бинарники через find
RUN ln -s $(find /zapret2 -name nfqws2 -type f | head -n 1) /usr/bin/nfqws2 || true
RUN ln -s $(find /zapret2 -name tpws -type f | head -n 1) /usr/bin/tpws || true

WORKDIR /zapret2
CMD ["sleep", "1800"]
