#import "lib.typ": vis-slides
#import "diagrams.typ": mermaid-diagram

#show: vis-slides.with(
  title: "VIS 主题样张",
  subtitle: "Diatypst 元素展示 / 中文为主的混排测试",
  date: "2026-07-24",
  authors: ("VIS Design", "Typst"),
  toc: true,
)

= 文本与链接

== 基础文本 <text-demo>

Diatypst 使用一级标题作为章节页，使用二级标题作为内容页。这里主要检查中文段落、_强调文本_ 和 *加粗文本*。

短代码 `layout: "large"` 应该贴合正文基线，少量 English words 也要自然混排。

外部链接示例：#link("https://typst.app")[Typst 官网]。本地引用示例：跳转到 @list-demo 或 @figure-demo。

#quote[
  一个报告主题首先要保证常见内容清晰可读，然后再体现品牌识别。
]

= 列表与步骤

== 列表层级 <list-demo>

- 无序列表用于罗列观察、风险或约束。
- 嵌套项目应该保持清楚的层级关系。
  - 第二层项目用于补充说明。
  - 长文本换行后不应破坏缩进节奏。
- 列表标记使用主题色，但不抢正文注意力。

+ 第一步：确认报告目标。
+ 第二步：组织证据和结构。
+ 第三步：输出结论和后续动作。

= 术语与引用

== 术语块

/ *主要色*: 用于标题、进度圆点、强调线条和关键状态。

/ *辅助色*: 用于定义块、轻量背景和低强调信息区域。

#quote[
  术语块适合展示定义、假设、指标口径或报告中的固定说明。
]

= 代码与参数

== 代码块

短参数适合写成 inline code，例如 `toc: true`、`count: "dot-section"` 和 `layout: "medium"`。

```typ
#show: vis-slides.with(
  title: "报告标题",
  subtitle: "可选副标题",
  authors: ("作者 A", "作者 B"),
  layout: "large",
  toc: true,
)
```

= 表格与数据

== 表格

#table(
  columns: (1.1fr, 1fr, 1fr, 1fr),
  inset: 6pt,
  align: (left, center, center, center),
  [元素], [用途], [主题色], [状态],
  [Footer], [上下文], [Primary], [已启用],
  [Agenda], [导航], [Primary + Border], [自定义],
  [Terms], [定义], [Secondary], [已适配],
  [Logo], [品牌识别], [Ink], [每页显示],
)

= 数学与图形

== 公式与图注 <figure-demo>

公式需要保持足够清晰，不要被版式装饰干扰：

$ "评分" = alpha dot "质量" + beta dot "清晰度" - gamma dot "风险" $

#figure(
  rect(
    width: 72%,
    height: 1.35cm,
    fill: luma(245),
    stroke: 0.8pt + luma(210),
    radius: 2pt,
  )[
    #align(center + horizon)[图形占位：趋势、截图或架构图]
  ],
  caption: [图注示例，用于检查 figure caption 的默认效果。],
) <sample-figure>

参见 @sample-figure。

= Mermaid 图形

== 组件图 <diagram-demo>

#mermaid-diagram("../vis/diagrams/fig/component-flow.svg", height: 4.4cm)

== 类图

#mermaid-diagram("../vis/diagrams/fig/class-model.svg", width: 74%, height: 6.9cm)

== 时序图

#mermaid-diagram("../vis/diagrams/fig/render-sequence.svg", height: 5.8cm)

= 栅格与布局

== 卡片和分栏

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.28cm,
  rect(width: 100%, height: 1.5cm, fill: rgb("#FFEEE5"), radius: 2pt)[
    #align(center + horizon)[指标]
  ],
  rect(width: 100%, height: 1.5cm, fill: rgb("#FFF8F4"), stroke: 0.8pt + luma(220), radius: 2pt)[
    #align(center + horizon)[洞察]
  ],
  rect(width: 100%, height: 1.5cm, fill: rgb("#F5F5F5"), stroke: 0.8pt + luma(220), radius: 2pt)[
    #align(center + horizon)[行动]
  ],
)

#v(0.35cm)

#columns(2, gutter: 0.45cm)[
  左侧可以放方法、结论或图表说明。

  #colbreak()

  右侧可以放解释、限制条件或后续动作。
]

= 本地导航

== 交叉引用 <nav-demo>

本地引用应该和正文基线一致，并且在视觉上能被识别为可点击对象：

- 回到文本页：@text-demo。
- 查看列表页：@list-demo。
- 检查图形引用：@sample-figure。

= 附录与结束

== 最后一页

这一页用于观察最后一页的 footer、section 标识和右上角进度圆点。Agenda 中现在有更多 section，可以检查多行目录的排布效果。
