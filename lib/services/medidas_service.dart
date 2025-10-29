import 'package:hive/hive.dart';

class MedidasService {
  static const String _boxName = 'medidas';

  static Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  static Future<List<Map<String, dynamic>>> listar() async {
    try {
      final box = await _getBox();
      final lista = box.values.toList();
      
      // Converter cada item para Map<String, dynamic>
      return lista.map<Map<String, dynamic>>((item) {
        if (item is Map) {
          // Se for um Map, converter para Map<String, dynamic>
          return Map<String, dynamic>.from(item);
        } else if (item is Map<dynamic, dynamic>) {
          // Se for um Map<dynamic, dynamic>, converter para Map<String, dynamic>
          return item.map((key, value) => 
            MapEntry(key.toString(), value is Map ? Map<String, dynamic>.from(value) : value)
          );
        }
        // Se não for nenhum dos tipos acima, retornar vazio
        return {};
      }).toList();
    } catch (e) {
      print('Erro ao listar medidas: $e');
      return [];
    }
  }

  static Future<void> adicionar(Map<String, dynamic> item) async {
    try {
      final box = await _getBox();
      // Criar uma cópia do mapa para garantir que todos os valores sejam serializáveis
      final Map<String, dynamic> itemParaSalvar = {};
      
      item.forEach((key, value) {
        if (value is Map) {
          // Se o valor for um mapa, converter para Map<String, dynamic>
          itemParaSalvar[key] = Map<String, dynamic>.from(value);
        } else if (value is List) {
          // Se for uma lista, mapear cada item
          itemParaSalvar[key] = value.map((e) => e is Map ? Map<String, dynamic>.from(e) : e).toList();
        } else {
          // Outros tipos de valores são copiados diretamente
          itemParaSalvar[key] = value;
        }
      });
      
      await box.add(itemParaSalvar);
    } catch (e) {
      print('Erro ao adicionar medida: $e');
      rethrow;
    }
  }

  static Future<void> atualizar(int index, Map<String, dynamic> item) async {
    try {
      final box = await _getBox();
      // Criar uma cópia do mapa para garantir que todos os valores sejam serializáveis
      final Map<String, dynamic> itemParaSalvar = {};
      
      item.forEach((key, value) {
        if (value is Map) {
          // Se o valor for um mapa, converter para Map<String, dynamic>
          itemParaSalvar[key] = Map<String, dynamic>.from(value);
        } else if (value is List) {
          // Se for uma lista, mapear cada item
          itemParaSalvar[key] = value.map((e) => e is Map ? Map<String, dynamic>.from(e) : e).toList();
        } else {
          // Outros tipos de valores são copiados diretamente
          itemParaSalvar[key] = value;
        }
      });
      
      await box.putAt(index, itemParaSalvar);
    } catch (e) {
      print('Erro ao atualizar medida: $e');
      rethrow;
    }
  }

  static Future<void> removerAt(int index) async {
    try {
      final box = await _getBox();
      await box.deleteAt(index);
    } catch (e) {
      print('Erro ao remover medida: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> obterPorId(dynamic id) async {
    try {
      final box = await _getBox();
      return box.get(id);
    } catch (e) {
      print('Erro ao obter medida por ID: $e');
      return null;
    }
  }
}
