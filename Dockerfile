FROM alpine:latest

RUN apk add --no-cache qemu-system-x86_64 bash

WORKDIR /app

RUN mkdir -p linux/arch/x86_64/boot/
RUN mkdir -p busybox/

# 左边是CI构建产物路径,右边是容器内路径
COPY linux/arch/x86_64/boot/bzImage  linux/arch/x86_64/boot/bzImage
COPY busybox/rootfs.img              busybox/rootfs.img
COPY scripts/run.sh                  run.sh

RUN chmod +x run.sh

# 启动命令不带任何参数，使用默认的 ./linux 和 ./busybox
CMD ["./run.sh"]
