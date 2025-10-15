## Doris 背景与入门概览

### 定位与演进
- Apache Doris 是分布式列式 OLAP 数据库，兼顾低时延与高并发，适合实时/交互式分析。
- 起源于百度 Palo，进入 Apache 后快速迭代，3.x 聚焦 Nereids 优化器与 Pipeline/向量化执行。

### 为什么选择 Doris
- 列存+向量化：压缩高、CPU 友好，扫描与聚合优势明显。
- MPP 扩展：计算与存储水平扩展，Shared-nothing。
- 低时延：子秒到秒级响应，支撑高并发场景。
- 生态兼容：MySQL 协议接入、外部 Catalog（Hive/Iceberg/Hudi）联邦查询。
- 物化视图：自动重写以加速热点查询。

### 架构概览
- FE：解析/优化/计划生成、元数据、任务调度、权限与管理；支持多 FE HA。
- BE：计划片段执行、Pipeline 算子、存储与副本、Compaction。
- 协议：前端 MySQL；后端 Thrift/RPC；HTTP/REST 用于导入与管理。

### 数据模型
- Duplicate/Aggregation/Primary(Unique) Key 三类，配合分区（常按时间）与分布（Hash+桶）。
- 物理切分为 Tablet（分区×分桶），多副本分散到不同 BE。
- 存储文件以 Rowset/Segment 组织，配合 ZoneMap/Bitmap 等索引。

### 查询优化与执行
- Nereids（Cascades + CBO）：规则重写、代价评估、搜索物理计划并切分为 PlanFragment。
- 向量化 + Pipeline：Block/Chunk 批处理；算子链组成 Driver 并行执行。
- 常见优化：Runtime Filter、列/分区裁剪、Join Reorder、广播/分布式 Join。

### 导入与生态
- Stream/Broker/Routine Load、INSERT INTO、Spark/Flink Connector、CDC。
- 外部 Catalog 联邦查询，物化视图下沉热点到本地加速。

### 存储与一致性
- Tablet -> Rowset -> Segment；新增数据以 Rowset 追加，后台 Compaction 合并。
- 多副本与自动均衡；主键/唯一键支持 Upsert/准实时。

### 运维与可观测性
- 启停脚本、配置文件、/metrics、WebUI、对接 Prometheus/Grafana。

### 适用场景
- 实时数仓、交互式报表、多维分析；湖仓一体查询与加速。
- 不适合强事务 OLTP 与重写热点（可用主键模型+评估）。

### 学习落地建议
- 跑通单机 + 最小 SQL + EXPLAIN；以断点佐证内部流程。
- FE：qe、nereids、planner、rpc；BE：runtime、pipeline/vec、exec；存储：olap。
- 在 logs 记录关键结构、EXPLAIN、结论。
