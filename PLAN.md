# 学习规划（3.1.1-rc01）

## 总目标（2–3 周）
- 跑通本地单机 FE/BE 并执行 SQL；掌握 EXPLAIN。
- 能单步跟踪一条 SQL 从 FE 到 BE 的全链路。
- 理解存储（tablet/rowset/segment）与 Pipeline 引擎。
- 跑通单元/回归测试并完成一个小功能或优化。

## 阶段与重点
1) 启动与验证（0.5–1 周）：构建、启动、最小表、EXPLAIN。
2) FE 主线（1–1.5 周）：qe 会话、Nereids、planner、下发 RPC。
3) BE 主线（1–1.5 周）：runtime、pipeline、vec、exec。
4) 存储主线（1 周）：olap、tablet、rowset、compaction。
5) 测试与练手（0.5 周）：UT/回归、小特性。

## 验收点
- M1：单机启动 + 示例 SQL 成功 + EXPLAIN 对齐。
- M2：命中 FE/BE 断点，能口述关键数据结构与流转。
- M3：画出存储结构与 Compaction 触发条件。
- M4：能运行测试并合入一个小改动（本地）。
