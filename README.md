# fruta
mapeamento de arvores




fruta_no_pe/
├── android/              <-- Diretório do projeto Android nativo
│   ├── app/              <-- Módulo principal da aplicação Android
│   │   ├── src/          <-- Código fonte (Kotlin/Java), recursos, Manifest
│   │   └── build.gradle.kts  <-- Script de build do módulo 'app' (configurações da aplicação)
│   ├── gradle/           <-- Arquivos do Gradle Wrapper
│   │   └── wrapper/
│   │       ├── gradle-wrapper.jar
│   │       └── gradle-wrapper.properties <-- Define a versão do Gradle
│   ├── build.gradle.kts  <-- Script de build do projeto Android (configurações globais)
│   ├── settings.gradle.kts <-- Configurações do Gradle (inclui módulos, repositórios, toolchains)
│   └── local.properties  <-- Configurações locais (caminho do SDK Flutter, SDK Android)
├── ios/                  <-- Diretório do projeto iOS nativo
├── lib/
│   ├── main.dart                # Ponto principal da aplicação/ Entrada
│   ├── home_page.dart           # Tela principal com filtros
│   ├── models/
│   │   └── arvore.dart          # Modelo de dados das árvores
│   ├── services/
│   │   └── geojson_loader.dart  # Carregamento do GeoJSON
│   └── widgets/
│       └── mapa_widget.dart     # Componente do mapa
├── test/                 <-- Testes unitários
├── web/                  <-- Arquivos para build web
├── assets/               <-- Ativos da aplicação (imagens, fontes, etc.)
├── pubspec.yaml          <-- Configurações do projeto Flutter (dependências, assets)
├── pubspec.lock          <-- Gerado pelo pub get
├── .gitignore            <-- Arquivos/diretórios ignorados pelo Git
└── ... outros arquivos e diretórios
