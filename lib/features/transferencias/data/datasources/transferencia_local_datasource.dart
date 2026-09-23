import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transferencia_model.dart';

abstract class ITransferenciaLocalDataSource {
  Future<List<TransferenciaModel>> getTransferencias();
  Future<void> saveTransferencia(TransferenciaModel transferencia);
}

class TransferenciaLocalDataSource implements ITransferenciaLocalDataSource {
  static const String _key = 'siao_transferencias_key';

  @override
  Future<List<TransferenciaModel>> getTransferencias() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null || jsonString.isEmpty) {
      // Seed inicial de demonstração do Administrador
      final initialSeed = [
        TransferenciaModel(
          id: 'demo-1',
          contaOrigem: 'Banco do Brasil - Convênio 01/2026',
          contaDestino: 'Caixa Interno (Fundo Fixo)',
          valor: 1500.00,
          data: DateTime.now().subtract(const Duration(days: 2)),
          finalidade: 'Saque gerencial para despesas miúdas de expediente',
          statusValidaAdmin: 'aprovado',
          criadoEm: DateTime.now().subtract(const Duration(days: 2)),
        ),
        TransferenciaModel(
          id: 'demo-2',
          contaOrigem: 'Caixa Econômica - Edital Doação',
          contaDestino: 'Conta Apoio Operacional',
          valor: 3200.50,
          data: DateTime.now().subtract(const Duration(days: 5)),
          finalidade: 'Aporte interno para fundo de reserva da sede',
          statusValidaAdmin: 'pendente',
          criadoEm: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];
      await _saveList(prefs, initialSeed);
      return initialSeed;
    }

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((item) => TransferenciaModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveTransferencia(TransferenciaModel transferencia) async {
    final list = await getTransferencias();
    list.insert(0, transferencia);
    final prefs = await SharedPreferences.getInstance();
    await _saveList(prefs, list);
  }

  Future<void> _saveList(
      SharedPreferences prefs, List<TransferenciaModel> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }
}
