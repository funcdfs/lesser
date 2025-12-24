from django.core.management.base import BaseCommand
from social.models import Post

class Command(BaseCommand):
    help = 'Seeds the database with comprehensive mock posts from Flutter'

    def handle(self, *args, **options):
        # Clear existing posts to avoid duplicates during dev
        Post.objects.all().delete()

        mock_posts_data = [
            {
                "username": "Sarah Chen",
                "content": "刚发布了我的新 React 设计系统！🎨 快来看看，告诉我你的想法。专为无障碍访问和高性能打造。",
                "likes": 2345,
                "comments_count": 45,
                "reposts_count": 12,
                "bookmarks_count": 8,
                "shares_count": 3,
                "location": "上海, 中国",
                "images": [
                    "https://tiebapic.baidu.com/forum/pic/item/962bd40735fae6cd7d3d75004ab30f2442a7d97e.jpg",
                    "https://tiebapic.baidu.com/forum/pic/item/7ea6a61ea8d3fd1f26f28689714e251f95ca5f33.jpg",
                    "https://tiebapic.baidu.com/forum/pic/item/2cf5e0fe9925bc3146d2cb7c1edf8db1cb137021.jpg",
                ]
            },
            {
                "username": "Alex Rivera",
                "content": '暴论：最好的代码就是没有代码。简单 > 复杂，永远如此。\n\n我们在构建软件时，经常陷入"为了做而做"的陷阱。我们引入复杂的架构、分层、模式，却忘了软件的本质是解决问题。\n\n少即是多。LESS IS MORE.',
                "likes": 12500,
                "comments_count": 156,
                "reposts_count": 78,
                "bookmarks_count": 45,
                "shares_count": 12,
                "location": "San Francisco, CA",
                "images": []
            },
            {
                "username": "Maya Patel",
                "content": "正在写一篇关于现代 Web 应用状态管理模式的新文章。大家有什么特别想看的话题吗？",
                "likes": 123456789,
                "comments_count": 8900,
                "reposts_count": 23,
                "bookmarks_count": 156,
                "shares_count": 34,
                "location": "London, UK",
                "images": [
                    "https://tiebapic.baidu.com/forum/pic/item/b3fb43166d224f4af7fa079919f790529922d100.jpg"
                ]
            },
            {
                "username": "David Kim",
                "content": "Web 开发的未来一片光明！WebAssembly、边缘计算和 AI 驱动的工具正在改变一切。",
                "likes": 567,
                "comments_count": 92,
                "reposts_count": 45,
                "bookmarks_count": 23,
                "shares_count": 8,
                "location": "Seoul, Korea",
                "images": [
                    "https://tiebapic.baidu.com/forum/pic/item/08f790529822720e6f28490a3bcb0a46f31fabe7.jpg",
                    "https://tiebapic.baidu.com/forum/pic/item/0823dd54564e9258284814e49982d158ccbf4e7e.jpg",
                    "https://tiebapic.baidu.com/forum/pic/item/d439b6003af33a87ec09e663c15c10385343b57e.jpg"
                ]
            },
            {
                "username": "Yuki Tanaka",
                "content": "Flutter 3.x is amazing! The performance improvements are noticeable. 🚀 #Flutter #MobileDev",
                "likes": 1205,
                "comments_count": 230,
                "reposts_count": 89,
                "bookmarks_count": 67,
                "shares_count": 23,
                "location": "Tokyo, Japan",
                "images": []
            }
        ]

        for data in mock_posts_data:
            Post.objects.create(
                username=data["username"],
                content=data["content"],
                likes=data["likes"],
                comments_count=data.get("comments_count", 0),
                reposts_count=data.get("reposts_count", 0),
                bookmarks_count=data.get("bookmarks_count", 0),
                shares_count=data.get("shares_count", 0),
                location=data["location"],
                images_json=data["images"]
            )

        self.stdout.write(self.style.SUCCESS(f'Successfully seeded {len(mock_posts_data)} posts with full interaction data'))
