import 'package:calculadora_financiera/repositories/database_helper.dart';
import 'package:calculadora_financiera/views/operation_list.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa la base de datos
  await DatabaseHelper.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Financiera',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(color: Colors.lightBlue),
      ),
      home: const OperationListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
