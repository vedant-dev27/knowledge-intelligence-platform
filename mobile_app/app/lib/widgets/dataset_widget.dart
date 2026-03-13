import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lumina/models/dataset_model.dart';

class DatasetWidget extends StatelessWidget {
  DatasetWidget({super.key, required this.dataset})
      : color = _generatePastelColor(dataset);

  final DatasetModel dataset;
  final Color color;

  static Color _generatePastelColor(DatasetModel dataset) {
    final random = Random(dataset.title.hashCode);

    final hue = random.nextDouble() * 360;
    const saturation = 0.9;
    const lightness = 0.87;

    return HSLColor.fromAHSL(
      1,
      hue,
      saturation,
      lightness,
    ).toColor();
  }

  IconData _getIcon() {
    switch (dataset.type) {
      case "pdf":
        return Icons.picture_as_pdf_rounded;
      case "image":
        return Icons.image_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIcon(),
                size: 26,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dataset.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatDate(dataset.createdAt),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black45,
                        ),
                      ),
                    ],
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
