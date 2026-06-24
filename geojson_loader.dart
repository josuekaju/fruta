import 'dart:convert';
import 'package:flutter/foundation.dart'; // Para compute
import 'package:flutter/services.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:latlong2/latlong.dart';

import '../models/arvore.dart';


// Estrutura de dados para retornar do Isolate
class ProcessedArvoresData {
  final List<Arvore> todas;
  final List<Arvore> catalogadas;
  final List<Arvore> frutiferas;
  final List<Arvore> flores;
  final List<Arvore> naoCatalogadas;
  final Map<String, List<Arvore>> recordistasPorCategoria;

  ProcessedArvoresData({
    required this.todas,
    required this.catalogadas,
    required this.frutiferas,
    required this.flores,
    required this.naoCatalogadas,
    required this.recordistasPorCategoria,
  });
}

// Função que será executada no Isolate
ProcessedArvoresData _parseAndProcessGeoJson(String geoJsonData) {
  print('[Isolate] Iniciando parse e processamento do GeoJSON...');
  final geoJson = GeoJSONFeatureCollection.fromJSON(geoJsonData);
  print('[Isolate] GeoJSON parseado. Features: ${geoJson.features.length}');

  final List<Arvore> todasArvores = geoJson.features
      .where((f) => f?.geometry is GeoJSONPoint)
      .map((f) => Arvore.fromGeoJson(f!))
      .toList();
  print('[Isolate] Objetos Arvore criados: ${todasArvores.length}');

  final List<Arvore> frutiferas = todasArvores.where((a) => a.tipoEspe0).toList();
  final List<Arvore> flores = todasArvores.where((a) => a.tipoEspe1).toList();
  final List<Arvore> naoCatalogadas = todasArvores.where((a) => a.tipoEspec == 0).toList();
  final List<Arvore> catalogadas = todasArvores.where((a) => a.tipoEspec != 0).toList();

  final Map<String, List<Arvore>> recordistas = {};
  if (todasArvores.isNotEmpty) {
    recordistas['altura'] = _topNIsolate(todasArvores, (a) => a.altura);
    recordistas['idade'] = _topNIsolate(todasArvores, (a) => a.idadeAproximada.toDouble());
    recordistas['circunfere'] = _topNIsolate(todasArvores, (a) => a.circunfere);
    recordistas['diametro'] = _topNIsolate(todasArvores, (a) => a.diametroE);
    recordistas['dap'] = _topNIsolate(todasArvores, (a) => a.dap);
  }
  print('[Isolate] Recordistas calculados.');

  return ProcessedArvoresData(
    todas: todasArvores,
    catalogadas: catalogadas,
    frutiferas: frutiferas,
    flores: flores,
    naoCatalogadas: naoCatalogadas,
    recordistasPorCategoria: recordistas,
  );
}

List<Arvore> _topNIsolate(List<Arvore> lista, double Function(Arvore) key) {
  final validas = lista.where((a) => key(a) > 0).toList();
  validas.sort((a, b) => key(b).compareTo(key(a)));
  return validas.take(10).toList();
}

class CidadeInfo {
  final String nome;
  final String assetPath;
  final LatLng centro;
  final double zoomInicial;

  const CidadeInfo({
    required this.nome,
    required this.assetPath,
    required this.centro,
    this.zoomInicial = 12.5,
  });
}

enum CidadeDisponivel {
  toledo,
  palotina,
}

final Map<CidadeDisponivel, CidadeInfo> cidadesInfo = {
  CidadeDisponivel.toledo: CidadeInfo(
    nome: 'Toledo',
    assetPath: 'assets/arvore_toledo.geojson',
    centro: LatLng(-24.7136, -53.7406), // Coordenadas do centro de Toledo
    zoomInicial: 12.5,
  ),
  CidadeDisponivel.palotina: CidadeInfo(
    nome: 'Palotina',
    assetPath: 'assets/arvore_palotina.geojson',
    centro: LatLng(-24.2838, -53.8394), // Coordenadas do centro de Palotina
    zoomInicial: 12.5,
  ),
};

class GeoJsonLoader {
  static Future<List<Arvore>> carregarArvores(CidadeDisponivel cidade) async {
    final cidadeInfo = cidadesInfo[cidade];
    if (cidadeInfo == null) throw Exception("Cidade não encontrada");

    print('Carregando arquivo GeoJSON de ${cidadeInfo.nome}...');
    final data = await rootBundle.loadString(cidadeInfo.assetPath);

    final geoJson = GeoJSONFeatureCollection.fromJSON(data);
    return geoJson.features
        .where((f) => f?.geometry is GeoJSONPoint)
        .map((f) => Arvore.fromGeoJson(f!))
        .toList();
  }

  static Future<ProcessedArvoresData> carregarEProcessarArvores({CidadeDisponivel cidade = CidadeDisponivel.toledo}) async {
    final cidadeInfo = cidadesInfo[cidade];
    if (cidadeInfo == null) throw Exception("Cidade não encontrada");
    
    print('Carregando e processando arquivo GeoJSON de ${cidadeInfo.nome}...');
    final String geoJsonString = await rootBundle.loadString(cidadeInfo.assetPath);
    return await compute(_parseAndProcessGeoJson, geoJsonString);
  }
}




