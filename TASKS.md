# 任务清单（3.1.1-rc01）

## 环境与启动
- [ ] 启动本地单机 FE/BE 并验证端口/健康
- [ ] 执行示例 SQL 并保存 EXPLAIN 到 logs

## FE 阅读与调试
- [ ] 梳理入口：org.apache.doris.PaloFe 与 qe 会话流
- [ ] 追踪 SELECT：nereids -> planner -> rpc，下断点
- [ ] 保存一份 EXPLAIN 并标注关键算子

## BE 阅读与调试
- [ ] 定位 PlanFragmentExecutor 与调度流程
- [ ] 阅读 Scan/Aggregate 两个算子生命周期（prepare/open/get_block）
- [ ] 通过日志/断点捕获一次短跑通路

## 存储深入
- [ ] 阅读 be/src/olap（tablet/rowset/segment）
- [ ] 总结版本链与 compaction 触发策略

## 测试
- [ ] 运行 FE/BE UT，记录失败/通过情况
- [ ] 运行回归测试，记录关键用例

## 练手小任务
- [ ] FE：新增只读 HTTP 状态接口或简单内置函数
- [ ] BE：在算子边界增加轻量指标或 trace 打点

## 本周优先级
- [ ] M1：启动集群与 SQL/EXPLAIN 验证
- [ ] FE 断点（规则/planner）
- [ ] BE 算子生命周期走查（scan、agg）
