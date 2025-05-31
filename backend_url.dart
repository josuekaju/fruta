import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class BackendURL {
  static String get url {
    if (kIsWeb) {
      // Flutter Web
      return 'http://192.168.1.4:3000'; // Coloque aqui o IP do seu PC
    } else if (Platform.isAndroid) {
      // Emulador Android físico (ou dispositivo real na mesma rede)
      return 'http://192.168.1.4:3000'; // Mesmo IP do PC
    } else if (Platform.isIOS) {
      return 'http://http://192.168.1.4:3000'; // iOS 
    } else {
      // Windows/Linux/Mac (dev local)
      return 'http://localhost:3000';
    }
  }
}
