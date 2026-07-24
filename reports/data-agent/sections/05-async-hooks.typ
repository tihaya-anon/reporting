= 异步执行与 Hooks

== 长任务必须异步化

Terraform 和 Terragrunt 的执行时间长、输出多、失败位置分散。对 agent 来说，如果同步等待完整输出，容易浪费上下文，也容易丢失中间状态。因此为 tf/tg 提供异步执行 MCP 是合理的演进。

机制可以概括为：

- agent 发起 Terraform/Terragrunt 命令。
- MCP 立即返回一个 job id 或 jsonl 路径。
- 底层命令用 `-json` 输出写入 `/tmp/xxx.jsonl`。
- agent 后续通过 tail 或回调函数增量读取状态。
- 完成后 agent 只提取 diagnostics、resource changes、error address 和 summary。

== jsonl 是 agent 友好的反馈流

相比一次性日志，jsonl 更适合 agent 消费。

#table(
  columns: (1fr, 1.45fr, 1.35fr),
  inset: 5pt,
  align: (left, left, left),
  [反馈类型], [同步日志的问题], [jsonl/异步的优势],
  [plan 进度], [输出太长，容易淹没关键信息], [按 event 读取，只保留 resource change],
  [错误诊断], [失败栈和上下文混在一起], [可按 diagnostic severity 过滤],
  [长时间 apply], [agent 被阻塞], [agent 可以并行查看代码或准备回滚],
  [结果归档], [终端输出难复用], [jsonl 文件可作为验证证据链接],
)

== post-tool hook 与 stop hook

hooks 把质量检查从“agent 记得去做”变成“系统自动提醒或执行”。

- `posttoolhook: formatter`：工具调用后自动格式化，减少 agent 修改文件后留下机械格式噪声。
- `stophook: lint`：agent 准备结束时触发 lint，避免把明显质量问题留给用户发现。
- 这些 hook 的定位不是替代测试，而是把低成本、确定性的检查前移。

== 对 DataAgent 的影响

异步执行和 hooks 让 DataAgent 的工程反馈更接近一个闭环系统：agent 发起动作，系统流式返回状态，工具自动修正格式，结束前再跑 lint。这样 agent 的注意力可以更多放在架构判断、失败诊断和数据口径上。
