import 'dart:ui'; // For glassmorphism blur
import 'package:Budget_App/components.dart';
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
        title: const Text(
          "Reports",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Summary Cards (Glassmorphism)
            Row(
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

            // Mini Pie Chart
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    Text(
                      "Expense by Category",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 200, child: _MiniPieChart()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 📊 Bar Chart
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    Text(
                      "Category Comparison",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 300, child: _BarChartWidget()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // View Full Breakdown Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FullPieChartPage(vm: vm)),
                );
              },
              icon: const Icon(Icons.pie_chart),
              label: const Text(
                "View Full Breakdown",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Glassmorphic Summary Card
  Widget _summaryCard(String title, double value, Color color, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  "\$${value.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
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
}

/// Mini Pie Chart Widget
class _MiniPieChart extends StatelessWidget {
  const _MiniPieChart();

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with your ViewModel data later
    final data = {"Shopping": 900, "Rent": 400, "Other": 465, "Bills": 1000};
    final total = data.values.fold(0, (sum, e) => sum + e);

    return PieChart(
      PieChartData(
        sections:
            data.entries.map((entry) {
              final percent = (entry.value / total) * 100;
              return PieChartSectionData(
                value: entry.value.toDouble(),
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
        centerSpaceRadius: 30,
        sectionsSpace: 3,
      ),
    );
  }
}

/// 📊 Bar Chart Widget
class _BarChartWidget extends StatelessWidget {
  const _BarChartWidget();

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with ViewModel data
    final data = {"Shopping": 900, "Rent": 400, "Other": 465, "Bills": 1000};
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
                if (index < 0 || index >= keys.length) {
                  return const SizedBox();
                }
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
                toY: entry.value.toDouble(),
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
