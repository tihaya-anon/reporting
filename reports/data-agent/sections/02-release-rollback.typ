= 灰度发布与回滚

== 先靠 Fargate 兜底

DataAgent 的运行时部署在 AWS ECS/Fargate 上。任务定义、服务部署、健康检查和回滚机制先挡住一部分发布错误。对 agent 来说，这不是“可以随便改”，而是每次小步迭代都有明确的版本和恢复路径。

- Fargate 让任务运行环境标准化，减少机器状态差异。
- ECS task definition 让每次部署都有可追踪版本。
- AWS 原生 rollback 降低坏镜像或坏配置直接长期影响环境的概率。
- dev/stage/prod 分支把灰度边界前移到代码流程。

== EFS release 减少重建

后续引入 EFS release，把 Docker 镜像从“业务代码 + 依赖 + 运行时”的完整包，改成更稳定的运行时依赖包。Docker 主要负责 `uv sync` 后的依赖和执行环境；业务代码作为 Python 包发布，解压到 EFS，再由运行时 image 挂载 EFS 后执行。这样大部分业务代码变更不需要重新构建完整镜像。

release metadata 的核心标识是 git sha。CD 通过 git sha 指定要激活的发布版本；如果新版本启动或健康检查失败，就不切换到最新提交，同时把 CD 标记为失败。这个 fallback 的关键不是“切回去”，而是“不切过去”：上一版服务继续对外工作。

#table(
  columns: (1fr, 1.35fr, 1.35fr),
  inset: 5pt,
  align: (left, left, left),
  [发布层级], [变更面], [适合场景],
  [ECS/Fargate 镜像], [较大，主要包含运行环境和依赖], [基础镜像、依赖、系统配置变化],
  [EFS release], [较小，主要是 Python 包和 git sha metadata 切换], [高频代码迭代、Dagster code location 更新],
  [supervisor], [进程级启动、健康检查与切换], [缩短发布反馈，同时保持旧版本可用],
)

== supervisor 管住切换点

supervisor 在日志里体现不多，但它管住了 EFS release 里的新旧 code location 切换。Dagster code location 以 gRPC server 形式运行；每次发布时，supervisor 先启动新 server，完成 healthcheck 后再把对外 proxy 从旧 server 原子切换到新 server，最后关闭旧 server。

- 对外仍然暴露稳定端口，例如 `4000`，内部先指向旧 server。
- 新 server 启动和健康检查通过前，不会影响上一版服务。
- 切换点就是主要回滚点：只要 supervisor 不切换，旧版本任务就不会停。
- 切换后再 shutdown 旧 server，实现近似 zero-downtime 的 code location 更新。

== 本章结论

灰度、回滚、EFS 和 supervisor 的作用，是把发布拆成可观察的步骤。agent 能按 git sha 追踪版本，按 healthcheck 判断是否切换，按旧版本继续服务来限制失败范围。这里没有承诺 zero incident，只是把失败尽量挡在切换前。
