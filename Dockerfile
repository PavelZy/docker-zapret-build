FROM alpine:latest AS builder
RUN apk add --no-cache git build-base linux-headers zlib-dev iptables ip6tables \
    luajit-dev bsd-compat-headers libcap-dev libnetfilter_queue-dev libmnl-dev

RUN git clone https://github.com/bol-van/zapret2
WORKDIR /zapret2

# 1. ХАК: Сброс прав (уже работает)
RUN find . -name "sec.c" -exec sed -i '/bool droproot(uid_t uid, const char \*user, const gid_t \*gid, int gid_count)/!b;n;c{ return true;' {} +

# 2. ХАК: Игнорируем ошибки BIND/UNBIND (теперь точно попадем в цель)
RUN find . -name "nfqws.c" -exec sed -i 's/if (nfq_unbind_pf(\*h, AF_INET) < 0)/if (0)/g' {} + && \
    find . -name "nfqws.c" -exec sed -i 's/if (nfq_bind_pf(\*h, AF_INET) < 0)/if (0)/g' {} +

# 3. ХАК: Игнорируем ошибки установки MODE и MAXLEN (чтобы MikroTik не ругался на параметры очереди)
RUN find . -name "nfqws.c" -exec sed -i 's/goto exiterr;/;/' {} +

RUN make

FROM alpine:latest
RUN apk add --no-cache luajit iptables ip6tables libnetfilter_queue libmnl libcap zlib
COPY --from=builder /zapret2 /zapret2
RUN ln -s /zapret2/binaries/my/nfqws2 /usr/bin/nfqws2 || true
WORKDIR /zapret2
CMD ["sleep", "1800"]
