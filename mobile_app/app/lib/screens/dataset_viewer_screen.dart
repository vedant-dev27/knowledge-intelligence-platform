import 'package:flutter/material.dart';
import 'package:lumina/models/dataset_model.dart';

class DatasetViewerScreen extends StatelessWidget {
  const DatasetViewerScreen({super.key, required this.dataset});

  final DatasetModel dataset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dataset.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(dataset.content),
      ),
    );
  }
}
