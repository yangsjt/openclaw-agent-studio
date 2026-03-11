# OpenClaw Agent 替代创建方案

本文档补充说明除 SOUL.md 驱动外的其他 Agent 创建方式，作为项目源文档的一部分。

## ACP Agents（外部运行时 Agent）

### 概念说明

ACP (Agent Communication Protocol) Agents 通过 ACP 协议启动外部 AI 运行时（Codex、Claude Code、Gemini CLI、OpenCode 等），作为持久化或一次性会话由 OpenClaw Gateway 管理。

### 与 SOUL.md 驱动的区别

- **SOUL.md 驱动**：使用内部 Pi 运行时，Agent 身份和配置完全由工作区文件定义
- **ACP Agent**：使用外部进程（如 Codex CLI），外部运行时有自己的能力集和行为模式

### 适用场景

- 需要特定 IDE Agent 能力（如 Codex 的代码执行沙箱、Claude Code 的文件操作）
- 需要利用外部运行时的专有特性
- 需要在特定通道线程中保持持久化的外部运行时会话

### 快速创建示例

```
/acp spawn codex --mode persistent --thread auto
/acp spawn claude --mode persistent --thread auto --cwd /repo
/acp spawn gemini --mode persistent --thread auto
```

### 配置要点

```json5
{
  acp: {
    enabled: true,                    // 启用 ACP 功能
    dispatch: { enabled: true },       // 启用 ACP 调度
    backend: "acpx",                   // 使用 acpx 后端
    allowedAgents: ["pi", "claude", "codex", "opencode", "gemini"],
    maxConcurrentSessions: 8,
  },
}
```

**前置条件**：
1. 安装 acpx 插件：`openclaw plugins install @openclaw/acpx`
2. 启用配置：`acp.enabled: true`
3. 验证安装：`/acp doctor`

### 核心操作

| 操作 | 命令 |
|------|------|
| 创建会话 | `/acp spawn codex --mode persistent --thread auto` |
| 查看状态 | `/acp status` |
| 调整模型 | `/acp model <provider/model>` |
| 设置权限 | `/acp permissions <profile>` |
| 引导方向 | `/acp steer <message>` |
| 取消当前轮 | `/acp cancel` |
| 关闭会话 | `/acp close` |
| 列出会话 | `/acp sessions` |

---

## Sub-agents（内部嵌套 Agent）

### 概念说明

Sub-agents 是从主 Agent 会话中派生的隔离子会话，使用内部 Pi 运行时。它们设计用于并行化工作、委派长任务、或执行不需要阻塞主运行的操作。

### 与独立 Agent 的区别

- **独立 Agent（SOUL.md 驱动）**：拥有完整工作区、所有 bootstrap 文件、独立的 openclaw.json 配置
- **Sub-agent**：共享 Gateway 资源、无需单独工作区、仅接收 AGENTS.md + TOOLS.md

### 适用场景

- 并行化独立的研究任务
- 委派长时间运行的操作而不阻塞主 Agent
- 需要临时工作者，不需要完整的 Agent 配置

### 快速创建示例

通过工具调用：
```json
{
  "tool": "sessions_spawn",
  "params": {
    "task": "研究 Node.js 速率限制的最佳实践",
    "label": "rate-limit-research",
    "runTimeoutSeconds": 300
  }
}
```

通过斜杠命令：
```
/subagents spawn main "研究 Node.js 速率限制的最佳实践"
```

### 关键参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `maxSpawnDepth` | 允许的嵌套深度 | 1（设为 2 可启用嵌套） |
| `maxConcurrent` | 全局并发上限 | 8 |
| `maxChildrenPerAgent` | 每个 Agent 会话的最大子 Agent 数 | 5 |
| `runTimeoutSeconds` | 运行超时（秒） | 0（无超时） |
| `archiveAfterMinutes` | 完成后自动归档时间 | 60 分钟 |

### 配置示例

```json5
{
  agents: {
    defaults: {
      subagents: {
        maxSpawnDepth: 2,
        maxChildrenPerAgent: 5,
        maxConcurrent: 8,
        runTimeoutSeconds: 900,
        archiveAfterMinutes: 60,
      },
    },
  },
}
```

### 核心操作

| 操作 | 命令 |
|------|------|
| 创建 Sub-agent | `/subagents spawn <agentId> <task>` |
| 列出活跃 Sub-agents | `/subagents list` |
| 停止 Sub-agent | `/subagents kill <id\|all>` |
| 查看日志 | `/subagents log <id>` |
| 发送消息 | `/subagents send <id> <message>` |
| 引导方向 | `/subagents steer <id> <message>` |

---

## 三种方式对比表

| 维度 | SOUL.md 驱动 | ACP Agent | Sub-agent |
|------|-------------|-----------|-----------|
| **运行时** | 内部 Pi | 外部进程（Codex、Claude 等） | 内部 Pi |
| **持久化** | 完整工作区 + SOUL.md | 会话级 | 会话级 |
| **独立性** | 完全独立 | 半独立 | 依附主 Agent |
| **Bootstrap 文件** | 全部 6 个文件 | 外部运行时配置 | 仅 AGENTS.md + TOOLS.md |
| **工作区** | 专用目录 | 共享或外部 | 继承父 Agent 工作区 |
| **配置位置** | `agents.list` + `bindings` | `acp` 配置段 | `subagents` 配置段 |
| **通道绑定** | 通过 `bindings` | 通过线程绑定 | 通过线程绑定 |
| **适用场景** | 长期运行的专业 Agent | 需要特定外部 AI 能力 | 临时并行任务 |
| **搭建成本** | 高（工作区 + 文件 + 配置） | 中（插件 + 配置） | 低（工具调用或命令） |

---

## 选择指南

### 选择 SOUL.md 驱动 Agent 当：

- 需要长期运行的、具有完整身份的专业 Agent
- Agent 需要跨会话保持记忆和上下文
- Agent 需要独立的通道绑定
- Agent 需要在 Gateway 重启后保持完整配置

### 选择 ACP Agent 当：

- 需要特定外部 AI 运行时的能力（Codex 沙箱、Claude Code 文件操作等）
- 需要在通道线程中维持持久化的外部运行时会话
- 外部运行时的特有功能是任务的关键需求

### 选择 Sub-agent 当：

- 需要快速委派一次性任务
- 需要并行化多个独立的研究或分析任务
- 不需要完整的 Agent 配置和工作区
- 任务是临时的，完成后不需要保留
