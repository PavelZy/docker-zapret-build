# Скачиваем ПЕРВУЮ версию zapret (она стабильнее для MikroTik)
RUN git clone https://github.com/bol-van/zapret
WORKDIR /zapret

# Собираем только tpws
RUN make -C tpws

FROM alpine:latest
RUN apk add --no-cache iptables ip6tables libcap zlib
COPY --from=builder /zapret/tpws/tpws /usr/bin/tpws

# Запуск tpws в режиме прозрачного прокси
CMD ["tpws", "--port", "999", "--uid", "0", "--disorder"]
