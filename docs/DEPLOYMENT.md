# 部署说明

本项目提供一支完整研究 Skill 和四支职责 Skill。它们是文件协议与操作规则，不依赖特定模型，也不包含自动调度器。

## 1. 获取项目

```bash
git clone https://github.com/540709984-dotcom/earth-online-agentdna.git
cd earth-online-agentdna
```

只需要完整研究工作流时，使用：

```text
.codebuddy/skills/agentdna-research/
```

也可下载 `packages/agentdna-research-v0.1.0.zip`，在支持 Skill ZIP 的客户端中导入。

## 2. WorkBuddy 项目级部署

1. 将仓库作为 WorkBuddy 项目目录打开，保留 `.codebuddy/skills/` 结构。
2. 新建会话，输入：“使用 `agentdna-research`，读取本目录材料，为本次任务建立研究任务包；先列出实际读取的模板路径。”
3. 确认客户端实际读到了 `SKILL.md` 与 `templates/research-brief.json`。
4. 先用 `examples/fde-handoff/` 做低风险演练；示例为合成数据。
5. 只有宿主实际提供独立代理或专家团能力时，才把 `verified.independence.different_actor` 设为 `true`。

单 Skill ZIP 的上传入口与字段可能随客户端版本变化；以当前 WorkBuddy 界面和官方文档为准。文件存在、上传完成和真实调用成功是三个不同状态。

## 3. Grok Bot 多 BOT 编制

建议从四个 Bot 开始，不需要把每个动作都拆成一个 Bot：

| Bot | 稳定职责 | 读取 | 交付 |
|---|---|---|---|
| 协调 Bot | 冻结任务包、分派、整合 | `gene-spec`、任务输入 | `research-brief.json`、最终稿 |
| 证据 Bot | 查找原始来源、记录口径与反证 | `evidence-transcribe` | `evidence-ledger.json` |
| 构建 Bot | 只消费批准过的任务包和证据 | 综合报告骨架 | 带版本的产物 |
| 复核 Bot | 不参与成稿，逐条核对验收标准 | `proofread-gate` | `verification-report.json` |

在 Grok Bot 中建立一个共享项目目录，把本仓库文件放入工作区。为每个 Bot 的长期规则写明职责、禁止事项和固定输出；每次任务只发送任务包和所需证据，不把全部长期材料反复复制进对话。群聊只负责可见交接，文件中的 `task_id`、`artifact_version` 和状态字段负责机器可读的一致性。

建议的启动消息：

```text
协调 Bot：读取 .codebuddy/skills/agentdna-research/SKILL.md 和 templates/research-brief.json。
为当前目标建立任务包，冻结范围、来源策略、预算、停止条件与验收标准。
证据 Bot 只交付证据账本；构建 Bot 不添加账本之外的事实；复核 Bot 不参与成稿。
任何外发、发布、付款、删除和生产变更必须保留人类决定。
```

Grok Bot 的群聊、持续执行和共享工作区属于平台能力；不同 Bot 共享同一环境时，不应把它们当成安全隔离边界。

## 4. 没有原生多代理时

选择 `single_agent_with_independent_review` 或 `manual_handoff`。先让一个会话研究和构建，再由另一模型、另一会话或人工对指定版本复核。一个会话里轮流自称“研究员”和“审核员”不能记录为独立复核。

## 5. 最小验收

部署后用同一合成任务检查：

1. 能否生成带 `task_id` 和版本的任务包；
2. 无来源数字是否保持 `unverified`；
3. 复核者是否拒绝作者自批；
4. 修改产物后旧核验是否变为 `stale`；
5. 没有人类验收时 `accepted.status` 是否保持 `pending`。

这五项通过表示工作流理解正确，不代表已经证明效率提升。正式评估请按 `docs/evaluation-plan.md` 做单代理基线与协作组对照。

## 6. 更新与回退

规则、模板与报告都通过 Git 版本管理。升级前记录当前 commit；若新版使验收率下降或交接损失上升，回到上一稳定 tag。经验只能先写入 `change-proposal.json`，由人逐条批准后再修改 Skill。

不要把客户资料、凭据、私人书稿或原始执行轨迹提交到公开仓库。公开示例使用合成数据或获得明确授权的资料。
