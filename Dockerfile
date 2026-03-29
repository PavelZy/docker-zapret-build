FROM alpine:latest AS builder
RUN apk add --no-cache git build-base linux-headers zlib-dev iptables ip6tables \
    luajit-dev bsd-compat-headers libcap-dev libnetfilter_queue-dev libmnl-dev

RUN git clone https://github.com/bol-van/zapret2
WORKDIR /zapret2

# ХАК: Вставляем "return true;" в самое начало функции droproot
RUN sed -i '/bool droproot(uid_t uid, const char \*user, const gid_t \*gid, int gid_count)/!b;n;c{ return true;' nfq2/sec.c

RUN make

FROM alpine:latest
RUN apk add --no-cache luajit iptables ip6tables libnetfilter_queue libmnl libcap zlib
COPY --from=builder /zapret2/nfq2/nfqws2 /usr/bin/nfqws2
COPY --from=builder /zapret2/lua /zapret2/lua
CMD ["nfqws2", "--uid", "0"]
