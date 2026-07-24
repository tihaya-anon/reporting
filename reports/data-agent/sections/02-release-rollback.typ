= 灰度发布与回滚

== 先靠 Fargate 兜底

DataAgent 的运行时部署在 AWS ECS/Fargate 上，天然获得了一层容错：任务定义、服务部署、健康检查和回滚机制可以把一部分错误隔离在发布流程里。对于 agent 开发，这意味着 agent 可以更大胆地做小步迭代，因为平台本身能在失败时保留恢复路径。

- Fargate 让任务运行环境标准化，减少机器状态差异。
- ECS task definition 让每次部署都有可追踪版本。
- AWS 原生 rollback 降低坏镜像或坏配置直接长期影响环境的概率。
- dev/stage/prod 分支把灰度边界前移到代码流程。

== EFS release 缩短部署时间

后续引入 EFS release 的意义，是把 Docker 镜像从“业务代码 + 依赖 + 运行时”的完整包，改成更稳定的运行时依赖包。Docker 主要负责 `uv sync` 后的依赖和执行环境，业务代码放到 EFS，由运行时挂载 EFS 后执行。这样大部分业务代码变更不再需要重新构建完整镜像，部署等待时间明显缩短。

#table(
  columns: (1fr, 1.35fr, 1.35fr),
  inset: 5pt,
  align: (left, left, left),
  [发布层级], [变更面], [适合场景],
  [ECS/Fargate 镜像], [较大，主要包含运行环境和依赖], [基础镜像、依赖、系统配置变化],
  [EFS release], [较小，主要是业务代码和 release metadata 切换], [高频代码迭代、Dagster code location 更新],
  [supervisor], [进程级启动、健康检查与切换], [缩短发布反馈，同时保持旧版本可用],
)

== supervisor 的位置

supervisor 在日志里体现不多，但它是 EFS release 能安全提速的关键。Dagster code location 本质上是一个 gRPC server；每次发布时，supervisor 会先启动新 server，完成 healthcheck 后再把对外 proxy 从旧 server 原子切换到新 server，最后关闭旧 server。

- 对外仍然暴露稳定端口，例如 `4000`，内部先指向旧 server。
- 新 server 启动和健康检查通过前，不会影响上一版服务。
- 切换点就是主要回滚点：只要 supervisor 不切换，旧版本任务就不会停。
- 切换后再 shutdown 旧 server，实现近似 zero-downtime 的 code location 更新。

== 对 agent 的价值

灰度、回滚、EFS 和 supervisor 组合起来，目标不是单纯追求部署技巧，而是在保证稳定性的前提下缩短反馈周期。agent 开发最怕的是反馈慢和失败不可解释；这套机制让业务代码可以快速进入运行环境，同时把失败挡在切换前。
