import 'dart:collection';
import 'package:uuid/uuid.dart'; // Para SplayTreeSet, se quiser ordenação natural complexa
////////////////////////////////////////
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

    // Helper para sanitizar strings ou retornar um valor padrão se a entrada for nula ou vazia após sanitização
    String sanitize(dynamic input, String defaultValue) {
      final str = input?.toString();
      if (str == null || str.isEmpty) return defaultValue;
      final sanitized = _sanitizeString(str);
      return sanitized.isNotEmpty ? sanitized : defaultValue;
    }

    return Arvore(
      id: props['id']?.toString() ?? Uuid().v4(), // Gera um ID se não houver
      latitude: point.coordinates[1].toDouble(),
      longitude: point.coordinates[0].toDouble(),
      tipoEspecie: parseBool(props['tipo_espe0']) ? 'Frutífera' : parseBool(props['tipo_espe1']) ? 'Flor' : 'Outra',
      nomeComum: sanitize(props['tipo_espe3'], 'Árvore não identificada'),
      nomeCientifico: sanitize(props['tipo_espe2'], ''),
      nomeLogradouro: sanitize(props['nome_logra'], ''),
      bairro: sanitize(props['bairro_nom'], ''),
      altura: double.tryParse(props['altura_apr']?.toString() ?? '') ?? 0,
      idadeAproximada: (_parseIdade(props['idade_apro']) ~/ 10),
      circunfere: double.tryParse(props['circunfere']?.toString() ?? '') ?? 0,
      diametroE: double.tryParse(props['diametro_e']?.toString() ?? '') ?? 0,
      dap: double.tryParse(props['dap']?.toString() ?? '') ?? 0,
      descricao: sanitize(props['descricao'], ''),
      tipoEspe0: parseBool(props['tipo_espe0']),
      tipoEspe1: parseBool(props['tipo_espe1']),
      tipoEspec: parsedTipoEspec, // Usa o valor já convertido para int
    );
  }
  static int _parseIdade(dynamic valor) {
  if (valor == null) return 0;
  final texto = valor.toString().trim().replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(texto) ?? 0;
}

  // Tornando _sanitizeString um método estático para que possa ser usado no factory constructor
  static String _sanitizeString(String input) {
  String result = input
      .trim()
      .replaceAllMapped(RegExp(r'&([a-z0-9]+|#[0-9]{1,6}|#x[0-9a-f]{1,6});', caseSensitive: false), (m) {
        final String htmlEntity = m.group(1)!.toLowerCase();
        switch (htmlEntity) {
          case 'ccedil': return 'ç';
          case 'aacute': return 'á';
          case 'acirc': return 'â';
          case 'atilde': return 'ã';
          case 'eacute': return 'é';
          case 'ecirc': return 'ê';
          case 'iacute': return 'í';
          case 'oacute': return 'ó';
          case 'ocirc': return 'ô';
          case 'otilde': return 'õ';
          case 'uacute': return 'ú';
          case 'agrave': return 'à';
          case 'uuml': return 'ü';
          case 'ntilde': return 'ñ';

          // Maiúsculas
          case 'Ccedil': return 'Ç';
          case 'Aacute': return 'Á';
          case 'Acirc': return 'Â';
          case 'Atilde': return 'Ã';
          case 'Eacute': return 'É';
          case 'Ecirc': return 'Ê';
          case 'Iacute': return 'Í';
          case 'Oacute': return 'Ó';
          case 'Ocirc': return 'Ô';
          case 'Otilde': return 'Õ';
          case 'Uacute': return 'Ú';
          case 'Agrave': return 'À';
          case 'Uuml': return 'Ü';
          case 'Ntilde': return 'Ñ';

          // Outras comuns
          case 'amp': return '&'; // &
          case 'lt': return '<';   // <
          case 'gt': return '>';   // >
          case 'quot': return '"'; // "
          case 'apos': return "'"; // '
          case '#39': return "'"; // ' (entidade numérica para apóstrofo)
          default: return m.group(0)!; // Retorna a entidade original se não mapeada
        }
      })
      // Remove caracteres de controle, exceto tab, nova linha, retorno de carro
      .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '')
      // Opcional: normalizar espaços múltiplos para um único espaço
      .replaceAll(RegExp(r'\s+'), ' ');

    // A linha abaixo removia toda pontuação. Removi-a para manter pontuações como '.', ',', '-' etc.
    // .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ''); // Regex Unicode para manter apenas letras, números e espaços
    return result.trim(); // Adiciona o return e trim no final
}
}
