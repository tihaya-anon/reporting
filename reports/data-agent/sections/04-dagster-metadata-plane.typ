#import "../layout.typ": report-diagram, slide-body

= Dagster 元数据缓存

== Dagster 是排障入口，dlt 是采集库

#slide-body[
Dagster 对 agent 来说更像一层元数据缓存。它保存 run、asset、partition、code location 这些指针，让 agent 先做少量读取，再决定下钻到哪里。

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
Dagster 先把问题缩到某个 run 或 partition；如果失败发生在采集层，再下钻到 dlt 的日志和状态。

+ pagination / cursor
+ request state
+ response shape
+ schema drift
]

== 运行问题要先筛选再深挖

#slide-body[
+ Dagster 先读元数据指针。
+ 采集问题再看 dlt。
+ 运行和存储问题再查 AWS。
+ 用同一 partition 重跑验证。
]
