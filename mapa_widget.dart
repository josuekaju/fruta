import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../models/arvore.dart';
import '../pages/adicionar_arvore_page.dart';
import '../utils/icone_utils.dart';
import '../pages/sugestao_page.dart';
import '../services/localizacao_service.dart';

Color getEmojiColor(Arvore arvore) {
  // Esta função agora define apenas a cor do emoji, sem considerar medalhas.
  // Regras de cores baseadas em arvore.tipoEspec (que agora é um int)
  switch (arvore.tipoEspec) {
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
    if (medalha == ' 🥈') return const Color.fromARGB(246, 165, 163, 156); // Um cinza um pouco mais escuro para borda
    if (medalha == ' 🥉') return const Color.fromARGB(255, 138, 99, 87); // Um marrom mais escuro para borda
  }
  return null; // Nenhuma cor de borda especial
}

typedef MedalhaCallback = String Function(String categoria, Arvore arvore);

class MapaWidget extends StatefulWidget {
  final List<Arvore> arvores;
  final MapController controller;
  final MedalhaCallback? medalhaCallback;
  final LatLng? currentUserLocation;
  final String? subfiltroEspecial;
  final List<LatLng> pontosDaRota;
  final bool exibirRota;
  final Function(LatLng, LatLng) onMostrarRota;
  final LatLng centroInicial;
  final double zoomInicial;
  final bool mostrarBotaoAdicionar;
  final Function()? onAdicionarArvore;
  final Function()? onMapReady;
  final void Function(LatLngBounds?)? onBoundsChanged; // ADICIONADO

  const MapaWidget({
    Key? key,
    required this.arvores,
    required this.controller,
    this.medalhaCallback,
    this.currentUserLocation,
    this.subfiltroEspecial,
    this.pontosDaRota = const [],
    this.exibirRota = false,
    required this.onMostrarRota,
    required this.centroInicial,
    this.zoomInicial = 15.0,
    this.mostrarBotaoAdicionar = true,
    this.onAdicionarArvore,
    this.onMapReady,
    this.onBoundsChanged, // ADICIONADO
  }) : assert(controller != null), // Verificação crítica
       super(key: key);

  @override
  State<MapaWidget> createState() => _MapaWidgetState();
}

class _MapaWidgetState extends State<MapaWidget> {
  Timer? _debounce;
  final Duration _debounceDuration = const Duration(milliseconds: 420);
  late List<Arvore> _arvoresAtuais;
  late String? _subfiltroAtual;

  @override
  void initState() {
    super.initState();
    _arvoresAtuais = widget.arvores;
    _subfiltroAtual = widget.subfiltroEspecial;
    
    // Garante que o mapa seja notificado quando o widget for montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.controller != null) {
        // Se o mapa já estiver pronto, chama o callback
        widget.onMapReady?.call();
      }
    });
  }
  
  // Método para carregar estilos do mapa (mantido para compatibilidade)
  void _carregarEstiloMapa() {
    // Este método pode ser usado para carregar estilos personalizados do mapa no futuro
    // Por enquanto, não é necessário fazer nada aqui
  }

  @override
  void didUpdateWidget(covariant MapaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Atualiza as referências locais e força a reconstrução se necessário
    bool precisaAtualizar = false;
    
    if (widget.arvores != _arvoresAtuais) {
      _arvoresAtuais = widget.arvores;
      precisaAtualizar = true;
    }
    
    if (widget.subfiltroEspecial != _subfiltroAtual) {
      _subfiltroAtual = widget.subfiltroEspecial;
      precisaAtualizar = true;
    }
    
    if (precisaAtualizar && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Função para abrir a tela de adicionar nova árvore
  void _abrirAdicionarArvore() async {
    // Usar a localização atual do mapa ou a localização inicial fornecida
    final localizacaoAtual = widget.controller.camera.center;
    
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AdicionarArvorePage(
          localizacaoInicial: localizacaoAtual,
        ),
      ),
    );

    // Se a sugestão foi enviada com sucesso, podemos atualizar o mapa se necessário
    if (resultado == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sugestão de nova árvore enviada com sucesso!')),
      );
      
      // Chamar o callback se fornecido
      if (widget.onAdicionarArvore != null) {
        widget.onAdicionarArvore!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar um ValueKey baseado nas árvores e no subfiltro para forçar a reconstrução quando necessário
    final mapKey = ValueKey('map_${_arvoresAtuais.length}_${_subfiltroAtual ?? 'no_filter'}');
    
    return Stack(
      children: [
        FlutterMap(
          key: mapKey,
          mapController: widget.controller,
          options: MapOptions(
            initialCenter: widget.centroInicial,
            initialZoom: widget.zoomInicial,
            onMapReady: widget.onMapReady,
            onPositionChanged: (MapCamera camera, bool hasGesture) { // CORRIGIDO para MapCamera
              if (hasGesture) {
                // Cancela o debounce anterior se houver
                _debounce?.cancel();
                
                // Agenda uma nova atualização após o tempo de debounce
                _debounce = Timer(_debounceDuration, () {
                  if (mounted) { // Verifica se o widget ainda está montado
                    setState(() {
                      // Força a reconstrução do widget quando o mapa para de se mover
                    });
                    // Chama o callback onBoundsChanged com os limites atuais do mapa
                    widget.onBoundsChanged?.call(camera.visibleBounds); // CORRIGIDO para camera.visibleBounds
                  }
                });
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.frutanope.app',
            ),
            MarkerLayer(
              markers: [
                ...widget.arvores.map<Marker>((arvore) {
                  Widget emojiWidget = Text(
                    getEmojiForArvore(
                      arvore,
                      medalhaCallback: widget.medalhaCallback,
                      subfiltroEspecial: widget.subfiltroEspecial,
                    ),
                    style: TextStyle(
                      fontSize: 22.0,
                      color: getEmojiColor(arvore),
                    ),
                  );

                  final Color? borderColor = getMedalBorderColor(
                      arvore, widget.medalhaCallback, widget.subfiltroEspecial);

                  if (borderColor != null) {
                    emojiWidget = Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor, width: 2.5),
                      ),
                      child: Center(child: emojiWidget),
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
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.directions, color: Colors.blue),
                                    tooltip: 'Traçar rota até esta árvore',
                                    onPressed: () async {
                                      Navigator.pop(context);
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
                                      '"${arvore.descricao}"',
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
                      child: emojiWidget,
                    ),
                  );
                }).toList(),
                // Marcador da localização atual do usuário (se disponível)
                if (widget.currentUserLocation != null)
                  Marker(
                    width: 55.5,
                    height: 55.5,
                    point: widget.currentUserLocation!,
                    child: Image.asset('assets/images/treant.png'),
                  ),
              ],
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
        ),
        // Botão flutuante para adicionar nova árvore
        if (widget.mostrarBotaoAdicionar)
          Positioned(
            bottom: 80,
            right: 10,
            child: FloatingActionButton.extended(
              onPressed: _abrirAdicionarArvore,
              icon: const Icon(Icons.add_location_alt),
              label: const Text(''),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }
}