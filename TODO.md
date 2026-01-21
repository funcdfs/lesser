flutter 底部的按钮现在是 timeline + channel + chat + my。 我要修改整个 app 为 IMDB（豆瓣）中国版本。现在 flutter 的 channel 部分实现比较完整，其他部分都是白纸。所以我要进行大调整。首先先放任后端不管，对于文档进行更新。更新文档结束之后对于 flutter 进行更新。接下来是我要做的事情：首先现在的底部栏是 timeline + channel（tags） + chat +  my（settings） 

我需要修改为： 

1 info page 用于展示各种信息。 

具体 UI 为： 

今日热门

横向滚动。  10+ 更多

本周站内热门 

横向滚动。  10+ 更多

最近受欢迎的标签。

横向滚动。  10+ 更多

最受欢迎的演员

横向滚动。  10+ 更多

更多：我可以随时添加。

2：channel page 不变。但是功能定位和 UI 细节要调整。 

改为用户创建的讨论组。（channel mode） 

每一集电视剧。对应一个 channel message 的 item。 

每一个电视剧，对应一个 channel。 

所以这个时候 flutter 的代码名字需要进行修改，虽然频道这种功能不变。

底部的  tags 修改为 是具体的电视剧或者电影的类型 tags。 

tags 开辟官方，用户，以及高级用户的筛选机制。

官方 channel：发表内容，周边，更新时间表等信息。 

用户 channel：发表相关的评价。

高级用户 channel == 明星 channel == 已经认证的用户 的 channel 

发表一些用于推广自己的电视剧，或者对于某一个集或者某一个系列的评价的 channel。 

3：之前是 chat page，删掉。改为 watchlist + news 页面。

稍后再看：

横向滚动。 10+ 更多。 

top news：

横向滚动： 10+ 更多。 

在执行任务之前，将你的疑问部分和我充分的交流，然后再行动，我们之前的交流采用中文