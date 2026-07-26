#import "../layout.typ": report-diagram, slide-body

= 快速反馈金字塔

== 数据路径先用小输入证明

#slide-body[
agent 开发最怕慢反馈。反馈越快，agent 越容易根据准确信号继续迭代；反馈越慢，错误就会被带进更重的环境。

#report-diagram("../reports/data-agent/diagrams/fig/cache-validation-pyramid.svg", height: 5.7cm)
]

== 开发侧只证明接口和数据形状

#slide-body[
开发侧只回答一件事：这条数据路径是不是成立。先用小输入拿到确定信号，再决定要不要进入 stage backfill。

- 请求脚本：API shape / pagination。
- S3 样例：真实输入。
- DuckDB：schema / partition。
- smoke backfill：source 到 raw event。
]

== CI/CD 缓存减少等待和版本歧义

#slide-body[
这里说的缓存不只是省资源。它让 agent 更快拿到结果，也让结果更容易归因到某个 git sha 或某次输入。

#table(
  columns: (1fr, 1.2fr, 1.2fr),
  inset: 5pt,
  align: (left, left, left),
  [机制], [减少什么], [结果],
  [layer cache], [重复构建], [CI 更快],
  [ECR cache], [版本歧义], [按 git sha 复用],
  [EFS release], [全量镜像], [代码发布更轻],
  [component detection], [无关部署], [反馈更干净],
)
]

== prod schedule 只接收已经验证过的路径

#slide-body[
固定顺序服务的是反馈速度，不是形式感：

+ API shape
+ S3 样例 + DuckDB
+ smoke backfill
+ stage backfill
+ prod schedule
]
