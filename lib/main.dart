import 'package:flutter/material.dart';
import 'objectbox.dart';
import 'components/transaction_list_view.dart';

late ObjectBox objectbox;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectbox = await ObjectBox.create();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Budget Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _selectedCategory = 'All'; // All / Income / Expense

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pilihan kategori dalam bentuk button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryButton('All', Colors.blueGrey),
                _buildCategoryButton('Income', Colors.green),
                _buildCategoryButton('Expense', Colors.red),
              ],
            ),
            const SizedBox(height: 20),
            // List transaksi sesuai kategori
            Expanded(
              child: TransactionList(type: _selectedCategory),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddTransaction()
          ));
        },
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Membuat tombol untuk kategori
  Widget _buildCategoryButton(String category, Color color) {
    return ElevatedButton(
      onPressed: () {
        _onCategoryChanged(category);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(100, 50),
        textStyle: const TextStyle(fontSize: 16),
      ),
      child: Text(category),
    );
  }
}
