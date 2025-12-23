import 'package:flutter/material.dart';

class PostImagesWidget extends StatelessWidget {
  final List<String> imageUrls;
  final double height;

  const PostImagesWidget({
    super.key,
    required this.imageUrls,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    // Max 50 limits enforced at model/data level usually, but we can clamp here too just in case.
    final displayUrls = imageUrls.take(50).toList();

    if (displayUrls.length == 1) {
      return Container(
        constraints: BoxConstraints(maxHeight: height),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(displayUrls.first),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayUrls.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Container(
            width: 250, // Fixed width for carousel items
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(displayUrls[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
