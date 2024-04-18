import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/shared/repositories/firebridge/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
  ));

  await GetStorage.init();
  runApp(const ProviderScope(child: NavigatorWidget()));
}

class NavigatorWidget extends StatefulWidget {
  const NavigatorWidget({super.key});

  @override
  State<NavigatorWidget> createState() => _NavigatorWidgetState();
}

class _NavigatorWidgetState extends State<NavigatorWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _buildInitialRouteWidget(),
    );
  }

  Widget _buildInitialRouteWidget() {
    return const AuthWidgetTest();
  }
}

class AuthWidgetTest extends ConsumerStatefulWidget {
  const AuthWidgetTest({super.key});

  @override
  _AuthWidgetTestState createState() => _AuthWidgetTestState();
}

class _AuthWidgetTestState extends ConsumerState<AuthWidgetTest> {
  @override
  Widget build(BuildContext context) {
    var bruh = ref.watch(authProvider("bob", "password"));
    print(bruh.valueOrNull is AuthSuccess);

    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              print(bruh);
            },
            child: const Text("asd")),
      ),
    );
  }
}
