#!/bin/bash
# 01-Linux + 07-CICD 实战：自动化部署与健康巡检脚本

PROJECT_DIR="/c/Users/Administrator/Desktop/DYsensei/enterprise-ops-combat"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "========================================="
echo "🚀 启动企业级项目自动部署流水线..."
echo "当前时间: $TIMESTAMP"
echo "========================================="

# 1. 检查目录
cd $PROJECT_DIR || { echo "❌ 目录不存在: $PROJECT_DIR"; exit 1; }

# 2. 重建测试网页 (模拟前端打包)
echo "📦 正在打包静态资源..."
mkdir -p nginx/html app
cat << 'EOF' > nginx/html/index.html
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Ops Combat Portal</title></head>
<body style="font-family: Arial; text-align: center; margin-top: 50px;">
    <h1>🔥 企业级云原生架构实战基地</h1>
    <p>Nginx 已经成功把门防守！</p>
    <a href="/api/test.json">点击测试穿透到后端的API请求</a>
</body>
</html>
EOF

# 模拟后端接口响应数据
cat << 'EOF' > app/test.json
{
  "status": 200,
  "msg": "Hello from backend container!",
  "architecture": "Nginx -> Backend API -> Redis/MySQL"
}
EOF

# 3. 部署容器 (04-Docker)
echo "🛑 停止并清理旧容器..."
docker-compose down

echo "🚢 启动新容器阵列 (Nginx + Backend + Redis + MySQL)..."
docker-compose up -d

# 4. 健康检查 (01-Linux)
echo "⏳ 等待5秒让服务完全启动..."
sleep 5

echo "🏥 正在执行健康巡检..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:80/)

if [ "$HTTP_STATUS" == "200" ]; then
    echo "✅ 网站前端连通性测试通过 (HTTP 200)"
else
    echo "❌ 网站连通性异常！状态码: $HTTP_STATUS"
fi

echo "========================================="
echo "🎉 部署完成！"
echo "请在浏览器打开 http://localhost 验收战果。"
echo "想要查看挂掉后端的502报错？执行: docker stop ops_backend"
echo "========================================="
