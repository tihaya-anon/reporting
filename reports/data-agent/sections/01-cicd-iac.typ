#import "../layout.typ": report-diagram, slide-body

= 环境隔离用来减少影响范围

== dev、stage、prod 都有独立资源

#slide-body(top: 0.14fr, bottom: 0.5fr)[
dev、stage、prod 是三条分支，也各自有 CI/CD、S3 bucket 和运行资源。dev 一定是 stage 的祖先，stage 一定是 prod 的祖先；资源不共用，提交历史有先后。

#report-diagram("../reports/data-agent/diagrams/fig/environment-boundary.svg", height: 5.1cm)
]

== commit 历史决定验证顺序

#slide-body[
stage 从 dev 提升，prod 从 stage 提升。stage 通常跑 backfill 验证；prod 才跑 schedule 任务。

- dev：没有固定要求，适合早期检查。
- stage：验证数据路径和权限。
- prod：只运行已经验证过的 schedule。
]

== IaC 让 agent 在动手前读清资源边界

#slide-body[
agent 不应该靠猜测判断环境。它要先读 IaC、pipeline 和 state。

#table(
  columns: (1fr, 1.2fr, 1.2fr),
  inset: 5pt,
  align: (left, left, left),
  [对象], [读什么], [回答什么],
  [网络], [VPC / SG / VPCE], [能不能连],
  [权限], [runtime / CI role], [能不能做],
  [运行时], [task / env / secret], [在哪里跑],
  [发布], [pipeline / image tag], [跑的是哪版],
)
]

== agent 先读事实再碰现场

#slide-body[
操作顺序很朴素：先读代码，再读 state 和 pipeline 规则，最后才查 AWS 现场。
]
