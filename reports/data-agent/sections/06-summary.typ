#import "../layout.typ": slide-body

= 团队操作约定

== 入口要做成 agent 能直接执行

#slide-body[
工程约定要落到文件、命令和可复用输入上。agent 不能靠口头经验判断下一步。

- 环境资源写进 IaC。
- backfill 输入可复用。
- Dagster metadata 足够定位。
- hooks 按代码类型配置。
]

== 验证标准要提前写清

#slide-body[
进入 prod 前，必须说清楚什么结果算通过，什么失败需要等待，什么失败必须回滚。

- 哪些 source 要先验证。
- backfill 看哪个时间窗口。
- schedule 出错影响哪些报表。
- 哪些失败可以等待，哪些要回滚。
]

== 指令要具体到 agent 可以执行

#slide-body[
好的 agent 指令不是“检查一下”。它应该写清环境、输入、检查命令、通过条件和失败时的查询入口。
]
