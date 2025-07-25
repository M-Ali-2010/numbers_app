import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(NumbersApp());

class NumbersApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Numbers Info',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
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
  String _result = '';
  bool _isLoading = false;

  Future<void> fetchNumberInfo() async {
    final number = _controller.text.trim();
    if (number.isEmpty || int.tryParse(number) == null) {
      showError('Введите корректное число.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('http://numbersapi.com/$number/$_selectedType');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() => _result = response.body);
      } else {
        showError('Ошибка при получении данных.');
      }
    } catch (e) {
      showError('Ошибка подключения к интернету.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ошибка'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📊 Информация о числе'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выберите тип информации:',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedType,
              isExpanded: true,
              items: ['trivia', 'math', 'date'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Введите число',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.confirmation_number_outlined),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: fetchNumberInfo,
                icon: Icon(Icons.search),
                label: Text('Получить информацию'),
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading) Center(child: CircularProgressIndicator()),
            if (_result.isNotEmpty) ...[
              Divider(height: 32),
              Text('📘 Результат:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  _result,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}