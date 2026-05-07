# fruta
Mapeamento de arvores

<img width="300" height="300" alt="treant" src="https://github.com/user-attachments/assets/da88cddf-6ee3-4082-a675-d61767422252" />


<img width="35%" height="35%" alt="1_1_" src="https://github.com/user-attachments/assets/f1da787c-30a1-404d-a5fa-000c2f3de7be" />

<img width="35%" height="35%" alt="3_estudos" src="https://github.com/user-attachments/assets/006721a5-6870-470e-9f4e-3fd6438d3405" />
<img width="35%" height="35%" alt="2_rara" src="https://github.com/user-attachments/assets/fae96cb5-98ff-46b2-bab4-a59e0613d8ed" />
<img width="35%" height="35%" alt="5_rota" src="https://github.com/user-attachments/assets/9d884f7b-aa44-4e1e-b5da-757a7179fac2" />
<img width="35%" height="35%" alt="2" src="https://github.com/user-attachments/assets/09c88636-8eb7-4ae1-8b9a-5a7736b250d9" />




# Arquitetura do APP

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
