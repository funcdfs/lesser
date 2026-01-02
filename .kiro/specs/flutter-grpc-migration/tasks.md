# Implementation Plan: Flutter gRPC Migration

## Overview

This implementation plan breaks down the Flutter gRPC migration into discrete, incremental tasks. Each task builds on previous work and includes testing to validate functionality early. The migration proceeds module-by-module to maintain application stability.

## Tasks

- [x] 1. Generate Proto Code and Setup Infrastructure
  - Generate Dart code from all proto files (feed, post, user, search, notification)
  - Verify generated files are in correct locations
  - Update pubspec.yaml if needed for proto dependencies
  - _Requirements: 1.1, 2.1, 3.1, 4.1, 5.1, 6.1_

- [x] 2. Implement Feed gRPC Client
  - [x] 2.1 Create FeedGrpcClient class with all methods
    - Implement like/unlike methods
    - Implement comment CRUD methods
    - Implement repost methods
    - Implement bookmark methods
    - Add error handling with GrpcErrorHandler
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7_

  - [ ]* 2.2 Write unit tests for FeedGrpcClient
    - Test each method calls correct RPC
    - Test error handling
    - Mock gRPC stub
    - _Requirements: 2.2, 2.3, 2.4, 2.5, 2.6, 11.1_

  - [x] 2.3 Create Feed model classes with proto conversion
    - Create CommentModel with fromProto/toProto/toEntity
    - Create RepostModel with fromProto/toProto/toEntity
    - Create BookmarkModel with fromProto/toProto/toEntity
    - Handle null values and defaults
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

  - [ ]* 2.4 Write property test for Feed model round-trip conversion
    - **Property 3: Model Round-Trip Conversion**
    - **Validates: Requirements 8.2, 8.4**
    - Generate random CommentModel instances
    - Verify toProto → fromProto produces equivalent model
    - Test with null optional fields
    - _Requirements: 8.2, 8.4, 8.5, 11.5_

  - [x] 2.5 Implement FeedGrpcDataSourceImpl
    - Implement all FeedRemoteDataSource interface methods
    - Use FeedGrpcClient for all operations
    - Convert proto responses to models
    - Handle gRPC errors
    - _Requirements: 2.8_

  - [ ]* 2.6 Write unit tests for FeedGrpcDataSourceImpl
    - Test all methods use gRPC client
    - Test model conversion
    - Test error handling
    - Mock FeedGrpcClient
    - _Requirements: 2.8, 11.2_

  - [x] 2.7 Update DI to register FeedGrpcClient and DataSource
    - Register FeedGrpcClient in injection.dart
    - Update FeedRemoteDataSource registration to use gRPC implementation
    - _Requirements: 10.1, 10.5_

- [x] 3. Checkpoint - Test Feed Module
  - Ensure all Feed tests pass
  - Manually test Feed functionality in app
  - Ask user if questions arise


- [x] 4. Implement Post gRPC Client
  - [x] 4.1 Create PostGrpcClient class with all methods
    - Implement create/get/list/delete/update methods
    - Add error handling with GrpcErrorHandler
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

  - [ ]* 4.2 Write unit tests for PostGrpcClient
    - Test each method calls correct RPC
    - Test error handling
    - Mock gRPC stub
    - _Requirements: 3.2, 3.3, 3.4, 3.5, 11.1_

  - [x] 4.3 Update PostModel with proto conversion methods
    - Add fromProto method
    - Add toProto method
    - Update toEntity method if needed
    - Handle null values and defaults
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

  - [ ]* 4.4 Write property test for Post model round-trip conversion
    - **Property 3: Model Round-Trip Conversion**
    - **Validates: Requirements 8.2, 8.4**
    - Generate random PostModel instances
    - Verify toProto → fromProto produces equivalent model
    - Test with null optional fields (title, mediaUrls)
    - _Requirements: 8.2, 8.4, 8.5, 11.5_

  - [x] 4.5 Implement PostGrpcDataSourceImpl
    - Implement all PostRemoteDataSource interface methods
    - Use PostGrpcClient for all operations
    - Convert proto responses to models
    - Handle gRPC errors
    - _Requirements: 3.7_

  - [ ]* 4.6 Write unit tests for PostGrpcDataSourceImpl
    - Test all methods use gRPC client
    - Test model conversion
    - Test error handling
    - Mock PostGrpcClient
    - _Requirements: 3.7, 11.2_

  - [x] 4.7 Update DI to register PostGrpcClient and DataSource
    - Register PostGrpcClient in injection.dart
    - Update PostRemoteDataSource registration to use gRPC implementation
    - _Requirements: 10.1, 10.5_

- [x] 5. Checkpoint - Test Post Module
  - Ensure all Post tests pass
  - Manually test Post functionality in app
  - Ask user if questions arise

- [x] 6. Implement User gRPC Client
  - [x] 6.1 Create UserGrpcClient class with all methods
    - Implement getProfile/updateProfile methods
    - Implement follow/unfollow methods
    - Implement getFollowers/getFollowing methods
    - Implement checkFollowing method
    - Add error handling with GrpcErrorHandler
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8_

  - [ ]* 6.2 Write unit tests for UserGrpcClient
    - Test each method calls correct RPC
    - Test error handling
    - Mock gRPC stub
    - _Requirements: 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 11.1_

  - [x] 6.3 Create ProfileModel with proto conversion
    - Create ProfileModel with fromProto/toProto/toEntity
    - Handle null values and defaults
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

  - [ ]* 6.4 Write property test for Profile model round-trip conversion
    - **Property 3: Model Round-Trip Conversion**
    - **Validates: Requirements 8.2, 8.4**
    - Generate random ProfileModel instances
    - Verify toProto → fromProto produces equivalent model
    - Test with null optional fields (avatarUrl, bio)
    - _Requirements: 8.2, 8.4, 8.5, 11.5_

  - [x] 6.5 Implement ProfileGrpcDataSourceImpl
    - Implement all ProfileRemoteDataSource interface methods
    - Use UserGrpcClient for all operations
    - Convert proto responses to models
    - Handle gRPC errors
    - _Requirements: 4.9_

  - [ ]* 6.6 Write unit tests for ProfileGrpcDataSourceImpl
    - Test all methods use gRPC client
    - Test model conversion
    - Test error handling
    - Mock UserGrpcClient
    - _Requirements: 4.9, 11.2_

  - [x] 6.7 Update DI to register UserGrpcClient and DataSource
    - Register UserGrpcClient in injection.dart
    - Update ProfileRemoteDataSource registration to use gRPC implementation
    - _Requirements: 10.1, 10.5_

- [x] 7. Checkpoint - Test Profile Module
  - Ensure all Profile tests pass
  - Manually test Profile functionality in app
  - Ask user if questions arise


- [x] 8. Implement Search gRPC Client
  - [x] 8.1 Create SearchGrpcClient class with all methods
    - Implement searchPosts method
    - Implement searchUsers method
    - Add pagination support
    - Add error handling with GrpcErrorHandler
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

  - [ ]* 8.2 Write unit tests for SearchGrpcClient
    - Test each method calls correct RPC
    - Test pagination parameters are passed correctly
    - Test error handling
    - Mock gRPC stub
    - _Requirements: 5.2, 5.3, 5.4, 11.1_

  - [ ]* 8.3 Write property test for pagination parameter preservation
    - **Property 2: Pagination Parameter Preservation**
    - **Validates: Requirements 5.4**
    - Generate random pagination parameters (page, pageSize)
    - Verify parameters are correctly included in gRPC request
    - Test with boundary values (page=1, pageSize=1, large values)
    - _Requirements: 5.4_

  - [x] 8.4 Implement SearchGrpcDataSourceImpl
    - Implement all SearchRemoteDataSource interface methods
    - Use SearchGrpcClient for all operations
    - Convert proto responses to models (reuse PostModel and ProfileModel)
    - Handle gRPC errors
    - _Requirements: 5.6_

  - [ ]* 8.5 Write unit tests for SearchGrpcDataSourceImpl
    - Test all methods use gRPC client
    - Test model conversion
    - Test error handling
    - Mock SearchGrpcClient
    - _Requirements: 5.6, 11.2_

  - [x] 8.6 Update DI to register SearchGrpcClient and DataSource
    - Register SearchGrpcClient in injection.dart
    - Update SearchRemoteDataSource registration to use gRPC implementation
    - _Requirements: 10.1, 10.5_

- [x] 9. Checkpoint - Test Search Module
  - Ensure all Search tests pass
  - Manually test Search functionality in app
  - Ask user if questions arise

- [x] 10. Implement Notification gRPC Client
  - [x] 10.1 Create NotificationGrpcClient class with all methods
    - Implement list method
    - Implement read/readAll methods
    - Implement getUnreadCount method
    - Add error handling with GrpcErrorHandler
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

  - [ ]* 10.2 Write unit tests for NotificationGrpcClient
    - Test each method calls correct RPC
    - Test error handling
    - Mock gRPC stub
    - _Requirements: 6.2, 6.3, 6.4, 11.1_

  - [x] 10.3 Create NotificationModel with proto conversion
    - Create NotificationModel with fromProto/toProto/toEntity
    - Handle null values and defaults
    - Handle NotificationType enum conversion
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

  - [ ]* 10.4 Write property test for Notification model round-trip conversion
    - **Property 3: Model Round-Trip Conversion**
    - **Validates: Requirements 8.2, 8.4**
    - Generate random NotificationModel instances
    - Verify toProto → fromProto produces equivalent model
    - Test with different NotificationType values
    - _Requirements: 8.2, 8.4, 8.5, 11.5_

  - [x] 10.5 Implement NotificationGrpcDataSourceImpl
    - Implement all NotificationRemoteDataSource interface methods
    - Use NotificationGrpcClient for all operations
    - Convert proto responses to models
    - Handle gRPC errors
    - _Requirements: 6.6_

  - [ ]* 10.6 Write unit tests for NotificationGrpcDataSourceImpl
    - Test all methods use gRPC client
    - Test model conversion
    - Test error handling
    - Mock NotificationGrpcClient
    - _Requirements: 6.6, 11.2_

  - [x] 10.7 Update DI to register NotificationGrpcClient and DataSource
    - Register NotificationGrpcClient in injection.dart
    - Update NotificationRemoteDataSource registration to use gRPC implementation
    - _Requirements: 10.1, 10.5_

- [x] 11. Checkpoint - Test Notification Module
  - Ensure all Notification tests pass
  - Manually test Notification functionality in app
  - Ask user if questions arise

