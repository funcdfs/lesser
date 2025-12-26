启动脚本：用我的脚本来实现具体的启动逻辑
- `start-all.sh`：启动所有服务（包括后端和前端）
- `start-dev.sh`：启动开发环境服务（包括后端和前端）
- `start-frontend.sh`：启动前端服务
- `start-backend.sh`：启动后端服务


优先在 SM x700 上启动前端服务。 
如果 SM x700 不可用，则在本地 chrome 上启动前端服务。

完成项目的代码修改之后，使用 flutter analyze 检查代码是否符合规范。
修复所有的错误。但是不要运行本地的测试，代码修改之后直接运行 flutter analyze 检查是否还有错误。结束。

新添加的每一次组件的 UI 都使用 https://forui.dev/docs/form/autocomplete 中的组件。查看官方文档，确保使用的是最新版本的组件。

test 文件要在 test 目录下。组件的测试文件要在 test/widgets 目录下。
所有的 API 调用都使用 chopper 包来实现。
所有的状态管理都使用 riverpod 包来实现。
所有的数据模型都使用 freezed 和 json_serializable 包来实现。
所有的本地存储都使用 shared_preferences 包来实现。
所有的分页列表都使用 infinite_scroll_pagination 包来实现。

完成代码之后也要写好的相应的测试，运行单元测试即可，但是不要本地运行所有代码。