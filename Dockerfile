FROM --platform=linux/arm/v7 alpine:latest
RUN apk add --no-cache git build-base linux-headers zlib-dev iptables ip6tables
RUN git clone https://github.com /zapret2
WORKDIR /zapret2
RUN make
# Запуск nfqws по умолчанию (параметры можно будет менять через cmd в MikroTik)
CMD ["/zapret2/nfq/nfqws"]
