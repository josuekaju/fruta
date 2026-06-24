import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Para usar File
import 'package:http/http.dart' as http; // Para requisições HTTP
import 'package:http_parser/http_parser.dart'; // Para MediaType ao enviar arquivos
////////////////////////////////////////////////
import '../models/arvore.dart'; 

class SugestaoPage extends StatefulWidget {
  final Arvore arvore;

  const SugestaoPage({required this.arvore, super.key});

  @override
  State<SugestaoPage> createState() => _SugestaoPageState();
}

class _SugestaoPageState extends State<SugestaoPage> {
  final _controller = TextEditingController();
  XFile? _imagemSelecionada;
  bool _isEnviando = false; // Para feedback visual durante o envio
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selecionarImagem(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Opcional: comprime um pouco a imagem
        maxWidth: 1024,    // Opcional: redimensiona a imagem
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

  Future<void> _enviarSugestaoParaBackend() async {
    if (_controller.text.trim().isEmpty && _imagemSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escreva uma sugestão ou adicione uma imagem.')),
      );
      return;
    }

    setState(() {
      _isEnviando = true;
    });

    // IMPORTANTE: Substitua pela URL real do seu backend
    final url = Uri.parse('https://SUA_URL_DE_BACKEND_AQUI/api/sugestao');
    final request = http.MultipartRequest('POST', url);

    // Adicionando campos de texto
    request.fields['arvoreId'] = widget.arvore.id;
    request.fields['nomeComumOriginal'] = widget.arvore.nomeComum;
    request.fields['nomeCientificoOriginal'] = widget.arvore.nomeCientifico.isNotEmpty ? widget.arvore.nomeCientifico : 'Não informado';
    request.fields['sugestaoTexto'] = _controller.text;
    request.fields['bairroOriginal'] = widget.arvore.bairro;
    request.fields['ruaOriginal'] = widget.arvore.nomeLogradouro;

    // Adicionando o arquivo de imagem, se selecionado
    if (_imagemSelecionada != null) {
      final file = File(_imagemSelecionada!.path);
      final fileName = file.path.split('/').last;
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();

      final multipartFile = http.MultipartFile(
        'imagem', // Nome do campo que o backend espera para o arquivo
        stream,
        length,
        filename: fileName,
        contentType: MediaType('image', fileName.split('.').last), // Ex: image/jpeg, image/png
      );
      request.files.add(multipartFile);
    }

    try {
      final response = await request.send();

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.pop(context); // Volta para a tela do mapa
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Obrigado! Sua sugestão foi enviada.')),
          );
        } else {
          final responseBody = await response.stream.bytesToString();
          print('Falha ao enviar sugestão. Status: ${response.statusCode}, Corpo: $responseBody');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha ao enviar sugestão: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar sugestão: $e')),
        );
      }
      print('Erro ao enviar sugestão para o backend: $e');
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
      appBar: AppBar(title: Text('Sugerir correção para ${widget.arvore.nomeComum}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Para esticar o ElevatedButton
          children: [
            Text('Qual o nome/informação correta para esta árvore?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(controller: _controller, decoration: InputDecoration(hintText: 'Ex: Mangueira (Manga Rosa)', border: OutlineInputBorder()), autofocus: true,),
            const SizedBox(height: 20),
            Text('Adicionar uma foto (opcional):', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeria'),
                  onPressed: () => _selecionarImagem(ImageSource.gallery),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Câmera'),
                  onPressed: () => _selecionarImagem(ImageSource.camera),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_imagemSelecionada != null)
              Column(
                children: [
                  Text('Imagem selecionada:', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Image.file(
                    File(_imagemSelecionada!.path),
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  TextButton(onPressed: () => setState(() => _imagemSelecionada = null), child: const Text('Remover imagem'))
                ],
              ),
            const Spacer(), // Empurra o botão de enviar para baixo
            ElevatedButton(
              onPressed: _isEnviando ? null : _enviarSugestaoParaBackend,
              child: _isEnviando
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Enviar Sugestão'),
            )
          ],
        ),
      ),
    );
  }
}