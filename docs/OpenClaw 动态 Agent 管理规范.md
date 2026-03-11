# **OpenClaw 动态 Agent 管理规范 (基于 soul.md 驱动)**

## **1\. 架构原理解析：Gateway 兼容模型**

理解 Agent 的操作逻辑，首先需要区分执行环境的两种模式：

* **Gateway (网关/指挥中心)**：负责逻辑路由与元数据管理。  
* **执行节点 (Node/物理战场)**：  
  * **本地节点 (Local Node)**：网关所在的机器本身。适用于单机部署或简单任务，无需额外安装 Node 程序。  
  * **远程节点 (Remote Node)**：如 Mac mini、Chromebook 或云端开发机。通过长连接注册到 Gateway。  
* **Node 选择器 (Node Selector)**：在创建 Agent 时，通过标签 (Tags) 或 ID 指定其运行环境。若未指定且未连接远程 Node，系统默认回退至 Gateway 本地环境运行。

**物理存储逻辑**：无论在本地还是远程，Agent 的工作区文件和 soul.md 都存储在 **当前执行节点** 的磁盘上。

## **2\. 核心理念：配置即文件 (Configuration as File)**

为了兼容动态工作区和不同节点环境，我们将 Agent 的“灵魂”解构为执行节点工作区目录下的物理文件：soul.md。

* **物理持久化**：配置随工作区移动。只要磁盘不损坏，设定永不丢失。  
* **环境自适应**：Agent 启动后通过读取 soul.md 识别当前是处于“本地网关”还是“远程节点”，并加载对应的环境变量。

## **3\. 维护规范：你需要关注哪些层级？**

### **A. Gateway 层：引导与路由**

* **对象**：Gateway 管理后台。  
* **内容**：基础引导指令 (Bootstrap Prompt)、Node 选择策略。  
* **本地运行建议**：若在本地运行，请确保网关进程有足够的磁盘读写权限。

### **B. Node 层：灵魂文件 (soul.md)**

* **对象**：工作区根目录文件。  
* **内容**：具体角色定位、该节点的特殊路径（如 Linux 的 /home 与 macOS 的 /Users 差异）。

### **C. 记录层：执行历史 (Git)**

* **建议**：在每个 Node 的工作区初始化 Git，以便跨节点同步代码和 Agent 配置。

## **4\. 动态工作区的 Memory（记忆）机制**

1. **Context Memory (对话上下文)**：由 Gateway 维护，随 Session 隔离。  
2. **Persistent Memory (持久化记忆)**：由 Node 上的 soul.md 维护。Agent 完成阶段性任务后，应将关键进展写回文件，实现“断点续传”。

## **5\. 常见问题 Q\&A**

* **Q: 为什么 Agent 找不到我的远程 Node？**  
  * **A**: 检查 Node 选择器标签是否匹配，并确认 Node 在 Gateway 列表中显示为 Online。  
* **Q: 如果我只在网关本地运行，还需要 soul.md 吗？**  
  * **A**: 需要。它能帮助 Agent 区分“系统全局配置”和“项目特定配置”，并解决动态 Agent 无法直接调用 System Prompt 的限制。  
* **Q: 如何实现跨节点迁移？**  
  * **A**: 将包含 soul.md 的整个工作区文件夹从机器 A 拷贝到机器 B，并在 Gateway 将 Agent 的 Node 选择器指向机器 B 即可。