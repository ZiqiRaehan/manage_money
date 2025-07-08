import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/stat_card.dart';
import '../widgets/chart_widget.dart';
import '../widgets/income_form.dart';
import '../widgets/expense_form.dart';
import '../widgets/saving_form.dart';
import '../services/db_service.dart';
import '../models/transaction.dart';
import '../models/income.dart';
import '../models/expense.dart';
import '../models/saving.dart';
import 'add_transaction_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  double totalBalance = 0.0;
  double monthlyIncome = 0.0;
  double monthlyExpense = 0.0;
  double totalSavings = 0.0;
  
  List<Transaction> recentTransactions = [];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _loadData();
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    final db = DatabaseService();
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    // Load monthly data
    final incomes = await db.getIncomes();
    final expenses = await db.getExpenses();
    final savings = await db.getSavings();
    
    double income = 0.0;
    double expense = 0.0;
    double savingsAmount = 0.0;
    
    for (final inc in incomes) {
      if (inc.date.isAfter(startOfMonth) && inc.date.isBefore(endOfMonth)) {
        income += inc.amount;
      }
    }
    
    for (final exp in expenses) {
      if (exp.date.isAfter(startOfMonth) && exp.date.isBefore(endOfMonth)) {
        expense += exp.totalAmount;
      }
    }
    
    for (final sav in savings) {
      if (sav.type == 'actual') {
        savingsAmount += sav.amount;
      }
    }
    
    setState(() {
      monthlyIncome = income;
      monthlyExpense = expense;
      totalSavings = savingsAmount;
      totalBalance = income - expense - savingsAmount;
    });
  }
  
  void _showQuickAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Tambah Transaksi Cepat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildQuickActionButton(
                      'Pengeluaran Hari Ini',
                      Icons.shopping_cart_rounded,
                      Colors.red,
                      () => _showExpenseForm(),
                    ),
                    SizedBox(height: 12),
                    _buildQuickActionButton(
                      'Catat Pendapatan',
                      Icons.attach_money_rounded,
                      Colors.green,
                      () => _showIncomeForm(),
                    ),
                    SizedBox(height: 12),
                    _buildQuickActionButton(
                      'Menabung Sekarang',
                      Icons.savings_rounded,
                      Colors.blue,
                      () => _showSavingForm(),
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
  
  Widget _buildQuickActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
  
  void _showExpenseForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseForm(onSubmit: (expense) {
        _saveExpense(expense);
      }),
    );
  }
  
  void _showIncomeForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IncomeForm(onSubmit: (income) {
        _saveIncome(income);
      }),
    );
  }
  
  void _showSavingForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SavingForm(onSubmit: (saving) {
        _saveSaving(saving);
      }),
    );
  }
  
  Future<void> _saveExpense(Expense expense) async {
    await DatabaseService().insertExpense(expense);
    _loadData();
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pengeluaran berhasil dicatat')),
    );
  }
  
  Future<void> _saveIncome(Income income) async {
    await DatabaseService().insertIncome(income);
    _loadData();
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pendapatan berhasil dicatat')),
    );
  }
  
  Future<void> _saveSaving(Saving saving) async {
    await DatabaseService().insertSaving(saving);
    _loadData();
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tabungan berhasil dicatat')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: Color(0xFF6C5CE7),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'MoneyManager',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6C5CE7),
                        Color(0xFF74B9FF),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),
                      Text(
                        'Saldo Saat Ini',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Rp ${totalBalance.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Cards
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Pendapatan',
                            amount: monthlyIncome,
                            icon: Icons.trending_up_rounded,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Pengeluaran',
                            amount: monthlyExpense,
                            icon: Icons.trending_down_rounded,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    StatCard(
                      title: 'Total Tabungan',
                      amount: totalSavings,
                      icon: Icons.savings_rounded,
                      color: Colors.blue,
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Chart Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statistik Keuangan Bulan Ini',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3436),
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            height: 200,
                            child: ChartWidget(
                              income: monthlyIncome,
                              expense: monthlyExpense,
                              savings: totalSavings,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Quick Actions
                    Text(
                      'Aksi Cepat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                            'Pengeluaran\nHari Ini',
                            Icons.shopping_cart_rounded,
                            Colors.red,
                            () => _showExpenseForm(),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildFeatureCard(
                            'Catat\nPendapatan',
                            Icons.attach_money_rounded,
                            Colors.green,
                            () => _showIncomeForm(),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildFeatureCard(
                            'Menabung\nSekarang',
                            Icons.savings_rounded,
                            Colors.blue,
                            () => _showSavingForm(),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Saving Plans
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rencana Tabungan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showSavingPlanForm(),
                          child: Text('Tambah Rencana'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    FutureBuilder<List<Saving>>(
                      future: DatabaseService().getSavings(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        
                        final plans = snapshot.data!.where((s) => s.type == 'plan').toList();
                        
                        if (plans.isEmpty) {
                          return Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.savings_outlined, size: 48, color: Colors.grey[400]),
                                SizedBox(height: 12),
                                Text(
                                  'Belum ada rencana tabungan',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Buat rencana tabungan untuk mencapai tujuan finansial',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return Column(
                          children: plans.map((plan) => _buildSavingPlanCard(plan)).toList(),
                        );
                      },
                    ),
                    
                    SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickAddModal,
        backgroundColor: Color(0xFF6C5CE7),
        child: Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
  
  Widget _buildFeatureCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSavingPlanCard(Saving plan) {
    final daysLeft = plan.targetDate?.difference(DateTime.now()).inDays ?? 0;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: daysLeft > 0 ? Colors.orange[100] : Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  daysLeft > 0 ? '$daysLeft hari lagi' : 'Tercapai',
                  style: TextStyle(
                    fontSize: 12,
                    color: daysLeft > 0 ? Colors.orange[700] : Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Target: Rp ${plan.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          if (plan.description != null) ...[
            SizedBox(height: 4),
            Text(
              plan.description!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  void _showSavingPlanForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SavingForm(
        isPlan: true,
        onSubmit: (saving) {
          _saveSaving(saving);
        },
      ),
    );
  }
}