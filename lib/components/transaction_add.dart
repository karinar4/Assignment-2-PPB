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
  void initState() {
    super.initState();
    _refreshCategoryList();
  }

  void _refreshCategoryList() {
    categories = objectbox.categoryBox.getAll().where((c) => c.type == _selectedType).toList();
    if (categories.isNotEmpty) currentCategory = categories.first;
    setState(() {});
  }

  void _createCategory(String name) {
    objectbox.categoryBox.put(Category(name, _selectedType));
    _refreshCategoryList();
  }

  void _createTransaction() {
    final amount = double.tryParse(inputController.text) ?? 0;
    if (amount <= 0) return;

    final tx = Transaction(_selectedType, amount, _selectedDate)
      ..category.target = currentCategory;

    objectbox.transactionBox.put(tx);
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter category name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
        onPressed: _pickDate,
        child: Text(
          DateFormat('yyyy-MM-dd').format(_selectedDate),
          style: const TextStyle(fontSize: 18),
        ),
      ),
    ],
  );

  Widget _buildCategoryDropdown() => Row(
    children: [
      Expanded(
        child: DropdownButton<Category>(
          value: categories.isNotEmpty ? currentCategory : null,
          isExpanded: true,
          hint: const Text('Select category'),
          items: categories.map((c) {
            return DropdownMenuItem(value: c, child: Text(c.name));
          }).toList(),
          onChanged: (value) => setState(() => currentCategory = value!),
        ),
      ),
      IconButton(onPressed: _showAddCategoryDialog, icon: const Icon(Icons.add)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
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
                onPressed: _createTransaction,
                child: const Text('Add', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
