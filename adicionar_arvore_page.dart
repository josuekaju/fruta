import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async'; // Para o Timer (debounce)
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:latlong2/latlong.dart';
import 'package:fruta_no_pe/core/config.dart';
import 'package:fruta_no_pe/models/sugestao_arvore.dart';
import 'package:flutter_map/flutter_map.dart'; // Para o mapa

class AdicionarArvorePage extends StatefulWidget {
  final LatLng localizacaoInicial;

  const AdicionarArvorePage({
    required this.localizacaoInicial,
    Key? key,
  }) : super(key: key);

  @override
  _AdicionarArvorePageState createState() => _AdicionarArvorePageState();
}

class _AdicionarArvorePageState extends State<AdicionarArvorePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeComumController = TextEditingController();
  final _nomeCientificoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _observacoesController = TextEditingController();
  
  XFile? _imagemSelecionada;
  bool _isEnviando = false;
  final ImagePicker _picker = ImagePicker();
  late LatLng _localizacaoSelecionada; // Localização que será enviada
  final MapController _mapController = MapController();
  Timer? _debounce;
  final Duration _debounceDuration = const Duration(milliseconds: 300);
  double _currentZoom = 17.0; // Zoom inicial e atual do mapa de seleção
  bool _mapaExpandido = false; // Estado para controlar a visibilidade do mapa

  @override
  void initState() {
    super.initState();
    _localizacaoSelecionada = widget.localizacaoInicial;
    _currentZoom = 17.0; // Pode ajustar conforme necessário
  }

  @override
  void dispose() {
    _nomeComumController.dispose();
    _nomeCientificoController.dispose();
    _descricaoController.dispose();
    _enderecoController.dispose();
    _bairroController.dispose();
    _observacoesController.dispose();
    _debounce?.cancel();
    _mapController.dispose(); // Certifique-se de que o mapController está sendo descartado
    super.dispose();
  }

  Future<void> _selecionarImagem(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (pickedFile != null) {
        setState(() {
          _imagemSelecionada = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: $e')),
        );
      }
    }
  }

  Future<void> _enviarSugestao() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isEnviando = true;
    });

    final sugestao = SugestaoArvore(
      latitude: _localizacaoSelecionada.latitude,
      longitude: _localizacaoSelecionada.longitude,
      nomeComum: _nomeComumController.text.trim(),
      nomeCientifico: _nomeCientificoController.text.trim().isNotEmpty 
          ? _nomeCientificoController.text.trim() 
          : null,
      descricao: _descricaoController.text.trim().isNotEmpty
          ? _descricaoController.text.trim()
          : null,
      enderecoAproximado: _enderecoController.text.trim().isNotEmpty
          ? _enderecoController.text.trim()
          : null,
      bairro: _bairroController.text.trim().isNotEmpty
          ? _bairroController.text.trim()
          : null,
      observacoes: _observacoesController.text.trim().isNotEmpty
          ? _observacoesController.text.trim()
          : null,
    );

    final uri = Uri.parse('${AppConfig.baseUrl}/api/sugestaoNovaArvore');
    final request = http.MultipartRequest('POST', uri);

    // Adiciona os campos da sugestão, convertendo valores para String
    final sugestaoMap = sugestao.toJson();
    sugestaoMap.forEach((key, value) {
      if (value != null) {
        // Garante que o valor seja convertido para String de forma segura
        request.fields[key] = value is DateTime 
            ? (value as DateTime).toIso8601String()
            : value.toString();
      }
    });


    // Adiciona a imagem, se houver
    if (_imagemSelecionada != null) {
      final file = File(_imagemSelecionada!.path);
      final fileName = path.basename(file.path);
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();

      final multipartFile = http.MultipartFile(
        'imagem',
        stream,
        length,
        filename: fileName,
        contentType: MediaType('image', fileName.split('.').last),
      );
      request.files.add(multipartFile);
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.pop(context, true); // Retorna true para indicar sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Obrigado! Sua sugestão de nova árvore foi enviada.')),
          );
        } else {
          throw Exception('Falha ao enviar sugestão: ${response.statusCode} - $responseBody');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar sugestão: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isEnviando = false;
        });
      }
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Sugerir Nova Árvore'),
    ),
    body: Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // 1. ENVOLVER O COLUMN PRINCIPAL COM SingleChildScrollView
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 2. LÓGICA if (_mapaExpandido) ... else ...
              if (_mapaExpandido) ...[
                // Seção do Mapa para seleção de localização (QUANDO EXPANDIDO)
                SizedBox(
                  height: 250, // Altura definida para o mapa
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _localizacaoSelecionada, // Usar _localizacaoSelecionada
                          initialZoom: _currentZoom,
                          onPositionChanged: (MapCamera camera, bool hasGesture) {
                            if (hasGesture) {
                              _debounce?.cancel();
                              _debounce = Timer(_debounceDuration, () {
                                if (mounted) {
                                  setState(() {
                                    _localizacaoSelecionada = camera.center;
                                    _currentZoom = camera.zoom;
                                  });
                                }
                              });
                            }
                          },
                          onMapReady: () {
                             if (mounted) {
                              Future.delayed(const Duration(milliseconds: 100), () {
                                  if (mounted) {
                                     setState(() {
                                      _localizacaoSelecionada = _mapController.camera.center;
                                      _currentZoom = _mapController.camera.zoom;
                                     });
                                  }
                              });
                             }
                          }
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: AppConfig.packageName,
                          ),
                        ],
                      ),
                      Center(
                        child: IgnorePointer(
                          child: Icon(
                            Icons.location_pin,
                            size: 50,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Exibição da Latitude e Longitude E BOTÃO CONFIRMAR
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column( // Alterado para Column para o botão
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Localização para Sugestão:', // Título ajustado
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Latitude: ${_localizacaoSelecionada.latitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Longitude: ${_localizacaoSelecionada.longitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text( // Mantido o texto de instrução
                        'Ajuste a localização no mapa e confirme abaixo.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Center( // Botão "Confirmar Localização"
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Confirmar Localização'),
                          onPressed: () {
                            setState(() {
                              _mapaExpandido = false; // Minimiza o mapa
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Seção de Localização Confirmada (QUANDO MINIMIZADO)
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                    title: const Text('Localização Confirmada'),
                    subtitle: Text(
                        'Lat: ${_localizacaoSelecionada.latitude.toStringAsFixed(4)}, Lon: ${_localizacaoSelecionada.longitude.toStringAsFixed(4)}'),
                    trailing: TextButton.icon(
                      icon: const Icon(Icons.edit_location_alt_outlined), // Ícone mais adequado
                      label: const Text('Ajustar'),
                      onPressed: () {
                        setState(() {
                          _mapaExpandido = true; // Re-expande o mapa
                        });
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16), // Espaço antes dos campos do formulário

              // 3. ListView para os campos do formulário (SEM Expanded)
              ListView(
                shrinkWrap: true, // Importante
                physics: const NeverScrollableScrollPhysics(), // Importante
                children: [
                  // Campo obrigatório: Nome comum
                  TextFormField(
                    controller: _nomeComumController,
                    decoration: const InputDecoration(
                      labelText: 'Nome popular da árvore *',
                      hintText: 'Ex: Mangueira, Goiabeira, etc.',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, informe o nome popular da árvore';
                      }
                      return null;
                    },
                  ),
                  // ... Seus outros TextFormField e a Card da imagem (COMO ESTAVAM ANTES) ...
                  // Campo opcional: Nome científico
                  TextFormField(
                    controller: _nomeCientificoController,
                    decoration: const InputDecoration(
                      labelText: 'Nome científico (opcional)',
                      hintText: 'Ex: Mangifera indica',
                    ),
                  ),
                  // Campo opcional: Descrição
                  TextFormField(
                    controller: _descricaoController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Descrição (opcional)',
                      hintText: 'Descreva a árvore, frutos, flores, etc.',
                    ),
                  ),
                  // Campo opcional: Endereço aproximado
                  TextFormField(
                    controller: _enderecoController,
                    decoration: const InputDecoration(
                      labelText: 'Endereço aproximado (opcional)',
                      hintText: 'Ex: Rua XV de Novembro, 123',
                    ),
                  ),
                  // Campo opcional: Bairro
                  TextFormField(
                    controller: _bairroController,
                    decoration: const InputDecoration(
                      labelText: 'Bairro (opcional)',
                      hintText: 'Nome do bairro',
                    ),
                  ),
                  // Seção de imagem
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Adicionar foto (opcional)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(icon: const Icon(Icons.photo_library), label: const Text('Galeria'), onPressed: () => _selecionarImagem(ImageSource.gallery)),
                              ElevatedButton.icon(icon: const Icon(Icons.camera_alt), label: const Text('Câmera'), onPressed: () => _selecionarImagem(ImageSource.camera)),
                            ],
                          ),
                          if (_imagemSelecionada != null) ...[
                            const SizedBox(height: 8),
                            Center(child: Image.file(File(_imagemSelecionada!.path), height: 150, fit: BoxFit.cover)),
                            Center(child: TextButton(onPressed: () => setState(() => _imagemSelecionada = null), child: const Text('Remover imagem'))),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Campo opcional: Observações
                  TextFormField(
                    controller: _observacoesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Observações adicionais (opcional)',
                      hintText: 'Alguma informação adicional que queira compartilhar',
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

              // Botão de envio fora do ListView e do SingleChildScrollView (se quisesse fixo no rodapé)
              // Mas para manter simples, vamos deixá-lo rolar com o conteúdo.
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: ElevatedButton(
                  onPressed: _isEnviando ? null : _enviarSugestao,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isEnviando
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Enviar Sugestão'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
