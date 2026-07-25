#import "../layout.typ": report-diagram, slide-body

= agent 使用方式必须写进工程流程

== 这份材料给团队制定操作约定

#slide-body[
技术同学要知道让 agent 读哪些文件、跑哪些检查。业务同学要知道在哪个环境验证，什么结果才够进入生产。

- 先选环境，再操作。
- 先验证数据路径，再谈发布。
- 先看 Dagster，再查底层系统。
- hooks 是代码操作时的护栏。

#report-diagram("../reports/data-agent/diagrams/fig/agent-workflow.svg", height: 4.7cm)
]

== 各类场景都有固定入口

#slide-body[
#table(
  columns: (1fr, 1.4fr, 1.45fr),
  inset: 5pt,
  align: (left, left, left),
  [场景], [先看什么], [不要先做什么],
  [改业务代码], [Python hook / smoke], [直接上 prod],
  [改 IaC], [plan / validate / state], [直接 apply],
  [查运行失败], [Dagster run / asset], [先翻 CloudWatch],
  [验证数据], [stage backfill], [全量 schedule],
)
]

== 一次 agent 操作要留下可检查证据

#slide-body[
一次可接受的 agent 操作至少说清楚：

- 改的是哪个环境。
- 验证用的是哪组输入。
- 哪些 hooks 通过了。
- 失败时从哪里继续查。
]
