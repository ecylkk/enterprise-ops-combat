FROM python:3.9-slim

# 设置工作目录
WORKDIR /app

# 把 app 目录里的所有文件复制进来
COPY . .

# 对外暴露 8080 端口
EXPOSE 8080

# 启动极简 Python 文件服务器
CMD ["python", "-m", "http.server", "8080"]
