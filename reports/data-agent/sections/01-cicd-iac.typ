= CI/CD 与 IaC

== 从一开始区分环境

DataAgent 早期就区分 dev、stage、prod 分支，并把 CI/CD 纳入默认工作流。这一点对 agent 建设很关键：agent 不只是在改代码，它还需要理解“这段代码会在哪个环境生效、通过什么流水线发布、失败后会影响什么范围”。

- dev 分支用于快速验证 runtime、source、backfill 和部署脚本。
- stage 分支用于模拟真实网络、权限、schedule 和数据落点。
- prod 分支保留更稳定的发布边界，避免 agent 的高频迭代直接扩大影响面。
- CI/CD 把 build、deploy、component detection、image tag、diff base、last applied commit 这些状态显式化。

== IaC 是 agent 的可观测性工程

后续引入 Terraform/Terragrunt，不只是为了自动建资源，而是把基建状态变成 agent 可以读取的代码资产。对于 AI agent，这等价于把“系统外部状态”尽可能拉回本地上下文。

#table(
  columns: (1fr, 1.45fr, 1.4fr),
  inset: 5pt,
  align: (left, left, left),
  [对象], [IaC 化后的表达], [agent 获得的能力],
  [网络], [VPC、subnet、security group、VPCE、ALB CIDR], [本地判断任务为何无法访问 RDS、Secrets Manager 或 control-plane],
  [权限], [runtime role、exec role、CI role、assume policy], [推理部署失败、catalog migration 失败、S3/Glue/Athena 权限缺口],
  [运行时], [ECS task、Fargate、worker size、env vars、secrets], [在改代码前先确认任务配置和资源边界],
  [状态引用], [remote state、state split、Terragrunt inputs], [理解 control-plane、ingestion、datalake 之间的依赖关系],
  [发布], [pipeline stages、image tag、release metadata], [追踪一次变更从 commit 到 code location 的传播路径],
)

== 从日志看推进路径

日志里多次出现 CI/CD buildspec、runtime role assume、Terraform state、component detection、pipeline source、Terragrunt roots、control-plane state 等修复。这些看起来是部署细节，但累计起来构成 DataAgent 的本地可读系统模型。

- 5 月：先把 dev/stage、runtime role、exec role、build cache 和部署脚本打通。
- 6 月：引入更通用的 IaC 与 runtime 模块，拆分 state、remote state 和 Terraform roots。
- 7 月：围绕 dev/stage rollout、Pulumi/Terragrunt state、component routing、pipeline stages 做收敛。

== 建设意义

CI/CD 和 IaC 最终降低的是 agent 的认知成本。agent 不需要每次都问“线上到底是什么样”，它可以先读代码、读 state 引用、读 pipeline 规则，再决定是否需要调用 AWS MCP 或跑实际命令。
