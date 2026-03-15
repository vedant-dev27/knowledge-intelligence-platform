import 'package:flutter/material.dart';
import 'package:synapse/widgets/dataset_menu_button.dart';
import 'package:synapse/widgets/recent_chat_widget.dart';
import 'package:synapse/models/recent_chat_list.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final List<RecentChats> fakeList = [
    RecentChats(title: "What are the laws of Thermodynamics", id: 6767),
    RecentChats(title: "Explain quantum entanglement simply", id: 6768),
    RecentChats(title: "How does photosynthesis work", id: 6769),
    RecentChats(title: "Difference between AI and Machine Learning", id: 6770),
    RecentChats(title: "Explain Newton's three laws", id: 6771),
    RecentChats(title: "What is Retrieval Augmented Generation", id: 6772),
    RecentChats(title: "How does a transformer model work", id: 6773),
    RecentChats(title: "Explain black holes in simple terms", id: 6774),
    RecentChats(title: "What is the Turing test", id: 6775),
    RecentChats(title: "How does blockchain technology work", id: 6776),
    RecentChats(title: "Explain the theory of relativity", id: 6777),
    RecentChats(title: "What is overfitting in machine learning", id: 6778),
    RecentChats(title: "How do neural networks learn", id: 6779),
    RecentChats(title: "What are vector embeddings", id: 6780),
    RecentChats(title: "Explain gradient descent", id: 6781),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Fixed Header
          Container(
            height: 203,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 10),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "Synapse",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 7),
                    Text("v0.6.5"),
                  ],
                ),
                Text("Designed by Vedant Singh"),
                SizedBox(height: 20),
                DatasetMenuButton(),
              ],
            ),
          ),

          /// Scrollable area
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Text(
                    "Recents",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                ...fakeList.map(
                  (chat) => RecentChatWidget(chat: chat),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
