#import "../layout.typ": report-diagram, slide-body

= 发布机制要先保留旧版本

== Fargate 让发布有版本边界

#slide-body[
Fargate 让每次发布都有版本、健康检查和回滚边界。

- task definition 固定运行环境。
- image tag 追踪发布版本。
- rollback 限制坏版本停留时间。
]

== EFS release 降低业务代码发布成本

#slide-body[
EFS release 把“依赖环境”和“高频业务代码”拆开，发布粒度变小。

#table(
  columns: (1fr, 1.35fr, 1.35fr),
  inset: 5pt,
  align: (left, left, left),
  [层级], [变什么], [何时用],
  [镜像], [运行时 / 依赖], [低频基础变更],
  [EFS release], [Python 包 / git sha], [高频代码迭代],
  [supervisor], [进程切换], [健康后再激活],
)
]

== supervisor 只在健康后切换入口

#slide-body[
supervisor 的核心职责：先启动新 server，健康后再切换入口。

#report-diagram("../reports/data-agent/diagrams/fig/release-switch.svg", height: 5.2cm)
]

== 失败要停在切换前

#slide-body[
这套发布链路不承诺 zero incident，只把失败尽量挡在切换前。
]
