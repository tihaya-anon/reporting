= 异步执行与 Hooks

== 长任务必须异步化

Terraform 和 Terragrunt 执行时间长、输出多、失败位置分散。agent 如果同步等待完整输出，会浪费上下文，也容易丢掉中间状态。tf/tg 需要异步执行 MCP，让命令继续跑，让 agent 分批读取结果。

机制是：

- agent 发起 Terraform/Terragrunt 命令。
- MCP 立即返回一个回调句柄或 jsonl 路径。
- 底层命令仍然全量执行并写入磁盘，`-json` 输出落到 `/tmp/xxx.jsonl`。
- agent 后续通过 tail 或回调函数增量读取状态。
- MCP 内预置 jq pattern，可以直接返回 summary、diagnostics 等摘要。
- agent 仍然可以自己读取 jsonl，并用 jq 做额外筛选。

== jsonl 是 agent 友好的反馈流

相比一次性日志，jsonl 更适合 agent 消费：每一行都是一个事件，能被 tail、jq 和 MCP summary 反复读取。

#table(
  columns: (1fr, 1.45fr, 1.35fr),
  inset: 5pt,
  align: (left, left, left),
  [反馈类型], [同步日志的问题], [jsonl/异步的优势],
  [plan 进度], [输出太长，容易淹没关键信息], [按 event 读取，只保留 resource change],
  [错误诊断], [失败栈和上下文混在一起], [MCP 预置 jq 摘要，agent 也可自行 jq],
  [长时间 apply], [agent 被阻塞], [agent 可以并行查看代码或准备回滚],
  [结果归档], [终端输出难复用], [jsonl 文件可作为验证证据链接],
)

== post-tool hook 与 stop hook

hooks 把质量检查从“agent 记得去做”改成“系统自动提醒或执行”。

- `posttoolhook: formatter`：工具调用后自动格式化，减少 agent 修改文件后留下机械格式噪声。
- `stophook: lint`：agent 准备结束时触发 lint，避免把明显质量问题留给用户发现。
- formatter 只 warning，不阻塞 agent；lint 会 block，agent 被 block 后需要自己修复再继续。
- 这些 hook 的定位不是替代测试，而是把低成本、确定性的检查前移。

== 对 DataAgent 的影响

异步执行和 hooks 改变了 DataAgent 的工作节奏：agent 发起动作，系统持续写出状态，工具处理格式，结束前再跑 lint。agent 不需要把注意力耗在等待和记忆检查项上，可以把更多上下文留给架构判断、失败诊断和数据口径。
