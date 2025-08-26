import 'dart:ui'; // For glassmorphism blur
import 'package:Budget_App/utils/colors.dart';
import 'package:Budget_App/view_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReportsPage extends HookConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(viewModel);

    final totalIncome = vm.totalIncome.toDouble();
    final totalExpense = vm.totalExpense.toDouble();
    final balance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: const Text(
          "Reports",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 💎 Summary Cards
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _summaryCard(
                    "Income",
                    totalIncome,
                    Colors.green,
                    Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryCard(
                    "Expenses",
                    totalExpense,
                    Colors.red,
                    Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryCard(
                    "Balance",
                    balance,
                    Colors.blue,
                    Icons.account_balance_wallet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 🥧 Mini Pie Chart
            _reportCard(
              title: "Expense by Category",
              child:
                  vm.expensesByCategory.isEmpty
                      ? const _EmptyChartMessage()
                      : Column(
                        children: [
                          SizedBox(
                            height: 220,
                            child: _MiniPieChart(data: vm.expensesByCategory),
                          ),
                          const SizedBox(height: 12),
                          _ChartLegend(data: vm.expensesByCategory),
                        ],
                      ),
            ),
            const SizedBox(height: 24),

            // 📊 Bar Chart
            _reportCard(
              title: "Category Comparison",
              child:
                  vm.expensesByCategory.isEmpty
                      ? const _EmptyChartMessage()
                      : SizedBox(
                        height: 300,
                        child: _BarChartWidget(data: vm.expensesByCategory),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Reusable Summary Card with Glassmorphism
  Widget _summaryCard(String title, double value, Color color, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  "\$${value.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Reusable Card Wrapper for Charts
  Widget _reportCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

/// 🥧 Pie Chart Widget
class _MiniPieChart extends StatelessWidget {
  final Map<String, double> data;
  const _MiniPieChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (sum, e) => sum + e);

    return PieChart(
      PieChartData(
        sections:
            data.entries.map((entry) {
              final percent = (entry.value / total) * 100;
              return PieChartSectionData(
                value: entry.value,
                title: "${percent.toStringAsFixed(1)}%",
                radius: 60,
                color: getColorForCategory(entry.key),
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
        centerSpaceRadius: 35,
        sectionsSpace: 3,
      ),
    );
  }
}

/// 📊 Bar Chart Widget
class _BarChartWidget extends StatelessWidget {
  final Map<String, double> data;
  const _BarChartWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    final keys = data.keys.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= keys.length) return const SizedBox();
                return Text(keys[index], style: const TextStyle(fontSize: 12));
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        barGroups: List.generate(data.length, (index) {
          final entry = data.entries.elementAt(index);
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: getColorForCategory(entry.key),
                width: 20,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// 📌 Chart Legend
class _ChartLegend extends StatelessWidget {
  final Map<String, double> data;
  const _ChartLegend({required this.data});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children:
          data.keys.map((category) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.center, // ✅ Align icon and text
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: getColorForCategory(category),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 6),
                Text(category, style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
    );
  }
}

/// 🚫 Empty State Message
class _EmptyChartMessage extends StatelessWidget {
  const _EmptyChartMessage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.insights_outlined,
            size: 50,
            color: Colors.grey.withOpacity(0.7),
          ),
          const SizedBox(height: 10),
          Text(
            "No data available",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
