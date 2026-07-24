= 从 AWS 到 Dagster

== 为什么需要 Dagster

AWS 提供了真实运行面：ECS task、Fargate、S3、Glue、Athena、Redshift、Secrets Manager、CloudWatch。但这些对象太深、太分散，agent 如果每次都直接从 AWS 底层查起，会浪费大量上下文和调用成本。

Dagster 的价值是提供统一的浅层元数据平面。它不替代 AWS，而是给 agent 一层“指针索引”：先快速知道哪个 asset、run、code location、sensor 或 ECS task 失败，再决定深入哪条 AWS 证据链。

== 浅层元数据指向深层数据

#table(
  columns: (1fr, 1.45fr, 1.4fr),
  inset: 5pt,
  align: (left, left, left),
  [Dagster 元数据], [浅层问题], [指向的深层证据],
  [run status], [哪个任务失败或超时], [ECS task arn、CloudWatch log stream、retry history],
  [asset key], [哪个数据资产受影响], [S3 prefix、Iceberg table、Redshift table、partition],
  [partition], [哪个日期或 resource 范围异常], [raw manifest、report date、source date、resource date],
  [code location], [是否加载了正确 release], [EFS release metadata、image tag、release pointer],
  [sensor event], [自动触发是否发生], [raw event、SNS/SQS payload、ODS manifest],
)

== agent 的调试路径

Dagster 让 agent 的调试路径从“盲查 AWS”变成“先筛选，再深挖”。

+ 在 Dagster 查失败 run 和最近变更的 asset。
+ 读取 run metadata，拿到 ECS task、code location、partition、resource key。
+ 根据 metadata 调用 AWS MCP 或 CLI，定位 CloudWatch、S3、Glue、Athena、Redshift 的深层证据。
+ 修复代码、IaC 或 contract 后，用相同 partition/source 重新触发 smoke 或 backfill。
+ 把运行结果回写到日志或报告，形成下一轮 agent 可读上下文。

== 日志里的对应建设

日志中的 Prefect 清理、Dagster stack、asset dependency boundary、ODS source assets、sensors、EFS release、code location metadata、pool limits、resource concurrency key，都可以放在这个框架下理解：它们在给 agent 建一个可检索、可跳转、可调试的运行地图。
