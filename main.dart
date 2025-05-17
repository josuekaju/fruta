import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  print('Iniciando aplicação...');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruta no Pé',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomePage(),
    );
  }
}
