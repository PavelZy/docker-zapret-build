FROM alpine:latest AS builder
RUN apk add --no-cache git build-base linux-headers zlib-dev iptables ip6tables \
    luajit-dev bsd-compat-headers libcap-dev libnetfilter_queue-dev libmnl-dev

RUN git clone https://github.com/bol-van/zapret2
WORKDIR /zapret2

# Более надежный способ вырезать setgroups (заменяем вызов на (0))
RUN sed -i 's/setgroups(0, NULL)/(0)/g' nfq2/sec.c

RUN make

FROM alpine:latest
RUN apk add --no-cache luajit iptables ip6tables libnetfilter_queue libmnl libcap zlib
COPY --from=builder /zapret2/nfq2/nfqws2 /usr/bin/nfqws2
COPY --from=builder /zapret2/lua /zapret2/lua
CMD ["nfqws2", "--uid", "0"]
