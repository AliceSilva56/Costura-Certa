import 'package:hive/hive.dart';

class MedidasService {
  static const _boxName = 'medidas_box_v1';
  static Future<Box> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  static Future<List<Map>> listar() async {
    final box = await _openBox();
    return box.values.cast<Map>().toList();
  }

  static Future<void> adicionar(Map item) async {
    final box = await _openBox();
    await box.add(item);
  }

  static Future<void> removerAt(int index) async {
    final box = await _openBox();
    final key = box.keyAt(index);
    await box.delete(key);
  }
}
