#import "../layout.typ": report-diagram, slide-body

= hooks 把代码检查放到工具边界

== hook 类型取决于 agent 正在操作的代码

#slide-body[
hooks 属于代码操作时的机械检查，不属于业务流程步骤。

#report-diagram("../reports/data-agent/diagrams/fig/async-hooks.svg", height: 5.2cm)
]

== 业务 Python 代码走 black 和 pyright

#slide-body[
改业务 Python 代码时，hook 应该先处理确定性问题。

#table(
  columns: (1fr, 1.2fr, 1.2fr),
  inset: 5pt,
  align: (left, left, left),
  [检查], [发现什么], [agent 怎么处理],
  [black], [格式噪声], [直接修],
  [pyright], [类型问题], [修到通过],
  [smoke], [路径错误], [保留失败输入],
)
]

== IaC 代码走 fmt、validate 和 plan 摘要

#slide-body[
改 Terraform 或 Terragrunt 时，hook 不该只跑通用 lint。

- `tffmt`
- `terragrunt hclfmt`
- `tg validate`
- plan summary / diagnostics
]

== jsonl 只用于长命令的执行反馈

#slide-body[
Terraform/Terragrunt apply 这类长命令需要 jsonl。它解决的是等待和筛选问题，不是业务步骤。
]
