import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
////////////////////////////////////////
import '../models/arvore.dart';
import '../services/geojson_loader.dart';
import '../widgets/mapa_widget.dart';
import '../services/localizacao_service.dart';
import '../services/rota_service.dart'; // Importar o novo serviço de rota
import '../widgets/loading_overlay.dart'; // Importar o novo widget de carregamento
import '../services/species_counter_service.dart'; // Importar o novo serviço de contagem
import 'package:fruta_no_pe/services/geojson_loader.dart' show CidadeDisponivel;

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MapController mapController = MapController();
  final RotaService _rotaService = RotaService(); // Instância do serviço de rota
  LatLngBounds? mapaBounds;
  bool _isLoading = true; // Adiciona um estado para controlar o carregamento inicial
  String? _loadingError; // Adiciona um estado para armazenar mensagens de erro
  LatLng? _currentLocationMarkerPosition; // Novo estado para a posição do marcador do usuário
  List<LatLng> _pontosDaRota = []; // Estado para armazenar os pontos da rota
  bool _exibirRotaNoMapa = false; // Estado para controlar a visibilidade da rota

  // Estado para controlar a cidade selecionada
  CidadeDisponivel _cidadeSelecionada = CidadeDisponivel.toledo;

  // Estados para o filtro de espécies frutíferas
  String? _especieFrutiferaSelecionada;
  List<String> _listaEspeciesFrutiferasDinamica = [];
  Map<String, int> _especiesContagem = {}; // Para armazenar as contagens

  @override
  void initState() {
    super.initState();
    print('🏠 HomePage.initState chamado');
    _carregarDadosArvores();
    _atualizarPosicaoMapa();
  }

  // Atualiza a posição do mapa para o centro da cidade selecionada
  void _atualizarPosicaoMapa() {
    print('🔄 HomePage._atualizarPosicaoMapa chamado para cidade: $_cidadeSelecionada');
    final cidadeInfo = cidadesInfo[_cidadeSelecionada];
    if (cidadeInfo != null) {
      // Adia a chamada para depois que o frame atual for construído
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { // Verifica apenas se o widget ainda está montado
          mapController.move(cidadeInfo.centro, cidadeInfo.zoomInicial);
          print('🗺️ Mapa movido para ${cidadeInfo.nome} em ${cidadeInfo.centro} com zoom ${cidadeInfo.zoomInicial}');
        } else if (mounted) {
          print('⚠️ MapController não estava pronto em _atualizarPosicaoMapa. O mapa pode não ter sido movido.');
        }
      });
    }
  }

  Future<void> _carregarDadosArvores() async {
    try {
      // Carrega os dados da cidade selecionada
      final processedData = await GeoJsonLoader.carregarEProcessarArvores(cidade: _cidadeSelecionada);
      if (mounted) {
        // Atribui os dados processados aos estados da HomePage
        _todas = processedData.todas;
        _catalogadas = processedData.catalogadas;
        _frutiferas = processedData.frutiferas;
        _flores = processedData.flores;
        _naoCatalogadas = processedData.naoCatalogadas;
        // Modifica o conteúdo do mapa existente em vez de reatribuir
        recordistasPorCategoria.clear();
        recordistasPorCategoria.addAll(processedData.recordistasPorCategoria);
        _especiesContagem = await SpeciesCounterService.loadSpeciesCounts(); // Carrega as contagens
        _extrairEspeciesFrutiferas(); // Extrai as espécies após carregar os dados

        setState(() {
          _isLoading = false;
        });
        
        // Atualiza a posição do mapa após carregar os dados
        _atualizarPosicaoMapa();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingError = "Erro ao carregar dados das árvores: $e";
        });
        print("Erro ao carregar árvores: $e");
      }
    }
  }

  List<Arvore> _todas = [];
  List<Arvore> _catalogadas = [];
  List<Arvore> _frutiferas = [];
  List<Arvore> _flores = [];
  List<Arvore> _naoCatalogadas = [];

  String filtroSelecionado = 'todas';
  String? subfiltroEspecial;

  final Map<String, List<Arvore>> recordistasPorCategoria = {
    'altura': [],
    'circunfere': [],
    'diametro': [],
    'dap': [],
    'idade': [],
  };

  void _extrairEspeciesFrutiferas() {
    if (_todas.isEmpty) {
      _listaEspeciesFrutiferasDinamica = [];
      return;
    }
    final Set<String> especies = {};
    for (var arvore in _todas) {
      // Usar arvore.tipoEspe0 para verificar se é frutífera
      if (arvore.tipoEspe0 && arvore.nomeComum.trim().isNotEmpty) {
        especies.add(arvore.nomeComum.trim());
      }
    }
    _listaEspeciesFrutiferasDinamica = especies.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }
  // A função _atualizarListas não é mais necessária da forma como era,
  // pois os dados já vêm processados.
  // A função calcularRecordistas também foi movida para o Isolate.
  // Se precisar de alguma lógica de atualização PÓS carregamento que dependa
  // de interação do usuário, ela pode ser mantida ou adaptada.

  // Função para solicitar e definir a rota a ser exibida no mapa
  Future<void> _mostrarRotaNoMapa(LatLng origem, LatLng destino) async {
    final List<LatLng> pontos = await _rotaService.obterPontosDaRota(origem, destino);
    if (mounted) {
      setState(() {
        _pontosDaRota = pontos;
        _exibirRotaNoMapa = true;
      });
    }
  }

  // Função para limpar a rota do mapa (pode ser chamada ao fechar o dialog ou mudar de árvore)
  void _limparRotaDoMapa() => setState(() { _pontosDaRota = []; _exibirRotaNoMapa = false; });

  List<Arvore> aplicarFiltro() {
    List<Arvore> base;
    bool aplicarFiltroDeVisibilidadePadrao = true; // Controls map bounds and 420 limit

    switch (filtroSelecionado) {
      case 'frutiferas':
        base = _frutiferas.where((arvore) {
          if (_especieFrutiferaSelecionada == null || _especieFrutiferaSelecionada!.isEmpty) {
            return true;
          }
          return arvore.nomeComum.trim().toLowerCase() == _especieFrutiferaSelecionada!.trim().toLowerCase();
        }).toList();
        break;
      case 'flores':
        base = _flores;
        break;
      case 'nao_catalogadas':
        base = _naoCatalogadas;
        break;
      case 'curiosidades':
        if (subfiltroEspecial != null) {  
          base = getRecordistas(_todas); // getRecordistas já filtra e pega o top 10
          aplicarFiltroDeVisibilidadePadrao = false; // Não aplica limite de mapa/visibilidade para recordistas
        } else {
          base = _todas; // Se 'curiosidades' for selecionado sem subfiltro
        }
        break;
      default: // 'todas' (catalogadas)
        base = _catalogadas;
        break;
    }

    if (aplicarFiltroDeVisibilidadePadrao) {
      final visiveis = base.where(dentroDoMapa).toList();
      return visiveis.length > 420 ? visiveis.take(420).toList() : visiveis;
    } else {
      // Para recordistas, eles já são limitados.
      // Se eles também precisarem estar dentro dos limites do mapa, adicione: base = base.where(dentroDoMapa).toList();
      return base;
    }
  }

  bool dentroDoMapa(Arvore a) {
    if (mapaBounds == null) return true;
    return mapaBounds!.contains(LatLng(a.latitude, a.longitude));
  }

  List<Arvore> getRecordistas(List<Arvore> arvores) {
    if (arvores.isEmpty) return [];

    double Function(Arvore) key;
    bool Function(Arvore) filtroValido;

    switch (subfiltroEspecial) {
      case 'circunfere':
        key = (a) => a.circunfere;
        filtroValido = (a) => a.circunfere > 0;
        break;
      case 'diametro':
        key = (a) => a.diametroE;
        filtroValido = (a) => a.diametroE > 0;
        break;
      case 'dap':
        key = (a) => a.dap;
        filtroValido = (a) => a.dap > 0;
        break;
      case 'idade':
        key = (a) => a.idadeAproximada.toDouble();
        filtroValido = (a) => a.idadeAproximada > 0;
        break;
      case 'altura':
      default:
        key = (a) => a.altura;
        filtroValido = (a) => a.altura > 0;
        break;
    }

    final validas = arvores.where(filtroValido).toList();
    validas.sort((a, b) => key(b).compareTo(key(a)));
    return validas.take(10).toList();
  }

  // Função auxiliar para obter o valor da categoria para depuração
  double _getValorDaCategoriaParaDebug(Arvore arvore, String categoria) {
    switch (categoria) {
      case 'altura': return arvore.altura;
      case 'circunfere': return arvore.circunfere;
      case 'diametro': return arvore.diametroE;
      case 'dap': return arvore.dap;
      case 'idade': return arvore.idadeAproximada.toDouble();
      default: return 0.0;
    }
  }

  String medalhaSeForTop(String categoria, Arvore arvore) {
    final lista = recordistasPorCategoria[categoria] ?? [];
    final List<String> idsNaListaDeRecordes = lista.map((r) => r.id).toList();
    final pos = lista.indexWhere((a) => a.id == arvore.id);

    // Adicionar este print para debug:
    // Imprime apenas para o subfiltro ativo para reduzir o volume de logs.
    if (filtroSelecionado == 'curiosidades' && categoria == subfiltroEspecial) {
      print('--- Medalha Check (medalhaSeForTop) ---');
      print('Categoria ativa: $categoria, Árvore ID: ${arvore.id} (Nome: ${arvore.nomeComum}, Valor: ${_getValorDaCategoriaParaDebug(arvore, categoria)})');
      print('IDs na lista de recordes ($categoria): $idsNaListaDeRecordes');
      // Opcional: Imprimir valores da lista de recordes para conferência
      // print('Valores na lista de recordes ($categoria): ${lista.map((r) => _getValorDaCategoriaParaDebug(r, categoria)).toList()}');
      print('Posição encontrada para ${arvore.id}: $pos');
    }

    return pos == 0 ? ' 🥇' : pos == 1 ? ' 🥈' : pos == 2 ? ' 🥉' : '';
  }

  @override
  Widget build(BuildContext context) {
    print('🔧 HomePage.build executado');
    return Scaffold(
      appBar: AppBar(title: const Text('Fruta no Pé')),
      drawer: construirDrawer(),
      body: Stack( // Usamos Stack para sobrepor o indicador de progresso ou erro
        children: [
          MapaWidget(
            arvores: aplicarFiltro(),
            controller: mapController,
            medalhaCallback: medalhaSeForTop,
            onBoundsChanged: (bounds) {
              if (mounted) { // Verifica se o widget ainda está montado
                setState(() => mapaBounds = bounds);
              }
            },
            currentUserLocation: _currentLocationMarkerPosition, // Passar a posição atual
            subfiltroEspecial: subfiltroEspecial, // Passar o subfiltro para o MapaWidget
            pontosDaRota: _pontosDaRota, // Passar os pontos da rota
            exibirRota: _exibirRotaNoMapa, // Passar o controle de visibilidade da rota
            onMostrarRota: _mostrarRotaNoMapa, // Passar a callback para mostrar a rota
            centroInicial: cidadesInfo[_cidadeSelecionada]!.centro, // Centro inicial baseado na cidade
            zoomInicial: cidadesInfo[_cidadeSelecionada]!.zoomInicial, // Zoom inicial baseado na cidade
          ),
          if (_isLoading) const LoadingOverlay(),
          if (_loadingError != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.red.withOpacity(0.6),
                child: Text(
                  _loadingError!,
                  style: const TextStyle(color: Color.fromARGB(255, 189, 189, 189)),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final posicao = await LocalizacaoService.obterLocalizacao();
          if (posicao != null) {
            final newLocation = LatLng(posicao.latitude, posicao.longitude);
            if (mounted) { // Verifica se o widget ainda está montado
              setState(() {
                _currentLocationMarkerPosition = newLocation; // Atualiza a posição do marcador
                _limparRotaDoMapa(); // Limpa qualquer rota existente ao buscar nova localização
              });
            }
            // Adia a movimentação do mapa para após o frame
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) { // Verifica apenas se o widget ainda está montado
                mapController.move( // Verifica apenas se o widget ainda está montado
                  newLocation,
                  17.0, // Zoom level, ajuste conforme necessário
                );
                print('🗺️ Mapa movido para a localização do usuário: $newLocation');
              }
            });
          } else {
            // Verifica se o widget ainda está montado antes de mostrar o SnackBar
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Não foi possível obter sua localização.')),
            );
          }
        },
        tooltip: 'Minha Localização',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget construirDrawer() {
    final filtros = ['todas', 'frutiferas', 'flores', 'curiosidades', 'nao_catalogadas'];

    return Drawer(
      backgroundColor: Theme.of(context).canvasColor.withOpacity(0.6),
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              // Faz o fundo do DrawerHeader transparente para usar o backgroundColor do Drawer
              color: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cidade', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<CidadeDisponivel>(
                  value: _cidadeSelecionada,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  ),
                  isExpanded: true,
                  items: CidadeDisponivel.values.map((cidade) {
                    return DropdownMenuItem<CidadeDisponivel>(
                      value: cidade,
                      child: Text(
                        cidade.toString().split('.').last[0].toUpperCase() + 
                        cidade.toString().split('.').last.substring(1)
                      ),
                    );
                  }).toList(),
                  onChanged: (CidadeDisponivel? novaCidade) async {
                    if (novaCidade != null && novaCidade != _cidadeSelecionada) {
                      setState(() {
                        _cidadeSelecionada = novaCidade;
                        _isLoading = true;
                        // Limpa os filtros ao mudar de cidade
                        filtroSelecionado = 'todas';
                        _especieFrutiferaSelecionada = null;
                        subfiltroEspecial = null;
                        _limparRotaDoMapa();
                      });
                      // Recarrega os dados da nova cidade e centraliza o mapa
                      await _carregarDadosArvores();
                      _atualizarPosicaoMapa();
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          for (var f in filtros)
            ListTile(
              title: Text(
                f == 'frutiferas'
                    ? 'Frutíferas'
                    : f == 'flores'
                        ? 'Flores'
                        : f == 'curiosidades'
                            ? 'Especiais'
                            : f == 'nao_catalogadas'
                                ? 'Não catalogadas'
                                : 'Todas (catalogadas)',
              ),
              leading: Radio<String>(
                value: f,
                groupValue: filtroSelecionado,
                onChanged: (value) {
                  setState(() {
                    filtroSelecionado = value!;
                    subfiltroEspecial = null;
                    if (value != 'frutiferas')
                    _especieFrutiferaSelecionada = null; // Reseta a espécie selecionada
                    _limparRotaDoMapa(); // Limpa a rota ao mudar de filtro principal
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          // Adiciona o Dropdown de espécies se o filtro "Frutíferas" estiver selecionado
          if (filtroSelecionado == 'frutiferas') ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0), // Ajusta padding
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Selecionar Espécie',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                ),
                value: _especieFrutiferaSelecionada,
                hint: const Text('Todas as espécies'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem<String>(
                    value: null, // Representa "Todas as espécies"
                    child: Text('Todas as espécies'),
                  ),
                  ..._listaEspeciesFrutiferasDinamica.map((String especie) {
                    return DropdownMenuItem<String>(
                      value: especie,
                      // Exibe o nome da espécie e sua contagem
                      child: Text('$especie (${_especiesContagem[especie] ?? 0})'),
                    );
                  }).toList(),
                ],
                onChanged: (String? novoValor) {
                  setState(() => _especieFrutiferaSelecionada = novoValor);
                },
              ),
            ),
          ],
          



          if (filtroSelecionado == 'curiosidades') ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Subfiltro', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            // Adiciona 'frutiferas_por_especie' à lista de subfiltros
            for (var s in ['altura', 'idade', 'circunfere', 'diametro', 'dap'])
              ListTile(
                title: Text(
                  s == 'altura'
                      ? 'Mais Altas'
                      : s == 'idade'
                          ? 'Mais Velhas'
                      : s == 'circunfere'
                          ? 'Maiores Circunferências'
                          : s == 'diametro'
                              ? 'Mais Largas'
                              : s == 'dap'
                                  ? 'Maiores Diametros à 1,30m'
                                  : 'Maiores Alturas',
                ),
                leading: Radio<String>(
                  value: s,
                  groupValue: subfiltroEspecial,
                  onChanged: (value) {
                    setState(() {
                       subfiltroEspecial = value;
                       _especieFrutiferaSelecionada = null; // Reseta a espécie ao mudar de subfiltro
                       _limparRotaDoMapa(); // Limpa a rota ao mudar de subfiltro
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }
}