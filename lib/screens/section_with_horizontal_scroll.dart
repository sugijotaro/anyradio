import 'package:flutter/material.dart';
import 'radio_grid_item.dart';
import '../models/radio.dart' as custom_radio;

class SectionWithHorizontalScroll extends StatelessWidget {
  final String title;
  final List<custom_radio.Radio> radios;
  final double itemWidth;
  final double itemHeight;
  final ValueChanged<custom_radio.Radio> onTap;

  SectionWithHorizontalScroll({
    required this.title,
    required this.radios,
    required this.itemWidth,
    required this.itemHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          height: itemHeight + 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: radios.length,
            itemBuilder: (context, index) {
              var radio = radios[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => onTap(radio),
                  child: RadioGridItem(
                    radio: radio,
                    width: itemWidth,
                    height: itemHeight,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
