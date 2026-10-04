import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/receita_model.dart';

abstract class IReceitaLocalDataSource {
  Future<List<ReceitaModel>> getReceitas();
  Future<void> saveReceita(ReceitaModel receita);
}

class ReceitaLocalDataSource implements IReceitaLocalDataSource {
  static const String _key = 'siao_receitas_key';

  @override
  Future<List<ReceitaModel>> getReceitas() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null || jsonString.isEmpty) {
      final initialSeed = [
        ReceitaModel(
          id: 'rec-1',
          fonteRecursoId: 'fonte-1',
          fonteRecursoNome: 'Termo de Fomento UFMA / Mais Gestão 2026',
          eProduto: false,
          valor: 10000.00,
          dataRecebimento: DateTime.now().subtract(const Duration(days: 4)),
          formaPagamento: 'PIX / Depósito Bancário',
          referenteAnoBase: true,
          descricao: 'Primeira parcela de repasse de incentivo do convênio estadual UFMA',
          statusValidaAdmin: 'aprovado',
          criadoEm: DateTime.now().subtract(const Duration(days: 4)),
        ),
        ReceitaModel(
          id: 'rec-2',
          fonteRecursoId: 'fonte-2',
          fonteRecursoNome: 'Doações Diretas e Mensalidades de Associados',
          eProduto: false,
          valor: 3200.00,
          dataRecebimento: DateTime.now().subtract(const Duration(days: 7)),
          formaPagamento: 'PIX / Depósito Bancário',
          referenteAnoBase: true,
          descricao: 'Arrecadação de contribuição voluntária de mantenedores locais',
          statusValidaAdmin: 'aprovado',
          criadoEm: DateTime.now().subtract(const Duration(days: 7)),
        ),
        ReceitaModel(
          id: 'rec-3',
          fonteRecursoId: 'fonte-3',
          fonteRecursoNome: 'Bazar Beneficente & Eventos Comunitários',
          eProduto: true,
          valor: 1500.00,
          dataRecebimento: DateTime.now().subtract(const Duration(days: 12)),
          formaPagamento: 'Dinheiro em Espécie',
          referenteAnoBase: true,
          descricao: 'Venda de artesanato e produtos doados no evento mensal da sede',
          statusValidaAdmin: 'aprovado',
          criadoEm: DateTime.now().subtract(const Duration(days: 12)),
        ),
      ];
      await _saveList(prefs, initialSeed);
      return initialSeed;
    }

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((item) => ReceitaModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveReceita(ReceitaModel receita) async {
    final list = await getReceitas();
    list.insert(0, receita);
    final prefs = await SharedPreferences.getInstance();
    await _saveList(prefs, list);
  }

  Future<void> _saveList(
      SharedPreferences prefs, List<ReceitaModel> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }
}
