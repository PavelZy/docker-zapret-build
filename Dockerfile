FROM alpine:latest
RUN apk add --no-cache git build-base linux-headers zlib-dev iptables
RUN git clone https://github.com /zapret2
WORKDIR /zapret2
RUN make
# Здесь мы оставляем только скомпилированные бинарники для экономии места
CMD ["/zapret2/nfq/nfqws", "--help"] 
