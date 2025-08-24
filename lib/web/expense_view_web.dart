import 'package:Budget_App/models.dart';
import 'package:Budget_App/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../components.dart';
import '../view_model.dart';

class ExpenseViewWeb extends HookConsumerWidget {
  const ExpenseViewWeb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(viewModel);

    // Only run once
    useEffect(() {
      vm.expensesStream();
      vm.incomesStream();
      return null;
    }, const []);

    return SafeArea(
      child: Scaffold(
        drawer: DrawerExpense(),
        appBar: AppBar(
          title: const Poppins(
            text: "Dashboard",
            size: 24,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          backgroundColor: Colors.deepPurple,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              tooltip: "Refresh Data",
              onPressed: () async => await vm.reset(),
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: "Logout",
              onPressed: () async => await vm.logout(),
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(40.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              // Desktop (>=1000px): keep full layout
              if (width >= 1000) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildLeftPanel(vm, context)),
                    const SizedBox(width: 40),
                    Expanded(flex: 2, child: _buildRightPanel(vm)),
                  ],
                );
              }

              // Tablet/Mid-size (600px–1000px): stack vertically but keep original sizes
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeftPanel(vm, context, isExpanded: false),
                    const SizedBox(height: 40),
                    _buildRightPanel(vm),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// LEFT PANEL – Summary + Pie Chart
  Widget _buildLeftPanel(
    ViewModel vm,
    BuildContext context, {
    bool isExpanded = true,
  }) {
    final chartWidget = GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FullPieChartPage(vm: vm)),
        );
      },
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.deepPurple.shade200, width: 1.5),
        ),
        child:
            vm.expenseTotalsByCategory.isEmpty
                ? const Center(child: Text("No expense data"))
                : PieChart(
                  PieChartData(
                    sections:
                        vm.expenseTotalsByCategory.entries.map((entry) {
                          final value = entry.value.toDouble();
                          return PieChartSectionData(
                            value: value,
                            title: '',
                            color: getColorForCategory(entry.key),
                            radius: 70,
                          );
                        }).toList(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 600),
                  swapAnimationCurve: Curves.easeOut,
                ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade100,
            borderRadius: BorderRadius.circular(25),
          ),
          child: TotalCalculation(18.0),
        ),
        const SizedBox(height: 40),
        isExpanded
            ? Expanded(child: chartWidget)
            : Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: chartWidget,
            ),
      ],
    );
  }

  /// RIGHT PANEL – Buttons + Expense/Income Lists
  Widget _buildRightPanel(ViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [AddExpense(), const SizedBox(width: 20), AddIncome()],
        ),
        const SizedBox(height: 40),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildListSection(title: "Expenses", items: vm.expenses),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: _buildListSection(title: "Incomes", items: vm.incomes),
            ),
          ],
        ),
      ],
    );
  }

  /// List builder for Expense or Income
  Widget _buildListSection({
    required String title,
    required List<Models> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Poppins(
          text: title,
          size: 20,
          color: Colors.deepPurple.shade900,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 15),
        Container(
          height: 400,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.deepPurple.shade200, width: 1.5),
            color: Colors.deepPurple.shade50,
          ),
          child:
              items.isEmpty
                  ? const Center(child: Text("No data"))
                  : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final amount = double.tryParse(item.amount) ?? 0;
                      return IncomeExpenseRowMobile(
                        text: item.name,
                        amount: amount,
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
