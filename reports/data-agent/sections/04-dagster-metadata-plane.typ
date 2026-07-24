= 出问题先看哪里

== 为什么需要 Dagster

AWS 是真实运行面：ECS task、Fargate、S3、Glue、Athena、Redshift、Secrets Manager、CloudWatch。但这些对象层级深、分布散，agent 如果每次都直接从 AWS 底层查起，会浪费上下文和调用成本。

Dagster 提供靠前的一层元数据。agent 先知道哪个 asset、run、code location、sensor 或 ECS task 失败，再决定查哪条 AWS 证据链。

DataAgent 的 ETL 主要通过 API 拉取数据，调试时还要看 Python `dlt` package。`dlt` 运行时产生 load、schema、resource、state 等元数据，可以和 Dagster run / asset metadata 一起排障。

== 元数据指向底层证据

#table(
  columns: (1fr, 1.45fr, 1.4fr),
  inset: 5pt,
  align: (left, left, left),
  [Dagster 元数据], [先看到的问题], [下一步证据],
  [run status], [哪个任务失败或超时], [ECS task arn、CloudWatch log stream、retry history],
  [asset key], [哪个数据资产受影响], [S3 prefix、Iceberg table、Redshift table、partition],
  [partition], [哪个日期或 resource 范围异常], [raw manifest、report date、source date、resource date],
  [code location], [是否加载了正确 release], [EFS release metadata、image tag、release pointer],
  [sensor event], [自动触发是否发生], [raw event、SNS/SQS payload、ODS manifest],
  [dlt metadata], [哪个 source/resource/load 出现异常], [API request state、schema drift、load package、pipeline state],
)

== agent 的调试路径

Dagster 让 agent 先筛选，再深挖。

+ 在 Dagster 查失败 run 和最近变更的 asset。
+ 读取 run metadata，拿到 ECS task、log stream、code location、partition、source/resource key。
+ 如果失败发生在采集或 ETL 阶段，再读取 dlt 的 load、schema、resource 和 state 元数据。
+ 用 metadata 调用 AWS MCP 或 CLI，定位 CloudWatch、S3、Glue、Athena、Redshift 里的底层证据。
+ 修复代码、IaC 或 contract 后，用相同 partition/source 重新触发 smoke 或 backfill。
+ 把运行结果回写到运行记录或报告，留给下一轮 agent 继续读。

== 这张运行地图覆盖什么

这张运行地图覆盖 Prefect 清理、Dagster stack、asset dependency boundary、ODS source assets、sensors、EFS release、code location metadata、pool limits、resource concurrency key。Dagster 负责 run、asset 和 code location；`dlt` 补上 API 拉取型 ETL 的 load、schema、resource 和 state。agent 可以从这些入口继续查，不用只从最终表或 CloudWatch 倒推问题。
