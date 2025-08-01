import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(NumbersApp());

class NumbersApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF6C63FF); // Indigo/Violet
    final Color backgroundColor = Color(0xFFF4F6FC); // Light bluish white
    final Color cardColor = Color(0xFFE6E9F0); // Light gray-blue

    return MaterialApp(
      title: 'Numbers Info',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: Colors.deepPurpleAccent,
          surface: cardColor,
          background: backgroundColor,
          onPrimary: Colors.white,
          onSurface: Colors.black87,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: NumberInfoPage(),
    );
  }
}

class NumberInfoPage extends StatefulWidget {
  @override
  _NumberInfoPageState createState() => _NumberInfoPageState();
}

class _NumberInfoPageState extends State<NumberInfoPage> {
  final TextEditingController _controller = TextEditingController();
  String _selectedType = 'trivia';
  bool _isLoading = false;

  Future<void> fetchNumberInfo({bool isRandom = false}) async {
    setState(() => _isLoading = true);
    final input = _controller.text.trim();
    final isInputValid = int.tryParse(input) != null;

    if (!isRandom && (input.isEmpty || !isInputValid)) {
      showError('Введите корректное число');
      setState(() => _isLoading = false);
      return;
    }

    final query = isRandom ? 'random' : input;
    final url = Uri.parse('http://numbersapi.com/$query/$_selectedType');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        showResultDialog(response.body);
      } else {
        showError('Ошибка при получении данных');
      }
    } catch (e) {
      showError('Нет подключения к интернету');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void showResultDialog(String result) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.stars, color: Colors.amber, size: 40),
            SizedBox(height: 16),
            Text(
              result,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.bookmark_add_outlined),
              label: Text('Сохранить'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                List<String> saved = prefs.getStringList('saved_items') ?? [];
                if (!saved.contains(result)) {
                  saved.add(result);
                  await prefs.setStringList('saved_items', saved);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Сохранено'),
                      backgroundColor: Colors.green.shade600,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Уже сохранено'),
                      backgroundColor: Colors.orange.shade600,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void openSavedPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SavedItemsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Числовые Факты'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.bookmarks_outlined),
            onPressed: openSavedPage,
            tooltip: 'Сохранённые',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Тип информации',
                      border: border,
                    ),
                    items: ['trivia', 'math', 'date'].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Введите число',
                      border: border,
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                  SizedBox(height: 24),
                  _isLoading
                      ? CircularProgressIndicator()
                      : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.search),
                          label: Text('Найти факт'),
                          onPressed: () =>
                              fetchNumberInfo(isRandom: false),
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.shuffle),
                          label: Text('Случайный факт'),
                          onPressed: () =>
                              fetchNumberInfo(isRandom: true),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SavedItemsPage extends StatefulWidget {
  @override
  _SavedItemsPageState createState() => _SavedItemsPageState();
}

class _SavedItemsPageState extends State<SavedItemsPage> {
  List<String> _savedItems = [];

  @override
  void initState() {
    super.initState();
    loadSavedItems();
  }

  Future<void> loadSavedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList('saved_items') ?? [];
    setState(() => _savedItems = items);
  }

  Future<void> removeItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _savedItems.removeAt(index);
    await prefs.setStringList('saved_items', _savedItems);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('⭐ Сохранённые')),
      body: _savedItems.isEmpty
          ? Center(child: Text('Нет сохранённых данных.'))
          : ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: _savedItems.length,
        separatorBuilder: (_, __) => SizedBox(height: 10),
        itemBuilder: (_, index) => Dismissible(
          key: Key(_savedItems[index]),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => removeItem(index),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 2,
            child: ListTile(
              title: Text(_savedItems[index]),
            ),
          ),
        ),
      ),
    );
  }
}
