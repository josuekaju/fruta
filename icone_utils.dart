import '../models/arvore.dart'; // Certifique-se que este import está correto

String getEmojiForArvore(
    Arvore arvore, {
  // Definindo o tipo da callback diretamente para evitar dependência de import do widget,
  String Function(String categoria, Arvore arvore)? medalhaCallback,
  String? subfiltroEspecial,
}) {
  final nome = (arvore.nomeComum ?? '').trim().toLowerCase();
  final nomeCientifico = (arvore.nomeCientifico ?? '').trim().toLowerCase();

  // --- SEÇÃO: FRUTÍFERAS ---
  // Aplicar estas regras se a árvore estiver marcada como frutífera (arvore.tipoEspe0).
  if (arvore.tipoEspe0) {
    // Casos Específicos e de Advertência (FRUTAS com aviso)
    if (nome.contains('aroeira-pimenta') || nomeCientifico.contains('schinus terebinthifolia')) return '🌶️';
    if (nome.contains('figueira mata pau') || nomeCientifico.contains('ficus insipida')) return '⚠️';
    if (nome.contains('porangaba') || nomeCientifico.contains('cordia ecalyculata')) return '🍵'; // Mais medicinal/chá
    if (nome.contains('espinheira-santa') || nomeCientifico.contains('monteverdia ilicifolia')) return '💊'; // Medicinal

    // Frutas mais comuns e com emojis dedicados
    if (nome.contains('mangueira') || nome.contains('manga')) return '🥭';
    if (nome.contains('coqueiro') || nome.contains('coco') || nomeCientifico.contains('cocos nucifera')) return '🥥';
    if (nome.contains('abacateiro') || nome.contains('abacate')) return '🥑';
    if (nome.contains('aceroleira') || nome.contains('acerola')) return '🍒';
    if (nome.contains('caramboleira') || nome.contains('carambola')) return '⭐';
    if (nome.contains('lichieira') || nome.contains('lichia')) return '🫕';
    if (nome.contains('romeira') || nome.contains('romã') || nomeCientifico.contains('punica granatum')) return '🫖';

    // Citrus
    if (nome.contains('tangerineira') || nome.contains('tangerina') || nome.contains('mexerica') || nome.contains('bergamota') || nomeCientifico.contains('citrus reticulata')) return '🍊';
    if (nome.contains('laranjeira') || nome.contains('laranja')) return '🍊';
    if (nome.contains('limoeiro') || nome.contains('limão')) return '🍋';
    if (nome.contains('citrus')) return '🍊'; // Genérico para outros citrus

    // Anonáceas
    if (nome.contains('gravioleira') || nome.contains('graviola')) return '🟢';
    if (nome.contains('fruta-do-conde') || nome.contains('pinha') || nome.contains('ata')) return '🟢';
    if (nome.contains('condessa')) return '🟢';
    if (nome.contains('araticum')) return '🟢';

    // Eugenias e similares
    if (nome.contains('pitangueira') || nome.contains('pitanga')) return '🍒';
    if (nome.contains('cerejeira') || nome.contains('cereja') && (nome.contains('rio grande') || nomeCientifico.contains('eugenia involucrata'))) return '🍒';
    if (nome.contains('cerejinha-silvestre') || nomeCientifico.contains('eugenia mattosii')) return '🍒';
    if (nome.contains('uvaia')) return '🟡';
    if (nome.contains('grumixameira') || nome.contains('grumixama')) return '🔴';
    if (nome.contains('araçá')) return '🔴';

    // Spondias
    if (nome.contains('ceriguela') || nome.contains('siriguela')) return '🍑';
    if (nome.contains('cajamanga') || nome.contains('cajarana')) return '🍏';

    // Jaca e Caqui
    if (nome.contains('jaqueira') || nome.contains('jaca')) return '🍈';
    if (nome.contains('caquizeiro') || nome.contains('caqui')) return '🍅';

    // Palmeiras Frutíferas
    if (nome.contains('jerivá') || nomeCientifico.contains('syagrus romanzoffiana')) return '🥥'; // Coquinhos
    if (nome.contains('butiazeiro') || nome.contains('butiá') || nomeCientifico.contains('butia capitata')) return '🟠';
    if (nome.contains('açaizeiro') || nome.contains('açai')) return '🟣';
    if (nome.contains('palmito') || nome.contains('juçara')) return '🌴'; // Foco no palmito/árvore
    if (nome.contains('tamareira') || nome.contains('tâmara')) return '🌴'; // Fruto é 🟤

    // Castanhas e sementes
    if (nome.contains('monguba') || nomeCientifico.contains('pachira aquatica')) return '🌰';
    if (nome.contains('castanha-do-maranhão') || nomeCientifico.contains('pachira glabra')) return '🌰';
    if (nome.contains('sete-copas') || nome.contains('amendoeira-da-praia')) return '🌰';
    if (nome.contains('araucária') || nome.contains('pinheiro-do-paraná')) return '🌲'; // Fruto (pinhão) é 🌰

    // Vagens Comestíveis
    if (nome.contains('inga') || nome.contains('ingazeiro')) return '🫛';
    if (nome.contains('feijão-guandu') || nome.contains('guandu')) return '🫛';
    if (nome.contains('tamarindeiro') || nome.contains('tamarindo')) return '🟤';
    if (nome.contains('mata-fome')) return '🫛';

    // Outras frutas
    if (nome.contains('goiabeira') || nome.contains('goiaba')) return '🍈';
    if (nome.contains('ameixa-amarela') || nome.contains('nêspera') || nomeCientifico.contains('eriobotrya japonica')) return '🍑';
    if (nome.contains('amoreira') || nome.contains('amora')) return '🟣';
    if (nome.contains('jabuticabeira') || nome.contains('jabuticaba') || nomeCientifico.contains('plinia')) return '⚫';
    if (nome.contains('jabolão') || nome.contains('jamelão') || nomeCientifico.contains('syzygium cumini')) return '⚫';
    if (nome.contains('uva-do-japão')) return '🍇';
    if (nome.contains('maçã-de-elefante') || nomeCientifico.contains('dillenia indica')) return '🍏';
    if (nome.contains('cajueiro') || nome.contains('caju')) return '🍑';
    if (nome.contains('gabiroba') || nome.contains('guabiroba')) return '🟡';
    if (nome.contains('jambo-vermelho') || nomeCientifico.contains('syzygium malaccense')) return '🔴';
    if ((nome.contains('jamboeiro') || nome.contains('jambo')) && nomeCientifico.contains('syzygium jambos')) return '🟠';
    if (nome.contains('mutamba')) return '⚫';
    if (nome.contains('olho-de-dragão') || nome.contains('longan')) return '🟤';
    if (nome.contains('abricó-da-praia')) return '🟠';
    if (nome.contains('abricó') && !nome.contains('praia') && (nomeCientifico.contains('mimusops elengi') || nomeCientifico.contains('pouteria caimito')) ) return '🟠';
    if (nome.contains('noni')) return '🍈';
    if (nome.contains('ameixeira') || nome.contains('ameixa') && !nome.contains('amarela')) return '🍑';

    // Plantas com outras partes comestíveis ou usos específicos (FRUTAS)
    if (nome.contains('oiti')) return '🟠';
    if (nome.contains('moringueira') || nome.contains('moringa')) return '🌱';
    if (nome.contains('jatobazeiro') || nome.contains('jatobá')) return '🌳'; // Fruto (polpa) 🟤
    if (nome.contains('ora-pro-nobis')) return '🌵';
    if (nome.contains('cordia') && nomeCientifico.contains('cordia myxa')) return '⚪';
    if (nome.contains('canela') || nome.contains('caneleira') || nomeCientifico.contains('cinnamomum')) return '🌿'; // Canela

    // Genérico para Figueiras (FRUTAS)
    if (nome.contains('figueira') || nome.contains('figo')) return ' figo'; // Emoji de figo? Ou outro?

    // Uva genérica (FRUTAS)
    if (nome.contains('uva') || nome.contains('parreira') && !nome.contains('uvaia') && !nome.contains('uva-do-japão')) return '🍇';
  }

  // --- SEÇÃO: FLORES E ORNAMENTAIS (Aplicar se NÃO for frutífera prioritária OU se for categoria "ornamental")

  // Plantas Tóxicas com Flores Vistosas
  if (nomeCientifico.contains('nerium oleander')) return '⚠️';
  if (nomeCientifico.contains('thevetia peruviana')) return '⚠️';
  if (nomeCientifico.contains('allamanda cathartica')) return '⚠️';
  if (nomeCientifico.contains('brugmansia suaveolens')) return '⚠️';
  if (nomeCientifico.contains('melia azedarach')) return '⚠️';
  if (nomeCientifico.contains('jatropha multifida')) return '⚠️';
  if (nomeCientifico.contains('robinia pseudoacacia')) return '⚠️';
  if (nomeCientifico.contains('solanum mauritianum')) return '⚠️';

  // Plantas Tóxicas (Foco na Folhagem/Forma)
  if (nomeCientifico.contains('euphorbia tirucalli')) return '⚠️';
  if (nomeCientifico.contains('euphorbia pulcherrima')) return '⚠️';
  if (nomeCientifico.contains('euphorbia candelabrum')) return '⚠️';

  // Ipês
  if (nome.contains('ipê-roxo') || nomeCientifico.contains('handroanthus impetiginosus') || nomeCientifico.contains('handroanthus heptaphyllus')) return '🌸';
  if (nome.contains('ipê-amarelo') || nomeCientifico.contains('handroanthus chrysotrichus') || nomeCientifico.contains('handroanthus ochraceus') || nomeCientifico.contains('handroanthus umbellatus')) return '🌼';
  if (nome.contains('ipê-branco') || nomeCientifico.contains('tabebuia roseoalba')) return '🌸';
  if (nome.contains('ipê-rosa') || nomeCientifico.contains('tabebuia rosea')) return '🌸';

  // Flamboyants e similares
  if (nome.contains('flamboyant') && !nome.contains('inho')) return '🔴';
  if (nome.contains('flamboyanzinho')) return '🟠';

  // Escovas-de-garrafa
  if (nome.contains('escova-de-garrafa') || nomeCientifico.contains('callistemon')) return '🔴';
  
  // Hibiscus
  if (nome.contains('hibisco-sinensis') || (nome.contains('hibisco') && nomeCientifico.contains('hibiscus rosa-sinensis'))) return '🌺';
  if (nome.contains('algodão-de-praia') || nomeCientifico.contains('hibiscus tiliaceus')) return '🌼';
  if (nome.contains('aurora') || nomeCientifico.contains('hibiscus mutabilis')) return '🌸';
  if (nome.contains('hibisco-do-brejo') || nomeCientifico.contains('talipariti pernambucense')) return '🌼';
  if (nome.contains('hibisco')) return '🌺';

  // Jasmins e Perfumadas
  if (nome.contains('jasmim-manga') || nomeCientifico.contains('plumeria rubra')) return '🌸';
  if (nome.contains('buquê-de-noiva') || nomeCientifico.contains('plumeria pudica')) return '🌸';
  if (nome.contains('gardênia')) return '🌸';
  if (nome.contains('jasmim-café')) return '🌸';
  if (nome.contains('dama-da-noite')) return '🌟';
  if (nome.contains('murta')) return '🌸';

  // Palmeiras Ornamentais
  if (nome.contains('palmeira-fênix') || nomeCientifico.contains('phoenix roebelenii')) return '🌴';
  if (nome.contains('palmeira-real') || nomeCientifico.contains('archontophoenix cunninghamiana')) return '🌴';
  if (nome.contains('palmeira-imperial') || nomeCientifico.contains('roystonea oleracea')) return '🌴';
  if (nome.contains('areca-bambu') || nomeCientifico.contains('dypsis lutescens')) return '🌴';
  if (nome.contains('palmeira-ráfia') || nomeCientifico.contains('rhapis excelsa')) return '🌴';
  if (nome.contains('palmeira-rabo-de-raposa') || nomeCientifico.contains('wodyetia bifurcata')) return '🌴';
  if (nome.contains('palmeira-triangular') || nomeCientifico.contains('dypsis decary')) return '🌴';
  if (nome.contains('palmeira-rabo-de-peixe') || nomeCientifico.contains('caryota urens')) return '🌴';
  if (nome.contains('palmeira-de-leque-chinesa') || nomeCientifico.contains('livistona chinensis')) return '🌴';
  if (nome.contains('palmeira-elegance') || nomeCientifico.contains('ptychosperma elegans')) return '🌴';
  if (nome.contains('palmeira-azul') || nomeCientifico.contains('bismarckia nobilis')) return '🌴';
  if (nome.contains('palmeira-leque') || nomeCientifico.contains('trithrinax brasiliensis')) return '🌴';
  if (nome.contains('palmeira')) return '🌴'; // Genérico para outras palmeiras ornamentais

  // Outras Flores Vistosas
  if (nome.contains('sibipiruna')) return '🌼';
  if (nome.contains('resedá')) return '🌸';
  if (nome.contains('quaresmeira')) return '🌸';
  if (nome.contains('brinco-de-índio')) return '🌸';
  if (nome.contains('pata-de-vaca') || nome.contains('unha-de-vaca')) return '🌸';
  if (nome.contains('manacá-da-serra') || nome.contains('manacá-de-cheiro')) return '🌸';
  if (nome.contains('primavera') || nomeCientifico.contains('bougainvillea')) return '🌸';
  if (nome.contains('tipuana')) return '🌼';
  if (nome.contains('violeteira')) return '💜';
  if (nome.contains('esponjinha') || nome.contains('caliandra')) return '🌸';
  if (nome.contains('grevílea')) return '🟠';
  if (nome.contains('magnólia-amarela') || nomeCientifico.contains('magnolia champaca')) return '🌼';
  if (nome.contains('magnólia') && nomeCientifico.contains('magnolia liliflora')) return '🌸';
  if (nome.contains('pinha-do-brejo') || nomeCientifico.contains('magnolia ovata')) return '🌸';
  if (nome.contains('coreutéria')) return '🌼';
  if (nome.contains('cerejeira-do-japão')) return '🌸';
  if (nome.contains('jacarandá')) return '💜';
  if (nome.contains('fedegoso')) return '🌼';
  if (nome.contains('canafístula')) return '🌼';
  if (nome.contains('chuva-de-ouro')) return '🌼';
  if (nome.contains('justícia-vermelha')) return '🔴';
  if (nome.contains('espatódea')) return '🟠';
  if (nome.contains('angico branco')) return '🌸';
  if (nome.contains('amarelinho') || nome.contains('ipê-de-jardim')) return '🌼';
  if (nome.contains('acácia-mimosa')) return '🌼';
  if (nome.contains('eritrina') || nome.contains('brasileirinha')) return '🔴';
  if (nome.contains('urucum')) return '🌸';
  if (nome.contains('dedaleiro')) return '🌼';
  if (nome.contains('ixora')) return '🔴';
  if (nome.contains('clúsia')) return '🌸';
  if (nome.contains('yuca')) return '🌸';
  if (nome.contains('guapuruvu')) return '🌼';
  if (nome.contains('azaléia')) return '🌸';
  if (nome.contains('paineira')) return '🌸';
  if (nome.contains('camélia')) return '🌸';
  if (nome.contains('flor-camarão')) return '🌼';
  if (nome.contains('sininho') || nome.contains('flor-de-sino')) return '🏮';
  if (nome.contains('cássia') && nomeCientifico.contains('senna multijuga')) return '🌼';
  if (nome.contains('triális')) return '🌼';
  if (nome.contains('mirindiba')) return '🌼';
  if (nome.contains('campainha-de-canudo')) return '🌸';
  if (nome.contains('sombreiro')) return '💜';
  if (nome.contains('astrapéia')) return '🌸';
  if (nome.contains('mussaendra')) return '🌸';
  if (nome.contains('kiri-japonês')) return '💜';
  if (nome.contains('manto-de-rei')) return '💜';
  if (nome.contains('chuva de prata')) return '💜';
  if (nome.contains('crista-de-galo')) return '🌸';

  // Plantas Ornamentais pela Folhagem/Forma
  if (nome.contains('alfeneiro') || nomeCientifico.contains('ligustrum lucidum')) return '🌿';
  if (nome.contains('aroeira-salsa')) return '🌿'; // Diferente da aroeira-pimenta (fruta com aviso)
  if (nome.contains('figueira-lira')) return '🌿';
  if (nome.contains('ficus benjamina')) return '🌿';
  if (nome.contains('palmeira-sagu') || nomeCientifico.contains('cycas')) return '🌿';
  if (nome.contains('cipreste')) return '🌲';
  if (nome.contains('buxinho')) return '🌿';
  if (nome.contains('croton')) return '🌿';
  if (nome.contains('dracena') || nomeCientifico.contains('dracaena') || nomeCientifico.contains('cordyline')) return '🌿';
  if (nome.contains('árvore-samambaia')) return '🌿';
  if (nome.contains('pata-de-elefante')) return '🌿';
  if (nome.contains('pinheiro') && nomeCientifico.contains('araucaria columnaris')) return '🌲';
  if (nome.contains('eucalipto')) return '🌿';
  if (nome.contains('ligustrinho')) return '🌿';
  if (nome.contains('figueira-de-bengala')) return '🌳';
  if (nome.contains('cheflera')) return '🌿';
  if (nome.contains('árvore-do-viajante')) return '🌿';
  if (nome.contains('neem')) return '🌿';
  if (nome.contains('crista-de-peru')) return '🌿';
  if (nome.contains('chorão')) return '🌿';
  if (nome.contains('seringueira-de-jardim')) return '🌿';
  if (nome.contains('árvore-mastro')) return '🌲';
  if (nome.contains('guaimbê')) return '🌿';
  if (nome.contains('freijó') || nomeCientifico.contains('cordia trichotoma')) return '🌸'; // Flores brancas, madeira nobre
  if (nome.contains('olho-de-pavão') && nomeCientifico.contains('adenanthera pavonina')) return '🔴'; // Sementes

  // Genérico para Pinheiro Ornamental (que não seja Buda ou Columnaris)
  if (nome.contains('pinheiro') && !nomeCientifico.contains('podocarpus macrophyllus') && !nomeCientifico.contains('araucaria columnaris')) return '🌲';

  // Árvores Grandes/Comuns sem flor ornamental como foco principal (ORNAMENTAIS)
  if (nome.contains('cabreúva')) return '🌳';
  if (nome.contains('jequitibá')) return '🌳';
  if (nome.contains('pau-brasil')) return '🌼';

  // --- FALLBACKS GENÉRICOS ---
  // Se a árvore não foi capturada por nenhuma regra específica acima:
  if (arvore.tipoEspe0) return '🌳'; // Frutífera genérica (se marcada como tal)
  if (arvore.tipoEspe1) return '🌸'; // Flor/Ornamental genérica (se marcada como tal)
  if (arvore.tipoEspec == 0) return '🌳'; // Fallback pela string tipoEspec

  return '🌲'; // Emoji padrão final para qualquer árvore não classificada
}