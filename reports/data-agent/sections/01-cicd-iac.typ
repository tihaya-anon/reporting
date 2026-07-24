= CI/CD 与 IaC

== 从一开始区分环境

DataAgent 早期就区分 dev、stage、prod 分支，并把 CI/CD 纳入默认工作流。agent 改代码时，必须同时知道三件事：这段代码会在哪个环境生效，通过哪条流水线发布，失败后会影响多大范围。

- dev 分支用于快速验证 runtime、source、backfill 和部署脚本。
- stage 分支用于模拟真实网络、权限、schedule 和数据落点。
- prod 分支保留更稳定的发布边界，防止高频迭代直接放大影响面。
- CI/CD 把 build、deploy、component detection、image tag、diff base、last applied commit 这些状态显式化。

== IaC 把云端状态拉回代码

后续引入 Terraform/Terragrunt，把网络、权限、运行时和 state 依赖都变成了 agent 可以读取的代码资产。agent 先看这些文件，再决定要不要调用 AWS MCP 或实际执行命令。

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

日志里多次出现 CI/CD buildspec、runtime role assume、Terraform state、component detection、pipeline source、Terragrunt roots、control-plane state 等修复。单看像部署细节，连起来就是 DataAgent 的本地系统模型。

- 5 月：先把 dev/stage、runtime role、exec role、build cache 和部署脚本打通。
- 6 月：引入更通用的 IaC 与 runtime 模块，拆分 state、remote state 和 Terraform roots。
- 7 月：围绕 dev/stage rollout、Pulumi/Terragrunt state、component routing、pipeline stages 做收敛。

== 本章结论

CI/CD 和 IaC 给 agent 的不是“自动化”这个抽象收益，而是一套可读的判断顺序：先读代码，再读 state 引用和 pipeline 规则，最后才查 AWS 现场。这样每次变更都能先确定环境、权限、发布路径和影响范围。
