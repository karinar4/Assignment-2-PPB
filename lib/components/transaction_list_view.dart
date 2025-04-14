import 'package:flutter/material.dart';

import './transaction_card.dart';
import '../main.dart';
import '../model.dart';

class TransactionList extends StatefulWidget {
  final String type;

  const TransactionList({Key? key, required this.type}) : super(key: key);

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  late Stream<List<Transaction>> _transactionStream;

  @override
  void initState() {
    super.initState();
    _updateStream();
  }

  void _updateStream() {
    if (widget.type == 'Income') {
      _transactionStream = objectbox.getIncomes();
    } else if (widget.type == 'Expense') {
      _transactionStream = objectbox.getExpenses();
    } else {
      _transactionStream = objectbox.getAllTransactions(); // Misal untuk "All"
    }
  }

  @override
  void didUpdateWidget(covariant TransactionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      // Jika kategori berubah, perbarui stream
      _updateStream();
    }
  }

  TransactionCard Function(BuildContext, int) _itemBuilder(List<Transaction> transactions){
    return (BuildContext context, int index) => TransactionCard(transaction: transactions[index]);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Transaction>>(
      stream: _transactionStream,
      builder: (context, snapshot){
        if (snapshot.data?.isNotEmpty ?? false){
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.hasData ? snapshot.data!.length : 0,
            itemBuilder: _itemBuilder(snapshot.data ?? []),
          );
        } else {
          return const Center(child: Text("Press the + icon to add transactions"));
        }
      }
    );
  }
}