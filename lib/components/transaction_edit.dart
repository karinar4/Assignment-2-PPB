import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../model.dart';

class EditTransaction extends StatefulWidget {
  final Transaction transaction;
  final VoidCallback onTransactionUpdated;

  const EditTransaction({Key? key, required this.transaction, required this.onTransactionUpdated}) : super(key: key);

  @override
  _EditTransactionState createState() => _EditTransactionState();
}

class _EditTransactionState extends State<EditTransaction> {
  final inputController = TextEditingController();
  List<Category> categories = [];
  String _selectedType = '';
  DateTime _selectedDate = DateTime.now();
  late Category currentCategory;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.transaction.type;
    _selectedDate = widget.transaction.date;
    inputController.text = widget.transaction.amount.toString();
    _refreshCategoryList();
  }

  void _refreshCategoryList() {
    categories = objectbox.categoryBox
        .getAll()
        .where((c) => c.type == _selectedType)
        .toList();
    if (categories.isNotEmpty) {
      currentCategory = categories.firstWhere((category) => category.id == widget.transaction.category.target!.id);
    }
    setState(() {});
  }

  void updateCategory(int newCategoryId) {
    Category newCurrentCategory = objectbox.categoryBox.get(newCategoryId)!;

    setState(() {
      currentCategory = newCurrentCategory;
    });
  }

  void _updateTransaction() {
    if (inputController.text.isNotEmpty) {
      double amount = double.tryParse(inputController.text) ?? 0.0;
      if (amount <= 0) return;

      widget.transaction.amount = amount;
      widget.transaction.type = _selectedType;
      widget.transaction.date = _selectedDate;
      widget.transaction.category.target = currentCategory;
      objectbox.transactionBox.put(widget.transaction);

      widget.onTransactionUpdated();
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

  void _deleteTransaction() {
    objectbox.transactionBox.remove(widget.transaction.id);

    widget.onTransactionUpdated();
    Navigator.pop(context);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Transaction')),
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
              decoration: const InputDecoration(hintText: 'Amount'),
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
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateTransaction,
                child: const Text('Update', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _deleteTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade200,
                ),
                child: const Text('Delete', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
