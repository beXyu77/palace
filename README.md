# 宫廷 · 后宫生存模拟（Flutter）

一个以 **中式古代宫廷** 为背景的单机模拟类游戏。  
玩家以「选秀入宫」为起点，在回合制推进中，通过事件选择、属性成长与派系博弈，决定自身命运与最终结局。

本项目当前聚焦 **MVP（最小可玩闭环）**，优先实现“能玩、能结算、能走向结局”的完整流程。

---

## 🎮 游戏核心概念

- **回合制推进**：以「天」为最小单位，30 天构成一月
- **事件驱动**：每日随机事件 → 选项 → 属性 / 派系变化
- **宫规考评**：每月结算，可能晋升、降位或触发惩罚
- **多结局系统**：主线结局 / 失败结局并存
- **生存优先**：宠爱 ≠ 胜利，失衡会引发风险

---

## 🧠 核心系统（MVP）

### 1. 属性系统（Stats）

| 属性 | 含义 |
|----|----|
| favor | 宠爱 |
| fame | 名声 |
| scheming | 心机 |
| talent | 才艺 |
| family | 家世 |
| health | 健康 |
| beauty | 外貌 |
| learning | 学识 |

- 数值范围：1 – 100
- 所有变化均由事件驱动
- 单一属性无法通关，必须平衡发展

---

### 2. 派系系统（Faction）

- 太后党（dowager）
- 皇后党（empress）
- 外戚党（inlaws）
- 清流派（pure）
- 军功派（military）
- 内廷宦官（eunuchs）

派系态度区间：`-100 ~ 100`  
影响事件权重、惩罚概率与隐藏结局。

---

### 3. 事件系统（Event）

- JSON 驱动
- 包含：
    - 触发条件（位份 / 属性 / Flag）
    - 多选项（Option）
    - 即时效果（属性 / 派系 / Flag / 位份）
- 支持高风险事件标签（risk / power）

---

### 4. 结局系统（Ending）

#### 主线结局（已规划）
- 封后（权力巅峰）
- 掌六宫（权谋线）
- 宠冠后宫（宠爱线）
- 安稳善终（生存线）

#### 失败结局（已实现部分）
- 冷宫幽禁
- 被赐死

---

## 🖼 UI / UX 设计原则

- **中式宫廷古典风**
- 低饱和、雅色系（非大红大紫）
- 所有主要流程通过 **中央弹窗（Panel / Modal）** 呈现
- Home 页面固定，事件 / 结算 / 月末浮层展示

---

## 📁 项目结构

```text
lib/
├── main.dart
├── app.dart                         # 应用入口 & GoRouter
│
├── core/
│   ├── data/
│   │   └── game_repository.dart     # JSON 数据加载
│   ├── models/
│   │   └── game_models.dart         # 核心数据模型
│   └── theme/
│       └── app_theme.dart           # 宫廷古典主题
│
├── features/
│   └── game/
│       ├── game_controller.dart     # 游戏主逻辑（Riverpod）
│       └── widgets/
│           └── delta_summary.dart   # 属性 / 派系变化展示
│
└── ui/
    ├── screens/
    │   ├── start_screen.dart
    │   ├── create_run_screen.dart   # Home 页面
    │   ├── loop_screen.dart         # 事件触发入口
    │   ├── resolution_screen.dart
    │   ├── month_end_screen.dart
    │   └── ending_screen.dart
    │
    └── widgets/
        ├── event_card.dart
        ├── option_button.dart
        ├── stat_chip.dart
        └── palace_modal.dart        # 中央弹窗容器
```

---
#### 可加入的一些功能
- 集邮（集齐所有结局）
- 存档/存档命名