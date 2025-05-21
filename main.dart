import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Adicionar este import

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
    return 
    MaterialApp( // A indentação aqui estava um pouco estranha, corrigi.
      title: 'Fruta no Pé', // Adicionar um título é uma boa prática
      home: const HomePage(), // Adicionar a HomePage aqui
      localizationsDelegates: const [ // Adicionar const
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate, // É bom incluir para widgets no estilo iOS
  ],
      supportedLocales: const [Locale('pt', 'BR')],
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0), // Mantém o textScaler
          ),
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontFamily: 'Roboto', // Definido aqui, mas pode ser melhor no ThemeData
              fontSize: 16,
              color: Colors.black87,
            ),
            child: child!,
          ),
        );
      },
      // Considere definir o tema aqui também para consistência
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto', // Definir a fonte padrão aqui é mais comum
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}