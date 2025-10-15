# 常用命令与搜索

## 构建与运行（示例）
./build.sh --help
./build.sh --fe --be -j"14"
./output/fe/bin/start_fe.sh --daemon
./output/be/bin/start_be.sh --daemon

## 连接与验证
mysql -h127.0.0.1 -P9030 -uroot -e "show frontends;"
mysql -h127.0.0.1 -P9030 -uroot -e "show backends\G"

## 最小示例 SQL
CREATE DATABASE demo; USE demo;
CREATE TABLE t (k1 INT, v1 STRING) DUPLICATE KEY(k1)
DISTRIBUTED BY HASH(k1) BUCKETS 1
PROPERTIES("replication_num"="1");
INSERT INTO t VALUES (1,'a'),(2,'b');
SELECT * FROM t;

## 代码搜索（ripgrep）
rg "class\s+PaloFe" fe -n
rg "PlanFragment" fe -n
rg "PlanFragmentExecutor" be/src -n
rg "pipeline.*operator" be/src -n
rg "class\s+Tablet" be/src/olap -n

## 调试建议
FE_JAVA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005" \n  ./output/fe/bin/start_fe.sh
# BE 调试
gdb --args ./output/be/lib/doris_be --flagfile=./conf/be.conf
