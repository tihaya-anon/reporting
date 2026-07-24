= 待深化问题

== 需要补充的事实

这版已经根据新增信息调整了重点。EFS release、supervisor 和 Dagster/dlt metadata 的定位已经可以写成确定结论；后续如果要把报告从“建设复盘”推进到“可执行设计说明”，还需要补一些具体证据。

- EFS release：release 包结构、metadata schema、activation wait 和 fallback 记录。
- supervisor：proxy 切换、healthcheck、旧 server shutdown 和失败不切换的运行样例。
- ECR cache：是 CodeBuild 本地缓存、远端 registry cache，还是专门的 cache repo；命中率如何衡量。
- 异步 MCP：job id、jsonl 路径、tail 协议、失败摘要和 artifact 保留策略。
- hooks：formatter 和 lint 的触发边界，是否会阻塞 agent 结束，失败时如何反馈。

== 下一步报告结构

如果继续细化，可以把报告改成更像一份“Agent-Native Data Platform”设计说明：

#table(
  columns: (1fr, 1.55fr, 1.3fr),
  inset: 5pt,
  align: (left, left, left),
  [章节], [要回答的问题], [需要材料],
  [本地理解], [agent 如何只靠 repo 理解环境与基建], [IaC 目录、state 引用、分支策略],
  [快速验证], [agent 如何小步验证 source 与 ETL], [请求脚本、S3 sync、DuckDB 示例],
  [低风险发布], [agent 如何快速发布且可回滚], [Fargate、EFS、supervisor、pipeline],
  [元数据调试], [agent 如何从 Dagster 指针进入 AWS 深层排障], [run metadata、task arn、log links],
  [自动反馈], [agent 如何消费异步任务和 hooks], [MCP jsonl、formatter、lint 记录],
)

== 建议追问方向

为了把下一版写得更深，我建议优先确认三件事：

+ EFS release 和 supervisor 的实际控制流：一次 agent 改代码后，最快路径是怎样从 commit 进入 Dagster code location 的？
+ Dagster 和 dlt metadata 到 AWS debug 的字段映射：哪些字段已经稳定沉淀，哪些还只是日志输出？
+ 多级缓存的典型命令和输出：页面请求、S3 sync、DuckDB validation、ECR cache 分别如何作为 agent 验证证据？
