import 'package:flutter/material.dart';

// PUBLIC_INTERFACE
void main() {
  runApp(const NoteEaseApp());
}

/// This is the main NoteEase application widget.
class NoteEaseApp extends StatelessWidget {
  const NoteEaseApp({super.key});

  // PUBLIC_INTERFACE
  @override
  Widget build(BuildContext context) {
    // Using custom colors as per specification
    return MaterialApp(
      title: 'NoteEase',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF1976D2),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF1976D2),
          secondary: const Color(0xFFFFFFFF),
          tertiary: const Color(0xFFFFC107),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFC107),
          foregroundColor: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF1976D2)),
          ),
        ),
      ),
      home: const NoteHomePage(),
    );
  }
}

/// Data class representing a note.
class Note {
  String id;
  String title;
  String content;
  String category;
  DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
  });
}

// PUBLIC_INTERFACE
class NoteHomePage extends StatefulWidget {
  const NoteHomePage({super.key});

  @override
  State<NoteHomePage> createState() => _NoteHomePageState();
}

class _NoteHomePageState extends State<NoteHomePage> {
  final List<Note> _notes = [];
  final List<String> _categories = ['All', 'Work', 'Personal', 'Ideas', 'Other'];
  String _searchTerm = '';
  String _activeCategory = 'All';

  // Generate a displayable filtered notes list based on search and selected category
  List<Note> get _filteredNotes {
    return _notes.where((note) {
      bool matchesCategory = _activeCategory == 'All' || note.category == _activeCategory;
      bool matchesSearch = _searchTerm.isEmpty ||
          note.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchTerm.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Handle search input
  void _onSearchChanged(String term) {
    setState(() {
      _searchTerm = term;
    });
  }

  // Handle category selection
  void _onCategorySelected(String category) {
    setState(() {
      _activeCategory = category;
    });
  }

  // Create or edit a note
  void _showNoteDialog({Note? note}) {
    bool isEditing = note != null;
    final titleCtrl = TextEditingController(text: note?.title ?? '');
    final contentCtrl = TextEditingController(text: note?.content ?? '');
    String chosenCategory = note?.category ?? (_categories.length > 1 ? _categories[1] : 'Other');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Note' : 'New Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  autofocus: !isEditing,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentCtrl,
                  decoration: const InputDecoration(labelText: 'Content'),
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  minLines: 2,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: isEditing ? chosenCategory : null,
                  hint: const Text('Category'),
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories
                      .where((cat) => cat != 'All')
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) chosenCategory = val;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? 'Save' : 'Create'),
              onPressed: () {
                final title = titleCtrl.text.trim();
                final content = contentCtrl.text.trim();
                if (title.isEmpty || content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title and Content cannot be empty!')),
                  );
                  return;
                }
                setState(() {
                  if (isEditing) {
                    note.title = title;
                    note.content = content;
                    note.category = chosenCategory;
                  } else {
                    _notes.add(Note(
                      id: UniqueKey().toString(),
                      title: title,
                      content: content,
                      category: chosenCategory,
                      createdAt: DateTime.now(),
                    ));
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Confirm and delete a note
  void _deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () {
              setState(() {
                _notes.removeWhere((n) => n.id == note.id);
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  // Show note details and allow editing/deletion
  void _showNoteDetail(Note note) {
    _showNoteDialog(note: note);
  }

  // UI: Main build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NoteEase'),
        elevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF1F3F4),
                hintText: 'Search notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Category filter chips row
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                return ChoiceChip(
                  label: Text(cat),
                  selectedColor: Theme.of(context).colorScheme.tertiary,
                  selected: _activeCategory == cat,
                  onSelected: (_) => _onCategorySelected(cat),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _categories.length,
            ),
          ),
          const Divider(height: 1),
          // Notes list
          Expanded(
            child: _filteredNotes.isEmpty
                ? Center(
                    child: Text(
                      'No notes yet. Tap + to create one!',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredNotes.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final note = _filteredNotes[idx];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        title: Text(
                          note.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          note.content.length > 70
                              ? '${note.content.substring(0, 67)}...'
                              : note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                          child: Text(
                            note.category.isNotEmpty
                                ? note.category.substring(0, 1)
                                : '-',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _showNoteDetail(note),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => _deleteNote(note),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                        onTap: () => _showNoteDetail(note),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
