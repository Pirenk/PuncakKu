import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/checklist_item.dart';

void main() {
  runApp(const TestApiApp());
}

class TestApiApp extends StatelessWidget {
  const TestApiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Test API Pendaki'),
        ),
        body: FutureBuilder<List<ChecklistItem>>(
          future: ApiService.getChecklist(1).then(
            (data) => data.map((item) {
              return ChecklistItem.fromJson(
                Map<String, dynamic>.from(item),
              );
            }).toList(),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final items = snapshot.data ?? [];

            return ListView(
              children: items.map((item) {
                return ListTile(
                  title: Text(item.nama),
                  subtitle: Text('Jumlah: ${item.jumlah}'),
                  trailing: Icon(
                    item.isChecked
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
