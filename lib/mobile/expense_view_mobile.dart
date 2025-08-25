import 'package:Budget_App/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../components.dart';
import '../view_model.dart';

bool isLoading = true;

class ExpenseViewMobile extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Correct provider usage
    final vm = ref.watch(viewModel);

    if (isLoading == true) {
      vm.expensesStream();
      vm.incomesStream();
      isLoading = false;
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        drawer: DrawerExpense(),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white, size: 30),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          title: const Poppins(
            text: "Dashboard",
            size: 20.0,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          actions: [
            IconButton(
              tooltip: "Refresh Data",
              onPressed: () async {
                await vm.reset();
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  children: [
                    Center(
                      child: Container(
                        height: 230,
                        width: screenWidth * 0.8,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade700,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.shade300.withOpacity(
                                0.5,
                              ),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: TotalCalculation(16.0),
                      ),
                    ),
                    const SizedBox(height: 35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AddExpense(),
                        const SizedBox(width: 20),
                        AddIncome(),
                      ],
                    ),
                    const SizedBox(height: 35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Poppins(
                                text: "Expenses",
                                size: 18.0,
                                color: Colors.deepPurple.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 230,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.deepPurple.shade200,
                                    width: 1.5,
                                  ),
                                  color: Colors.deepPurple.shade50,
                                ),
                                padding: const EdgeInsets.all(10),
                                child: ListView.builder(
                                  itemCount: vm.expenses.length,
                                  itemBuilder: (context, index) {
                                    final e = vm.expenses[index];
                                    return IncomeExpenseRowMobile(
                                      text: e.name,
                                      amount: double.tryParse(e.amount) ?? 0,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Poppins(
                                text: "Incomes",
                                size: 18.0,
                                color: Colors.deepPurple.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 230,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.deepPurple.shade200,
                                    width: 1.5,
                                  ),
                                  color: Colors.deepPurple.shade50,
                                ),
                                padding: const EdgeInsets.all(10),
                                child: ListView.builder(
                                  itemCount: vm.incomes.length,
                                  itemBuilder: (context, index) {
                                    final i = vm.incomes[index];
                                    return IncomeExpenseRowMobile(
                                      text: i.name,
                                      amount: double.tryParse(i.amount) ?? 0,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // ==== Add Category-wise Expense Summary and Pie Chart here ==== //
                    const SizedBox(height: 35),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Poppins(
                          text: "Expense by Category",
                          size: 18.0,
                          color: Colors.deepPurple.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 10),

                        // Category totals list
                        Column(
                          children:
                              vm.expenseTotalsByCategory.entries.map((entry) {
                                return ListTile(
                                  title: Text(entry.key),
                                  trailing: Text('${entry.value}\$'),
                                );
                              }).toList(),
                        ),

                        const SizedBox(height: 20),

                        // Pie Chart for category expenses
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullPieChartPage(vm: vm),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections:
                                    vm.expenseTotalsByCategory.entries.map((
                                      entry,
                                    ) {
                                      final value = entry.value.toDouble();
                                      return PieChartSectionData(
                                        value: value,
                                        title: '',
                                        color: getColorForCategory(entry.key),
                                        radius: 60,
                                      );
                                    }).toList(),
                                centerSpaceRadius: 35, // donut preview
                                sectionsSpace: 2,
                              ),
                              swapAnimationDuration: const Duration(
                                milliseconds: 600,
                              ),
                              swapAnimationCurve: Curves.easeOut,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }
}
