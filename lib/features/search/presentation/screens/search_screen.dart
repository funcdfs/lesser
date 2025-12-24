import 'package:flutter/material.dart';

/// 搜索页面
///
/// 负责：
/// - 搜索输入框
/// - 显示搜索结果（用户、帖子、标签等）
/// - 显示热搜和最近搜索
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = ['Flutter', 'Dart', 'UI Design'];
  final List<String> _trendingSearches = ['#Flutter', '#Design', '#Mobile'];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search users, posts, tags...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _isSearching = false;
                      });
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onChanged: (value) {
            setState(() {
              _isSearching = value.isNotEmpty;
            });
          },
        ),
        elevation: 0,
      ),
      body: _isSearching ? _buildSearchResults() : _buildSearchSuggestions(),
    );
  }

  Widget _buildSearchSuggestions() {
    return ListView(
      children: [
        // 最近搜索
        if (_recentSearches.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _recentSearches.clear();
                        });
                      },
                      child: const Text('Clear all'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  _recentSearches.length,
                  (index) => ListTile(
                    leading: const Icon(Icons.history, size: 20),
                    title: Text(_recentSearches[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() {
                          _recentSearches.removeAt(index);
                        });
                      },
                    ),
                    onTap: () {
                      _searchController.text = _recentSearches[index];
                      setState(() {
                        _isSearching = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        const Divider(),
        // 热搜
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trending',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(
                _trendingSearches.length,
                (index) => ListTile(
                  leading: const Icon(Icons.local_fire_department, size: 20),
                  title: Text(_trendingSearches[index]),
                  onTap: () {
                    _searchController.text = _trendingSearches[index];
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return ListView(
      children: [
        // 用户结果
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Users',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...List.generate(
                3,
                (index) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('User ${index + 1}'),
                  subtitle: const Text('@username'),
                  trailing: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Follow'),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        // 帖子结果
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Posts',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...List.generate(
                3,
                (index) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: const Text('User name'),
                  subtitle: const Text('Post content preview...'),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
