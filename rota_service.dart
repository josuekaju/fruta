import 'package:flutter/foundation.dart'; // Para kDebugMode
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart'; // Importar o pacote OpenRouteService

// IMPORTANTE: Substitua "SUA_CHAVE_DO_OPENROUTESERVICE_AQUI" pela sua chave de API real do OpenRouteService.
// Considere usar variáveis de ambiente para chaves de API em produção.
const String _OPENROUTESERVICE_API_KEY_PLACEHOLDER = "SUA_CHAVE_DO_OPENROUTESERVICE_AQUI";
const String _OPENROUTESERVICE_API_KEY = "5b3ce3597851110001cf624849119ba456b8452a8fb1341e63659d16"; // Mantenha sua chave real aqui ou use dotenv

class RotaService {
  // Instancia o cliente do OpenRouteService com sua chave de API.
  final OpenRouteService _orsClient = OpenRouteService(apiKey: _OPENROUTESERVICE_API_KEY);

  Future<List<LatLng>> obterPontosDaRota(LatLng origem, LatLng destino) async {
    // Verifica se a chave configurada ainda é o placeholder
    if (_OPENROUTESERVICE_API_KEY == _OPENROUTESERVICE_API_KEY_PLACEHOLDER && kDebugMode) {
      print(
          "AVISO RotaService: Chave da API do OpenRouteService não configurada. Retornando rota reta para depuração.");
      return [origem, destino]; // Retorna rota reta para depuração se a chave não estiver configurada
    }

    List<LatLng> rotaDecodificada = [];

    try {
      // O OpenRouteService espera uma lista de ORSCoordinate.
      List<ORSCoordinate> waypoints = [
        ORSCoordinate(latitude: origem.latitude, longitude: origem.longitude),
        ORSCoordinate(latitude: destino.latitude, longitude: destino.longitude),
      ];

      // Solicita a rota para o perfil 'foot-walking'. Outros perfis: 'driving-car', 'cycling-regular', etc.
      List<ORSCoordinate> rotaORS = await _orsClient.directionsMultiRouteCoordsPost(
        coordinates: waypoints,
        profileOverride: ORSProfile.footWalking, // Ou ORSProfile.drivingCar, etc.
      );

      if (rotaORS.isNotEmpty) {
        rotaDecodificada = rotaORS.map((p) => LatLng(p.latitude, p.longitude)).toList();
      } else {
        if (kDebugMode) {
          print("RotaService: Nenhum ponto retornado pela API do OpenRouteService.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("RotaService: Erro ao obter rota da API do OpenRouteService: $e");
      }
      // Em caso de erro ou nenhum ponto, retorna uma rota reta como fallback
      return [origem, destino];
    }

    // Se a rota decodificada estiver vazia (ex: erro silencioso da API), retorna rota reta
    return rotaDecodificada.isNotEmpty ? rotaDecodificada : [origem, destino];
  }
}