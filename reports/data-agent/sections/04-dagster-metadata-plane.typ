= 从 AWS 到 Dagster

== 为什么需要 Dagster

AWS 提供了真实运行面：ECS task、Fargate、S3、Glue、Athena、Redshift、Secrets Manager、CloudWatch。但这些对象太深、太分散，agent 如果每次都直接从 AWS 底层查起，会浪费大量上下文和调用成本。

Dagster 的价值是提供统一的浅层元数据平面。它不替代 AWS，而是给 agent 一层“指针索引”：先快速知道哪个 asset、run、code location、sensor 或 ECS task 失败，再决定深入哪条 AWS 证据链。

DataAgent 的 ETL 主要是请求 API 拉取数据，不是 CDC 链路，因此 Python `dlt` package 也很重要。`dlt` 运行时产生的 load、schema、resource、state 等元数据，可以和 Dagster run / asset metadata 一起构成更完整的调试入口。

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
  [dlt metadata], [哪个 source/resource/load 出现异常], [API request state、schema drift、load package、pipeline state],
)

== agent 的调试路径

Dagster 让 agent 的调试路径从“盲查 AWS”变成“先筛选，再深挖”。

+ 在 Dagster 查失败 run 和最近变更的 asset。
+ 读取 run metadata，拿到 ECS task、log stream、code location、partition、source/resource key。
+ 如果失败发生在采集或 ETL 阶段，再读取 dlt 的 load、schema、resource 和 state 元数据。
+ 根据 metadata 调用 AWS MCP 或 CLI，定位 CloudWatch、S3、Glue、Athena、Redshift 的深层证据。
+ 修复代码、IaC 或 contract 后，用相同 partition/source 重新触发 smoke 或 backfill。
+ 把运行结果回写到日志或报告，形成下一轮 agent 可读上下文。

== 日志里的对应建设

日志中的 Prefect 清理、Dagster stack、asset dependency boundary、ODS source assets、sensors、EFS release、code location metadata、pool limits、resource concurrency key，都可以放在这个框架下理解：它们在给 agent 建一个可检索、可跳转、可调试的运行地图。dlt 元数据则补上 API 拉取型 ETL 的细粒度运行上下文，让 agent 不必只从最终表或 CloudWatch 日志倒推问题。
