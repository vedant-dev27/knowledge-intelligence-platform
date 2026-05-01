import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:synapse/models/dataset_model.dart';
import 'package:synapse/screens/dataset_viewer_screen.dart';
import 'package:synapse/services/upload_service.dart';
import 'package:synapse/widgets/dataset_widget.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final List<DatasetModel> data = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final box = Hive.box('uploads');

    data.clear();

    for (var item in box.values) {
      data.add(
        DatasetModel(
          title: item['title'],
          createdAt: DateTime.parse(item['createdAt']),
          type: item['type'],
          content: '',
        ),
      );
    }

    setState(() {});
  }

  Future<void> _showBlockingDialog(String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final theme = Theme.of(context);

        return PopScope(
          canPop: false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 32,
                    width: 32,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadFile() async {
    if (_isUploading) return;

    final result = await FilePicker.pickFiles(type: FileType.any);
    if (result == null) return;

    final pickedFile = result.files.single;
    if (pickedFile.path == null) return;

    final file = File(pickedFile.path!);

    setState(() => _isUploading = true);

    _showBlockingDialog("Uploading and processing file...");

    try {
      final response = await UploadService.uploadFile(file);

      if (!mounted) return;

      Navigator.of(context).pop(); // close loading dialog

      final box = Hive.box('uploads');

      final item = {
        'title': pickedFile.name,
        'createdAt': DateTime.now().toIso8601String(),
        'type': response['ext'],
      };

      box.add(item);

      setState(() {
        data.insert(
          0,
          DatasetModel(
            title: pickedFile.name,
            createdAt: DateTime.now(),
            type: response['ext'],
            content: '',
          ),
        );
      });

      showDialog(
        context: context,
        builder: (_) {
          final theme = Theme.of(context);

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle,
                      color: theme.colorScheme.primary, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    "Upload Complete",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pickedFile.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) Navigator.of(context).pop();
      });
    } catch (_) {
      if (!mounted) return;

      Navigator.of(context).pop(); // close loading dialog

      showDialog(
        context: context,
        builder: (_) {
          final theme = Theme.of(context);

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error, color: theme.colorScheme.error, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    "Upload Failed",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          "Your Uploads",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: data.isEmpty
            ? Center(
                child: Text(
                  "No uploads yet",
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final dataset = data[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DatasetViewerScreen(dataset: dataset),
                        ),
                      );
                    },
                    child: DatasetWidget(dataset: dataset),
                  );
                },
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _pickAndUploadFile,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
