#import "../layout.typ": report-diagram, slide-body

= 小样本验证把错误留在低成本环境

== 数据路径先用小输入证明

#slide-body[
验证顺序要从低成本证据开始，再进入更接近生产的路径。

#report-diagram("../reports/data-agent/diagrams/fig/cache-validation-pyramid.svg", height: 5.7cm)
]

== 开发侧只证明接口和数据形状

#slide-body[
开发侧只回答一件事：这条数据路径是不是成立。

- 请求脚本：API shape / pagination。
- S3 样例：真实输入。
- DuckDB：schema / partition。
- smoke backfill：source 到 raw event。
]

== CI/CD 缓存减少等待和版本歧义

#slide-body[
CI/CD 缓存的作用：少等、少误触发、版本更清楚。

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
固定顺序：

+ API shape
+ S3 样例 + DuckDB
+ smoke backfill
+ stage backfill
+ prod schedule
]
