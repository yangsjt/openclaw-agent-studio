> **Note (2026-03)**: The SOUL.md and system-prompt specifications in this PRD reflect the original design. The authoritative, updated specifications are in `skill/references/soul-md-spec.md` (new 4-section personality-focused format) and `skill/references/system-prompt-template.md` (new 5-section operation manual format). See also `docs/OpenClaw Agent 创建与系统提示词规范.md` for the updated Chinese source document.

# PRD: OpenClaw Agent Creation Skill

## 产品概述

**openclaw-agent-studio** 是一个 Claude Code skill，提供标准化的 OpenClaw Agent 创建和优化工作流。它指导用户通过 SOUL.md 驱动架构创建完整的 Agent（包括系统提示词、bootstrap 文件体系、openclaw.json 配置和验证流程），并支持对已有 Agent 进行审计和优化。

**定位**：专注于 Agent 创建流程，与 `openclaw` skill（覆盖运维操作）互补不重叠。

## 背景与动机

### 问题

1. **创建流程不标准化**：缺乏统一的 Agent 创建流程，每次创建需要手动组装多个配置文件
2. **知识分散**：SOUL.md 规范、系统提示词模板、配置格式散落在不同文档中
3. **上手门槛高**：新用户需要理解 Gateway/Node 架构、bootstrap 文件体系、binding 配置等多个概念
4. **缺少替代方案参考**：用户不清楚何时应该使用 SOUL.md 驱动 vs ACP Agent vs Sub-agent

### 解决方案

将所有 Agent 创建知识整合为一个 Claude Code skill，使 Claude 能在用户请求创建 Agent 时自动提供：
- 标准化的 8 步创建工作流
- 可直接复制的模板和配置
- 创建前后的检查清单
- 替代方案的对比和选择指南

## 核心概念

### SOUL.md 驱动架构（Configuration as File）

Agent 的"灵魂"被解构为工作区目录下的物理文件，以 SOUL.md 为核心：
- **物理持久化**：配置随工作区移动，磁盘不损坏则设定永不丢失
- **环境自适应**：Agent 启动后读取 SOUL.md 判断运行环境并加载对应变量
- **跨节点一致性**：无论在 Gateway 本地还是远程 Node，相同的 SOUL.md 协议保证行为一致

### Bootstrap 文件体系（6 文件协作）

| 文件 | 角色 | 层级 |
|------|------|------|
| SOUL.md | 身份基础 + 环境感知 | 核心层 |
| AGENTS.md | 操作指令 + 持久记忆 | 指令层 |
| TOOLS.md | 工具使用说明 | 指令层 |
| BOOTSTRAP.md | 首次运行仪式 | 初始化层 |
| IDENTITY.md | 人设/风格/表情 | 人格层 |
| USER.md | 用户画像/偏好 | 上下文层 |

文件间的协作关系：
- SOUL.md 是基础，所有其他文件引用或扩展它
- AGENTS.md 假设 SOUL.md 身份已加载
- IDENTITY.md 和 USER.md 是 SOUL.md 之上的人格/上下文层
- BOOTSTRAP.md 在首次运行后自动删除

### 环境感知机制

Agent 需要感知两种执行环境：
- **Gateway 本地**：Gateway 进程所在机器，无需额外 Node 连接
- **远程 Node**：通过 WebSocket 连接的外部设备，需要 Node Selector 配置

### 5 步核心运行机制

1. **环境探测 (Detect)**：确认 Gateway 本地 vs 远程 Node
2. **自举加载 (Bootstrap)**：读取 SOUL.md 和其他 bootstrap 文件
3. **身份觉醒 (Awaken)**：继承身份、目标、工具规范
4. **路径适配 (Adapt)**：根据 OS 调整路径和工具链
5. **状态回写 (Write Back)**：任务节点将进度更新至 SOUL.md

## 功能需求

### FR1: 标准系统提示词生成

**描述**：提供标准的 bootstrap loader 系统提示词模板，Agent 的 `instruction` 字段使用此模板。

**内容**：
- 中文标准模板（可直接复制）
- 5 步核心机制的详细说明
- 针对不同角色（编码、运维、社交）的定制指导
- 限制说明：未确认 SOUL.md 环境约束前禁止越权操作

**验收标准**：
- [ ] 模板可直接复制到 openclaw.json 的 instruction 字段
- [ ] 包含所有 5 步核心机制
- [ ] 提供至少 3 种角色的定制示例

### FR2: SOUL.md 模板生成

**描述**：提供 SOUL.md 编写规范和标准模板。

**内容**：
- 4 章节标准模板（带占位符）
- 每个章节的详细字段说明
- 环境自愈记录的规范
- 2-3 个完整 SOUL.md 示例（编码、运维、社交 Agent）

**验收标准**：
- [ ] 模板覆盖全部 4 个标准章节
- [ ] 提供至少 3 个完整的角色示例
- [ ] 包含环境自愈记录的规范说明

### FR3: 完整 Bootstrap 文件体系生成

**描述**：提供所有 6 个 bootstrap 文件的模板和编写指南。

**内容**：
- 6 个文件的概览表（用途、是否必需）
- 每个文件的编写模板
- 每个文件的实际示例
- 文件间协作关系的说明
- Sub-agent 的 bootstrap 上下文限制说明

**验收标准**：
- [ ] 覆盖全部 6 个 bootstrap 文件
- [ ] 每个文件都有模板和至少 1 个示例
- [ ] 说明了文件间的协作关系

### FR4: openclaw.json 配置生成

**描述**：提供可直接使用的 openclaw.json 配置模板。

**内容**：
- 完整的 JSON5 配置模板（agents.list + bindings）
- Binding match fields 说明
- Binding 优先级规则
- Per-agent 配置覆盖选项

**验收标准**：
- [ ] 配置模板可直接复制并修改占位符后使用
- [ ] 覆盖 agents.list、bindings、tools 三大配置段
- [ ] 说明了 binding 匹配规则和优先级

### FR5: 创建检查清单与验证流程

**描述**：提供创建前的信息收集清单、创建中的执行清单、创建后的验证清单。

**内容**：
- 信息收集清单（8 项）
- 创建执行清单（12 项 checkbox）
- openclaw.json 配置模板
- 创建后验证清单（CLI 命令 + 功能测试）

**验收标准**：
- [ ] 清单覆盖从信息收集到验证的完整流程
- [ ] 每个清单项可逐条勾选
- [ ] 验证命令可直接执行

### FR6: 动态管理与跨节点迁移

**描述**：提供 Agent 动态管理规范，包括三层维护、记忆机制、跨节点迁移。

**内容**：
- 架构概览（Gateway + Local/Remote Node + Node Selector）
- 三层维护（Gateway 层、Node 层、记录层）
- 记忆机制（Context Memory + Persistent Memory）
- 跨节点迁移 4 步流程
- Node 操作命令参考
- FAQ

**验收标准**：
- [ ] 清晰解释了 Gateway/Node 架构
- [ ] 跨节点迁移流程可操作
- [ ] FAQ 覆盖常见问题

### FR7: 替代方案参考

**描述**：提供 ACP Agents 和 Sub-agents 作为 SOUL.md 驱动的替代方案参考。

**内容**：
- ACP Agents 说明（概念、配置、快速创建）
- Sub-agents 说明（概念、配置、快速创建）
- 三种方式对比表（9 个维度）
- 选择指南（决策树）

**验收标准**：
- [ ] 清晰区分三种创建方式
- [ ] 对比表覆盖关键维度
- [ ] 选择指南可指导用户做出决策

### FR8: 现有 Agent 审计与优化

**描述**：提供已有 Agent 的审计流程和优化指南，帮助用户将不符合规范的 Agent 升级到 SOUL.md 驱动架构。

**内容**：
- 5 步优化工作流（Audit → Analyze → Report → Fix → Verify）
- 4 维度差距分析检查清单（SOUL.md、系统提示词、Bootstrap 文件、配置）
- 严重性分级（Critical / High / Medium / Low）
- 7 种常见优化模式及修复方案
- 优化报告模板（结构化输出格式）
- 优化后验证流程

**验收标准**：
- [ ] 检查清单覆盖 SOUL.md、系统提示词、Bootstrap 文件、配置四个维度
- [ ] 每个检查项有明确的通过标准和严重性等级
- [ ] 7 种优化模式可逐条对照执行
- [ ] 报告模板可直接复制使用

### FR9: 工作区日常维护

**描述**：提供工作区文件的日常维护工作流，包括 Token 预算审计、冗余检测、记忆蒸馏和文件生命周期管理。参考 `openclaw-workspace` 项目的最佳实践。

**内容**：
- 5 步维护工作流（Token Budget Audit → Redundancy Check → Staleness Review → Memory Distillation → Offload to docs/）
- Token 预算管理（单文件 20k 上限、总量 ~150k、分级阈值）
- 冗余审计矩阵（SOUL.md vs AGENTS.md, TOOLS.md vs MEMORY.md 等交叉检查）
- 记忆蒸馏流程（Heartbeat 自动 + 手动两种模式）
- 完整工作区文件覆盖（11 个文件类型：新增 HEARTBEAT.md, BOOT.md, MEMORY.md, daily logs, checklists）
- 常见问题与修复方案

**验收标准**：
- [ ] Token 预算阈值表可指导文件大小管理
- [ ] 冗余审计矩阵覆盖主要交叉检查场景
- [ ] 记忆蒸馏流程可逐步执行
- [ ] bootstrap-files.md 覆盖全部 11 种文件类型
- [ ] workspace-maintenance.md 包含可执行的审计命令

## 架构设计

### Gateway 兼容模型

```
                    ┌─────────────┐
                    │   Gateway   │
                    │ (Command    │
                    │  Center)    │
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
       ┌──────┴──────┐ ┌──┴───┐ ┌──────┴──────┐
       │ Local Node  │ │ Node │ │ Remote Node │
       │ (Gateway    │ │Selec-│ │ (Mac mini,  │
       │  machine)   │ │ tor  │ │  cloud, etc)│
       └─────────────┘ └──────┘ └─────────────┘
```

- **Gateway**：逻辑路由与元数据管理
- **Local Node**：Gateway 所在机器，无需额外安装
- **Remote Node**：通过 WebSocket 连接的外部设备
- **Node Selector**：通过 Tags 或 ID 指定执行环境

### 三层维护架构

| 层级 | 对象 | 内容 |
|------|------|------|
| Gateway 层 | 管理后台 | Bootstrap Prompt、Node 选择策略 |
| Node 层 | 工作区文件 | SOUL.md、AGENTS.md 等 bootstrap 文件 |
| 记录层 | Git 仓库 | 执行历史、配置变更记录 |

### 记忆机制

| 类型 | 维护者 | 生命周期 | 用途 |
|------|--------|----------|------|
| Context Memory | Gateway | 会话级 | 对话历史、中间推理 |
| Persistent Memory | Node 磁盘 (SOUL.md) | 跨会话 | 任务进度、关键决策 |

## 与 OpenClaw 现有体系的对齐

### SOUL.md 命名对齐

原始设计文档使用小写 `soul.md`，本 skill 统一使用大写 `SOUL.md`，与 OpenClaw bootstrap 文件体系（AGENTS.md、TOOLS.md 等）保持一致。

### Bootstrap 文件体系对齐

本 skill 覆盖 OpenClaw `agent_runtime.md` 中定义的完整 bootstrap 文件体系（6 个文件），而非仅关注 SOUL.md。

### Config 结构对齐

配置模板使用 OpenClaw 标准的 `openclaw.json` (JSON5) 格式，字段路径与 `config_reference.md` 完全一致。

### Node 系统对齐

动态管理规范中的 Node 操作命令与 `nodes.md` 参考一致，跨节点迁移流程兼容 Node 系统的实际行为。

## 非功能需求

### NFR1: Token 消耗控制

- SKILL.md 主入口文件控制在 150 行以内
- 详细内容放在 references/ 目录，按需加载
- 避免在 SKILL.md 中重复 reference 文件的完整内容

### NFR2: 模板可复制性

- 所有模板使用 markdown 代码块包裹
- 占位符使用 `<description>` 格式，易于识别和替换
- JSON5 配置模板包含注释说明

### NFR3: 与 openclaw skill 互补

- 本 skill 不包含 OpenClaw 安装、配置排障等运维内容
- Node 操作命令仅作简要参考，详细内容指向 openclaw skill
- 两个 skill 的 "When to Activate" 条件互不重叠

### NFR4: 安装简便性

- 单命令安装：`bash install.sh`
- Symlink 方式：源码修改即时生效
- 无需额外依赖

## 验收标准

### 安装验收

- [ ] `bash install.sh` 成功创建 symlink
- [ ] `ls -la ~/.claude/skills/openclaw-agent-studio/SKILL.md` 可访问
- [ ] Claude Code 会话中 skill 可被正确识别

### 功能验收

- [ ] 请求"创建一个新的 OpenClaw Agent"时 skill 被激活
- [ ] 生成的系统提示词符合标准模板
- [ ] 生成的 SOUL.md 包含全部 4 个标准章节
- [ ] openclaw.json 配置模板可直接使用
- [ ] 创建检查清单覆盖完整流程
- [ ] 请求"优化一个现有的 Agent"时 skill 被激活
- [ ] 审计检查清单可逐条执行并生成优化报告
- [ ] 优化模式可指导修复不符合规范的 Agent

### 内容验收

- [ ] SKILL.md < 150 行
- [ ] 8 个 reference 文件各自内容完整
- [ ] 所有模板可直接复制使用
- [ ] 三种创建方式的对比清晰完整
- [ ] PRD 覆盖所有功能需求和价值点
