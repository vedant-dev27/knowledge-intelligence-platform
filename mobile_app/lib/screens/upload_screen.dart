import 'package:flutter/material.dart';
import 'package:synapse/models/dataset_model.dart';
import 'package:synapse/screens/dataset_viewer_screen.dart';
import 'package:synapse/widgets/dataset_widget.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

final List<DatasetModel> fakeData = [
  DatasetModel(
    title: "Introduction of Langchain",
    createdAt: DateTime.now(),
    type: "pdf",
    content: "Thermodynamics",
  ),
  DatasetModel(
    title: "Statics and Dynamics",
    createdAt: DateTime.now(),
    type: "image",
    content: "Algebra",
  ),
  DatasetModel(
    title: "Rise of Agentic AI Research Paper",
    createdAt: DateTime.now(),
    type: "pdf",
    content: "Prokaryotic Cell",
  ),
];

class _UploadScreenState extends State<UploadScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.menu, size: 30),
        ),
        title: const Text(
          "Synapse",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                "Your Uploads",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 120),
                itemCount: fakeData.length,
                itemBuilder: (context, index) {
                  final dataset = fakeData[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: InkWell(
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
                    ),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              heroTag: "camera",
              backgroundColor: Colors.black,
              onPressed: () {},
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
