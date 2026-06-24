// Exemplo de backend Node.js com Express e Multer (para upload de arquivos)
const express = require('express');
const multer = require('multer');
const nodemailer = require('nodemailer'); // Para enviar e-mails

const app = express();
const upload = multer({ dest: 'uploads/' }); // Configura multer para salvar arquivos temporariamente

app.post('/api/sugestao', upload.single('imagem'), async (req, res) => {
  console.log('Sugestão recebida (corpo):', req.body);
  console.log('Imagem recebida (arquivo):', req.file);

  const { arvoreId, nomeComumOriginal, nomeCientificoOriginal, sugestaoTexto, bairroOriginal, ruaOriginal } = req.body;
  const imagem = req.file;

  // --- LÓGICA PARA ENVIAR O E-MAIL AQUI ---
  // Configure o nodemailer (ou outro serviço de e-mail como SendGrid, Mailgun)
  // para enviar um e-mail para 'frutanopepr@gmail.com'
  // com 'sugestaoTexto', 'arvoreId', etc., no corpo do e-mail
  // e 'imagem.path' (se existir) como anexo.

  // Exemplo básico com nodemailer (requer configuração e tratamento de erros robusto)
  let transporter = nodemailer.createTransport({
    service: 'gmail', // ou outro provedor SMTP
    auth: {
      user: 'frutanopepr@gmail.com', // E-mail que enviará
      pass: 'Lmgiqz13' // Senha de aplicativo se usar Gmail com 2FA
    }   
  });

  let mailOptions = {
    from: '"App Fruta no Pé" <frutanopepr@gmail.com>',
    to: 'frutanopepr@gmail.com',
    subject: `Nova Sugestão para Árvore ID: ${arvoreId}`,
    html: `
      <p>Uma nova sugestão foi enviada:</p>
      <ul>
        <li><b>ID da Árvore Original:</b> ${arvoreId}</li>
        <li><b>Nome Comum Original:</b> ${nomeComumOriginal}</li>
        <li><b>Nome Científico Original:</b> ${nomeCientificoOriginal}</li>
        <li><b>Bairro Original:</b> ${bairroOriginal}</li>
        <li><b>Rua Original:</b> ${ruaOriginal}</li>
        <li><b>Sugestão do Usuário:</b> ${sugestaoTexto || 'Nenhuma sugestão de texto fornecida.'}</li>
      </ul>
      ${imagem ? '<p>Uma imagem foi anexada.</p>' : '<p>Nenhuma imagem foi anexada.</p>'}
    `,
    attachments: []
  };

  if (imagem) {
    mailOptions.attachments.push({
      filename: imagem.originalname,
      path: imagem.path // Caminho do arquivo salvo pelo multer
    });
  }

  try {
    await transporter.sendMail(mailOptions);
    console.log('E-mail de sugestão enviado com sucesso.');
    res.status(200).send('Sugestão recebida e e-mail enviado.');
  } catch (error) {
    console.error('Erro ao enviar e-mail de sugestão:', error);
    res.status(500).send('Erro ao processar a sugestão.');
  }
  // Não se esqueça de limpar o arquivo da pasta 'uploads/' após o envio, se necessário.
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Servidor rodando na porta ${PORT}`));
