import '../models/journal_entry.dart';

class JournalService {
  static final JournalService _instance = JournalService._internal();
  factory JournalService() => _instance;
  JournalService._internal();

  final List<JournalEntry> _entries = [];

  List<JournalEntry> getEntries() => _entries;

  void addEntry(JournalEntry entry) {
    _entries.add(entry);
  }
}
