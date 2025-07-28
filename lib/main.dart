import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(NumbersApp());

class NumbersApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Numbers Info',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
        ),
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
      showError('Число должно быть в виде цифры.');
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
        showError('Ошибка при получении данных.');
      }
    } catch (e) {
      showError('Ошибка подключения к интернету.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('✨ Результат'),
        content: Text(result),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              List<String> saved =
                  prefs.getStringList('saved_items') ?? [];
              saved.add(result);
              await prefs.setStringList('saved_items', saved);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Сохранено'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green.shade600,
                ),
              );
            },
            icon: Icon(Icons.save_alt_outlined),
            label: Text('Сохранить'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('⚠️ Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Ок'),
          )
        ],
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
      borderRadius: BorderRadius.circular(16),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('📊 Информация о числе'),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmarks_outlined),
            tooltip: 'Сохраненные',
            onPressed: openSavedPage,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              margin: EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                    SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Введите число',
                        border: border,
                        prefixIcon: Icon(Icons.numbers_outlined),
                      ),
                    ),
                    SizedBox(height: 24),
                    if (_isLoading) CircularProgressIndicator(),
                    if (!_isLoading)
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.search),
                              label: Text('Получить информацию'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () => fetchNumberInfo(isRandom: false),
                            ),
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.shuffle),
                              label: Text('Случайное число'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () => fetchNumberInfo(isRandom: true),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
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
      appBar: AppBar(title: Text('⭐ Сохранённые данные')),
      body: _savedItems.isEmpty
          ? Center(child: Text('Нет сохранённых данных.', style: TextStyle(fontSize: 16)))
          : ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: _savedItems.length,
              separatorBuilder: (_, __) => SizedBox(height: 10),
              itemBuilder: (_, index) => Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
                child: ListTile(
                  title: Text(_savedItems[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => removeItem(index),
                  ),
                ),
              ),
            ),
    );
  }
}
