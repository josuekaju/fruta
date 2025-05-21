# fruta
mapeamento de arvores


fruta_no_pefruta_no_pe/		
│   ├── android/              <-- Diretório do projeto Android nativo    
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
│ 	│
│   │
│   ├── ios/                   # Configurações iOS	  
│   ├── assets/               <-- Ativos da aplicação (imagens, etc.)      
│   │  ├─ icon/
│   │  └─ images/    
│   │    
│   ├── lib/		  
│   │  ├── home_page.dart     # Tela principal		  
│   │  ├── mapa_widget.dart   # Widget do mapa		  
│   │  ├── models/		  
│   │  │   └── arvore.dart    # Modelo de dados das árvores		  
│   │  ├── services/		  
│   │  │   ├── geojson_loader.dart # Carregamento do GeoJSON		  
│   │  │   └── species_counter_service.dart # Contagem de espécies		  
│   │  ├── widgets/		  
│   │  │   └── loading_overlay.dart # Tela de carregamento		  
│   │  └── main.dart          # Ponto de entrada		  
│   │    		  
│   ├── assets/		
│   │  ├── arvore.geojson     # Dados principais		  
│   │  ├── especies_com_contagem_.csv # Dados de espécies				  
│   │  └── images/            # Ícones		  
│   │      └── treant.png		  
│   │		  
│   ├── banco_de_dados/        # Seus scripts Python  (ONDE COLOCAR O BANCO DE DADOS DA LISTA DE CIDADES? 		  
│   │  ├── donwloads_DRZ_1_faltantes.py                   AS ARVORES DE TOLEDO ESTA EM ASSETS 'fruta_no_pe/assets/arvore_.geojson'		  
│   │  ├── donwloads_DRZ_1.py		  
│   │  ├── donwloads_DRZ_.py		
│   │  └── lista_cidades_.py		        
│   │		  
│   ├── pubspec.yaml           # Dependências Flutter    
│   └── README.md    
│    
│    
fruta_no_pe_backend/    
│   ├── uploads/             // Pasta para uploads temporários (se usar multer com dest)    
│   ├── index.js             // Seu arquivo principal do servidor Node.js  
│   ├── package.json         // Define dependências (express, multer, nodemailer, etc.)    
│   ├── package-lock.json      
│   └── node_modules/        // Pasta de dependências (gerada pelo npm install)      
│    
│    
fruta_no_pe_scripts/       # Scripts Python ou IA para limpeza/análise dos SHP    
│   └── limpeza_dados.py    
│    
│    
