import 'package:flutter/material.dart';

class ChartWidget extends StatelessWidget {
  final double income;
  final double expense;
  final double savings;
  final bool showOnlyIncome;
  final bool showOnlyExpense;

  const ChartWidget({
    Key? key,
    required this.income,
    required this.expense,
    required this.savings,
    this.showOnlyIncome = false,
    this.showOnlyExpense = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxVal = [income, expense, savings].reduce((a, b) => a > b ? a : b);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (!showOnlyExpense)
          _buildBar(context, 'Pendapatan', income, maxVal, Colors.green),
        if (!showOnlyIncome)
          _buildBar(context, 'Pengeluaran', expense, maxVal, Colors.red),
        if (!showOnlyIncome && !showOnlyExpense)
          _buildBar(context, 'Tabungan', savings, maxVal, Colors.blue),
      ],
    );
  }

  Widget _buildBar(BuildContext context, String label, double value, double max,
      Color color) {
    final percent = max == 0 ? 0.1 : (value / max).clamp(0.1, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 500),
          width: 32,
          height: 120 * percent,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Rp\n${value.toStringAsFixed(0)}',
              style: TextStyle(color: Colors.white, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
