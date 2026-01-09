# Comment 评论组件包

独立的评论系统，可在任何场景复用（帖子、频道消息、文章等）。

## 架构

```
comment/
├── comment.dart           # 统一导出
├── comment_handler.dart   # 业务逻辑处理器
├── comment_page.dart      # 评论页面
├── utils.dart             # 工具函数
├── models/
│   └── comment_model.dart # 数据模型
└── widgets/
    ├── comment_entry.dart     # 评论入口（头像堆叠 + 数量）
    ├── comment_list.dart      # 评论列表
    ├── comment_item.dart      # 评论项
    ├── comment_bubble.dart    # 评论气泡
    ├── comment_actions.dart   # 操作按钮（点赞/回复）
    ├── comment_input_bar.dart # 输入栏
    ├── comment_highlight.dart # 高亮动画（深层链接）
    ├── message_header.dart    # 消息头部
    └── scroll_buttons.dart    # 滚动按钮
```

## 使用方式

### 1. 实现数据源接口

```dart
class MyCommentDataSource implements CommentDataSource {
  @override
  Future<CommentListState> loadComments(String targetId, String targetType) async {
    // 调用 gRPC 获取评论列表
    final response = await _client.getComments(...);
    return CommentListState(
      comments: response.comments.map(_toModel).toList(),
      totalCount: response.totalCount,
      hasMore: response.hasMore,
      cursor: response.cursor,
    );
  }

  @override
  Future<CommentListState> loadThread(CommentModel rootComment) async {
    // 加载子评论线程
  }

  @override
  Future<void> toggleLike(String commentId) async {
    // 切换点赞
  }

  @override
  Future<CommentModel> submitComment({...}) async {
    // 发表评论
  }

  // ... 其他方法
}
```

### 2. 显示评论入口

```dart
CommentEntry(
  commentCount: 42,
  avatarUrls: ['url1', 'url2', 'url3'],
  onTap: () => _openComments(),
)
```

### 3. 打开评论页面

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CommentPage(
      targetId: postId,
      targetType: 'post',
      dataSource: MyCommentDataSource(),
      title: '评论',
    ),
  ),
);
```

### 4. 打开子评论线程

```dart
CommentPage(
  targetId: postId,
  targetType: 'post',
  dataSource: dataSource,
  rootComment: parentComment,  // 传入根评论进入线程视图
)
```

## 核心类

### CommentDataSource（数据源接口）

| 方法 | 说明 |
|------|------|
| `loadComments()` | 加载评论列表 |
| `loadMoreComments()` | 加载更多（分页） |
| `loadThread()` | 加载子评论线程 |
| `getDescendantCount()` | 获取子孙评论数量 |
| `toggleLike()` | 切换点赞 |
| `submitComment()` | 发表评论 |
| `deleteComment()` | 删除评论 |

### CommentHandler（业务处理器）

继承 `ChangeNotifier`，管理评论列表和输入状态：

- `listState` - 评论列表状态
- `inputState` - 输入框状态
- 乐观更新：点赞/删除操作立即更新 UI，失败时回滚

### CommentModel（评论模型）

```dart
CommentModel(
  id: 'comment_id',
  targetId: 'post_id',
  targetType: 'post',
  author: CommentAuthor(...),
  content: '评论内容',
  replyTo: ReplyTarget(...),  // 回复目标（可选）
  replyCount: 5,
  likeCount: 10,
  isLiked: false,
  createdAtMs: 1234567890000,
  isPinned: false,
  isDeleted: false,
)
```

## 特性

- **线程视图**：支持多级评论嵌套，点击"查看回复"进入子线程
- **深层链接**：支持 `targetCommentId` 参数，自动滚动并高亮目标评论
- **乐观更新**：点赞/删除操作即时响应，失败自动回滚
- **置顶评论**：支持 `pinnedComment` 显示在列表顶部
- **滚动位置恢复**：从子线程返回时恢复到进入前的位置
- **上下文菜单**：长按/点击显示操作菜单（回复、复制、转发等）

## 工具函数

```dart
// 用户名颜色（根据 ID 哈希）
Color color = getNameColor(userId);

// 格式化数量
String count = formatCount(12345);  // "1.2w"

// 格式化时间
String time = formatTime(dateTime);  // "刚刚" / "5分钟前" / "昨天"

// 截断文本
String text = truncateText(content, 100);
```
