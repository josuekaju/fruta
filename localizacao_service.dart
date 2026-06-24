import 'package:geolocator/geolocator.dart';

class LocalizacaoService {
  /// Obtém a localização atual do usuário com tratamento de erro
  static Future<Position?> obterLocalizacao() async {
    try {
      final status = await Geolocator.checkPermission();
      if (status == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('📍 Localização obtida: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Erro ao obter localização: $e');
      return null;
    }
  }
}
