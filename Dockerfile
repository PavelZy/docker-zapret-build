FROM alpine:latest AS builder
RUN apk add --no-cache git build-base linux-headers zlib-dev iptables ip6tables \
    luajit-dev bsd-compat-headers libcap-dev libnetfilter_queue-dev libmnl-dev

RUN git clone https://github.com/bol-van/zapret2
WORKDIR /zapret2

# ХАК: Отключаем сброс прав (уже проверено, работает)
RUN sed -i '/bool droproot(uid_t uid, const char \*user, const gid_t \*gid, int gid_count)/!b;n;c{ return true;' nfq2/sec.c

# Собираем всё (nfq2, tpws, mdig и т.д.)
RUN make

FROM alpine:latest
# Устанавливаем библиотеки, нужные для работы всех компонентов
RUN apk add --no-cache luajit iptables ip6tables libnetfilter_queue libmnl libcap zlib

# Копируем всё содержимое проекта после сборки
COPY --from=builder /zapret2 /zapret2

# Создаем симлинки для удобства запуска
RUN ln -s /zapret2/nfq2/nfqws2 /usr/bin/nfqws2 && \
    ln -s /zapret2/tpws/tpws /usr/bin/tpws

WORKDIR /zapret2
CMD ["sleep", "1800"]
