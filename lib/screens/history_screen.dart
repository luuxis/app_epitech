// lib/screens/history_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<JournalEntry> entries = JournalService().getEntries();

    return Scaffold(
      appBar: AppBar(title: const Text('Historique du Journal')),
      body: entries.isEmpty
          ? const Center(child: Text('Aucune entrée dans le journal.'))
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Image.file(File(entry.imagePath), width: 100, height: 100, fit: BoxFit.cover),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.weatherData.cityName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('${entry.weatherData.temperature.toStringAsFixed(1)}°C, ${entry.weatherData.description}'),
                              Text('État : ${entry.motionStatus}'),
                              const SizedBox(height: 5),
                              Text(
                                '${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year}',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}