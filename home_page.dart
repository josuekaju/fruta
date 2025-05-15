import 'package:flutter/material.dart';
import '../models/arvore.dart';
import '../services/geojson_loader.dart';
import '../widgets/mapa_widget.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});
  late Map<String, List<Arvore>> recordistasPorCategoria;

void calcularRecordistas(List<Arvore> arvores) {
  recordistasPorCategoria['altura'] = _top3(arvores, (a) => a.altura);
  recordistasPorCategoria['circunfere'] = _top3(arvores, (a) => a.circunfere);
  recordistasPorCategoria['diametro'] = _top3(arvores, (a) => a.diametroE);
  recordistasPorCategoria['dap'] = _top3(arvores, (a) => a.dap);
  recordistasPorCategoria['idade'] = _top3(arvores, (a) => a.idadeAproximada.toDouble());
}

List<Arvore> _top3(List<Arvore> lista, double Function(Arvore) key) {
  final validas = lista.where((a) => key(a) > 0).toList();
  validas.sort((a, b) => key(b).compareTo(key(a)));
  return validas.take(3).toList();
}

String medalhaSeForTop(String categoria, Arvore arvore) {
  final lista = recordistasPorCategoria[categoria] ?? [];
  final pos = lista.indexWhere((a) => a.id == arvore.id);
  return pos == 0 ? ' 🥇' : pos == 1 ? ' 🥈' : pos == 2 ? ' 🥉' : '';
}


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Map<String, List<Arvore>> recordistasPorCategoria;

void calcularRecordistas(List<Arvore> arvores) {
  recordistasPorCategoria['altura'] = _top3(arvores, (a) => a.altura);
  recordistasPorCategoria['circunfere'] = _top3(arvores, (a) => a.circunfere);
  recordistasPorCategoria['diametro'] = _top3(arvores, (a) => a.diametroE);
  recordistasPorCategoria['dap'] = _top3(arvores, (a) => a.dap);
  recordistasPorCategoria['idade'] = _top3(arvores, (a) => a.idadeAproximada.toDouble());
}

List<Arvore> _top3(List<Arvore> lista, double Function(Arvore) key) {
  final validas = lista.where((a) => key(a) > 0).toList();
  validas.sort((a, b) => key(b).compareTo(key(a)));
  return validas.take(3).toList();
}

String medalhaSeForTop(String categoria, Arvore arvore) {
  final lista = recordistasPorCategoria[categoria] ?? [];
  final pos = lista.indexWhere((a) => a.id == arvore.id);
  return pos == 0 ? ' 🥇' : pos == 1 ? ' 🥈' : pos == 2 ? ' 🥉' : '';
}

  late Future<List<Arvore>> _carregarArvores;
  String filtroSelecionado = 'todas';
  String? subfiltroEspecial;
  List<String> filtros = ['todas', 'frutiferas', 'flores', 'curiosidades'];

  @override
  void initState() {
    super.initState();
    _carregarArvores = GeoJsonLoader.carregarArvores();
    recordistasPorCategoria = {
      'altura': [],
      'circunfere': [],
      'diametro': [],
      'dap': [],
      'idade': [],
    };
  }

  // Replaced aplicarFiltro method
  List<Arvore> aplicarFiltro(List<Arvore> lista) {
    final filtradas = lista.where((a) {
      switch (filtroSelecionado) {
        case 'frutiferas': return a.tipoEspe0; // Assuming tipoEspe0 is bool
        case 'flores': return a.tipoEspe1;     // Assuming tipoEspe1 is bool
        case 'curiosidades': return true; // Filtered further down if subfiltroEspecial is set
        default: return true; // 'todas' or any other case
      }
    }).toList();

    if (filtroSelecionado == 'curiosidades' && subfiltroEspecial != null) {
      return getRecordistas(filtradas); // 'filtradas' here are all trees if 'curiosidades' was selected
    }

    // If the list is very large, limit to 1000 for performance
    // This applies to 'frutiferas', 'flores', 'todas',
    // and 'curiosidades' when subfiltroEspecial is null.
    return filtradas.length > 1000 ? filtradas.take(1000).toList() : filtradas;
  }

  List<Arvore> getRecordistas(List<Arvore> arvores) {
  if (arvores.isEmpty) return [];

  double Function(Arvore) key;
  bool Function(Arvore) filtroValido = (a) => true; // ← aqui está a correção
  
  switch (subfiltroEspecial) {
    case 'altura': key = (a) => a.altura; filtroValido = (a) => a.altura > 0; break;
    case 'circunfere': key = (a) => a.circunfere; filtroValido = (a) => a.circunfere > 0; break;
    case 'diametro': key = (a) => a.diametroE; filtroValido = (a) => a.diametroE > 0; break;
    case 'dap': key = (a) => a.dap; filtroValido = (a) => a.dap > 0; break;
    case 'idade': key = (a) => a.idadeAproximada.toDouble(); filtroValido = (a) => a.idadeAproximada > 0; break;
    default: key = (a) => a.altura; break; // Default key if subfiltroEspecial is null or not matched
  }

  final validas = arvores.where(filtroValido).toList();
  if (validas.isEmpty) return [];
  int n = (validas.length / 10).ceil().clamp(1, validas.length); // Get top 10% or at least 1
  validas.sort((a, b) => key(b).compareTo(key(a)));

  return validas.take(n).toList();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Árvores de Toledo'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white.withOpacity(0.6),
        child: ListView(
  children: [
    const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    ),
    for (var f in filtros)
      ListTile(
        title: Text(
          f == 'frutiferas' ? 'Frutíferas' :
          f == 'flores' ? 'Flores' :
          f == 'curiosidades' ? 'Especiais' : 'Todas'
        ),
        leading: Radio<String>(
          value: f,
          groupValue: filtroSelecionado,
          onChanged: (value) {
            setState(() {
              filtroSelecionado = value!;
              subfiltroEspecial = null; // limpa subfiltro quando troca filtro principal
            });
            Navigator.pop(context);
          },
        ),
      ),

    if (filtroSelecionado == 'curiosidades') ...[
      const Divider(),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text('Subfiltro Especiais', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      for (var s in ['altura', 'circunfere', 'diametro', 'dap', 'idade'])
        ListTile(
          title: Text(
            s == 'altura' ? 'Mais Altas' :
            s == 'circunfere' ? 'Maior Circunferência' :
            s == 'diametro' ? 'Maior Diâmetro (base)' :
            s == 'dap' ? 'Maior DAP (1.30m)' : 'Mais Velhas (aprox.)',
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

      ),
      body: FutureBuilder<List<Arvore>>(
        future: _carregarArvores,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final todasArvores = snapshot.data ?? [];
          if (todasArvores.isNotEmpty) { // Ensure recordistas are calculated only if data is available
            calcularRecordistas(todasArvores); // Atualiza os top 3 para cada categoria
          }
          final arvoresFiltradas = aplicarFiltro(todasArvores);


          return MapaWidget(
            arvores: arvoresFiltradas,
            medalhaCallback: medalhaSeForTop,
          );
        },
      ),
    );
  }
}