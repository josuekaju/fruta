import 'package:geojson_vi/geojson_vi.dart';

class Arvore {
  final String id;
  final double latitude;
  final double longitude;
  final String tipoEspecie;
  final String nomeComum;
  final String nomeCientifico;
  final String nomeLogradouro;
  final String bairro;
  final double altura;
  final int idadeAproximada;
  final double circunfere;
  final double diametroE;
  final double dap;
  final String descricao;
  final bool tipoEspe0; // Frutífera
  final bool tipoEspe1; // Flor
  final int tipoEspec;

  Arvore({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.tipoEspecie,
    required this.nomeComum,
    required this.nomeCientifico,
    required this.nomeLogradouro,
    required this.bairro,
    required this.altura,
    required this.idadeAproximada,
    required this.circunfere,
    required this.diametroE,
    required this.dap,
    required this.descricao,
    required this.tipoEspe0,
    required this.tipoEspe1,
    required this.tipoEspec,
  });

  factory Arvore.fromGeoJson(GeoJSONFeature feature) {
    final props = feature.properties ?? {};
    final point = feature.geometry as GeoJSONPoint;
    // lembre: GeoJSON = [lon, lat]
    bool parseBool(val) {
      if (val == null) return false;
      if (val is bool) return val;
      final s = val.toString().toLowerCase().trim();
      return ['verdadeiro', 'true', 'v', 't', '1'].contains(s);
}
    // Calcula o valor de tipoEspec
    final String? tipoEspecStr = props['tipo_espec']?.toString();
    int parsedTipoEspec = 0; // Valor padrão
    if (tipoEspecStr != null && tipoEspecStr.isNotEmpty) {
      // Tenta converter para double primeiro para lidar com "XXX.0", depois para int
      final double? valAsDouble = double.tryParse(tipoEspecStr);
      if (valAsDouble != null) {
        parsedTipoEspec = valAsDouble.toInt();
      }
      // Se valAsDouble for null (ex: para strings não numéricas), parsedTipoEspec permanece 0
    }

    print('GeoJSON props[\'tipo_espec\'] = "${props['tipo_espec']}" \t→ Arvore.tipoEspec = $parsedTipoEspec');

    return Arvore(
      id: props['id']?.toString() ?? '',
      latitude: point.coordinates[1].toDouble(),
      longitude: point.coordinates[0].toDouble(),
      tipoEspecie: parseBool(props['tipo_espe0']) ? 'Frutífera' : parseBool(props['tipo_espe1']) ? 'Flor' : 'Outra',
      nomeComum: props['tipo_espe3']?.toString() ?? 'Árvore não identificada',
      nomeCientifico: props['tipo_espe2']?.toString() ?? '',
      nomeLogradouro: props['nome_logra']?.toString() ?? '',
      bairro: props['bairro_nom']?.toString() ?? '',
      altura: double.tryParse(props['altura_apr']?.toString() ?? '') ?? 0,
      idadeAproximada: (_parseIdade(props['idade_apro']) ~/ 10),
      circunfere: double.tryParse(props['circunfere']?.toString() ?? '') ?? 0,
      diametroE: double.tryParse(props['diametro_e']?.toString() ?? '') ?? 0,
      dap: double.tryParse(props['dap']?.toString() ?? '') ?? 0,
      descricao: props['descricao']?.toString() ?? '',
      tipoEspe0: parseBool(props['tipo_espe0']),
      tipoEspe1: parseBool(props['tipo_espe1']),
      tipoEspec: parsedTipoEspec,
    );
  }
  static int _parseIdade(dynamic valor) {
  if (valor == null) return 0;
  final texto = valor.toString().trim().replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(texto) ?? 0;
}



  static bool parseBool(dynamic val) {
  if (val == null) return false;
  if (val is bool) return val;
  final s = val.toString().toLowerCase().trim();
  return ['verdadeiro', 'true', 'v', 't', '1'].contains(s);
}


}
