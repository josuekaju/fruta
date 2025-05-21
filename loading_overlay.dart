import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class LoadingOverlay extends StatefulWidget {
  final Stream<double>? progressStream; // Stream de 0.0 a 1.0

  const LoadingOverlay({super.key, this.progressStream});

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  // Frase principal que ficará no centro
  static const String frasePrincipal = 'A natureza exige paciência...';
  static const String fraseEspecial = 'Não mexa na tela...';


  // Lista original de todas as frases
  static const List<String> _grupo1 = [
   // Grupo 1
    'Pergunte, porém, aos animais, e eles o ensinarão...',
    'Pergunte, porém, às aves do céu, e elas contarão a você...',
    'Fale com a terra, e ela o instruirá...',
    '"Deixe que os peixes do mar o informem..."',
    'Delas bebem todos os animais selvagens...',
    'Se te fatigas correndo com homens que vão a pé, Como poderás competir com os que vão a cavalo?..',
    'Se em terra de paz não te sentes seguro, que farás na floresta do Jordão?..',
    'Produza a terra erva verde, erva que dê semente, árvore frutífera que dê fruto',
    'a terra produziu erva, e viu Deus que era bom',
    'toda a erva que dê semente, e toda a árvore, em que há fruto que dê semente',
    'Não tenha inveja do homem violento, nem siga nenhum de seus caminhos.',
    'Um tempo para cada atividade debaixo do céu. Plante uma arvore...',
    'A Natureza criou os prazeres, o homem criou os excessos...',
    'Cada árvore tem seu inimigo, poucas têm um defensor...',
    'Nem tudo que reluz é ouro, Nem todos os que vagueiam estão perdidos...',
    'Atrapalhar a natureza é heresia. Mesmo quando a força da natureza parece destrutiva...',
    'Não seja tão havido a julgar os outros, nem mesmos os mais sábios conseguem ver o quadro todo...',
    'Mobilizariam a própria natureza para sua causa...',
    'Qual é a melhor data para plantar uma árvore? 20 anos atrás. E a segunda melhor? Hoje!',
    'Tudo o que temos de decidir é o que fazer com o tempo que nos é dado...',
    'Pode contar as maçãs de uma semente?',
    'Estamos aqui, no coração da floresta, para defender a nossa terra, as nossas árvores e o nosso lar...',
    'O planeta Terra, a nossa casa, cuide como seu jardim...',
    'A natureza é um tesouro que devemos proteger, a Mãe que nos dá a vida e nos sustenta...',
    'A guerra contra a natureza é uma guerra contra si mesmo'
    

  ];

    // Grupo 2
    static const List<String> _grupo2 = [
    // A frase especial será tratada separadamente no início
    'Devo proteger a terra...', 
    'Plantando sementes de curiosidade...',
    'Vá em direção às árvores...',
    'Apareceu um arco-íris...',
    'Atrapalhar a natureza é heresia...',
    'Observando o ciclo da vida...',
    'O tempo é o jardineiro da vida...',
    'Florescem aqueles que esperam...',
    '... Como competir com os que vão a cavalo?',
    'Pergunte aos animais, e eles o ensinarão...',
    'Pergunte às aves do céu, e elas contarão a você...',
    'Fale com a terra, e ela o instruirá...',
    'Não deixe que os peixes do mar nos informem...', 
    'Cada árvore tem sua estação...',
    'Quem ofende um rio, ofende Deus...',
    'A destruição do ambiente ofende a Deus...',
    'O tempo passa depressa...',
    'As raízes crescem no silêncio...',
    'Você sabia que o bambu chinês...',
    'Ah, o Bambu Chinês...',
    'A Última marcha... com rocha e pedra!',
    'Muitas dessas árvores eram minhas amigas.',
    'Observem os pássaros...',
    'Já olhou a lua hoje?..',
    'Mais um dia, todo seu...',
    'Que céu azul lou...',
    'É a selva de pedra... ela esmaga. ',
    'Não deixe que a natureza vire inimiga',
    'A cada amanhecer, um novo ciclo, uma nova oportunidade de viver...',
    'Matar a natureza é matar a todos...',
    'A beleza da natureza preenche a alma'

  ];

  // Lista de frases que irão alternar (excluindo a principal)
  late List<String> _frasesAlternantes;

  String _fraseTopo = '';
  String _fraseBaixo = '';
  int _contagemTopoEspecial = 0;
  int _contagemBaixoEspecial = 0;
  int _indiceTopo = 0;
  int _indiceBaixo = 0;

  double _opacidadeAlternantes = 1.0; // Opacidade para as frases topo e baixo
  Timer? _timer;

  static const Duration _duracaoExibicaoGrupo1 = Duration(milliseconds: 6300); // 6.3 segundos
  static const Duration _duracaoExibicaoGrupo2 = Duration(milliseconds: 4200); // 4.2 segundos
  static const Duration _duracaoFadeOut = Duration(milliseconds: 420); // Duração do fade out

  // Estilos de texto
  static const TextStyle _estiloPrincipal = TextStyle(
    color: Color.fromARGB(255, 200, 230, 200), // Um pouco mais brilhante
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle _estiloAlternante = TextStyle(
    color: Color.fromARGB(255, 180, 220, 180),
    fontSize: 18, // Um pouco menor
    fontWeight: FontWeight.w500,
  );

  @override
  void initState() {
    super.initState();
  if (kDebugMode) print("[LoadingOverlay] initState - Início");

    // Filtra as frases, excluindo a principal
    // e a frase especial, pois ela será tratada à parte no início.
    _frasesAlternantes = [
      ..._grupo1.where((f) => f != frasePrincipal && f != fraseEspecial && f.isNotEmpty),
      ..._grupo2.where((f) => f != frasePrincipal && f != fraseEspecial && f.isNotEmpty),
    ]
      .toSet() // Remove duplicatas entre _grupo1 e _grupo2
      .toList(); // Converte de volta para lista
    _frasesAlternantes.shuffle(); // Embaralha para variedade

    if (kDebugMode) print("[LoadingOverlay] initState - Frases alternantes (pós-especial) carregadas: ${_frasesAlternantes.length}");

    // Configura a primeira exibição da fraseEspecial
    _fraseTopo = fraseEspecial;
    _fraseBaixo = fraseEspecial;
  

    if (kDebugMode) print("[LoadingOverlay] initState - Primeira exibição especial: Topo='$_fraseTopo', Baixo='$_fraseBaixo'");

    _iniciarProximoCicloTimer();
  }

  void _iniciarProximoCicloTimer() {
    _timer?.cancel(); 

    Duration duracaoAtual = _getDuracaoParaFraseAtual();
    if (kDebugMode) print("[LoadingOverlay] Agendando timer para $duracaoAtual");

    _timer = Timer(duracaoAtual, () {
      if (kDebugMode) print("[LoadingOverlay] Timer disparou após $duracaoAtual - Montado: $mounted");
      if (!mounted) {
        if (kDebugMode) print("[LoadingOverlay] Timer - Widget não montado, retornando.");
        return;
      }
      setState(() {
        if (kDebugMode) print("[LoadingOverlay] Timer - SetState para opacidadeAlternantes = 0.0");
        _opacidadeAlternantes = 0.0; 
      });

      Future.delayed(_duracaoFadeOut, () {
        if (kDebugMode) print("[LoadingOverlay] Future.delayed (_duracaoFadeOut) - Montado: $mounted");
        if (!mounted) return;

        _atualizarFrasesAlternantes(); 
        if (kDebugMode) print("[LoadingOverlay] Future.delayed - Novas frases - Topo: '$_fraseTopo', Baixo: '$_fraseBaixo'");
        
        setState(() {
          if (kDebugMode) print("[LoadingOverlay] Future.delayed - SetState para opacidadeAlternantes = 1.0");
          _opacidadeAlternantes = 1.0; 
        });
        _iniciarProximoCicloTimer(); 
      });
    });
  }

  Duration _getDuracaoParaFraseAtual() {
    if (kDebugMode) print("[LoadingOverlay] _getDuracaoParaFraseAtual: Verificando duração. Topo='$_fraseTopo', Baixo='$_fraseBaixo', ContagemEspecial=$_contagemTopoEspecial");

    // 1. Tratar a fraseEspecial:
    // Se _fraseTopo ou _fraseBaixo for a fraseEspecial, significa que estamos em um dos 3 ciclos da frase especial.
    if (_fraseTopo == fraseEspecial || _fraseBaixo == fraseEspecial) {
      if (kDebugMode) print("[LoadingOverlay] _getDuracaoParaFraseAtual: Frase especial ativa. Retornando _duracaoExibicaoGrupo2");
      return _duracaoExibicaoGrupo2;
    }

    // 2. Frases Alternantes: Determinar duração baseada no conteúdo de _fraseTopo E _fraseBaixo
    bool topoEmGrupo1 = _grupo1.contains(_fraseTopo);
    // Considerar _fraseBaixo apenas se não estiver vazia
    bool baixoEmGrupo1 = _fraseBaixo.isNotEmpty && _grupo1.contains(_fraseBaixo);

    if (topoEmGrupo1 || baixoEmGrupo1) {
      if (kDebugMode) print("[LoadingOverlay] _getDuracaoParaFraseAtual: Alternando - uma ou ambas frases são do Grupo 1. Retornando _duracaoExibicaoGrupo1");
      return _duracaoExibicaoGrupo1;
    }

    // 3. Duração padrão (para frases do Grupo 2 ou se algo inesperado acontecer)
    // Todas as frases em _frasesAlternantes devem pertencer a _grupo1 ou _grupo2 (após filtragem).
    if (kDebugMode) print("[LoadingOverlay] _getDuracaoParaFraseAtual: Alternando - frases são do Grupo 2 ou padrão. Retornando _duracaoExibicaoGrupo2");
    return _duracaoExibicaoGrupo2; // Duração padrão ou para frases do Grupo 2
  }

  @override
  void dispose() {
    _timer?.cancel();
  if (kDebugMode) print("[LoadingOverlay] dispose - Timer cancelado.");
    super.dispose();
  }




  void _atualizarFrasesAlternantes() {

  // Lógica para frase de baixo
  if (_contagemBaixoEspecial < 1) {
    _fraseBaixo = fraseEspecial;
    _contagemBaixoEspecial++;
  } else {
    _fraseBaixo = _frasesAlternantes[_indiceBaixo % _frasesAlternantes.length];
    _indiceBaixo++;
  }

  // Lógica para frase do topo
  if (_contagemTopoEspecial < 1) {
    _fraseTopo = fraseEspecial;
    _contagemTopoEspecial++;
  } else {
    _fraseTopo = _frasesAlternantes[_indiceTopo % _frasesAlternantes.length];
    _indiceTopo++;
  }

  // Garantir que não mostre a mesma frase nos dois lugares
  // Esta condição verifica se ambas as frases vieram da lista _frasesAlternantes
  // e se a lista tem mais de uma opção para escolher uma frase diferente.
  if (_fraseTopo == _fraseBaixo &&
      _frasesAlternantes.length > 1 &&
      _contagemTopoEspecial >= 2 && // Significa que _fraseTopo veio de _frasesAlternantes
      _contagemBaixoEspecial >= 1) { // Significa que _fraseBaixo veio de _frasesAlternantes
    
    // Se _fraseTopo e _fraseBaixo colidiram (eram a mesma frase P):
    // _fraseTopo (para exibição) é P.
    // _indiceTopo já foi incrementado e aponta para a próxima frase para o topo no ciclo seguinte.
    // _indiceBaixo também já foi incrementado.

    // Avança _indiceTopo um passo extra. Isso ajuda a evitar que o _fraseTopo do PRÓXIMO ciclo
    // seja a frase que _fraseBaixo está prestes a ser resolvida NESTE ciclo.
    _indiceTopo++;

    // Resolve _fraseBaixo para a próxima frase disponível, usando o _indiceBaixo já incrementado.
    _fraseBaixo = _frasesAlternantes[_indiceBaixo % _frasesAlternantes.length];
    _indiceBaixo++; // Avança _indiceBaixo novamente para o seu próximo turno.
  }
}
    

  @override
  Widget build(BuildContext context) {
  if (kDebugMode) print("[LoadingOverlay] build - fraseTopo: '$_fraseTopo', fraseBaixo: '$_fraseBaixo', opacidade: $_opacidadeAlternantes");
    return Container(
      color: Colors.black.withOpacity(0.7),
      padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 20.0), // Aumenta o padding vertical
      child: Stack( // Alterado de Column para Stack
        children: [
          // Frase do Topo (alternante)
          Align( // Alinha ao topo central
            alignment: Alignment.topCenter,
            child: AnimatedOpacity(
              opacity: _opacidadeAlternantes,
              duration: _duracaoFadeOut,
              child: Text(
                _fraseTopo,
                style: _estiloAlternante,
                textAlign: TextAlign.center,
                key: ValueKey<String>("top_$_fraseTopo"),
              ),
            ),
          ),

          // Parte Central (agrupada para manter no meio)
          Center( // Centraliza este conteúdo na Stack
            child: widget.progressStream == null
                ? Column( // Conteúdo original se não houver stream de progresso
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        frasePrincipal,
                        style: _estiloPrincipal,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : StreamBuilder<double>( // StreamBuilder para exibir o progresso
                    stream: widget.progressStream, // Usar o stream passado para o widget
                    builder: (context, snapshot) {
                      final progress = snapshot.data ?? 0.0; // Default para 0.0 se não houver dados ainda
                      return Text('Carregando ${(progress * 100).toStringAsFixed(1)}%', style: _estiloPrincipal, textAlign: TextAlign.center,);
                    },
                  ),
          ),

          // Frase de Baixo (alternante)
          Align( // Alinha à base central
            alignment: Alignment.bottomCenter,
            child: Padding( // Adicionado Padding
              padding: const EdgeInsets.only(bottom: 30.0), // Ajuste este valor conforme necessário
              child: AnimatedOpacity(
                opacity: _opacidadeAlternantes,
                duration: _duracaoFadeOut,
                child: Text(
                  _fraseBaixo,
                  style: _estiloAlternante,
                  textAlign: TextAlign.center,
                  key: ValueKey<String>("bottom_$_fraseBaixo"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}