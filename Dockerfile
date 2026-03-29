FROM alpine:latest
# Добавляем lua5.4-dev и другие зависимости для компиляции nfq2
RUN apk add --no-cache git build-base linux-headers zlib-dev iptables ip6tables lua5.4-dev
RUN git clone https://github.com/bol-van/zapret2
WORKDIR /zapret2
# Компилируем всё
RUN make
# Указываем путь к nfq2 (это основная программа в zapret2)
CMD ["/zapret2/nfq2/nfq2"]
