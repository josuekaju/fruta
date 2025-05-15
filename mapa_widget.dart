import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/arvore.dart';

typedef MedalhaCallback = String Function(String categoria, Arvore arvore);

Color corPorTipo(Arvore arvore) {
  switch (arvore.tipoEspecie) {
    case 'Frutífera':
      return Colors.green;
    case 'Rara':
      return Colors.red;
    case 'Flor':
    case 'Flores':
      return Colors.purple;
    default:
      return Colors.brown;
  }
}

IconData iconePorTipo(Arvore arvore) {
  switch (arvore.tipoEspecie) {
    case 'Frutífera':
      return Icons.apple;
    case 'Flor':
    case 'Flores':
      return Icons.local_florist;
    case 'Recorde':
      return Icons.star;
    case 'Típica/regional':
      return Icons.park_outlined;
    case 'Rara':
      return Icons.report;
    default:
      return Icons.park;
  }
}

class MapaWidget extends StatelessWidget {
  final List<Arvore>? arvores;
  final MedalhaCallback? medalhaCallback;

  const MapaWidget({super.key, this.arvores, this.medalhaCallback});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(-24.7132, -53.7403),
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(
          markers: (arvores?.map<Marker>((arvore) {
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
                            Text('Altura: ${arvore.altura.toStringAsFixed(1)} m${medalhaCallback?.call("altura", arvore) ?? ''}'),
                          if (arvore.circunfere > 0)
                            Text('Circunf: ${arvore.circunfere.toStringAsFixed(1)} cm${medalhaCallback?.call("circunfere", arvore) ?? ''}'),
                          if (arvore.diametroE > 0)
                            Text('Diâmetro: ${arvore.diametroE.toStringAsFixed(1)} cm${medalhaCallback?.call("diametro", arvore) ?? ''}'),
                          if (arvore.dap > 0)
                            Text('DAP: ${arvore.dap.toStringAsFixed(1)} cm${medalhaCallback?.call("dap", arvore) ?? ''}'),
                          if (arvore.idadeAproximada > 0)
                            Text('Idade: ${arvore.idadeAproximada} anos${medalhaCallback?.call("idade", arvore) ?? ''}'),
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
                child: Icon(
                  iconePorTipo(arvore),
                  color: corPorTipo(arvore),
                  size: 22.0,
                ),
              ),
            );
          }).toList()) ?? <Marker>[],
        ),
      ],
    );
  }
}
