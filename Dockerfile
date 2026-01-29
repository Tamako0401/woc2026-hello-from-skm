FROM alpine:latest

RUN apk add --no-cache qemu-system-x86_64 bash

WORKDIR /app

COPY linux/arch/x86_64/boot/bzImage /app/bzImage
COPY busybox/rootfs.img /app/rootfs.img
COPY scripts/run.sh /app/run.sh

RUN chmod +x /app/run.sh

EXPOSE 5555 5556

ENV IN_CONTAINER=true

CMD ["./run.sh", "-k", ".", "-b", "."]
