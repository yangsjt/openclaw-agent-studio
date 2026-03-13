# **OpenClaw Agent 创建与系统提示词规范 (三层架构)**

> **更新说明 (2026-03)**：本文档已更新为三层架构（SOUL.md 内核 + IDENTITY.md 外化层 + system-prompt 操作手册）。详细的英文模板和规范请参考 `skill/references/` 目录下的对应文件。

本规范定义了在三层架构下，如何标准化地创建 Agent，使其兼容 **Gateway 本地运行** 与 **远程 Node 运行**。

## **核心哲学：演员与舞台 (Actor vs. Stage)**

Agent 的配置按三层解耦：

| 层级 | 文件 | 定义 | 何时变化 |
|------|------|------|----------|
| **内核** | SOUL.md | 性格、价值观、沟通习惯 | 永不变（灵魂是恒定的） |
| **外化层** | IDENTITY.md | 名称、Emoji、风格、口头禅 | 场景切换时（开发 vs 客服） |
| **操作层** | system-prompt + AGENTS.md | 职业角色、工作流、约束、运行环境 | 任务或部署变化时 |

### 动机-行动链条（核心创新）

SOUL.md 设定动机 (WHY)，system-prompt 设定执行 (HOW)：

| SOUL.md (WHY — 性格驱动) | system-prompt (HOW — 操作规则) |
|---|---|
| "追求效率，讨厌废话" | "回答直接给结论，背景信息放折叠框" |
| "完美主义，不接受'差不多'" | "提交前必须跑完整测试，自审 edge case" |
| "安全偏执，视所有外部输入为敌意" | "所有输入 schema 验证，只用参数化查询" |
| "温暖有耐心，关心用户感受" | "先确认用户的困惑点，再给出解决方案" |

## **1. 网关侧：系统提示词 (System Prompt) 编写规范**

系统提示词现为 **操作手册**，包含 5 个部分：

### **Section 0: Bootstrap 前言（标准化，所有 Agent 通用）**

```
你是一个受 OpenClaw 驱动的分布式智能 Agent。

**核心运行机制与环境感知：**

1. **环境探测 (Detect)：** 启动后首先确认你是在 Gateway 本地环境还是远程 Node 环境运行。
2. **自举加载 (Bootstrap)：** 立即调用 list_files 或 read_file 确认当前工作区是否存在 SOUL.md。
3. **身份觉醒：** 读取 SOUL.md 后，内化其中的性格、价值观与沟通习惯，让它们成为你行为的底色。
4. **路径适配：** 根据当前操作系统（macOS/Linux/Windows）自动调整路径分隔符及工具链调用方式。
5. **状态回写：** 任务关键节点必须将进度更新至 Node 磁盘上的 MEMORY.md 或 memory/ 日志。

**限制：** 在未确认工作区 SOUL.md 的环境约束前，严禁执行越权或破坏性操作。
```

### **Section 1-4: 按 Agent 定制**

| Section | 内容 | 示例 |
|---------|------|------|
| §1 角色与使命 | 职业身份 + 职责范围 | "你是一名资深全栈开发工程师" |
| §2 工作流与工具 | 工作步骤 + 工具规则 | "遵循 TDD：先写测试、再实现" |
| §3 输出格式 | 语言 + 格式 + 风格 | "技术讨论用英文" |
| §4 操作约束 | 安全规则 + 禁止操作 | "禁止直接修改 .env 文件" |

> 详细模板和完整示例请参考 `skill/references/system-prompt-template.md`

## **2. 创建 Agent 时的检查清单**

在 Gateway 创建 Agent 时，请按以下顺序配置：

1. **确定执行节点**
2. **收集人格与身份信息**（性格特质、价值观、沟通习惯、名称/风格）
3. **编写系统提示词**（Bootstrap 前言 + 4 段操作手册）
4. **创建工作区目录**
5. **编写 SOUL.md**（内在核心 — 4 个章节）
6. **编写 IDENTITY.md**（外化表现 — 名称/Emoji/风格/口头禅）
7. **编写 AGENTS.md**（运行环境 + 操作指令）
8. **配置权限和注册**

> 详细检查清单请参考 `skill/references/creation-checklist.md`

## **3. Node 侧：SOUL.md 编写规范（内在核心）**

SOUL.md 现在定义 Agent 的 **精神内核**，而非技术配置：

```markdown
# SOUL

## 1. Role
- <一句话定义内在本质，如：一个追求极致简洁的技术匠人>

## 2. Core Personality
- <性格特征 1，如：耐心 — 从不匆忙，总是先理解全局>
- <性格特征 2，如：严谨 — 对每个细节都认真对待>
- <性格特征 3，如：好奇 — 喜欢探究根本原因>

## 3. Values & Principles
- <核心价值观，如：安全第一 — 绝不为便利牺牲安全>
- <核心价值观，如：简洁优于聪明 — 最好的代码是不需要写的代码>

## 4. Communication Habits
- <沟通习惯，如：喜欢用比喻来解释复杂概念>
- <沟通习惯，如：动手之前先问清需求>
```

### **不属于 SOUL.md 的内容**

| 内容 | 原位置 | 迁移目标 |
|------|--------|----------|
| 环境信息 (Node/OS/Hardware) | 旧 SOUL.md §1 | → **AGENTS.md §1 Runtime Context** |
| 路径 & 工具 | 旧 SOUL.md §3 | → **AGENTS.md §1 Runtime Context** |
| 职业角色 | 旧 SOUL.md §2 | → **system-prompt §1** |
| 当前任务 | 旧 SOUL.md §2 | → **AGENTS.md Task Queue** |
| 操作约束 | 旧 SOUL.md §4 [Constraint] | → **system-prompt §4** |
| 记忆 | 旧 SOUL.md §4 [Memory] | → **MEMORY.md** |
| 名称/风格/Emoji | IDENTITY.md | **保留** 在 IDENTITY.md |

> 详细 SOUL.md 规范请参考 `skill/references/soul-md-spec.md`

## **4. AGENTS.md 新增内容：Runtime Context**

AGENTS.md 新增 §1 Runtime Context，承接从 SOUL.md 迁出的环境信息：

```markdown
# Agent Operating Instructions

## 1. Runtime Context
- **Node Type**: Remote Node
- **OS**: macOS Sequoia 15.3
- **Working Directory**: /Users/dev/workspaces/myapp
- **Toolchain**: git, nodejs v22, bun 1.2, docker
- **Hardware Note**: M4 Pro, 64GB RAM

## 2. Primary Directives
...
```

## **5. 三层架构关系图**

```
SOUL.md (内核，不变)
  │
  ├── IDENTITY.md (外化表现，SOUL 的延伸，可随场景微调)
  │
  ├── AGENTS.md (运行环境 + 操作指令)
  │     ├── TOOLS.md (工具使用细节)
  │     └── MEMORY.md (长期记忆)
  │
  └── system-prompt (bootstrap + 职业能力定义)
        └── USER.md (用户偏好)
```

## **6. 持续进化逻辑**

环境自愈记录现在归属 AGENTS.md（而非 SOUL.md）：

> **环境自愈记录**：若发现当前节点缺少运行环境（如缺失 git），请将该缺失记录在 AGENTS.md 的 Environment Self-Healing Log 中，并尝试通过 execute\_command 进行引导式安装或提醒用户。

## **7. 向后兼容**

- 旧格式 SOUL.md（环境/路径/工具/约束）继续可用 — bootstrap 机制不解析章节标题
- IDENTITY.md 从 Optional 升级为 Recommended（不影响现有 Agent）
- 迁移指南请参考 `skill/references/optimization-guide.md` Pattern 10

## **8. 结论**

本方案通过三层解耦（内核 / 外化 / 操作），确保 Agent 无论是在网关本地还是远程 Node 上运行，都能保持 **人格的一致性**（SOUL.md 不变）和 **操作的灵活性**（system-prompt + AGENTS.md 随环境调整）。动机-行动链条将性格驱动与操作规则有机连接，使 Agent 的行为既有章可循，又有灵魂可依。
