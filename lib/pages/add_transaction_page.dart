import 'package:flutter/material.dart';
import '../widgets/expense_form.dart';
import '../widgets/income_form.dart';
import '../widgets/saving_form.dart';

class AddTransactionPage extends StatefulWidget {
  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Transaksi'),
        backgroundColor: Color(0xFF6C5CE7),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: Icon(Icons.trending_down_rounded), text: 'Pengeluaran'),
            Tab(icon: Icon(Icons.trending_up_rounded), text: 'Pendapatan'),
            Tab(icon: Icon(Icons.savings_rounded), text: 'Tabungan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ExpenseForm(onSubmit: (expense) {
            Navigator.pop(context);
          }),
          IncomeForm(onSubmit: (income) {
            Navigator.pop(context);
          }),
          SavingForm(onSubmit: (saving) {
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }
}
