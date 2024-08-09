FROM node:18-alpine AS builder

WORKDIR /app
COPY . ./

# 设置 node 阿里镜像
RUN npm config set registry https://registry.npmmirror.com
# 设置--max-old-space-size
ENV NODE_OPTIONS=--max-old-space-size=16384

# 设置阿里镜像、pnpm、依赖、编译
RUN npm install pnpm -g && \
    pnpm install --frozen-lockfile && \
    pnpm build

RUN echo "Builder Success 🎉"

FROM nginx:1.23.3-alpine as production

COPY --from=builder /app/dist /usr/share/nginx/html
COPY --from=builder /app/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80

# start nginx
CMD ["nginx", "-g", "daemon off;"]