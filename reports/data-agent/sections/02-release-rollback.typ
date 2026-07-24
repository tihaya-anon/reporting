= 灰度发布与回滚

== 先靠 Fargate 兜底

DataAgent 的运行时部署在 AWS ECS/Fargate 上，天然获得了一层容错：任务定义、服务部署、健康检查和回滚机制可以把一部分错误隔离在发布流程里。对于 agent 开发，这意味着 agent 可以更大胆地做小步迭代，因为平台本身能在失败时保留恢复路径。

- Fargate 让任务运行环境标准化，减少机器状态差异。
- ECS task definition 让每次部署都有可追踪版本。
- AWS 原生 rollback 降低坏镜像或坏配置直接长期影响环境的概率。
- dev/stage/prod 分支把灰度边界前移到代码流程。

== EFS release 缩短部署时间

后续引入 EFS release 的意义，是减少每次变更都重新打完整镜像、重新铺全部运行时的成本。日志里能看到 release metadata、release pointer、activation wait、publish image fallback、control-plane refresh 等工作，这些都是在把部署从“重资产镜像切换”改成“更轻的 release 指针切换”。

#table(
  columns: (1fr, 1.35fr, 1.35fr),
  inset: 5pt,
  align: (left, left, left),
  [发布层级], [变更面], [适合场景],
  [ECS/Fargate 镜像], [较大，包含运行环境和代码包], [基础镜像、依赖、系统配置变化],
  [EFS release], [较小，更多是代码位置和 metadata 切换], [高频代码迭代、Dagster code location 更新],
  [supervisor], [运行期进程管理和恢复], [缩短失败恢复路径，避免每次都依赖完整部署],
)

== supervisor 的位置

supervisor 在日志里体现不多，但从架构意义上看，它补的是“运行中如何快速恢复和管理进程”。如果 Fargate 管的是任务级别生命周期，EFS release 管的是代码分发速度，supervisor 管的是进程层面的稳定性和重启策略。

- 对 agent 来说，supervisor 可以把一些失败收敛在运行时内部，不必每次走完整 CI/CD。
- 对迭代速度来说，它减少了“改一行代码到看到任务重启”的等待。
- 对稳定性来说，它需要和 Dagster run、ECS task、CloudWatch log 的元数据关联起来，避免失败被隐藏。

== 对 agent 的价值

灰度、回滚、EFS 和 supervisor 组合起来，目标不是单纯追求部署技巧，而是在保证稳定性的前提下缩短反馈周期。agent 开发最怕的是反馈慢和失败不可解释；这套机制同时处理了这两个问题。
