# 使用 docker-compose 启动 Doris（3.1.1）

## 前置准备
- 安装 Docker 与 docker-compose（或 Docker Compose 插件）。

## 启动（含数据持久化）
```bash
./start-doris.sh
```

## 验证
```bash
./manage-doris.sh status
./doris-sql.sh "SHOW FRONTENDS;"
./doris-sql.sh "SHOW BACKENDS\\G"
```

## 日常管理
- 查看日志：
```bash
./manage-doris.sh logs -f
```
- 执行 SQL：
```bash
./doris-sql.sh "CREATE DATABASE demo;"
```
- 停止：
```bash
./stop-doris.sh
```
- 清理（删除数据卷，谨慎）：
```bash
./manage-doris.sh clean
```

## 连接信息（默认）
- FE Web: http://127.0.0.1:8030
- BE Web: http://127.0.0.1:8040
- MySQL 协议: 127.0.0.1:9030 用户 root 无密码
