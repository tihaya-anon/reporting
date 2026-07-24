= 总览

== 这次要讲什么

DataAgent 这轮工作把重点放在工程路径上：agent 怎么理解系统，怎么先做小范围验证，怎么把变更发布出去，失败后又从哪里继续查。

- CI/CD 和 IaC 负责环境边界：dev/stage/prod、权限、网络、runtime、state 都要能读。
- 本地脚本、DuckDB、source smoke 和缓存负责验证顺序：先查小样本，再进流水线。
- Fargate、EFS release 和 supervisor 负责发布：先启动新版本，检查通过后再切换。
- Dagster 和 `dlt` 负责排障入口：先定位 run、asset、partition、source，再查 AWS。
- 异步 MCP 和 hooks 负责反馈：长任务有进度，结束前有格式和 lint 检查。

== 整套节奏

#table(
  columns: (1fr, 1.4fr, 1.45fr),
  inset: 5pt,
  align: (left, left, left),
  [顺序], [这一页回答的问题], [听众应该带走什么],
  [1. 环境边界], [这次变更会影响哪里？], [先读 IaC、pipeline 和 state],
  [2. 验证顺序], [怎么避免一上来就跑全量？], [先用小样本证明数据路径],
  [3. 发布流程], [新版本失败时怎么处理？], [检查通过再切换，旧版本先保留],
  [4. 排障入口], [任务失败后从哪里查？], [先看 Dagster 和 `dlt` metadata],
  [5. 长任务反馈], [Terraform/Terragrunt 怎么让 agent 跟得上？], [jsonl、summary、formatter、lint],
)

== 评估标准

这套 slides 只看一件事：这些工程设施有没有降低 agent 的工作阻力。

- agent 能不能判断环境、权限、发布路径和影响范围。
- agent 能不能用小样本复现问题，避免直接跑全量。
- agent 能不能看懂发布版本，知道失败卡在哪一步。
- agent 能不能从 Dagster / `dlt` metadata 跳到 AWS 证据。
- agent 能不能在长任务执行中分批读取状态，并在结束前处理确定性问题。
