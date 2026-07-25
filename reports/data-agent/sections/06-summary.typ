#import "../layout.typ": slide-body

= agent 使用要落成团队约定

== 技术团队负责把入口做实

#slide-body[
技术侧要把入口做成 agent 能直接读、能直接跑的形式。

- 环境资源写进 IaC。
- backfill 输入可复用。
- Dagster metadata 足够定位。
- hooks 按代码类型配置。
]

== 业务团队负责定义可接受验证

#slide-body[
业务侧要说清楚什么叫“可以进入 prod”。

- 哪些 source 要先验证。
- backfill 看哪个时间窗口。
- schedule 出错影响哪些报表。
- 哪些失败可以等待，哪些要回滚。
]

== 指令要具体到 agent 可以执行

#slide-body[
好的 agent 指令不是“检查一下”。它应该写清环境、输入、hook、通过条件和失败时的查询入口。
]
