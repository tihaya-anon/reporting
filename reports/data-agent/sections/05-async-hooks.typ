#import "../layout.typ": report-diagram, slide-body

= 异步 hooks

== hooks 的普通形态是 format 和 lint

#slide-body[
hooks 接在开发动作里，不单独排一个流程阶段。它们用 format、lint、validate 这类确定性检查处理本次更改。

#report-diagram("../reports/data-agent/diagrams/fig/async-hooks.svg", height: 5.2cm)
]

== hooks 只关心改了什么代码

#slide-body[
hook 不需要理解这段代码管理的是任务逻辑、基础设施还是调度配置。它只看 changed files，再选择对应的检查。

#table(
  columns: (1fr, 1.2fr, 1.2fr),
  inset: 5pt,
  align: (left, left, left),
  [改动], [常见 hook], [agent 怎么处理],
  [Python], [black / pyright], [修到通过],
  [IaC], [fmt / validate], [读 plan 摘要],
  [配置], [schema / lint], [保留失败输入],
)
]

== async hook 是给长任务的 plus

#slide-body[
同步 hook 适合短检查。apply、backfill、长 smoke 这类任务要异步执行，用 jsonl 持续吐出结构化状态。

- 命令开始、进度、失败点都要可读。
- agent 可以先继续做别的事，再回来读结果。
- 输出要能定位到文件、资源、partition 或 run。
]

== jsonl 只用于长命令的执行反馈

#slide-body[
Terraform/Terragrunt apply、stage backfill 这类长命令需要 jsonl。它解决的是等待问题：长任务不该卡住 agent。
]
