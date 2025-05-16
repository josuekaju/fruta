import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/arvore.dart';
import '../services/geojson_loader.dart';
import '../widgets/mapa_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MapController mapController = MapController();
  LatLngBounds? mapaBounds;
  bool _isLoading = true; // Adiciona um estado para controlar o carregamento inicial
  String? _loadingError; // Adiciona um estado para armazenar mensagens de erro

  @override
  void initState() {
    super.initState();
    _carregarDadosArvores();
  }

  Future<void> _carregarDadosArvores() async {
    try {
      final arvores = await GeoJsonLoader.carregarArvores();
      if (mounted) {
        _atualizarListas(arvores);
        setState(() {
          _isLoading = false;
        });
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

  void _atualizarListas(List<Arvore> arvores) {
    _todas = arvores;
    _frutiferas = arvores.where((a) => a.tipoEspe0).toList();
    _flores = arvores.where((a) => a.tipoEspe1).toList();
    // Corrigido: Verifica se tipoEspec é a string "0" para "não catalogadas"
    _naoCatalogadas = arvores.where((a) => a.tipoEspec == 0).toList();
    // Corrigido: Verifica se tipoEspec é diferente da string "0" para "catalogadas"
    _catalogadas = arvores.where((a) => a.tipoEspec != 0).toList();
    if (arvores.isNotEmpty) { // Calcula recordistas apenas se houver árvores
      
    print('Exemplo tipoEspec: ${_todas.take(5).map((a) => a.tipoEspec)}');


    calcularRecordistas(arvores);
    }
    if (mounted) setState(() {});
  }

  List<Arvore> aplicarFiltro() {
    final List<Arvore> base = switch (filtroSelecionado) {
      'frutiferas' => _frutiferas,
      'flores' => _flores,
      'nao_catalogadas' => _naoCatalogadas,
      'curiosidades' => _todas,
      _ => _catalogadas,
    };

    if (filtroSelecionado == 'curiosidades' && subfiltroEspecial != null) {
    return getRecordistas(base);
    }

    final visiveis = base.where(dentroDoMapa).toList();
    return visiveis.length > 420 ? visiveis.take(420).toList() : visiveis;
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

  void calcularRecordistas(List<Arvore> arvores) {
    recordistasPorCategoria['altura'] = _topN(arvores, (a) => a.altura);
    recordistasPorCategoria['idade'] = _topN(arvores, (a) => a.idadeAproximada.toDouble());
    recordistasPorCategoria['circunfere'] = _topN(arvores, (a) => a.circunfere);
    recordistasPorCategoria['diametro'] = _topN(arvores, (a) => a.diametroE);
    recordistasPorCategoria['dap'] = _topN(arvores, (a) => a.dap);
    

    // Logs de debug
    print('TOP Alturas: ${recordistasPorCategoria['altura']?.map((a) => a.altura.toStringAsFixed(1)).join(', ')}m');
    print('TOP DAPs: ${recordistasPorCategoria['dap']?.map((a) => a.dap.toStringAsFixed(1)).join(', ')}cm');
    print('TOP Idades: ${recordistasPorCategoria['idade']?.map((a) => a.idadeAproximada).join(', ')} anos');
    print('TOP Circunferências: ${recordistasPorCategoria['circunfere']?.map((a) => a.circunfere.toStringAsFixed(1)).join(', ')}cm');
    print('TOP Diâmetros: ${recordistasPorCategoria['diametro']?.map((a) => a.diametroE.toStringAsFixed(1)).join(', ')}cm');
  } 

  List<Arvore> _topN(List<Arvore> lista, double Function(Arvore) key) {
    final validas = lista.where((a) => key(a) > 0).toList();
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
          ),
          if (_isLoading)
            // Tela de carregamento personalizada
            Container(
              color: Colors.black.withOpacity(0.7), // Fundo escuro semi-transparente
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'A natureza exige paciência...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          if (_loadingError != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.red.withOpacity(0.6),
                child: Text(
                  _loadingError!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
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
            child: const Text('Filtros'),
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
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          if (filtroSelecionado == 'curiosidades') ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Subfiltro', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
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
                    setState(() => subfiltroEspecial = value);
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
