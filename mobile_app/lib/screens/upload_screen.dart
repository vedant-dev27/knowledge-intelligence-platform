import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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

  Future<void> _pickAndUploadFile() async {
    if (_isUploading) return;

    final FilePickerResult? result =
        await FilePicker.pickFiles(type: FileType.any);

    if (result == null) return;

    final PlatformFile pickedFile = result.files.single;
    if (pickedFile.path == null) return;

    final File file = File(pickedFile.path!);

    setState(() => _isUploading = true);

    try {
      final response = await UploadService.uploadFile(file);

      if (!mounted) return;

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
        barrierDismissible: false,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 36),
                const SizedBox(height: 12),
                const Text(
                  "Upload Complete",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  pickedFile.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      );

      Future.delayed(const Duration(milliseconds: 1600), () {
        if (mounted) Navigator.of(context).pop();
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload failed'),
        ),
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
        centerTitle: false,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.arrow_back, size: 30),
        ),
        title: const Text(
          "Your Uploads",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: data.isEmpty
                  ? const Center(child: Text("No uploads yet"))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 120),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final dataset = data[index];

                        return InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DatasetViewerScreen(dataset: dataset),
                              ),
                            );
                          },
                          child: DatasetWidget(dataset: dataset),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 64),
        child: FloatingActionButton(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.black,
          onPressed: _isUploading ? null : _pickAndUploadFile,
          child: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
