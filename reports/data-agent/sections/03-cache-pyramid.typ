= 再小范围验证

== 验证要分层

DataAgent 的缓存分成开发缓存、数据缓存、CI 缓存和 CD 缓存。它们减少等待时间，也让 agent 按风险分层验证：先用局部样例确认假设，再进入更接近生产的路径。

== 开发侧缓存

从开发角度，DataAgent 提供了几类本地或小批量验证入口。agent 可以先证明 API、schema 和 partition 逻辑成立，再触发真实调度。

- 页面请求脚本：允许本地对 API 或页面发起小批量请求，验证 auth、pagination、response shape、nullable 字段和限流策略。
- backfill input / source smoke helper：用较小日期窗口或资源范围验证 source 到 raw event 的路径。
- S3 bucket sync 脚本：把远端样例数据同步到本地，降低每次验证都查询云资源的成本。
- DuckDB 本地 ETL 验证：对 parquet、schema、字段转换、分区落点做快速检查。

== CI/CD 侧缓存

CI/CD 侧缓存主要是减少 agent 每次迭代等待流水线的时间。其中 ECR cache 是一个自建 cache repo：每次 CI 成功构建后都会把镜像推到 cache repo，tag 使用 git sha；当 CD 成功后，再把 `latest` tag 指向这一次 git sha。

#table(
  columns: (1fr, 1.45fr, 1.35fr),
  inset: 5pt,
  align: (left, left, left),
  [缓存/减面机制], [解决的问题], [agent 怎么用],
  [Docker layer cache], [依赖层不重复构建], [普通代码改动更快看到 CI 结果],
  [ECR cache repo], [CI 成功产物按 git sha 持久化，CD 成功后推进 latest], [复用已验证镜像，减少重复构建和发布歧义],
  [ECS 到 EFS release], [避免每次全量镜像发布], [高频代码迭代更快进入 Dagster],
  [Terraform 到 Terragrunt], [缩小 IaC 变更作用域], [agent 可以只 plan/apply 相关组件],
  [component detection], [避免无关 diff 触发部署], [减少噪声反馈和误部署],
)

== 固定验证顺序

多级缓存给 agent 一条固定验证顺序。

+ 先本地请求，验证 API 形状。
+ 再同步 S3 样例，用 DuckDB 验证 ETL。
+ 再跑 smoke backfill，验证 source 到 raw event。
+ 再触发 dev/stage pipeline，验证 IaC、runtime 和 Dagster metadata。
+ 最后进入 prod 发布。

这条顺序让 agent 尽量在本地、小样本和 dev/stage 中暴露问题。前面的证据够了，变更才进入 prod 发布。
