import 'package:Budget_App/view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BudgetPage extends HookConsumerWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(viewModel);

    // Make sure expense/income streams are running so expenseTotalsByCategory is always fresh
    useEffect(() {
      vm.expensesStream();
      vm.incomesStream();
      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Budgets",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<BudgetModel>>(
        stream: vm.budgetsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(child: Text('No budgets added yet.'));
          }

          final budgets = snap.data!;

          return ListView.builder(
            itemCount: budgets.length,
            itemBuilder: (context, i) {
              final b = budgets[i];

              // 🔴 LIVE spent from expenses stream (category must match budget.name)
              final int spentLive = vm.expenseTotalsByCategory[b.name] ?? 0;
              final int remaining = (b.limit - spentLive).clamp(
                -0x7fffffff,
                0x7fffffff,
              );
              final double progress =
                  b.limit == 0 ? 0 : (spentLive / b.limit).clamp(0.0, 1.0);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            b.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Optional priority/frequency badges
                          Row(
                            children: [
                              if (b.priority.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: Colors.grey.shade200,
                                  ),
                                  child: Text(
                                    b.priority,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              if (b.frequency.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: Colors.grey.shade200,
                                  ),
                                  child: Text(
                                    b.frequency,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Numbers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Limit: ₹${b.limit}'),
                          Text('Used: ₹$spentLive'),
                          Text(
                            remaining >= 0
                                ? 'Left: ₹$remaining'
                                : 'Over: ₹${remaining.abs()}',
                            style: TextStyle(
                              color: remaining < 0 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Progress
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade300,
                        color: remaining < 0 ? Colors.red : Colors.green,
                      ),
                      const SizedBox(height: 10),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed:
                                () => _showEditBudgetDialog(context, vm, b),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => vm.deleteBudget(b.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _showAddBudgetDialog(context, vm),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, ViewModel vm) {
    final key = GlobalKey<FormState>();
    final name = TextEditingController();
    final limit = TextEditingController();

    // dropdown states
    String priority = "Optional";
    String frequency = "Monthly";

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Add Budget'),
                  content: Form(
                    key: key,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: name,
                          decoration: const InputDecoration(
                            labelText: 'Category (must match Expense category)',
                          ),
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                        ),
                        TextFormField(
                          controller: limit,
                          decoration: const InputDecoration(labelText: 'Limit'),
                          keyboardType: TextInputType.number,
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                        ),
                        const SizedBox(height: 12),

                        // 🔹 Priority dropdown
                        DropdownButtonFormField<String>(
                          value: priority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                          ),
                          items:
                              ["Optional", "High", "Medium", "Low"]
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() => priority = v!),
                        ),

                        const SizedBox(height: 12),

                        // 🔹 Frequency dropdown
                        DropdownButtonFormField<String>(
                          value: frequency,
                          decoration: const InputDecoration(
                            labelText: 'Frequency',
                          ),
                          items:
                              ["Monthly", "Weekly", "Yearly"]
                                  .map(
                                    (f) => DropdownMenuItem(
                                      value: f,
                                      child: Text(f),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() => frequency = v!),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        if (!key.currentState!.validate()) return;
                        final model = BudgetModel(
                          id: '',
                          name: name.text.trim(),
                          limit: int.tryParse(limit.text.trim()) ?? 0,
                          spent: 0, // computed live
                          priority: priority,
                          frequency: frequency,
                          notes: '',
                        );
                        await vm.addBudget(model);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showEditBudgetDialog(
    BuildContext context,
    ViewModel vm,
    BudgetModel b,
  ) {
    final key = GlobalKey<FormState>();
    final limit = TextEditingController(text: b.limit.toString());

    String priority = b.priority;
    String frequency = b.frequency;

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text('Edit ${b.name}'),
                  content: Form(
                    key: key,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: limit,
                          decoration: const InputDecoration(labelText: 'Limit'),
                          keyboardType: TextInputType.number,
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          value: priority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                          ),
                          items:
                              ["Optional", "High", "Medium", "Low"]
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() => priority = v!),
                        ),

                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          value: frequency,
                          decoration: const InputDecoration(
                            labelText: 'Frequency',
                          ),
                          items:
                              ["Monthly", "Weekly", "Yearly"]
                                  .map(
                                    (f) => DropdownMenuItem(
                                      value: f,
                                      child: Text(f),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() => frequency = v!),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        if (!key.currentState!.validate()) return;
                        final updated = BudgetModel(
                          id: b.id,
                          name: b.name,
                          limit: int.tryParse(limit.text.trim()) ?? b.limit,
                          spent: b.spent,
                          priority: priority,
                          frequency: frequency,
                          notes: b.notes,
                        );
                        await vm.updateBudget(b.id, updated);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Update'),
                    ),
                  ],
                ),
          ),
    );
  }
}
