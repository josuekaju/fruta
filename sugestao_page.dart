import 'package:flutter/material.dart';
import '../models/arvore.dart'; // Ajuste o caminho se o seu modelo Arvore estiver em outro lugar
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Para usar File

class SugestaoPage extends StatefulWidget {
  final Arvore arvore;

  const SugestaoPage({required this.arvore, super.key});

  @override
  State<SugestaoPage> createState() => _SugestaoPageState();
}

class _SugestaoPageState extends State<SugestaoPage> {
  final _controller = TextEditingController();
  XFile? _imagemSelecionada;
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
              onPressed: () {
                String logImagem = _imagemSelecionada != null ? 'Imagem: ${_imagemSelecionada!.path}' : 'Nenhuma imagem selecionada.';
                print('🌳 Sugestão para Árvore ID ${widget.arvore.id} (${widget.arvore.nomeComum}): ${_controller.text}. $logImagem');
                // Em uma implementação real, você faria o upload da imagem aqui.
                Navigator.pop(context); // Volta para a tela do mapa
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Obrigado pela sua sugestão!')),
                );
              },
              child: const Text('Enviar Sugestão'),
            )
          ],
        ),
      ),
    );
  }
}