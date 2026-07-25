#import "../layout.typ": report-diagram, slide-body

= Dagster 负责定位运行问题

== Dagster 是排障入口，dlt 是采集库

#slide-body[
Dagster 是统一监控入口。它先告诉 agent：哪个 run、asset、partition 或 task 出问题。

`dlt` 不是监控平台。它是拉 API 数据的库，主要帮我们处理分页、请求状态和 schema 漂移。

#report-diagram("../reports/data-agent/diagrams/fig/metadata-debug-path.svg", height: 5.2cm)
]

== Dagster 元数据先缩小排障范围

#slide-body[
#table(
  columns: (1fr, 1.2fr, 1.2fr),
  inset: 5pt,
  align: (left, left, left),
  [看什么], [定位什么], [再查什么],
  [run status], [任务失败], [ECS / logs],
  [asset key], [数据资产], [S3 / table],
  [partition], [日期范围], [raw manifest],
  [code location], [发布版本], [EFS / image tag],
)
]

== dlt 只在采集问题里下钻

#slide-body[
dlt 解决的是 API 拉取层的问题。

+ pagination / cursor
+ request state
+ response shape
+ schema drift
]

== 运行问题要先筛选再深挖

#slide-body[
+ Dagster 定位失败对象。
+ 采集问题再看 dlt。
+ 运行问题再查 AWS。
+ 用同一 partition 重跑验证。
]
