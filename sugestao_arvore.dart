class SugestaoArvore {
  final double latitude;
  final double longitude;
  final String nomeComum;
  final String? nomeCientifico;
  final String? descricao;
  final String? enderecoAproximado;
  final String? bairro;
  final String? observacoes;
  final String? imagemUrl;
  final DateTime dataSugestao;

  SugestaoArvore({
    required this.latitude,
    required this.longitude,
    required this.nomeComum,
    this.nomeCientifico,
    this.descricao,
    this.enderecoAproximado,
    this.bairro,
    this.observacoes,
    this.imagemUrl,
    DateTime? dataSugestao,
  }) : dataSugestao = dataSugestao ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'nomeComum': nomeComum,
      'nomeCientifico': nomeCientifico,
      'descricao': descricao,
      'enderecoAproximado': enderecoAproximado,
      'bairro': bairro,
      'observacoes': observacoes,
      'imagemUrl': imagemUrl,
      'dataSugestao': dataSugestao.toIso8601String(),
      'tipo': 'nova_arvore',
    };
  }
}
