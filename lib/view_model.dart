import 'package:Budget_App/components.dart';
import 'package:Budget_App/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

/// Providers
final viewModel = ChangeNotifierProvider.autoDispose<ViewModel>(
  (ref) => ViewModel(),
);

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.read(viewModel).authStateChange,
);
final _auth = FirebaseAuth.instance;
CollectionReference userCollection = FirebaseFirestore.instance.collection(
  'users',
);

/// ViewModel
class ViewModel extends ChangeNotifier {
  /// Firebase & Google
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn.instance;

  final notificationsProvider = StateProvider<bool>((ref) => true);
  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  /// Logger
  final Logger logger = Logger();

  /// Firestore collection
  CollectionReference userCollection = FirebaseFirestore.instance.collection(
    'users',
  );

  /// State
  List<Models> expenses = [];
  List<Models> incomes = [];
  bool isObscure = true; // For password field
  bool isBalanceHidden = false; // 👈 For privacy toggle

  int totalExpense = 0;
  int totalIncome = 0;
  int budgetLeft = 0;

  /// Name & Amount lists
  List<String> incomesName = [];
  List<String> incomesAmount = [];
  List<String> expensesName = [];
  List<String> expensesAmount = [];

  /// Categories
  String selectedIncomeCategory = 'Salary';
  String selectedExpenseCategory = 'Food';

  List<String> incomeCategories = [
    'Salary',
    'Bonus',
    'Investment',
    'Gift',
    'Other',
  ];

  List<String> expenseCategories = [
    'Food',
    'Rent',
    'Shopping',
    'Bills',
    'Other',
  ];

  /// Totals by category
  Map<String, int> expenseTotalsByCategory = {};
  Map<String, int> incomeTotalsByCategory = {};

  List<Map<String, dynamic>> get transactions {
    final List<Map<String, dynamic>> all = [];

    for (var e in expenses) {
      all.add({
        "title": e.name,
        "amount": -(int.tryParse(e.amount) ?? 0), // negative for expenses
        "date": e.date ?? "",
        "category": e.category,
      });
    }

    for (var i in incomes) {
      all.add({
        "title": i.name,
        "amount": int.tryParse(i.amount) ?? 0,
        "date": i.date ?? "",
        "category": i.category,
      });
    }

    all.sort((a, b) => b["date"].compareTo(a["date"]));
    return all;
  }

  /// ==================== REPORT HELPERS ====================
  Map<String, int> get incomeVsExpense => {
    "Income": totalIncome,
    "Expense": totalExpense,
  };

  List<Map<String, dynamic>> get expenseReportData {
    return expenseTotalsByCategory.entries.map((e) {
      return {"category": e.key, "amount": e.value};
    }).toList();
  }

  List<Map<String, dynamic>> get incomeReportData {
    return incomeTotalsByCategory.entries.map((e) {
      return {"category": e.key, "amount": e.value};
    }).toList();
  }

  List<Map<String, dynamic>> get dailyReportData {
    final Map<String, int> dailyTotals = {};

    for (var t in transactions) {
      final date = (t["date"] as String).split("T").first;
      dailyTotals[date] = (dailyTotals[date] ?? 0) + t["amount"] as int;
    }

    final list =
        dailyTotals.entries.map((e) {
          return {"date": e.key, "amount": e.value};
        }).toList();

    list.sort((a, b) => (a["date"] as String).compareTo(b["date"] as String));
    return list;
  }

  /// ==================== AUTH ====================
  Stream<User?> get authStateChange => _auth.authStateChanges();

  Future<void> logout() async => await _auth.signOut();

  /// ==================== TOGGLES ====================
  void toggleObscure() {
    isObscure = !isObscure;
    notifyListeners();
  }

  void togglePrivacy() {
    isBalanceHidden = !isBalanceHidden;
    notifyListeners();
  }

  // budget//
  List<BudgetModel> budgets = [];

  /// ==================== CALCULATIONS ====================

  void calculate() {
    totalExpense = 0;
    totalIncome = 0;

    for (final e in expenses) {
      totalExpense += int.tryParse(e.amount) ?? 0;
    }
    for (final i in incomes) {
      totalIncome += int.tryParse(i.amount) ?? 0;
    }

    budgetLeft = totalIncome - totalExpense;
    notifyListeners();
  }

  void calculateCategoryTotals() {
    expenseTotalsByCategory = {};
    incomeTotalsByCategory = {};

    for (var expense in expenses) {
      final category = expense.category;
      final amount = int.tryParse(expense.amount) ?? 0;
      expenseTotalsByCategory[category] =
          (expenseTotalsByCategory[category] ?? 0) + amount;
    }

    for (var income in incomes) {
      final category = income.category;
      final amount = int.tryParse(income.amount) ?? 0;
      incomeTotalsByCategory[category] =
          (incomeTotalsByCategory[category] ?? 0) + amount;
    }

    notifyListeners();
  }

  /// Email registration
  Future<void> createUserWithEmailAndPassword(
    BuildContext context,
    String email,
    String password, {
    VoidCallback? onSuccess,
  }) async {
    // ✅ Validation first
    if (email.isEmpty || password.isEmpty) {
      DialogBox(context, "Please enter both email and password");
      return;
    }
    if (password.length < 6) {
      DialogBox(context, "Password must be at least 6 characters");
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      logger.d("Registration successful");
      if (onSuccess != null) onSuccess();
    } on FirebaseAuthException catch (e) {
      DialogBox(context, e.message ?? "Registration failed");
    }
  }

  Future<void> signInWithEmailAndPassword(
    BuildContext context,
    String email,
    String password, {
    VoidCallback? onSuccess,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      DialogBox(context, "Please enter both email and password");
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      logger.d("Signed in successfully");
      if (onSuccess != null) onSuccess();
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        DialogBox(context, "No account found. Please register first.");
      } else if (e.code == "wrong-password") {
        DialogBox(context, "Incorrect password. Try again.");
      } else {
        DialogBox(context, e.message ?? "Login failed");
      }
    }
  }

  /// Google sign-in (Mobile)
  Future<void> signInWithGoogleMobile(
    BuildContext context, {
    VoidCallback? onSuccess,
  }) async {
    try {
      final account = await _google.authenticate(scopeHint: const ['email']);
      final idToken = account.authentication.idToken;

      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'NO_ID_TOKEN',
          message: 'Failed to retrieve Google ID token.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      logger.d('Signed in successfully: $userCredential');
      if (onSuccess != null) onSuccess();
    } catch (error) {
      logger.d(error);
      DialogBox(context, error.toString().replaceAll(RegExp(r'\[.*?\]'), ''));
    }
  }

  /// Add expense
  Future addExpense(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final controllerName = TextEditingController();
    final controllerAmount = TextEditingController();

    return await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                actionsAlignment: MainAxisAlignment.center,
                contentPadding: const EdgeInsets.all(32.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: const BorderSide(width: 1.0, color: Colors.black),
                ),
                title: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          TextForm(
                            text: "Name",
                            containerWidth: 130.0,
                            hintText: "Name",
                            controller: controllerName,
                            validator:
                                (text) =>
                                    text.toString().isEmpty
                                        ? "Required."
                                        : null,
                          ),
                          const SizedBox(width: 10.0),
                          TextForm(
                            text: "Amount",
                            containerWidth: 100.0,
                            hintText: "Amount",
                            controller: controllerAmount,
                            digitsOnly: true,
                            validator:
                                (text) =>
                                    text.toString().isEmpty
                                        ? "Required."
                                        : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: selectedExpenseCategory,
                        decoration: const InputDecoration(
                          labelText: "Category",
                        ),
                        items:
                            expenseCategories.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedExpenseCategory = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  MaterialButton(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const OpenSans(
                      text: "Save",
                      size: 15.0,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final int amount =
                            int.tryParse(controllerAmount.text.trim()) ?? 0;

                        // Add expense to Firestore
                        await userCollection
                            .doc(_auth.currentUser!.uid)
                            .collection("expenses")
                            .add({
                              "name": controllerName.text.trim(),
                              "amount": controllerAmount.text.trim(),
                              "category": selectedExpenseCategory,
                              "date": DateTime.now().toIso8601String(),
                            })
                            .then((value) {
                              logger.d("Expense added");
                            })
                            .onError((error, stackTrace) {
                              logger.d("add expense error = $error");
                              return DialogBox(context, error.toString());
                            });

                        // ✅ Update budget spent for this category
                        await incrementBudgetSpent(
                          selectedExpenseCategory,
                          amount,
                        );

                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              );
            },
          ),
    );
  }

  /// Add income
  Future addIncome(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final controllerName = TextEditingController();
    final controllerAmount = TextEditingController();

    return await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                actionsAlignment: MainAxisAlignment.center,
                contentPadding: const EdgeInsets.all(32.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: const BorderSide(width: 1.0, color: Colors.black),
                ),
                title: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          TextForm(
                            text: "Name",
                            containerWidth: 130.0,
                            hintText: "Name",
                            controller: controllerName,
                            validator:
                                (text) =>
                                    text.toString().isEmpty
                                        ? "Required."
                                        : null,
                          ),
                          const SizedBox(width: 10.0),
                          TextForm(
                            text: "Amount",
                            containerWidth: 100.0,
                            hintText: "Amount",
                            controller: controllerAmount,
                            digitsOnly: true,
                            validator:
                                (text) =>
                                    text.toString().isEmpty
                                        ? "Required."
                                        : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: selectedIncomeCategory,
                        decoration: const InputDecoration(
                          labelText: "Category",
                        ),
                        items:
                            incomeCategories.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedIncomeCategory = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  MaterialButton(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const OpenSans(
                      text: "Save",
                      size: 15.0,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await userCollection
                            .doc(_auth.currentUser!.uid)
                            .collection("incomes")
                            .add({
                              "name": controllerName.text.trim(),
                              "amount": controllerAmount.text.trim(),
                              "category": selectedIncomeCategory,
                              "date": DateTime.now().toIso8601String(),
                            })
                            .then((value) {
                              logger.d("Income added");
                            })
                            .onError((error, stackTrace) {
                              logger.d("add income error = $error");
                              return DialogBox(context, error.toString());
                            });
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              );
            },
          ),
    );
  }

  /// Expense Stream
  void expensesStream() async {
    await for (var snapshot
        in FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('expenses')
            .snapshots()) {
      expenses = [];
      snapshot.docs.forEach((element) {
        expenses.add(Models.fromJson(element.data()));
      });
      logger.d("Expense Models ${expenses.length}");
      notifyListeners();

      expensesAmount = [];
      expensesName = [];

      for (var expense in snapshot.docs) {
        expensesName.add(expense.data()['name']);
        expensesAmount.add(expense.data()['amount']);
        logger.d(expensesName, error: expensesAmount);
        notifyListeners();
      }
      calculate();
      calculateCategoryTotals(); // NEW
    }
  }

  /// Income Stream
  void incomesStream() async {
    await for (var snapshot
        in FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('incomes')
            .snapshots()) {
      incomes = [];
      snapshot.docs.forEach((element) {
        incomes.add(Models.fromJson(element.data()));
      });
      notifyListeners();

      incomesAmount = [];
      incomesName = [];

      for (var income in snapshot.docs) {
        incomesName.add(income.data()['name']);
        incomesAmount.add(income.data()['amount']);
        logger.d(incomesName, error: incomesAmount);
        notifyListeners();
      }
      calculate();
      calculateCategoryTotals(); // NEW
    }
  }

  /// Reset all data
  Future<void> reset() async {
    await userCollection
        .doc(_auth.currentUser!.uid)
        .collection("expenses")
        .get()
        .then((snapshot) {
          for (DocumentSnapshot ds in snapshot.docs) {
            ds.reference.delete();
          }
        });

    await userCollection
        .doc(_auth.currentUser!.uid)
        .collection("incomes")
        .get()
        .then((snapshot) {
          for (DocumentSnapshot ds in snapshot.docs) {
            ds.reference.delete();
          }
        });
  }

  /// ==================== SETTINGS ====================

  /// Change display name
  Future<void> updateDisplayName(BuildContext context, String newName) async {
    try {
      await _auth.currentUser!.updateDisplayName(newName);
      await userCollection.doc(_auth.currentUser!.uid).set({
        "displayName": newName,
      }, SetOptions(merge: true));
      notifyListeners();
      DialogBox(context, "Name updated successfully!");
    } catch (e) {
      logger.e("Name update error: $e");
      DialogBox(context, e.toString());
    }
  }

  /// Backup user data to Firestore
  Future<void> backupData(BuildContext context) async {
    try {
      await userCollection.doc(_auth.currentUser!.uid).set({
        "backup": {
          "expenses": expenses.map((e) => e.toJson()).toList(),
          "incomes": incomes.map((i) => i.toJson()).toList(),
          "timestamp": DateTime.now().toIso8601String(),
        },
      }, SetOptions(merge: true));
      DialogBox(context, "Backup successful!");
    } catch (e) {
      logger.e("Backup error: $e");
      DialogBox(context, "Backup failed: $e");
    }
  }

  /// Restore user data from Firestore
  /// Restore user data from Firestore
  Future<void> restoreData(BuildContext context) async {
    try {
      final doc = await userCollection.doc(_auth.currentUser!.uid).get();
      final data = doc.data(); // Map<String, dynamic>?
      if (data == null) {
        DialogBox(context, "No data found.");
        return;
      }

      // ✅ Cast backup safely
      final backup =
          (data as Map<String, dynamic>)["backup"] as Map<String, dynamic>?;

      if (backup != null) {
        // ✅ Explicitly cast to List<Map<String, dynamic>>
        final expensesList =
            (backup["expenses"] as List<dynamic>? ?? [])
                .map(
                  (e) => Models.fromJson(Map<String, dynamic>.from(e as Map)),
                )
                .toList();

        final incomesList =
            (backup["incomes"] as List<dynamic>? ?? [])
                .map(
                  (i) => Models.fromJson(Map<String, dynamic>.from(i as Map)),
                )
                .toList();

        expenses = expensesList;
        incomes = incomesList;

        calculate();
        calculateCategoryTotals();
        notifyListeners();

        DialogBox(context, "✅ Restore successful!");
      } else {
        DialogBox(context, "⚠️ No backup found.");
      }
    } catch (e) {
      logger.e("Restore error: $e");
      DialogBox(context, "❌ Restore failed: $e");
    }
  }

  /// For charts – cleaner alias
  Map<String, double> get expensesByCategory {
    return expenseTotalsByCategory.map(
      (key, value) => MapEntry(key, value.toDouble()),
    );
  }

  Map<String, double> get incomesByCategory {
    return incomeTotalsByCategory.map(
      (key, value) => MapEntry(key, value.toDouble()),
    );
  }
}

/// ==================== BUDGETS ====================

/// ==================== BUDGETS ====================

class BudgetModel {
  final String id;
  final String name;
  final int limit;
  final int spent;
  final String priority;
  final String frequency;
  final String notes;

  BudgetModel({
    required this.id,
    required this.name,
    required this.limit,
    required this.spent,
    required this.priority,
    required this.frequency,
    required this.notes,
  });

  factory BudgetModel.fromJson(String id, Map<String, dynamic> json) {
    return BudgetModel(
      id: id,
      name: json['name'] ?? '',
      limit: json['limit'] ?? 0,
      spent: json['spent'] ?? 0,
      priority: json['priority'] ?? 'Optional',
      frequency: json['frequency'] ?? 'Monthly',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "limit": limit,
      "spent": spent,
      "priority": priority,
      "frequency": frequency,
      "notes": notes,
    };
  }
}

/// ==================== BUDGET FUNCTIONS IN VIEWMODEL ====================

extension BudgetFunctions on ViewModel {
  Stream<List<BudgetModel>> budgetsStream() {
    final uid = _auth.currentUser!.uid;
    return userCollection
        .doc(uid)
        .collection("budgets")
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => BudgetModel.fromJson(doc.id, doc.data()))
                  .toList(),
        );
  }

  Future<void> addBudget(BudgetModel budget) async {
    final uid = _auth.currentUser!.uid;
    await userCollection.doc(uid).collection("budgets").add(budget.toJson());
  }

  Future<void> updateBudget(String docId, BudgetModel budget) async {
    final uid = _auth.currentUser!.uid;
    await userCollection
        .doc(uid)
        .collection("budgets")
        .doc(docId)
        .update(budget.toJson());
  }

  Future<void> deleteBudget(String docId) async {
    final uid = _auth.currentUser!.uid;
    await userCollection.doc(uid).collection("budgets").doc(docId).delete();
  }

  Future<void> incrementBudgetSpent(String category, int amount) async {
    final uid = _auth.currentUser!.uid;
    final query =
        await userCollection
            .doc(uid)
            .collection("budgets")
            .where("name", isEqualTo: category)
            .get();

    for (var doc in query.docs) {
      final currentSpent = doc.data()['spent'] ?? 0;
      await doc.reference.update({"spent": currentSpent + amount});
    }
  }

  Future<void> resetBudgets() async {
    final uid = _auth.currentUser!.uid;
    final snapshot = await userCollection.doc(uid).collection("budgets").get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
