import 'package:Budget_App/utils/colors.dart';
import 'package:Budget_App/view_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenSans extends StatelessWidget {
  final String text;
  final double size;
  final Color? color;
  final FontWeight? fontWeight;

  const OpenSans({
    Key? key,
    required this.text,
    required this.size,
    this.color,
    this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.openSans(
        fontSize: size,
        color: color ?? Colors.black,
        fontWeight: fontWeight ?? FontWeight.normal,
      ),
    );
  }
}

class Poppins extends StatelessWidget {
  final String text;
  final double size;
  final Color? color;
  final FontWeight? fontWeight;

  const Poppins({
    Key? key,
    required this.text,
    required this.size,
    this.color,
    this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: size,
        color: color ?? Colors.black,
        fontWeight: fontWeight ?? FontWeight.normal,
      ),
    );
  }
}

/// IncomeExpenseRow
class IncomeExpenseRow extends StatelessWidget {
  final String text;
  final double amount;

  const IncomeExpenseRow({Key? key, required this.text, required this.amount})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade600,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.shade400.withOpacity(0.5),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Poppins(
            text: text,
            size: 16.0,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          Poppins(
            text: "${amount.toStringAsFixed(2)} \$",
            size: 16.0,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

/// IncomeExpenseRowMobile
class IncomeExpenseRowMobile extends StatelessWidget {
  final String text;
  final double amount;

  const IncomeExpenseRowMobile({
    Key? key,
    required this.text,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade600,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.shade400.withOpacity(0.5),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "${amount.toStringAsFixed(2)} \$",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// AddExpense
class AddExpense extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelProvider = ref.watch(viewModel);
    return FittedBox(
      child: ElevatedButton.icon(
        icon: Icon(Icons.remove_circle_outline, color: Colors.white),
        label: Poppins(text: "Add Expense", size: 16.0, color: Colors.white),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          backgroundColor: Colors.deepPurple.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 6,
          shadowColor: Colors.deepPurple.shade300,
        ),
        onPressed: () async {
          await viewModelProvider.addExpense(context);
        },
      ),
    );
  }
}

/// AddIncome
class AddIncome extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelProvider = ref.watch(viewModel);
    return FittedBox(
      child: ElevatedButton.icon(
        icon: Icon(Icons.add_circle_outline, color: Colors.white),
        label: Poppins(text: "Add Income", size: 16.0, color: Colors.white),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          backgroundColor: Colors.green.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 6,
          shadowColor: Colors.green.shade300,
        ),
        onPressed: () async {
          await viewModelProvider.addIncome(context);
        },
      ),
    );
  }
}

/// TotalCalculation
class TotalCalculation extends HookConsumerWidget {
  final double size;
  TotalCalculation(this.size);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelProvider = ref.watch(viewModel);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRow(
          "Budget Left",
          "${viewModelProvider.budgetLeft}\$",
          size,
          Colors.black,
        ),
        _buildRow(
          "Total Expense",
          "${viewModelProvider.totalExpense}\$",
          size,
          Colors.redAccent,
        ),
        _buildRow(
          "Total Income",
          "${viewModelProvider.totalIncome}\$",
          size,
          const Color.fromARGB(255, 13, 153, 85),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String amount, double size, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Poppins(
            text: label,
            size: size,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
          Poppins(
            text: amount,
            size: size,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}

/// DrawerExpense
class DrawerExpense extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelProvider = ref.watch(viewModel);
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              padding: const EdgeInsets.only(bottom: 10.0),
              decoration: BoxDecoration(color: Colors.deepPurple.shade100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 3.0,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Image.asset('assets/logo.png', height: 60),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Budget Buddy",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  elevation: 8,
                  shadowColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: OpenSans(
                  text: "Logout",
                  size: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                onPressed: () async {
                  await viewModelProvider.logout();
                },
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: "Instagram",
                    onPressed:
                        () async => await launchUrl(
                          Uri.parse("https://www.instagram.com/tomcruise"),
                        ),
                    icon: SvgPicture.asset(
                      "assets/instagram.svg",
                      colorFilter: const ColorFilter.mode(
                        Colors.deepPurple,
                        BlendMode.srcIn,
                      ),
                      width: 36,
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    tooltip: "Twitter",
                    onPressed:
                        () async => await launchUrl(
                          Uri.parse("https://www.twitter.com/tomcruise"),
                        ),
                    icon: SvgPicture.asset(
                      "assets/twitter.svg",
                      colorFilter: const ColorFilter.mode(
                        Colors.deepPurple,
                        BlendMode.srcIn,
                      ),
                      width: 36,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// DialogBox
DialogBox(BuildContext context, String title) {
  return showDialog<void>(
    context: context,
    builder:
        (BuildContext context) => AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          contentPadding: EdgeInsets.all(32.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(width: 2.0, color: Colors.black),
          ),
          title: OpenSans(text: title, size: 20.0),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              color: Colors.black,
              child: OpenSans(text: "Okay", size: 20.0, color: Colors.white),
            ),
          ],
        ),
  );
}

/// TextForm
class TextForm extends StatelessWidget {
  final String text;
  final double containerWidth;
  final String hintText;
  final TextEditingController controller;
  final bool? digitsOnly;
  final validator;

  const TextForm({
    Key? key,
    required this.text,
    required this.containerWidth,
    required this.hintText,
    required this.controller,
    this.digitsOnly,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OpenSans(size: 13.0, text: text),
        SizedBox(height: 5.0),
        SizedBox(
          width: containerWidth,
          child: TextFormField(
            validator: validator,
            inputFormatters:
                digitsOnly != null
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : [],
            controller: controller,
            decoration: InputDecoration(
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.tealAccent, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(fontSize: 13.0),
            ),
          ),
        ),
      ],
    );
  }
}

/// FullPieChartPage
class FullPieChartPage extends StatefulWidget {
  final ViewModel vm;

  const FullPieChartPage({Key? key, required this.vm}) : super(key: key);

  @override
  State<FullPieChartPage> createState() => _FullPieChartPageState();
}

class _FullPieChartPageState extends State<FullPieChartPage> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final entries = widget.vm.expenseTotalsByCategory.entries.toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    return Scaffold(
      appBar: AppBar(
        title: const Poppins(
          text: "Expense Breakdown",
          size: 24,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          /// Donut Chart
          Expanded(
            child: PieChart(
              PieChartData(
                sections: List.generate(entries.length, (index) {
                  final entry = entries[index];
                  final value = entry.value.toDouble();
                  final percent = (value / total * 100).toStringAsFixed(1);
                  final isTouched = index == touchedIndex;

                  return PieChartSectionData(
                    value: value,
                    title: "$percent%",
                    color: getColorForCategory(entry.key),
                    radius: isTouched ? 140 : 120,
                    titleStyle: TextStyle(
                      fontSize: isTouched ? 18 : 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 4),
                      ],
                    ),
                  );
                }),
                sectionsSpace: 4,
                centerSpaceRadius: 70,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      setState(() => touchedIndex = null);
                      return;
                    }
                    setState(
                      () =>
                          touchedIndex =
                              response.touchedSection!.touchedSectionIndex,
                    );
                  },
                ),
              ),
              swapAnimationDuration: const Duration(milliseconds: 800),
              swapAnimationCurve: Curves.easeOutQuint,
            ),
          ),

          const SizedBox(height: 20),

          /// Legends
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children:
                entries.map((entry) {
                  final percent = (entry.value / total * 100).toStringAsFixed(
                    1,
                  );
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: getColorForCategory(entry.key),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${entry.key} - ${entry.value}\$ ($percent%)",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
