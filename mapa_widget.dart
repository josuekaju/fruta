import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async'; // Importar para usar o Timer
import '../models/arvore.dart';
import '../utils/icone_utils.dart'; // Importa o novo arquivo
import '../pages/sugestao_page.dart'; // Importar a nova tela de sugestão
import '../services/localizacao_service.dart'; // Para obter a localização atual


Color getEmojiColor(Arvore arvore) {
  // Esta função agora define apenas a cor do emoji, sem considerar medalhas.
  // Regras de cores baseadas em arvore.tipoEspec (que agora é um int)
  switch (arvore.tipoEspec) { // arvore.tipoEspec é um int
    case 0: // Exemplo: Não catalogada
      return Colors.blueGrey;
    case 1: // Exemplo: Tipo Específico 1
      return Colors.orange.shade700;
    case 2: // Exemplo: Tipo Específico 2
      return Colors.teal;
    // Adicione mais casos conforme necessário
    default: // Cor padrão se tipoEspec não corresponder ou para outros casos
      if (arvore.tipoEspe0) return Colors.green.shade700; // Frutífera genérica
      if (arvore.tipoEspe1) return Colors.pink.shade300;  // Flor genérica
      return Colors.brown.shade600; // Cor realmente padrão
  }
}

Color? getMedalBorderColor(Arvore arvore, MedalhaCallback? medalhaCallback, String? subfiltroEspecial) {
  if (medalhaCallback != null && subfiltroEspecial != null && subfiltroEspecial.isNotEmpty) {
    final medalha = medalhaCallback(subfiltroEspecial, arvore);
    if (medalha == ' 🥇') return Colors.amber.shade700;
    if (medalha == ' 🥈') return Colors.grey.shade600; // Um cinza um pouco mais escuro para borda
    if (medalha == ' 🥉') return Colors.brown.shade700; // Um marrom mais escuro para borda
  }
  return null; // Nenhuma cor de borda especial
}

typedef MedalhaCallback = String Function(String categoria, Arvore arvore);

class MapaWidget extends StatefulWidget {
  final List<Arvore> arvores;
  final MapController controller;
  final void Function(LatLngBounds?)? onBoundsChanged;
  final MedalhaCallback? medalhaCallback;
  final String? subfiltroEspecial; // Adicionado para passar para corPorTipo
  final LatLng? currentUserLocation; // Novo parâmetro para a localização do usuário
  final List<LatLng> pontosDaRota; // Pontos para desenhar a rota
  final bool exibirRota; // Controla se a rota deve ser exibida
  final Function(LatLng origem, LatLng destino) onMostrarRota; // Callback para solicitar a rota


  const MapaWidget({
    super.key,
    required this.arvores,
    required this.controller,
    this.onBoundsChanged,
    this.medalhaCallback,
    this.subfiltroEspecial, // Adicionado para passar para corPorTipo
    this.currentUserLocation, // Adicionado ao construtor
    required this.pontosDaRota,
    required this.exibirRota,
    required this.onMostrarRota,
  });

  @override
  State<MapaWidget> createState() => _MapaWidgetState();
}

class _MapaWidgetState extends State<MapaWidget> {
  Timer? _debounce;
  final Duration _debounceDuration = const Duration(milliseconds: 420);

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MapaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.subfiltroEspecial != oldWidget.subfiltroEspecial) {
    }
    // Você pode adicionar verificações para outras propriedades se necessário, como widget.arvores
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.controller,
      options: MapOptions(
        initialCenter: widget.currentUserLocation ?? const LatLng(-24.7132, -53.7403), // Centraliza no usuário se disponível
        initialZoom: 13.0, // Zoom inicial
        onPositionChanged: (MapCamera pos, bool hasGesture) {
          final bounds = pos.visibleBounds;
          widget.onBoundsChanged?.call(bounds);
        },
      ),
      children: [
        // mapa_widget.dart
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          userAgentPackageName: 'com.frutanope.app',
          tileProvider: NetworkTileProvider(),
        ),
        MarkerLayer(
          markers: widget.arvores.map<Marker>((arvore) { // Acessar arvores via widget.arvores
            
            print('buildando marcador para ${arvore}');
            
            Widget emojiWidget = Text(
              getEmojiForArvore(
                arvore,
                // medalhaCallback e subfiltroEspecial não são mais usados por getEmojiForArvore para retornar medalhas
                // mas podem ser mantidos se houver outra lógica futura que os utilize.
                // Para esta implementação de borda, eles não afetam o emoji retornado.
                medalhaCallback: widget.medalhaCallback,
                subfiltroEspecial: widget.subfiltroEspecial,
              ),
              style: TextStyle(
                fontSize: 22.0,
                color: getEmojiColor(arvore), // Usa a nova função para cor do emoji
              ),
            );

            final Color? borderColor = getMedalBorderColor(arvore, widget.medalhaCallback, widget.subfiltroEspecial);

            if (borderColor != null) {
              emojiWidget = Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Ou BoxShape.rectangle
                  border: Border.all(color: borderColor, width: 2.5), // Ajuste a largura da borda
                ),
                child: Center(child: emojiWidget), // Centraliza o emoji dentro do contorno
              );
            }

            return Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(arvore.latitude, arvore.longitude),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(arvore.nomeComum),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Botão de Rota
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: const Icon(Icons.directions, color: Colors.blue),
                              tooltip: 'Traçar rota até esta árvore',
                              onPressed: () async {
                                Navigator.pop(context); // Fecha o AlertDialog
                                final posicaoAtual = await LocalizacaoService.obterLocalizacao();
                                if (posicaoAtual != null && mounted) {
                                  final origem = LatLng(posicaoAtual.latitude, posicaoAtual.longitude);
                                  final destino = LatLng(arvore.latitude, arvore.longitude);
                                  widget.onMostrarRota(origem, destino);
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Não foi possível obter sua localização para traçar a rota.')),
                                  );
                                }
                              },
                            ),
                          ),
                          if (arvore.nomeCientifico.isNotEmpty)
                            Text('Nome científico: ${arvore.nomeCientifico}'),
                          Text('Bairro: ${arvore.bairro}'),
                          Text('Rua: ${arvore.nomeLogradouro}'),
                          if (arvore.tipoEspe0) Text('🌳 Frutífera'),
                          if (arvore.tipoEspe1) Text('🌸 Flor ornamental'),
                          if (arvore.altura > 0)
                            Text('Altura: ${arvore.altura.toStringAsFixed(1)} m${widget.medalhaCallback?.call("altura", arvore) ?? ''}'),
                          if (arvore.circunfere > 0)
                            Text('Circunf: ${arvore.circunfere.toStringAsFixed(1)} cm${widget.medalhaCallback?.call("circunfere", arvore) ?? ''}'),
                          if (arvore.diametroE > 0)
                            Text('Diâmetro: ${arvore.diametroE.toStringAsFixed(1)} cm${widget.medalhaCallback?.call("diametro", arvore) ?? ''}'),
                          if (arvore.dap > 0)
                            Text('DAP: ${arvore.dap.toStringAsFixed(1)} cm${widget.medalhaCallback?.call("dap", arvore) ?? ''}'),
                          if (arvore.idadeAproximada > 0)
                            Text('Idade: ${arvore.idadeAproximada} anos${widget.medalhaCallback?.call("idade", arvore) ?? ''}'),
                          if (arvore.descricao.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '“${arvore.descricao}”',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Fechar'),
                        ),
                        TextButton.icon(
                          icon: Icon(Icons.edit, color: Colors.orange.shade700),
                          label: Text('Errado ou Atualizar', style: TextStyle(color: Colors.orange.shade700)),
                          onPressed: () {
                            // Fecha o AlertDialog atual antes de navegar
                            Navigator.pop(context); 
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SugestaoPage(arvore: arvore),
                            ));
                          },
                        ),
                      ],
                    ),
                  );
                },
                child: emojiWidget, // Usa o widget do emoji, possivelmente com borda
              ),
            );
          }).toList(),
        ),
        
        // Camada para desenhar a rota
        if (widget.exibirRota && widget.pontosDaRota.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.pontosDaRota,
                strokeWidth: 5.0,
                color: Colors.blue.withOpacity(0.8),
              ),
            ],
          ),
      ],
    );
  }
}
