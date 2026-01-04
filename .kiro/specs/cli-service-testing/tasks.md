# Implementation Plan: CLI Service Testing

## Overview

本实现计划将 CLI 服务测试功能分解为可执行的任务，包括数据库验证、测试轮次、联动测试等模块的实现。实现语言为 Rust，与现有 CLI 工具保持一致。

## Tasks

- [x] 1. 扩展 CLI 命令结构
  - [x] 1.1 更新 `cli.rs` 添加新的测试目标
    - 添加 `Db`, `Integration`, `Round1`, `Round2`, `Round3`, `Full` 到 `TestTarget` 枚举
    - _Requirements: 2.1, 2.2, 2.3, 2.4_
  - [x] 1.2 更新 `main.rs` 处理新命令
    - 添加新测试目标的命令分发逻辑
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [x] 2. 实现数据库验证模块
  - [x] 2.1 创建 `database.rs` 模块
    - 定义 `DatabaseSchema` 结构体
    - 实现 `verify_database_schema()` 函数
    - 实现 `check_table_exists()` 函数
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_
  - [x] 2.2 编写数据库验证属性测试
    - **Property 1: Database Schema Completeness**
    - **Validates: Requirements 1.1, 1.2, 1.3, 1.4**

- [x] 3. 实现测试轮次运行器
  - [x] 3.1 创建 `rounds.rs` 模块
    - 定义 `TestRound` 枚举
    - 定义 `RoundStats` 结构体
    - 实现 `execute_round()` 函数
    - _Requirements: 3.1-3.6, 4.1-4.7, 5.1-5.5_
  - [x] 3.2 实现第一轮测试逻辑
    - 执行 `init` → `start` → 等待健康 → 服务测试 → 联动测试
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_
  - [x] 3.3 实现第二轮测试逻辑
    - 执行 `stop` → `clean volumes` → `start` → 等待健康 → 服务测试 → 联动测试
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7_
  - [x] 3.4 实现第三轮测试逻辑
    - 执行 `restart` → 等待健康 → 服务测试 → 联动测试
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_
  - [x] 3.5 实现完整三轮测试
    - 顺序执行三轮测试并汇总结果
    - _Requirements: 3.1-5.5_
  - [x] 3.6 编写测试轮次属性测试
    - **Property 2: Test Round Execution Order**
    - **Validates: Requirements 3.1-3.6, 4.1-4.7, 5.1-5.5**

- [x] 4. 实现联动测试模块
  - [x] 4.1 创建 `integration.rs` 模块
    - 定义 `IntegrationScenario` 枚举
    - 实现 `run_integration_tests()` 函数
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_
  - [x] 4.2 实现用户内容流程测试
    - 注册 → 登录 → 创建内容 → 点赞/收藏/转发
    - _Requirements: 7.1_
  - [x] 4.3 实现内容评论流程测试
    - 创建内容 → 评论 → 验证通知
    - _Requirements: 7.2_
  - [x] 4.4 实现关注时间线流程测试
    - 用户关注 → 发帖 → 验证时间线更新
    - _Requirements: 7.3_
  - [x] 4.5 实现聊天消息流程测试
    - 创建会话 → 发送消息 → 接收消息
    - _Requirements: 7.4_
  - [x] 4.6 实现管理员操作流程测试
    - 管理员登录 → 封禁用户 → 验证状态变更
    - _Requirements: 7.5_
  - [x] 4.7 编写联动测试属性测试
    - **Property 4: Integration Flow Verification**
    - **Validates: Requirements 7.1-7.6**

- [x] 5. 更新测试运行器
  - [x] 5.1 更新 `runner.rs` 支持新测试目标
    - 添加 `Db`, `Integration`, `Round1`, `Round2`, `Round3`, `Full` 的处理逻辑
    - _Requirements: 2.1, 2.2, 2.3, 2.4_
  - [x] 5.2 实现测试进度显示
    - 实时显示当前轮次、服务、测试名称
    - _Requirements: 8.1_
  - [x] 5.3 实现测试结果汇总
    - 每轮结束后显示汇总
    - 三轮结束后显示对比汇总
    - _Requirements: 8.2, 8.3_
  - [x] 5.4 编写测试结果一致性属性测试
    - **Property 6: Test Result Consistency**
    - **Validates: Requirements 8.1-8.5**

- [x] 6. 更新模块入口
  - [x] 6.1 更新 `test/mod.rs`
    - 添加新模块导出
    - _Requirements: 2.1_

- [x] 7. Checkpoint - 确保所有测试通过
  - 运行 `cargo test` 验证所有单元测试，消除所有 warning
  - 运行 `cargo build --release` 验证编译
  - 如有问题，询问用户

- [x] 8. 执行第一轮测试
  - [x] 8.1 运行 `devlesser init`
    - 初始化开发环境
    - _Requirements: 3.1_
  - [x] 8.2 运行 `devlesser start`
    - 启动所有服务
    - _Requirements: 3.2_
  - [x] 8.3 运行 `devlesser test db`
    - 验证数据库分表
    - _Requirements: 1.1, 1.2, 1.3_
  - [x] 8.4 运行 `devlesser test all`
    - 测试所有服务
    - _Requirements: 6.1-6.11_
  - [x] 8.5 运行 `devlesser test integration`
    - 测试服务联动
    - _Requirements: 7.1-7.6_
  - [x] 8.6 记录第一轮测试结果和发现的 Bug
    - _Requirements: 8.2, 9.1, 9.2_

- [x] 9. 修复第一轮发现的 Bug
  - [x] 9.1 修复 CLI Bug
    - 根据测试结果修复 CLI 工具问题
    - _Requirements: 9.1_
  - [x] 9.2 修复服务 Bug
    - 根据测试结果修复服务问题
    - _Requirements: 9.2_

- [x] 10. Checkpoint - 第一轮测试完成
  - 确保所有第一轮测试通过
  - 如有问题，询问用户

- [x] 11. 执行第二轮测试
  - [x] 11.1 运行 `devlesser stop`
    - 停止所有服务
    - _Requirements: 4.1_
  - [x] 11.2 运行 `devlesser clean volumes`
    - 删除所有数据
    - _Requirements: 4.2_
  - [x] 11.3 运行 `devlesser start`
    - 重建并启动服务
    - _Requirements: 4.3_
  - [x] 11.4 运行 `devlesser test db`
    - 验证数据库分表
    - _Requirements: 1.1, 1.2, 1.3_
  - [x] 11.5 运行 `devlesser test all`
    - 测试所有服务
    - _Requirements: 6.1-6.11_
  - [x] 11.6 运行 `devlesser test integration`
    - 测试服务联动
    - _Requirements: 7.1-7.6_
  - [x] 11.7 记录第二轮测试结果和发现的 Bug
    - _Requirements: 8.2, 9.1, 9.2_
    - **第二轮测试结果 (删除重建测试)**:
      - 数据库验证: 24/24 通过 (100%)
      - 服务测试: 108/109 通过 (99.1%)
        - 失败: Timeline Service "获取推荐 Feed" (预期行为，推荐系统需要更多数据)
      - 联动测试: 5/5 通过 (100%)
    - **发现的问题**:
      1. Chat 服务容器在 `devlesser start service` 时未自动启动，需要手动启动
      2. RabbitMQ 容器启动时偶尔出现 unhealthy 状态，但会自动恢复
      3. Timeline Service 的推荐 Feed 在数据量不足时返回空结果（预期行为）

- [ ] 12. 修复第二轮发现的 Bug
  - [ ] 12.1 修复发现的问题
    - _Requirements: 9.1, 9.2_

- [ ] 13. Checkpoint - 第二轮测试完成
  - 确保所有第二轮测试通过
  - 如有问题，询问用户

- [ ] 14. 执行第三轮测试
  - [ ] 14.1 运行 `devlesser restart`
    - 重启所有服务
    - _Requirements: 5.1_
  - [ ] 14.2 运行 `devlesser test db`
    - 验证数据库分表
    - _Requirements: 1.1, 1.2, 1.3_
  - [ ] 14.3 运行 `devlesser test all`
    - 测试所有服务
    - _Requirements: 6.1-6.11_
  - [ ] 14.4 运行 `devlesser test integration`
    - 测试服务联动
    - _Requirements: 7.1-7.6_
  - [ ] 14.5 记录第三轮测试结果和发现的 Bug
    - _Requirements: 8.2, 9.1, 9.2_

- [ ] 15. 修复第三轮发现的 Bug
  - [ ] 15.1 修复发现的问题
    - _Requirements: 9.1, 9.2_

- [ ] 16. Final Checkpoint - 所有测试完成
  - 确保三轮测试全部通过
  - 生成最终测试报告
  - 如有问题，询问用户

## Notes

- 所有任务均为必需，确保全面测试覆盖
- 每个任务引用了具体的需求条款以确保可追溯性
- Checkpoint 任务用于验证阶段性成果
- 属性测试验证核心正确性属性
- 实际执行测试时可能发现新的 Bug，需要灵活处理

