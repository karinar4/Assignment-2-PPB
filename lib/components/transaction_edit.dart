import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../model.dart';

class EditTransaction extends StatefulWidget {
  final Transaction transaction;
  final VoidCallback onTransactionUpdated;

  const EditTransaction({Key? key, required this.transaction, required this.onTransactionUpdated,}) : super(key: key);

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
    categories = objectbox.categoryBox.getAll().where((c) => c.type == _selectedType).toList();

    if (categories.isNotEmpty) {
      currentCategory = categories.firstWhere((c) => c.id == widget.transaction.category.target?.id, orElse: () => categories.first);
    }

    setState(() {});
  }

  void _updateTransaction() {
    final amount = double.tryParse(inputController.text) ?? 0;
    if (amount <= 0) return;

    widget.transaction.amount = amount;
    widget.transaction.type = _selectedType;
    widget.transaction.date = _selectedDate;
    widget.transaction.category.target = currentCategory;

    objectbox.transactionBox.put(widget.transaction);
    widget.onTransactionUpdated();
    Navigator.pop(context);
  }

  void _deleteTransaction() {
    objectbox.transactionBox.remove(widget.transaction.id);
    widget.onTransactionUpdated();
    Navigator.pop(context);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
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

  Widget _buildAmountInput() => TextField(
    controller: inputController,
    keyboardType: TextInputType.number,
    style: const TextStyle(fontSize: 18),
    decoration: const InputDecoration(hintText: 'Amount'),
  );

  Widget _buildDateSelector() => Row(
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
  );

  Widget _buildCategoryDropdown() => DropdownButton<Category>(
    value: categories.isNotEmpty ? currentCategory : null,
    isExpanded: true,
    hint: const Text('Select category'),
    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
    onChanged: (value) => setState(() => currentCategory = value!),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 16),
            _buildAmountInput(),
            const SizedBox(height: 16),
            _buildDateSelector(),
            const SizedBox(height: 16),
            _buildCategoryDropdown(),
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
