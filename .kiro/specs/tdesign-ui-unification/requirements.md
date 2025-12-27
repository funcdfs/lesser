# Requirements Document

## Introduction

本规范定义了将 Flutter 前端 UI 组件统一迁移到腾讯 TDesign 组件库的需求。当前项目存在多种 UI 风格混用的问题：forui 组件、Material Design 组件、自定义 Shadcn 风格组件等混杂使用，导致 UI 不一致且维护困难。

目标是将所有 UI 组件统一为 TDesign Flutter 组件库，并将默认的蓝色基调改为黑色基调，实现视觉风格的大一统。

## Glossary

- **TDesign**: 腾讯开源的企业级设计体系，提供统一的设计语言和组件库
- **TDesign_Flutter**: TDesign 的 Flutter 实现，包名为 `tdesign_flutter`
- **Theme_System**: 主题系统，负责管理颜色、字体、间距等设计令牌
- **Design_Token**: 设计令牌，可复用的设计变量（如颜色、间距、圆角等）
- **Component_Migration**: 组件迁移，将现有组件替换为 TDesign 组件的过程
- **Dark_Theme**: 黑色基调主题，以深色为主的视觉风格

## Requirements

### Requirement 1: 依赖管理

**User Story:** As a developer, I want to use TDesign Flutter as the unified UI component library, so that I can have consistent UI components across the application.

#### Acceptance Criteria

1. WHEN the project dependencies are configured, THE Build_System SHALL include `tdesign_flutter` as a dependency
2. WHEN the project dependencies are configured, THE Build_System SHALL remove the `forui` dependency
3. WHEN the TDesign package is imported, THE Application SHALL be able to access all TDesign components and themes

### Requirement 2: 主题系统重构

**User Story:** As a developer, I want a unified dark-themed design system based on TDesign, so that the application has a consistent black-toned visual style.

#### Acceptance Criteria

1. THE Theme_System SHALL define a dark color palette based on TDesign's color specification with black as the primary tone
2. THE Theme_System SHALL provide semantic color tokens (primary, secondary, background, surface, error, etc.)
3. WHEN the application starts, THE Theme_System SHALL apply the dark theme as the default theme
4. THE Theme_System SHALL define consistent spacing tokens (xs, sm, md, lg, xl)
5. THE Theme_System SHALL define consistent border radius tokens
6. THE Theme_System SHALL define consistent typography tokens following TDesign specifications
7. WHEN a component needs styling, THE Component SHALL use design tokens from Theme_System instead of hardcoded values

### Requirement 3: 按钮组件迁移

**User Story:** As a developer, I want all buttons to use TDesign button components, so that buttons have a consistent appearance and behavior.

#### Acceptance Criteria

1. WHEN a primary action button is needed, THE UI SHALL use TDButton with primary style
2. WHEN a secondary action button is needed, THE UI SHALL use TDButton with outline or text style
3. WHEN a destructive action button is needed, THE UI SHALL use TDButton with danger style
4. THE Button_Component SHALL support loading state with TDesign's loading indicator
5. THE Button_Component SHALL support disabled state with appropriate visual feedback
6. WHEN ElevatedButton, TextButton, or OutlinedButton from Material is used, THE Migration SHALL replace them with TDButton

### Requirement 4: 输入组件迁移

**User Story:** As a developer, I want all input fields to use TDesign input components, so that form inputs have a consistent appearance.

#### Acceptance Criteria

1. WHEN a text input is needed, THE UI SHALL use TDInput component
2. WHEN a password input is needed, THE UI SHALL use TDInput with password type
3. WHEN FTextField from forui is used, THE Migration SHALL replace it with TDInput
4. THE Input_Component SHALL support validation error display
5. THE Input_Component SHALL support placeholder text
6. THE Input_Component SHALL support prefix and suffix icons

### Requirement 5: 导航组件迁移

**User Story:** As a developer, I want navigation components to use TDesign navigation, so that app navigation is consistent.

#### Acceptance Criteria

1. WHEN a bottom navigation bar is needed, THE UI SHALL use TDBottomTabBar component
2. WHEN a top navigation bar is needed, THE UI SHALL use TDNavBar component
3. THE Navigation_Component SHALL support the dark theme color scheme
4. THE Navigation_Component SHALL maintain current navigation state correctly

### Requirement 6: 卡片和列表组件迁移

**User Story:** As a developer, I want cards and lists to use TDesign components, so that content display is consistent.

#### Acceptance Criteria

1. WHEN a card container is needed, THE UI SHALL use TDCard or TDCell component
2. WHEN a list item is needed, THE UI SHALL use TDCell or TDSwipeCell component
3. THE Card_Component SHALL support the dark theme styling
4. THE List_Component SHALL support dividers consistent with TDesign specifications

### Requirement 7: 对话框和弹窗组件迁移

**User Story:** As a developer, I want dialogs and popups to use TDesign components, so that modal interactions are consistent.

#### Acceptance Criteria

1. WHEN a confirmation dialog is needed, THE UI SHALL use TDDialog component
2. WHEN a toast notification is needed, THE UI SHALL use TDToast component
3. WHEN a bottom sheet is needed, THE UI SHALL use TDPopup component
4. THE Dialog_Component SHALL support the dark theme styling

### Requirement 8: 头像和图片组件迁移

**User Story:** As a developer, I want avatar and image components to use TDesign components, so that media display is consistent.

#### Acceptance Criteria

1. WHEN a user avatar is needed, THE UI SHALL use TDAvatar component
2. WHEN an image with loading state is needed, THE UI SHALL use TDImage component
3. THE Avatar_Component SHALL support different sizes (small, medium, large)
4. THE Image_Component SHALL support placeholder and error states

### Requirement 9: 加载和状态组件迁移

**User Story:** As a developer, I want loading and state indicators to use TDesign components, so that feedback states are consistent.

#### Acceptance Criteria

1. WHEN a loading indicator is needed, THE UI SHALL use TDLoading component
2. WHEN a skeleton loading is needed, THE UI SHALL use TDSkeleton component
3. WHEN an empty state is needed, THE UI SHALL use TDEmpty component
4. THE Loading_Component SHALL use the dark theme color scheme

### Requirement 10: 清理遗留代码

**User Story:** As a developer, I want all legacy UI code removed, so that the codebase is clean and maintainable.

注意不要伤害已经实现的 UI 细节和功能。只是组件库替换统一。但是不要丢失功能。类似于换一个游戏皮肤。

#### Acceptance Criteria

1. WHEN migration is complete, THE Codebase SHALL NOT contain any forui imports
2. WHEN migration is complete, THE Codebase SHALL NOT contain custom Shadcn-style components that duplicate TDesign functionality
3. WHEN migration is complete, THE Codebase SHALL NOT contain hardcoded color values in UI components
4. THE Shared_Widgets folder SHALL only contain TDesign-based wrapper components or truly custom components not provided by TDesign
