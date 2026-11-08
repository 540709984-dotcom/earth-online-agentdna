# WorkBuddy 部署与验收

版本：0.1.0。格式依据核对日期：2026-11-08。

本包提供四个可独立复制的 Skill、任务模板和虚构演练。它是协作方法与文件协议，不是调度器、隔离系统或强制执行的权限控制。尚未在当前用户 WorkBuddy 客户端完成导入与真实业务验收。

## 文件与能力

| 技能 | 用途 | 自包含模板 |
|---|---|---|
| `gene-spec` | 目标、责任、版本、预算与停止条件 | `task-spec.json`、`handoff-receipt.json` |
| `evidence-transcribe` | 来源、日期、数字口径、反证 | `evidence-ledger.json`、`handoff-receipt.json` |
| `proofread-gate` | 独立复核、版本失效、接收与验收分离 | `verification-report.json`、`handoff-receipt.json` |
| `heritage-proposal` | 证据回读后的经验候选，保留逐条人审 | `heritage-proposal.json` |

每个技能的模板都在自己的 `templates/` 下，没有对其他技能目录的运行依赖。仓库根 `templates/` 提供集中阅读副本；运行时以技能内部模板为准。维护者修改模板后应同步对应副本并核对差异。

这些名称中的基因、转录、传承均为工程类比，不表示修改模型权重、生物遗传或已经实现低错误率。

## 安装方式 A：项目目录

1. 将此仓库作为独立 WorkBuddy 工作目录。保留 `.codebuddy/skills/<skill-name>/SKILL.md` 与同目录模板。
2. 新建会话，明确调用技能，例如：“使用 gene-spec，根据当前目录的材料建立任务契约；先确认你实际读取的技能与模板。”
3. 检查它列出的技能名称与内容是否吻合，再用合成示例启动小任务。如果未发现，不自行猜测其他配置路径，改用方式 B。

官方中文项目文档明确介绍 `.codebuddy/skills/`、`.codebuddy/agents/`、`.codebuddy/rules/` 和 `AGENTS.md` 兼容。项目级配置的说明适用于项目工作目录；云端项目资产、个人客户端技能库和本地目录是不同存储面。[WorkBuddy 项目文档](https://www.codebuddy.cn/docs/workbuddy/From-Beginner-to-Expert-Guide/Function-Description/Project)

## 安装方式 B：上传单一技能 ZIP

1. 选择要使用的技能包。包内结构应为 `<skill-name>/SKILL.md` 与该目录的 `templates/`。
2. WorkBuddy → 技能 → 添加技能 → 上传技能，选择 ZIP。若界面名称与文档不一致，以当前客户端实际页面为准。
3. 平台会做安全检查；安装结果以客户端显示为准。高风险提示需按平台要求由用户处理，不绕过检查。
4. 开新会话点名调用，要求输出已读取的模板路径，再运行下述演练。上传文件存在并不等于技能成功加载。

上传流程依据 [WorkBuddy Skills](https://www.workbuddy.ai/docs/workbuddy/From-Beginner-to-Expert-Guide/Function-Description/Skills)；包结构与市场元数据依据 [WorkBuddy 开放平台技能规范](https://open.workbuddy.cn/docs/skill)。本包包括 `name`、中英展示名、中英描述、`description`、`version`、`author`，这些字段的结构检查不等于官方市场审核通过。

## 最小工作流程

默认三种工作角色足够：协调兼构建、研究、独立复核。协调者写任务契约与最终产物，研究者提供证据，独立复核者对指定版本核验；最终使用者验收仍独立记录。

```text
用户目标 → 协调兼构建：任务契约
                    ↓
                 研究：证据账本
                    ↓
             协调兼构建：产物与交接
                    ↓
              独立复核：通过或退回
                    ↓
              使用者：接收与业务验收
                    ↓
              经验候选 → 逐条人工审核
```

只有宿主实际提供独立代理调度能力时才采用多代理执行，并保存真实调用记录。否则使用串行单代理加另一会话/人工复核，或明确的人工交接。一个会话分别写“研究员说”“审核员说”不能算独立协作。复杂任务才增加可并行且边界清楚的研究分支。

WorkBuddy 官方区分 Skill、专家与专家团；专家团才是由团长组织并行成员的产品机制。本包没有专家团 manifest、自动组队入口或原生调度器，不把 Skill 安装成功称为专家团部署成功。[专家说明](https://www.codebuddy.cn/docs/workbuddy/From-Beginner-to-Expert-Guide/Function-Description/Expert-Center)；[专家团包规范](https://open.workbuddy.cn/docs/expert-team)

## 公共字段与状态

| 字段 | 用途 |
|---|---|
| `task_id`、`parent_spec.id/version` | 将工作绑定到目标和父契约 |
| `producer`、`reviewer` | 记录产物作者和独立复核责任人 |
| `source_refs`、`claim_status` | 支持结论的来源及其认识状态 |
| `artifact_version`、可选真实 `artifact_sha256` | 精确识别产物；未知哈希保留 null |
| `received` | 接收方确实收到指定版本 |
| `verified` | 复核方有证据的技术/内容检查 |
| `accepted` | 有权使用者或授权业务流程完成验收 |

`claim_status`：`source_reported`、`inferred`、`proposed`、`unverified`、`contradicted`。来源被找到不等于结论被独立复现。

状态枚举：接收为 `pending/received`；核验为 `pending/pass/fail/stale`；验收为 `pending/accepted/rejected`。产物内容或父契约变化，旧核验应为 `stale`，不能继续引用旧通过标签。模板仅记录这些要求，不强制阻止错误状态转换；正式自动化需要独立执行层和测试。

预算模板中的调用数、重试与时间是待采用的建议值，不是用户付款授权。费用未知写 null 并注明未知，不当成无限预算。到达预算、关键来源缺失或独立复核不可用时停下依赖步骤，交出缺口。外发、发布与付款遵循既有明确授权并记录范围；未授权动作先形成可审阅结果再交用户决定。

## 虚构演练

从 `examples/fde-handoff/README.md` 开始。示例中的公司、任务、数字、角色与状态事件均为合成数据，不是本轮实测，也不能当成真实企业案例。

在 WorkBuddy 中可粘贴：

> 请读取 examples/fde-handoff/README.md。用 evidence-transcribe 整理示例证据，再由实际独立执行方使用 proofread-gate 检查 draft.md。不要把示例状态当成真实调用证据，不要发布、发送或写入长期记忆。请指出那条效率数字为何不能通过，并输出真实本次运行的接收、验证、验收状态。无独立代理能力时直说，保留待独立复核状态。

期待检查的是：是否发现无来源的“30%”、是否维持 `accepted=pending`、是否拒绝自批、修改版本后是否使旧验证失效。它只验证工作流理解，不证明多智能体提高效率。

## 真正评估效率的方法

选同类任务做单代理基线和协作组，统一输入、工具范围、时间及费用预算，分别记录首次验收通过率、遗漏/错误、总时长、人类复核分钟数与每个验收成果成本。记录模型、客户端、技能版本与失败案例；没有真实对照数据时不填收益数字。不能把并行速度、文本长度、角色数量或模型自评分当成工作效率。

## 本地验证与人工验收分开

文件检查包括必填 frontmatter、JSON 可解析和自包含模板路径。客户端导入、实际独立调度、真实文件交接、业务收益与用户认可需要另行执行并保留证据。本轮没有更改 WorkBuddy 的用户配置、连接器、模型或付费设置，没有替用户向其他人发送消息。

2026-11-08 本地结构自检：4/4 个技能具备上述必填 frontmatter 字段且名称与目录一致；16/16 个 JSON 可解析且包含公共交接字段；7/7 个技能内部模板与根模板一致；技能文本引用的模板均存在；所有示例 JSON 均标有 `simulation: true`。这些是文件结构检查，不是 WorkBuddy 导入或业务验收。

经验候选遵守项目既定 Beacon/Von 与人工审核约定；评分、候选草稿和技能文件存在都不能单独证明“自我升级完成”。
