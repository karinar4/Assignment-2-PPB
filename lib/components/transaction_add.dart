import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../model.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({Key? key}) : super(key: key);

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final inputController = TextEditingController();
  List<Category> categories = [];
  String _selectedType = 'Income';
  DateTime _selectedDate = DateTime.now();
  late Category currentCategory;

  @override
  void initState(){
    super.initState();
    _refreshCategoryList();
  }

  void _refreshCategoryList() {
    categories = objectbox.categoryBox
        .getAll()
        .where((c) => c.type == _selectedType)
        .toList();
    if (categories.isNotEmpty) {
      currentCategory = categories[0];
    }
    setState(() {});
  }

  void updateCategory(int newCategoryId){
    Category newCurrentCategory = objectbox.categoryBox.get(newCategoryId)!;

    setState(() {
      currentCategory = newCurrentCategory;
    });
  }

  void _createCategory(String name){
    final newCategory = Category(name, _selectedType);
    objectbox.categoryBox.put(newCategory);
    _refreshCategoryList();
  }

  void createTransaction(){
    if (inputController.text.isNotEmpty){
      double amount = double.tryParse(inputController.text) ?? 0.0;
      if (amount <= 0) return;

      final newTransaction = Transaction(_selectedType, amount, _selectedDate);
      newTransaction.category.target = currentCategory;
      objectbox.transactionBox.put(newTransaction);

      Navigator.pop(context);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _createCategory(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    final types = ['Income', 'Expense'];

    return Row(
      children: types.map((type) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Center(child: Text(type, style: const TextStyle(fontSize: 16))),
              selected: _selectedType == type,
              selectedColor: Colors.deepOrange.shade200,
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    _selectedType = type;
                    _refreshCategoryList();
                  });
                }
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      key: UniqueKey(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 16),
            TextField(
              controller: inputController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                hintText: 'Amount',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Date: ', style: TextStyle(fontSize: 18)),
                TextButton(
                  onPressed: _selectDate,
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(_selectedDate),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<Category>(
                    value: categories.isNotEmpty ? currentCategory : null,
                    isExpanded: true,
                    hint: const Text('Select category'),
                    items: categories.map((Category category) {
                      return DropdownMenuItem<Category>(
                        value: category,
                        child: Text(category.name, style: const TextStyle(fontSize: 18)),
                      );
                    }).toList(),
                    onChanged: (Category? newValue) {
                      if (newValue != null) {
                        setState(() {
                          currentCategory = newValue;
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: _showAddCategoryDialog,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: createTransaction,
                child: const Text('Add', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        )
      )
    );
  }
}