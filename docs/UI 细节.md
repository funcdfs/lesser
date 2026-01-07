## 社交流应用 UI 开发大局观准则 (Manifesto)

### 1. 以“内容”为原子中心的架构 (Content-Centric Architecture)

在 X、Threads 和 Telegram 的混合体中，**“内容卡片”是应用的主权单位**。

* **非装饰性原则：** 所有的 UI 元素（线条、阴影、背景色切换）必须为提升内容可读性服务。如果一个设计元素（如过粗的分割线）分散了对文字的注意，就应该弱化或去除。
* **组件的“递归”性：** 一个“帖子”组件在首页是 Feed 流，在详情页是主客体，在转发中是子组件。开发时必须采用**高度解耦的 Slot（插槽）模式**，确保同一个内容组件在不同容器中能自适应调整密度。

### 2. 呼吸感与密度的动态平衡 (Density & Breathing Space)


* **隐式网格系统：** 严禁使用硬性的、厚重的边框。优先通过**对齐方式**和**垂直间距 (Vertical Rhythm)** 来区分内容块，利用“负空间”引导用户视觉流动。
* **边缘穿透感：** 内容应尽可能横向铺满或保持统一的小边距，营造出一种“信息无限延伸”的沉浸感。

### 3. 交互的“瞬时性”反馈 (Instantaneous Interaction)

chat page 借鉴 Telegram 的高效。

* **状态优先：** 任何交互（点赞、发送、切换 Tab）必须先在 UI 上给予**乐观更新 (Optimistic UI)**。即用户点击后，UI 立即变化，后台异步请求。
* **触感反馈层：** 所有点击区域必须有明确的、符合物理直觉的视觉反馈（如轻微的缩放或底色变幻），模拟物理按钮的反馈逻辑。

### 4. 渐进式披露逻辑 (Progressive Disclosure)

避免像早期 Telegram 那样功能过于隐蔽，或像 X 网页版那样过于繁杂。

* **操作下沉：** 核心操作（回复、点赞、转发）必须直观可见。次级操作（屏蔽、举报、复制链接）应隐藏在“更多”按钮下，且以 **Bottom Sheet (底部抽屉)** 形式呼出，而非弹出居中对话框。
* **信息分层：** 优先展示用户名和正文。元数据（时间戳、设备来源、阅读数）应在视觉上降低一个层级（降低灰度或缩小字体）。

### 5. 导航的“直觉映射” (Navigation Intuition)

* **单一焦点原则：** 每个页面只能有一个核心动作。首页是“浏览”，消息页是“沟通”，发布页是“创作”。
* **全局导航的持久性：** 底部导航条是应用的“锚点”，无论用户进入多深的内容层级，都应支持通过简单的滑动手势或点击 Tab 回到核心流。

---

## 给 AI 和开发者的架构实现指导

### A. 容器约束 (Container Constraints)

> **准则：** “外层定义边界，内层决定表现。”
> 开发组件时，组件不应自带外边距（Margin）。外边距由布局容器（List, Stack, Grid）统一分发。这样可以确保组件在 Telegram 式的紧凑列表和 Threads 式的宽松列表间无缝切换。

### B. 语义化层级 (Semantic Hierarchies)

不要直接定义颜色和字体大小，要定义**意图**：

* `Text.Primary`: 绝对焦点（如正文）。
* `Text.Secondary`: 身份标识（如用户名）。
* `Text.Tertiary`: 辅助信息（如时间、统计数据）。
* `Surface.Base`: 底层背景。
* `Surface.Elevated`: 浮起层（如卡片、抽屉）。

### C. 动效的大局观 (Motion Strategy)

* **进入/退出：** 使用“滑入”而非“淡入”，强调层级的前后关系。
- 动画哪里来就是哪里回去。动画方向和细节要准确的反应具体组件的功能来源。
* **微交互：** 点赞时的心形跳动、切换 Tab 时的下划线平滑位移，这些不是点缀，而是告诉用户“你的操作已生效”的确认。这些微小的细腻交互也不可马虎。

---

# 大局观组件图：

![信息流](ver1%20设计图/image.png)

![信息流的关注部分](ver1%20设计图/image-1.png)

![聊天页面 1](ver1%20设计图/image-2.png)

![聊天页面的后面（往下滑动之后的东西](ver1%20设计图/image-3.png)

![通知区域](ver1%20设计图/image-4.png)

![我的区域](ver1%20设计图/image-5.png)

---

### D. 图标风格准则 (Icon Style Guidelines)

* **圆润优先：** 所有图标统一使用 `_rounded` 后缀的圆润版本（如 `Icons.favorite_rounded`、`Icons.chat_bubble_rounded`），营造亲和、现代的视觉感受。
* **禁止尖锐图标：** 避免使用 `_sharp` 后缀或默认的尖角图标，保持整体风格一致。
* **常用图标对照：**
  - ❌ `Icons.favorite` → ✅ `Icons.favorite_rounded`
  - ❌ `Icons.chat_bubble` → ✅ `Icons.chat_bubble_rounded`
  - ❌ `Icons.share` → ✅ `Icons.share_rounded`
  - ❌ `Icons.bookmark` → ✅ `Icons.bookmark_rounded`
  - ❌ `Icons.more_horiz` → ✅ `Icons.more_horiz_rounded`
  - ❌ `Icons.arrow_back` → ✅ `Icons.arrow_back_rounded`