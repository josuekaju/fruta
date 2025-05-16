import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async'; // Importar para usar o Timer
import '../models/arvore.dart';
import '../utils/icone_utils.dart'; // Importa o novo arquivo

Color corPorTipo(Arvore arvore, MedalhaCallback? medalhaCallback, String? subfiltroEspecial) {
  // Prioridade para cores de medalha se for um recordista
  final medalha = medalhaCallback?.call(subfiltroEspecial ?? '', arvore);
  if (medalha == ' 🥇') return Colors.amber.shade700;
  if (medalha == ' 🥈') return Colors.grey.shade400;
  if (medalha == ' 🥉') return Colors.brown.shade400;

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


typedef MedalhaCallback = String Function(String categoria, Arvore arvore);

class MapaWidget extends StatefulWidget {
  final List<Arvore> arvores;
  final MapController controller;
  final void Function(LatLngBounds?)? onBoundsChanged;
  final MedalhaCallback? medalhaCallback;
  final String? subfiltroEspecial; // Adicionado para passar para corPorTipo

  const MapaWidget({
    super.key,
    required this.arvores,
    required this.controller,
    this.onBoundsChanged,
    this.medalhaCallback,
    this.subfiltroEspecial, // Adicionado para passar para corPorTipo
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
      print('[MapaWidget didUpdateWidget] subfiltroEspecial mudou de "${oldWidget.subfiltroEspecial}" para "${widget.subfiltroEspecial}"');
    }
    // Você pode adicionar verificações para outras propriedades se necessário, como widget.arvores
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.controller,
      options: MapOptions(
        initialCenter: LatLng(-24.7132, -53.7403),
        initialZoom: 13,
        onPositionChanged: (MapPosition pos, bool hasGesture) {
          if (widget.onBoundsChanged != null) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(_debounceDuration, () {
              widget.onBoundsChanged!(pos.bounds);
            });
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          // subdomains: const ['a', 'b', 'c'], // Removed as per OSM policy
          userAgentPackageName: 'com.seuprojeto.frutadope', // Replace with your actual package name
          tileBuilder: (context, tileWidget, tile) {
            // The 'tile' argument is not used in this builder, but it's part of the signature.
            // 'tileWidget' is the widget flutter_map would normally build for the tile.
            return Stack(
              children: [
                tileWidget, // The actual tile image
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.05), // Semi-transparent overlay
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        MarkerLayer(
          markers: widget.arvores.map<Marker>((arvore) { // Acessar arvores via widget.arvores
            
            print('[MapaWidget build] Construindo marcador para ${arvore.id}. SubfiltroEspecial atual: "${widget.subfiltroEspecial}"');

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
                      ],
                    ),
                  );
                },
                child: Text(
                  getEmojiForArvore(
                    arvore,
                    medalhaCallback: widget.medalhaCallback,
                    subfiltroEspecial: widget.subfiltroEspecial,
                  ),
                  style: TextStyle(
                    fontSize: 22.0, // Ajuste o tamanho conforme necessário
                    color: corPorTipo(arvore, widget.medalhaCallback, widget.subfiltroEspecial),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
