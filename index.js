// SEU INDEX.JS MELHORADO (com /api/sugestaoNovaArvore e /api/sugestao para correções)

const express = require('express');
const multer = require('multer');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// --- Funções Utilitárias ---
function getDataHojeFormatada() {
  return new Date().toISOString().split('T')[0]; // YYYY-MM-DD
}

function criarPastasDeUploadSeNaoExistirem() {
  const pastaBaseUploads = path.join(__dirname, 'uploads');
  const pastaDataHoje = path.join(pastaBaseUploads, getDataHojeFormatada());
  if (!fs.existsSync(pastaBaseUploads)) fs.mkdirSync(pastaBaseUploads, { recursive: true });
  if (!fs.existsSync(pastaDataHoje)) fs.mkdirSync(pastaDataHoje, { recursive: true });
  return pastaDataHoje;
}

// --- Configuração do Multer ---
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const destino = criarPastasDeUploadSeNaoExistirem();
    cb(null, destino);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const extensao = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + extensao);
  },
});

const upload = multer({
  storage: storage,
  fileFilter: function (req, file, cb) {
    const tiposPermitidos = /jpeg|jpg|png|gif/;
    const extensaoValida = tiposPermitidos.test(path.extname(file.originalname).toLowerCase());
    const mimetypeValido = tiposPermitidos.test(file.mimetype);
    if (extensaoValida && mimetypeValido) {
      return cb(null, true);
    } else {
      cb(new Error('Apenas arquivos de imagem (JPEG, PNG, GIF) são permitidos!'), false);
    }
  },
  limits: { fileSize: 5 * 1024 * 1024 },
});

// --- Banco de Dados (Arquivos JSON) ---
const CAMINHO_DB_NOVAS_ARVORES = path.join(__dirname, 'sugestoesNovasArvores.json');
const CAMINHO_DB_CORRECOES = path.join(__dirname, 'sugestoesCorrecoes.json'); // Arquivo separado para correções

function inicializarArquivoJSON(caminho) {
  try {
    if (!fs.existsSync(caminho)) {
      fs.writeFileSync(caminho, JSON.stringify([]), 'utf-8');
      console.log(`Arquivo de banco de dados criado: ${caminho}`);
    } else {
      JSON.parse(fs.readFileSync(caminho, 'utf-8')); // Verifica se é JSON válido
    }
  } catch (error) {
    console.warn(`Arquivo (${caminho}) corrompido ou inválido. Recriando...`, error.message);
    fs.writeFileSync(caminho, JSON.stringify([]), 'utf-8');
  }
}
inicializarArquivoJSON(CAMINHO_DB_NOVAS_ARVORES);
inicializarArquivoJSON(CAMINHO_DB_CORRECOES);


// --- ROTA PARA SUGERIR NOVAS ÁRVORES ---
app.post('/api/sugestaoNovaArvore', upload.single('imagem'), (req, res) => {
  console.log("---- REQUISIÇÃO EM /api/sugestaoNovaArvore ----");
  console.log("req.body:", JSON.stringify(req.body, null, 2));
  console.log("req.file:", req.file);

  const {
    latitude, longitude, nomeComum,
    nomeCientifico, descricao, enderecoAproximado, bairro, observacoes,
    // tipo e dataSugestao são enviados pelo Flutter via toJson()
  } = req.body;

  if (!latitude || !longitude || !nomeComum) {
    return res.status(400).json({ error: 'Latitude, longitude e nome comum são obrigatórios.' });
  }
  // Adicione validação para 'observacoes' se for um campo obrigatório para novas árvores
  // if (!observacoes || observacoes.trim() === "") {
  //   return res.status(400).json({ error: 'O campo de observações é obrigatório.' });
  // }

  const novaSugestao = {
    id: Date.now().toString(),
    latitude: parseFloat(latitude),
    longitude: parseFloat(longitude),
    nomeComum,
    nomeCientifico: nomeCientifico || null,
    descricao: descricao || null,
    enderecoAproximado: enderecoAproximado || null,
    bairro: bairro || null,
    observacoes: observacoes || null, // <- CAMPO CHAVE AQUI
    imagemUrl: req.file ? `${getDataHojeFormatada()}/${req.file.filename}` : null,
    dataSugestao: req.body.dataSugestao || new Date().toISOString(), // Usa o do Flutter ou gera novo
    tipo: req.body.tipo || 'nova_arvore', // Usa o do Flutter ou define
    status: 'pendente',
    timestampRecepcao: new Date().toISOString(),
  };

  try {
    const dadosAtuais = JSON.parse(fs.readFileSync(CAMINHO_DB_NOVAS_ARVORES, 'utf-8'));
    dadosAtuais.push(novaSugestao);
    fs.writeFileSync(CAMINHO_DB_NOVAS_ARVORES, JSON.stringify(dadosAtuais, null, 2), 'utf-8');
    console.log('Nova sugestão de árvore salva:', novaSugestao);
    res.status(201).json({ sucesso: true, mensagem: 'Sugestão de nova árvore enviada!', dados: novaSugestao });
  } catch (error) {
    console.error('Erro ao salvar nova sugestão:', error);
    res.status(500).json({ error: 'Erro interno ao salvar a sugestão.' });
  }
});


// --- ROTA PARA SUGERIR CORREÇÕES DE ÁRVORES EXISTENTES ---
app.post('/api/sugestaoCorrecao', upload.single('imagem'), (req, res) => { // << ENDPOINT DIFERENTE
  console.log("---- REQUISIÇÃO EM /api/sugestaoCorrecao ----");
  console.log("req.body:", JSON.stringify(req.body, null, 2));
  console.log("req.file:", req.file);

  const {
    arvoreId, // ID da árvore existente
    // Quais campos o Flutter envia para correção?
    // Exemplo: sugestaoNomeComum, sugestaoObservacoes, etc.
    // Vamos assumir que o Flutter envia um campo 'comentarioDoUsuario' para o texto da correção
    comentarioDoUsuario, // Este é o texto que descreve a correção
    // Adicione outros campos que podem ser enviados para correção (novos valores)
    // Ex: novoNomeComum, novaLatitude, etc.
  } = req.body;

  if (!arvoreId || !comentarioDoUsuario) {
    return res.status(400).json({ error: 'ID da árvore e um comentário sobre a correção são obrigatórios.' });
  }

  const sugestaoDeCorrecao = {
    id: Date.now().toString(),
    arvoreId,
    comentarioDoUsuario,
    // Adicione aqui os campos com os novos valores sugeridos
    // Ex: novoNomeComum: req.body.novoNomeComum || undefined,
    imagemUrl: req.file ? `${getDataHojeFormatada()}/${req.file.filename}` : null,
    tipo: 'correcao_arvore',
    status: 'pendente',
    timestampRecepcao: new Date().toISOString(),
  };

  try {
    const dadosAtuais = JSON.parse(fs.readFileSync(CAMINHO_DB_CORRECOES, 'utf-8'));
    dadosAtuais.push(sugestaoDeCorrecao);
    fs.writeFileSync(CAMINHO_DB_CORRECOES, JSON.stringify(dadosAtuais, null, 2), 'utf-8');
    console.log('Sugestão de correção salva:', sugestaoDeCorrecao);
    res.status(201).json({ sucesso: true, mensagem: 'Sugestão de correção enviada!', dados: sugestaoDeCorrecao });
  } catch (error) {
    console.error('Erro ao salvar sugestão de correção:', error);
    res.status(500).json({ error: 'Erro interno ao salvar a sugestão de correção.' });
  }
});


// Rota de exemplo para buscar todas as sugestões (para teste)
// Modificado para buscar de ambos os arquivos ou de um específico via query param
app.get('/api/sugestoesGerais', (req, res) => {
  try {
    const novas = JSON.parse(fs.readFileSync(CAMINHO_DB_NOVAS_ARVORES, 'utf-8'));
    const correcoes = JSON.parse(fs.readFileSync(CAMINHO_DB_CORRECOES, 'utf-8'));
    res.json({ novasArvores: novas, correcoes: correcoes });
  } catch (error) {
    console.error('Erro ao ler sugestões:', error);
    res.status(500).json({ error: 'Erro ao buscar sugestões.' });
  }
});

// Middleware para tratamento de erros
app.use((err, req, res, next) => {
  // ... (seu tratamento de erro do Multer e geral) ...
  if (err instanceof multer.MulterError) {
    return res.status(400).json({ error: `Erro no upload do arquivo: ${err.message}` });
  } else if (err) {
    if (err.message === 'Apenas arquivos de imagem (JPEG, PNG, GIF) são permitidos!') {
        return res.status(400).json({ error: err.message });
    }
    console.error("Erro não tratado:", err);
    return res.status(500).json({ error: 'Ocorreu um erro inesperado no servidor.' });
  }
  next();
});

// --- Inicialização do Servidor ---
app.listen(PORT, '0.0.0.0', () => {
  // ... (seus logs de inicialização) ...
  console.log(`\n🌿 Servidor Fruta No Pé (Backend) rodando!`);
  console.log(`   Ouvindo em todas as interfaces na porta: ${PORT}`);
  console.log(`   Acessível localmente via: http://localhost:${PORT}`);
  console.log(`   Sugestões de NOVAS ÁRVORES são salvas em: ${CAMINHO_DB_NOVAS_ARVORES}`);
  console.log(`   Sugestões de CORREÇÕES são salvas em: ${CAMINHO_DB_CORRECOES}`);
  console.log(`   Imagens são salvas em: ${path.join(__dirname, 'uploads')}`);
  console.log(`   Imagens são servidas de: http://localhost:${PORT}/uploads/`);
  console.log(`   Para acessar na rede local, use o IP da sua máquina (ex: http://192.168.X.X:${PORT})\n`);
});