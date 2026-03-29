FROM alpine:latest AS builder
# Устанавливаем всё для сборки
RUN apk add --no-cache git build-base linux-headers zlib-dev iptables ip6tables \
    luajit-dev bsd-compat-headers libcap-dev libnetfilter_queue-dev libmnl-dev

RUN git clone https://github.com/bol-van/zapret2
WORKDIR /zapret2

# ХАК: Отключаем вызов setgroups, который блокирует запуск на MikroTik
RUN sed -i 's/if (setgroups(0, NULL)==-1)/if (0)/' nfq2/sec.c

# Собираем
RUN make

# --- ФИНАЛЬНЫЙ ОБРАЗ (ОЧИЩЕННЫЙ) ---
FROM alpine:latest
# Оставляем только то, что нужно для работы (без компиляторов)
RUN apk add --no-cache luajit iptables ip6tables libnetfilter_queue libmnl libcap zlib

# Копируем только готовые бинарники и скрипты из первого этапа
COPY --from=builder /zapret2/nfq2/nfqws2 /usr/bin/nfqws2
COPY --from=builder /zapret2/lua /zapret2/lua

# Запуск под рутом (uid 0)
CMD ["nfqws2", "--uid", "0"]
