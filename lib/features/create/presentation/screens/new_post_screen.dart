import 'package:flutter/material.dart';

/// 发布页面
///
/// 负责：
/// - 用户输入 Post 内容
/// - 上传图片
/// - 发布 Post
class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final List<String> _selectedImages = [];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed:
                _selectedImages.isNotEmpty || _contentController.text.isNotEmpty
                ? _publishPost
                : null,
            child: const Text('Post'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 用户信息
          Row(
            children: [
              const CircleAvatar(radius: 24, child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Your Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Public',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 内容输入
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              hintText: 'What\'s on your mind?',
              border: InputBorder.none,
            ),
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          // 图片预览
          if (_selectedImages.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.image)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _selectedImages.removeAt(index);
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 16),
          // 工具栏
          Row(
            children: [
              IconButton(icon: const Icon(Icons.image), onPressed: _addImages),
              IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.location_on_outlined),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addImages() {
    // 选择图片
    setState(() {
      _selectedImages.add('image_url');
    });
  }

  void _publishPost() {
    // 发布 Post
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post published!')));
    Navigator.pop(context);
  }
}
