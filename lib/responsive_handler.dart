import 'package:Budget_App/mobile/expense_view_mobile.dart';
import 'package:Budget_App/mobile/login_view_mobile.dart';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'view_model.dart';

class ResponsiveHandler extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("Rebuild checker");
    final _authState = ref.watch(authStateProvider);

    return _authState.when(
      data: (data) {
        if (data != null) {
          return ExpenseViewMobile();
        }
        return LoginViewMobile();
      },
      error: (e, trace) {
        return LoginViewMobile();
      },
      loading: () => LoginViewMobile(),
    );
  }
}
