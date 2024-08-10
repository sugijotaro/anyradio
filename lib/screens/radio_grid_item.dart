import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../models/radio.dart' as custom_radio;

class RadioGridItem extends StatelessWidget {
  final custom_radio.Radio radio;

  RadioGridItem({required this.radio});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
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
              width: double.infinity,
              height: MediaQuery.of(context).size.width / 2,
              placeholder: (context, url) => Container(
                color: Colors.grey,
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey,
                child: Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 48.0,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
            child: Text(
              radio.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
