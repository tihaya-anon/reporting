= 先固定环境边界

== 先回答三个问题

agent 改代码前，要先回答三个问题：这段代码在哪个环境生效，通过哪条流水线发布，失败后影响多大。dev、stage、prod 分支和 CI/CD 规则就是为这个判断服务的。

- dev 分支用于快速验证 runtime、source、backfill 和部署脚本。
- stage 分支用于模拟真实网络、权限、schedule 和数据落点。
- prod 分支保留更严格的发布边界，避免高频迭代直接放大影响面。
- CI/CD 把 build、deploy、component detection、image tag、diff base、last applied commit 这些状态写出来。

== 云端配置也要能读

Terraform/Terragrunt 把网络、权限、运行时和 state 依赖放回代码里。agent 先看这些文件，再决定要不要调用 AWS MCP 或实际执行命令。

#table(
  columns: (1fr, 1.45fr, 1.4fr),
  inset: 5pt,
  align: (left, left, left),
  [对象], [IaC 化后的表达], [agent 可以怎么用],
  [网络], [VPC、subnet、security group、VPCE、ALB CIDR], [本地判断任务为何无法访问 RDS、Secrets Manager 或 control-plane],
  [权限], [runtime role、exec role、CI role、assume policy], [推理部署失败、catalog migration 失败、S3/Glue/Athena 权限缺口],
  [运行时], [ECS task、Fargate、worker size、env vars、secrets], [在改代码前先确认任务配置和资源边界],
  [状态引用], [remote state、state split、Terragrunt inputs], [理解 control-plane、ingestion、datalake 之间的依赖关系],
  [发布], [pipeline stages、image tag、release metadata], [追踪一次变更从 commit 到 code location 的传播路径],
)

== 三个月里完成的边界整理

这轮整理覆盖了 CI/CD buildspec、runtime role assume、Terraform state、component detection、pipeline source、Terragrunt roots、control-plane state 等位置。单看都是部署细节，放在一起就是 agent 的本地系统模型。

- 5 月：先把 dev/stage、runtime role、exec role、build cache 和部署脚本打通。
- 6 月：引入更通用的 IaC 与 runtime 模块，拆分 state、remote state 和 Terraform roots。
- 7 月：围绕 dev/stage rollout、Pulumi/Terragrunt state、component routing、pipeline stages 清理边界。

== 本章结论

CI/CD 和 IaC 给 agent 一套判断顺序：先读代码，再读 state 引用和 pipeline 规则，最后查 AWS 现场。每次变更先确定环境、权限、发布路径和影响范围。
