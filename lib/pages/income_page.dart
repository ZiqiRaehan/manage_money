import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/income.dart';
import '../services/db_service.dart';
import '../widgets/income_form.dart';
import '../widgets/chart_widget.dart';

class IncomePage extends StatefulWidget {
  @override
  _IncomePageState createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  List<Income> incomes = [];
  double totalIncome = 0.0;
  double monthlyIncome = 0.0;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _loadIncomes();
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadIncomes() async {
    final db = DatabaseService();
    final loadedIncomes = await db.getIncomes();
    
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    double total = 0.0;
    double monthly = 0.0;
    
    for (final income in loadedIncomes) {
      total += income.amount;
      if (income.date.isAfter(startOfMonth) && income.date.isBefore(endOfMonth)) {
        monthly += income.amount;
      }
    }
    
    setState(() {
      incomes = loadedIncomes;
      totalIncome = total;
      monthlyIncome = monthly;
    });
  }
  
  void _showIncomeForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IncomeForm(
        onSubmit: (income) {
          _saveIncome(income);
        },
      ),
    );
  }
  
  Future<void> _saveIncome(Income income) async {
    await DatabaseService().insertIncome(income);
    _loadIncomes();
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pendapatan berhasil dicatat'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  Future<void> _deleteIncome(Income income) async {
    await DatabaseService().deleteIncome(income.id!);
    _loadIncomes();
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pendapatan berhasil dihapus'),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  void _showDeleteDialog(Income income) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Pendapatan'),
        content: Text('Apakah Anda yakin ingin menghapus pendapatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteIncome(income);
            },
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  String _getSourceLabel(String source) {
    switch (source) {
      case 'salary':
        return 'Gaji';
      case 'freelance':
        return 'Freelance';
      case 'found':
        return 'Nemu Uang';
      case 'other':
        return 'Lainnya';
      default:
        return source;
    }
  }
  
  Color _getSourceColor(String source) {
    switch (source) {
      case 'salary':
        return Colors.blue;
      case 'freelance':
        return Colors.purple;
      case 'found':
        return Colors.orange;
      case 'other':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getSourceIcon(String source) {
    switch (source) {
      case 'salary':
        return Icons.work_rounded;
      case 'freelance':
        return Icons.laptop_rounded;
      case 'found':
        return Icons.money_rounded;
      case 'other':
        return Icons.more_horiz_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, _slideAnimation.value),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: Colors.green,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Pendapatan',
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
                        Colors.green,
                        Colors.green[300]!,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),
                      Text(
                        'Pendapatan Bulan Ini',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Rp ${monthlyIncome.toStringAsFixed(0)}',
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
                    // Statistics Card
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Pendapatan',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Icon(
                                Icons.trending_up_rounded,
                                color: Colors.green,
                                size: 24,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Rp ${totalIncome.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
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
                            'Grafik Pendapatan Bulan Ini',
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
                              expense: 0,
                              savings: 0,
                              showOnlyIncome: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Income List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Riwayat Pendapatan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        Text(
                          '${incomes.length} transaksi',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Income List
                    if (incomes.isEmpty)
                      Container(
                        padding: EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.money_off_rounded,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada pendapatan tercatat',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Mulai catat pendapatan Anda untuk mengelola keuangan dengan lebih baik',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: incomes.length,
                        itemBuilder: (context, index) {
                          final income = incomes[index];
                          return _buildIncomeCard(income);
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
        onPressed: _showIncomeForm,
        backgroundColor: Colors.green,
        child: Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
  
  Widget _buildIncomeCard(Income income) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getSourceColor(income.source).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getSourceIcon(income.source),
            color: _getSourceColor(income.source),
            size: 24,
          ),
        ),
        title: Text(
          _getSourceLabel(income.source),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              income.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${income.date.day}/${income.date.month}/${income.date.year}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Rp ${income.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 4),
            InkWell(
              onTap: () => _showDeleteDialog(income),
              child: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}