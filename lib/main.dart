import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'objectbox.dart';
import 'components/transaction_list_view.dart';
import 'components/transaction_add.dart';

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
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Income', 'Expense'];

  double _balance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _calculateBalance();
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _calculateBalance() {
    final all = objectbox.transactionBox.getAll();
    double income = 0.0;
    double expense = 0.0;

    for (var tx in all) {
      if (tx.type == 'Income') {
        income += tx.amount;
      } else if (tx.type == 'Expense') {
        expense += tx.amount;
      }
    }

    setState(() {
      _totalIncome = income;
      _totalExpense = expense;
      _balance = income - expense;
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
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.deepOrange.shade100,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Balance',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      currencyFormatter.format(_balance),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Income: ${currencyFormatter.format(_totalIncome)}',
                          style: const TextStyle(fontSize: 14, color: Colors.green),
                        ),
                        Text(
                          'Expense: ${currencyFormatter.format(_totalExpense)}',
                          style: const TextStyle(fontSize: 14, color: Colors.red),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: _categories.map((category) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Center(child: Text(category)),
                      selected: _selectedCategory == category,
                      selectedColor: Colors.deepOrange.shade200,
                      onSelected: (bool selected) {
                        if (selected) {
                          _onCategoryChanged(category);
                        }
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Transaction list
            Expanded(
              child: TransactionList(type: _selectedCategory, onTransactionUpdated: _calculateBalance),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddTransaction(),
          ));
          _calculateBalance();
          setState(() {});
        },
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }
}
