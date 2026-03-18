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
echo "📦 正在打包专业级监控看板..."
mkdir -p nginx/html app
cat << 'EOF' > nginx/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cloud-Native Ops Dashboard</title>
</head>
<body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; text-align: center; margin: 0; padding: 0; background-color: #f0f2f5; color: #1c1e21;">
    <div style="max-width: 900px; margin: 50px auto; background: white; padding: 40px; border-radius: 12px; box-shadow: 0 8px 30px rgba(0,0,0,0.12); border-top: 6px solid #007bff;">
        <h1 style="margin-bottom: 5px;">🌐 Global Infrastructure Status</h1>
        <p style="color: #65676b; margin-top: 0; margin-bottom: 30px;">Production Monitoring & Operations Control Center</p>
        
        <div style="display: flex; justify-content: space-around; margin-bottom: 40px;">
            <div style="background: #e7f3ff; padding: 20px; border-radius: 10px; flex: 1; margin: 0 10px;">
                <div style="font-size: 0.9em; color: #007bff; font-weight: bold;">NODE STATUS</div>
                <div style="font-size: 1.8em; font-weight: bold; margin-top: 5px; color: #28a745;">ACTIVE</div>
            </div>
            <div style="background: #fdf2f2; padding: 20px; border-radius: 10px; flex: 1; margin: 0 10px;">
                <div style="font-size: 0.9em; color: #dc3545; font-weight: bold;">LATENCY (AVG)</div>
                <div id="latency" style="font-size: 1.8em; font-weight: bold; margin-top: 5px;">14.0ms</div>
            </div>
            <div style="background: #f0fdf4; padding: 20px; border-radius: 10px; flex: 1; margin: 0 10px;">
                <div style="font-size: 0.9em; color: #28a745; font-weight: bold;">UPTIME</div>
                <div style="font-size: 1.8em; font-weight: bold; margin-top: 5px;">99.98%</div>
            </div>
        </div>

        <table style="width: 100%; border-collapse: collapse; text-align: left; margin-bottom: 30px;">
            <thead>
                <tr style="border-bottom: 2px solid #eee; color: #65676b; font-size: 0.9em;">
                    <th style="padding: 12px;">COMPONENT</th>
                    <th style="padding: 12px;">REGION</th>
                    <th style="padding: 12px;">INSTANCE</th>
                    <th style="padding: 12px;">HEALTH</th>
                </tr>
            </thead>
            <tbody>
                <tr style="border-bottom: 1px solid #f0f0f0;">
                    <td style="padding: 12px; font-weight: bold;">Nginx Ingress</td>
                    <td style="padding: 12px;">Global Edge</td>
                    <td style="padding: 12px;">Standard_D2s_v3</td>
                    <td style="padding: 12px; color: #28a745;">● Healthy</td>
                </tr>
                <tr style="border-bottom: 1px solid #f0f0f0;">
                    <td style="padding: 12px; font-weight: bold;">Microservice (Python)</td>
                    <td style="padding: 12px;">HK-East-01</td>
                    <td style="padding: 12px;">Standard_B1ms</td>
                    <td style="padding: 12px; color: #28a745;">● Healthy</td>
                </tr>
                <tr style="border-bottom: 1px solid #f0f0f0;">
                    <td style="padding: 12px; font-weight: bold;">Redis Cache Layer</td>
                    <td style="padding: 12px;">HK-Internal-VPC</td>
                    <td style="padding: 12px;">Premium_v2</td>
                    <td style="padding: 12px; color: #28a745;">● Healthy</td>
                </tr>
            </tbody>
        </table>

        <div style="margin-top: 40px;">
            <a href="test.json" target="_blank" style="padding: 15px 40px; background: #007bff; color: white; text-decoration: none; border-radius: 8px; font-weight: bold; box-shadow: 0 4px 14px 0 rgba(0,118,255,0.39);">
                ACCESS RAW SYSTEM TELEMETRY (API)
            </a>
        </div>
        
        <p style="margin-top: 40px; font-size: 0.85em; color: #8e8e8e;">
            Last Polled: <span id="time"></span> | Infrastructure Version: v2.4.0-stable
        </p>
    </div>

    <script>
        function updateClock() {
            document.getElementById('time').innerText = new Date().toUTCString();
        }
        setInterval(updateClock, 1000);
        updateClock();

        setInterval(() => {
            const latencyEl = document.getElementById('latency');
            const baseLatency = 14.0;
            const jitter = (Math.random() * 2 - 1).toFixed(1);
            latencyEl.innerText = (baseLatency + parseFloat(jitter)).toFixed(1) + 'ms';
            latencyEl.style.transition = 'color 0.2s';
            latencyEl.style.color = '#dc3545';
            setTimeout(() => { latencyEl.style.color = '#1c1e21'; }, 200);
        }, 3000);
    </script>
</body>
</html>
EOF

# 同步到 app 目录用于云端部署
cp nginx/html/index.html app/index.html

# 模拟业务指标响应数据
cat << 'EOF' > app/test.json
{
  "system_status": "Operational",
  "node_uptime": "99.98%",
  "active_sessions": 1242,
  "db_latency_ms": 15,
  "cache_hit_rate": "89.4%",
  "region": "Singapore-Az-1"
}
EOF

# 3. 部署容器 (04-Docker)
echo "🛑 停止并清理旧容器..."
docker-compose down

echo "🚢 启动新容器阵列 (Nginx + Backend + Redis + MySQL)..."
docker-compose up -d

# 4. 健康检查 (01-Linux)
echo "⏳ 等待3秒让服务完全启动..."
sleep 3

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
echo "想要查看挂大后端的502报错？执行: docker stop ops_backend"
echo "========================================="
