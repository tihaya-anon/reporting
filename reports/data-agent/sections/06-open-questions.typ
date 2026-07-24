= 待深化问题

== 需要补充的事实

这版已经根据新增信息调整了重点，但还有几处最好继续补证据或机制细节，后续可以让报告更扎实。

- supervisor：它具体管理哪些进程，重启策略是什么，如何和 ECS task、Dagster run、CloudWatch log 关联。
- EFS release：release 包结构、metadata schema、activation wait、fallback 和 rollback 的准确流程。
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
+ Dagster metadata 到 AWS debug 的字段映射：现在 run metadata 里有哪些 task/log/partition/source 指针，哪些还要补？
+ 多级缓存的实际目录和命令：页面请求、S3 sync、DuckDB validation、ECR cache 分别对应哪些脚本和典型输出？
