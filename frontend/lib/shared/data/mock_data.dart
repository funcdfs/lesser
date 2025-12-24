import '../../features/auth/domain/models/user.dart';
import '../../features/feeds/domain/models/story.dart';

final List<User> mockFollowingUsers = [
  const User(
    id: 1,
    username: 'sarahchen',
    email: 'sarah@example.com',
    firstName: 'Sarah',
    lastName: 'Chen',
  ),
  const User(
    id: 2,
    username: 'alexrivera',
    email: 'alex@example.com',
    firstName: 'Alex',
    lastName: 'Rivera',
  ),
  const User(
    id: 3,
    username: 'mayapatel',
    email: 'maya@example.com',
    firstName: 'Maya',
    lastName: 'Patel',
  ),
  const User(
    id: 4,
    username: 'davidkim',
    email: 'david@example.com',
    firstName: 'David',
    lastName: 'Kim',
  ),
  const User(
    id: 5,
    username: 'emmawilson',
    email: 'emma@example.com',
    firstName: 'Emma',
    lastName: 'Wilson',
  ),
];

final Map<int, List<Story>> mockStories = {
  1: [
    Story(
      id: 's1',
      imageUrl:
          'https://tiebapic.baidu.com/forum/pic/item/962bd40735fae6cd7d3d75004ab30f2442a7d97e.jpg',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ],
  2: [
    Story(
      id: 's2',
      imageUrl:
          'https://tiebapic.baidu.com/forum/pic/item/7ea6a61ea8d3fd1f26f28689714e251f95ca5f33.jpg',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ],
  3: [
    Story(
      id: 's3',
      imageUrl:
          'https://tiebapic.baidu.com/forum/pic/item/2cf5e0fe9925bc3146d2cb7c1edf8db1cb137021.jpg',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ],
};
