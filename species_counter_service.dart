import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart'; // You'll need to add this package to pubspec.yaml

class SpeciesCounterService {
  static Future<Map<String, int>> loadSpeciesCounts() async {
    final Map<String, int> counts = {};
    try {
      print("[SpeciesCounterService] Tentando carregar 'assets/especies_com_contagem_.csv'");
      final csvString = await rootBundle.loadString('assets/especies_com_contagem_.csv');
      // Check for and remove BOM if present
      String cleanedCsvString = csvString;
      if (csvString.startsWith('\uFEFF')) {
        print("[SpeciesCounterService] BOM detectado e removido.");
        cleanedCsvString = csvString.substring(1);
      }
      print("[SpeciesCounterService] CSV String carregado (limpo), tamanho: ${cleanedCsvString.length}");

      // Assuming the CSV has a header row.
      // The CsvToListConverter handles quotes and commas.
      // Specify EOL character if it's not the default \n (e.g. \r\n for Windows) and the correct fieldDelimiter
      List<List<dynamic>> csvTable = const CsvToListConverter(eol: '\n', fieldDelimiter: ';').convert(cleanedCsvString);

      print("[SpeciesCounterService] CSV convertido para tabela, linhas: ${csvTable.length}");
      if (csvTable.isNotEmpty) {
        // Find header indices (more robust than assuming column order)
        List<dynamic> headerRow = csvTable.first;
        int? tipoEspe3Index; // Index for species name
        int? quantidadeIndex; // Index for count

        for (int i = 0; i < headerRow.length; i++) {
          // Print each header found for debugging
          String rawHeader = headerRow[i].toString();
          print("[SpeciesCounterService] Header Bruto[$i]: '$rawHeader'");
          String processedHeader = rawHeader.trim().toLowerCase();
          if (processedHeader == 'tipo_espe3') {
            tipoEspe3Index = i;
          } else if (processedHeader == 'quantidade') {
            quantidadeIndex = i;
          }
        } 

        print("[SpeciesCounterService] Índice para 'tipo_espe3': $tipoEspe3Index, Índice para 'quantidade': $quantidadeIndex");
        if (tipoEspe3Index != null && quantidadeIndex != null) {
          // Start from the second row (index 1) to skip the header
          for (int i = 1; i < csvTable.length; i++) {
            final row = csvTable[i];
            // Basic validation for row length
            if (row.length > tipoEspe3Index && row.length > quantidadeIndex) {
              final String speciesName = row[tipoEspe3Index].toString().trim(); // Nome da espécie do CSV
              final String countStr = row[quantidadeIndex].toString().trim();
              final int? count = int.tryParse(countStr);
              if (speciesName.isNotEmpty && count != null) {
                counts[speciesName] = count;
              }
            }
          }
        } else {
          print("SpeciesCounterService Error: 'tipo_espe3' or 'quantidade' column not found in CSV header.");
        }
      }
    } catch (e) {
      print('SpeciesCounterService Fatal Error: Error loading or parsing species count CSV: $e');
      // Return empty map or handle error as appropriate
    }
    // print('Species counts loaded: $counts'); // For debugging
    return counts;
  }
}
