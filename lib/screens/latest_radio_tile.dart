import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../models/radio.dart' as custom_radio;

class LatestRadioTile extends StatelessWidget {
  final custom_radio.Radio radio;
  final VoidCallback onTap;

  LatestRadioTile({required this.radio, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // ここで画像の幅と高さを明示的に設定
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                width: 100, // 明示的な幅
                height: 100, // 明示的な高さ
                child: CachedNetworkImage(
                  cacheManager: CacheManager(
                    Config(
                      'customCacheKey',
                      stalePeriod: const Duration(days: 7),
                      maxNrOfCacheObjects: 100,
                    ),
                  ),
                  imageUrl: radio.thumbnail,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    radio.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    radio.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
