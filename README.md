# fruta 
mapeamento de arvores   	


C:\Users\aguia\Desktop\project\fruta_no_pe_suite_2\ 
		├── fruta_no_pe\                # Projeto Flutter   
		│   ├── android\                # Configurações específicas do Android  
		│   │   ├── app\    
		│   │   ├── gradle\    
		│   │   ├── build.gradle.kts    
		│   │   ├── settings.gradle.kts     
		│   │   └── local.properties    
		│   ├── ios\                    # Configurações específicas do iOS  
		│   ├── lib\                    # Código Dart do aplicativo     
		│   │   ├── main.dart   
		│   │   ├── home_page.dart  
		│   │   ├── mapa_widget.dart    
		│   │   ├── models\ 
		│   │   │   └── arvore.dart 
		│   │   ├── services\   
		│   │   │   ├── geojson_loader.dart 
		│   │   │   └── species_counter_service.dart    
		│   │   └── widgets\    
		│   │       └── loading_overlay.dart    
		│   ├── assets\                 # Ativos da aplicação   
		│   │   ├── data\               # Arquivos de dados (GeoJSON, CSV, etc.)    
		│   │   │   ├── arvore.geojson  
		│   │   │   ├── especies_com_contagem.csv       
		│   │   │   └── lista_cidades.json  # Exemplo para sua lista de cidades 
		│   │   ├── images\             # Imagens e ícones  
		│   │   │   ├── icon\           # Subpasta para ícones, se necessário   
		│   │   │   └── treant.png  
		│   ├── banco_de_dados\         # Seus scripts Python para processamento de dados   
		│   │   ├── donwloads_DRZ_1_faltantes.py    
		│   │   ├── donwloads_DRZ_1.py  
		│   │   ├── donwloads_DRZ_.py   
		│   │   └── lista_cidades_.py   
		│   ├── .gitignore  
		│   ├── pubspec.yaml    
		│   └── README.md   
		│   
		└── fruta_no_pe_backend\        # Projeto Node.js Backend   
		│   ├── .env        
		│   ├── .gitignore      
		│   ├── index.js                  # Ponto de entrada principal  
		│   ├── package.json        
		│   ├── package-lock.json         # Use o seu arquivo existente 
		│   ├── config\ 
		│   │   └── serverConfig.js 
		│   ├── data\                     # Arquivos de dados JSON (sugestões)  
		│   │   ├── sugestoes.json        # Use o seu arquivo existente 
		│   │   └── sugestoesNovasArvores.json # Use o seu arquivo existente    
		│   ├── middleware\ 
		│   │   ├── errorHandler.js     
		│   │   └── multerConfig.js     
		│   ├── public\ 
		│   │   └── index.html  
		│   ├── routes\ 
		│   │   └── sugestaoRoutes.js   
		│   ├── controllers\    
		│   │   └── sugestaoController.js   
		│   ├── uploads\                  # Pasta para armazenar os arquivos enviados   
		│   │   └── .gitkeep              # Para manter a pasta no Git  
		│   └── utils\  
		│       └── fileUtils.js    
		│       
		│       
		└── fruta_no_pe_scripts/       # Scripts Python ou IA para limpeza/análise dos SHP     
		│   └── limpeza_dados.py        
		│       
		│       
