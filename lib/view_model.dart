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

/// ViewModel
class ViewModel extends ChangeNotifier {
  /// Firebase & Google
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn.instance;

  /// Logger
  final Logger logger = Logger();

  /// Firestore collection
  CollectionReference userCollection = FirebaseFirestore.instance.collection(
    'users',
  );

  /// State
  List<Models> expenses = [];
  List<Models> incomes = [];
  bool isObscure = true;

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

  /// Auth stream
  Stream<User?> get authStateChange => _auth.authStateChanges();

  /// Logout
  Future<void> logout() async => await _auth.signOut();

  /// Toggle password visibility
  void toggleObscure() {
    isObscure = !isObscure;
    notifyListeners();
  }

  /// Total calculation
  void calculate() {
    totalExpense = 0;
    totalIncome = 0;

    for (final e in expenses) {
      totalExpense += int.parse(e.amount);
    }
    for (final i in incomes) {
      totalIncome += int.parse(i.amount);
    }

    budgetLeft = totalIncome - totalExpense;
    notifyListeners();
  }

  /// Totals per category
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
    String password,
  ) async {
    await _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) => logger.d("Login successful"))
        .onError((error, stackTrace) {
          logger.d(error);
          DialogBox(
            context,
            error.toString().replaceAll(RegExp('\\[.*?\\]'), ''),
          );
        });
  }

  /// Email login
  Future<void> signInWithEmailAndPassword(
    BuildContext context,
    String email,
    String password,
  ) async {
    await _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) => logger.d("Login successful"))
        .onError((error, stackTrace) {
          logger.d(error);
          DialogBox(
            context,
            error.toString().replaceAll(RegExp('\\[.*?\\]'), ''),
          );
        });
  }

  /// Google sign-in (Web)
  Future<void> signInWithGoogleWeb(BuildContext context) async {
    final googleProvider = GoogleAuthProvider();
    await _auth
        .signInWithPopup(googleProvider)
        .then((_) {
          logger.d(
            'Current user UID present? ${_auth.currentUser?.uid.isNotEmpty ?? false}',
          );
        })
        .onError((error, stackTrace) {
          logger.d(error);
          return DialogBox(
            context,
            error.toString().replaceAll(RegExp(r'\[.*?\]'), ''),
          );
        });
  }

  /// Google sign-in (Mobile)
  Future<void> signInWithGoogleMobile(BuildContext context) async {
    final GoogleSignInAccount account = await _google
        .authenticate(scopeHint: const ['email'])
        .onError((error, stackTrace) {
          logger.d(error);
          DialogBox(
            context,
            error.toString().replaceAll(RegExp(r'\[.*?\]'), ''),
          );
          throw error!;
        });

    final String? idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);

    await _auth
        .signInWithCredential(credential)
        .then((value) {
          logger.e('Signed in successfully $value');
        })
        .onError((error, stackTrace) {
          logger.d(error);
          DialogBox(
            context,
            error.toString().replaceAll(RegExp(r'\[.*?\]'), ''),
          );
        });
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
                        await userCollection
                            .doc(_auth.currentUser!.uid)
                            .collection("expenses")
                            .add({
                              "name": controllerName.text,
                              "amount": controllerAmount.text,
                              "category": selectedExpenseCategory,
                            })
                            .onError((error, stackTrace) {
                              logger.d("add expense error = $error");
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
                              "name": controllerName.text,
                              "amount": controllerAmount.text,
                              "category": selectedIncomeCategory,
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
}
