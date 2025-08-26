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
    final vm = ref.watch(viewModel);

    if (isLoading) {
      vm.expensesStream();
      vm.incomesStream();
      isLoading = false;
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        drawer: DrawerExpense(),
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white, size: 26),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          title: const Poppins(
            text: "Dashboard",
            size: 20.0,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          actions: [
            IconButton(
              tooltip: "Refresh Data",
              onPressed: () async => await vm.reset(),
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
          ],
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  children: [
                    /// ==== Total Summary Card ====
                    Center(
                      child: Container(
                        width: screenWidth * 0.9,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(255, 104, 47, 177),
                              Color.fromARGB(255, 190, 134, 243),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TotalCalculation(18.0),
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// ==== Add Buttons ====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AddExpense(),
                        const SizedBox(width: 14),
                        AddIncome(),
                      ],
                    ),

                    const SizedBox(height: 32),

                    /// ==== Expense / Income Cards ====
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildCardSection(
                            context: context,
                            title: "Expenses",
                            icon: Icons.arrow_upward,
                            iconColor: Colors.redAccent,
                            items:
                                vm.expenses
                                    .map(
                                      (e) => IncomeExpenseRowMobile(
                                        text: e.name,
                                        amount: double.tryParse(e.amount) ?? 0,
                                        isExpense: true,
                                      ),
                                    )
                                    .toList(),
                            onViewAll:
                                () => _showAllBottomSheet(
                                  context,
                                  "All Expenses",
                                  vm.expenses
                                      .map(
                                        (e) => IncomeExpenseRowMobile(
                                          text: e.name,
                                          amount:
                                              double.tryParse(e.amount) ?? 0,
                                          isExpense: true,
                                        ),
                                      )
                                      .toList(),
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCardSection(
                            context: context,
                            title: "Incomes",
                            icon: Icons.arrow_downward,
                            iconColor: Colors.green,
                            items:
                                vm.incomes
                                    .map(
                                      (i) => IncomeExpenseRowMobile(
                                        text: i.name,
                                        amount: double.tryParse(i.amount) ?? 0,
                                        isExpense: false,
                                      ),
                                    )
                                    .toList(),
                            onViewAll:
                                () => _showAllBottomSheet(
                                  context,
                                  "All Incomes",
                                  vm.incomes
                                      .map(
                                        (i) => IncomeExpenseRowMobile(
                                          text: i.name,
                                          amount:
                                              double.tryParse(i.amount) ?? 0,
                                          isExpense: false,
                                        ),
                                      )
                                      .toList(),
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    /// ==== Category Expense + Pie Chart ====
                    _buildCategoryChart(vm, context),
                  ],
                ),
      ),
    );
  }

  /// ==== Modern Card Section with "View All" BELOW ====
  Widget _buildCardSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> items,
    required VoidCallback onViewAll,
  }) {
    return Container(
      height: 220, // 🔥 Equal height for both Expense & Income cards
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title + Icon
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Poppins(
                text: title,
                size: 16.0,
                color: Colors.grey.shade900,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// View All (below, right aligned)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                "View All",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.indigo,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// Show only first 3 items
          Expanded(
            child:
                items.isNotEmpty
                    ? ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: items.take(3).toList(),
                    )
                    : Center(
                      child: Poppins(
                        text: "No records found",
                        size: 14.0,
                        color: Colors.grey,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  /// ==== Bottom Sheet for "View All" ====
  void _showAllBottomSheet(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Poppins(
                        text: title,
                        size: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),

                  /// Full List
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: items.length,
                      itemBuilder: (context, index) => items[index],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// ==== Category Chart Section ====
  Widget _buildCategoryChart(ViewModel vm, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.category, color: Colors.indigo, size: 20),
              const SizedBox(width: 8),
              Poppins(
                text: "Expense by Category",
                size: 16.0,
                color: Colors.grey.shade900,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...vm.expenseTotalsByCategory.entries.map(
            (entry) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Poppins(
                text: entry.key,
                size: 15.0,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
              trailing: Poppins(
                text: "${entry.value}\$",
                size: 15.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Center(
            child: SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections:
                      vm.expenseTotalsByCategory.entries.map((entry) {
                        return PieChartSectionData(
                          value: entry.value.toDouble(),
                          title: '',
                          color: getColorForCategory(entry.key),
                          radius: 65,
                        );
                      }).toList(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 3,
                ),
                swapAnimationDuration: const Duration(milliseconds: 700),
                swapAnimationCurve: Curves.easeOutQuint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
