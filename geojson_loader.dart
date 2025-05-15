import 'package:flutter/services.dart';
import 'package:geojson_vi/geojson_vi.dart';
import '../models/arvore.dart';

class GeoJsonLoader {
  static Future<List<Arvore>> carregarArvores() async {
    print('Carregando arquivo GeoJSON...');
    final data = await rootBundle.loadString('assets/arvore.geojson'); // corrigido o nome aqui
    print('Arquivo carregado: ${data.length} caracteres');

    final geoJson = GeoJSONFeatureCollection.fromJSON(data);
    print('Total de features: ${geoJson.features.length}');


    final lista = geoJson.features
        .where((f) => f?.geometry is GeoJSONPoint)
        .map((f) => Arvore.fromGeoJson(f!))
        .toList();

    print('Total de features carregadas: ${lista.length}');
    print("tipoEspe0/tipoEspe1 (primeiras 20): ${lista.take(20).map((a) => [a.tipoEspe0, a.tipoEspe1]).toList()}");

    return lista;
  }
}
