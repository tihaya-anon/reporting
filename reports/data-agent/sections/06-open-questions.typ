= 待深化问题

== 需要补充的事实

这版已经根据新增信息调整了重点。EFS release、supervisor、ECR cache、异步 MCP 和 hooks 的定位已经可以写成确定结论；后续如果要把报告从“建设复盘”推进到“可执行设计说明”，还需要补一些运行证据和边界条件。

- EFS release：Python 包结构、git sha metadata、activation wait 和 fallback 记录。
- supervisor：proxy 切换、healthcheck、旧 server shutdown 和失败不切换的运行样例。
- ECR cache repo：git sha tag、latest tag 推进、缓存命中和 CD 成功后的 tag 变更记录。
- 异步 MCP：回调句柄、jsonl 路径、预置 jq pattern、失败摘要和 artifact 保留策略。
- hooks：formatter warning 样例、lint block 样例，以及 agent 被 block 后的自修复记录。

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

为了把下一版写得更深，我建议优先补三类证据：

+ 发布证据：git sha release metadata、supervisor healthcheck、proxy 切换和 CD fail 不切换的样例。
+ 元数据证据：Dagster run metadata、dlt load/schema/resource/state 与 AWS task/log/partition 指针的样例。
+ 反馈证据：ECR cache tag 推进、异步 MCP summary/diagnostics、formatter warning 和 lint block 的样例。
