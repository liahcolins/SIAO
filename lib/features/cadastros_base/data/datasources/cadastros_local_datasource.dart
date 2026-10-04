import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fornecedor_model.dart';
import '../models/fonte_recurso_model.dart';

abstract class ICadastrosLocalDataSource {
  Future<List<FornecedorModel>> getFornecedores();
  Future<void> saveFornecedor(FornecedorModel fornecedor);
  
  Future<List<FonteRecursoModel>> getFontesRecursos();
  Future<void> saveFonteRecurso(FonteRecursoModel fonte);
}

class CadastrosLocalDataSource implements ICadastrosLocalDataSource {
  static const String _keyFornecedores = 'siao_fornecedores_key';
  static const String _keyFontes = 'siao_fontes_recursos_key';

  @override
  Future<List<FornecedorModel>> getFornecedores() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyFornecedores);

    if (jsonString == null || jsonString.isEmpty) {
      final initialSeed = [
        FornecedorModel(
          id: 'forn-1',
          nomeRazaoSocial: 'Papelaria & Armarinho Central Ltda',
          tipoPessoa: 'PJ',
          cpfCnpj: '12.345.678/0001-90',
          tipoOperacao: 'Despesa',
          telefone: '(98) 98123-4567',
          email: 'contato@papelariacentral.com.br',
          criadoEm: DateTime.now().subtract(const Duration(days: 10)),
        ),
        FornecedorModel(
          id: 'forn-2',
          nomeRazaoSocial: 'João Pedro da Silva - Serviço de Transporte',
          tipoPessoa: 'PF',
          cpfCnpj: '123.456.789-00',
          tipoOperacao: 'Despesa',
          telefone: '(98) 99988-1122',
          email: 'joaopedro.transporte@gmail.com',
          criadoEm: DateTime.now().subtract(const Duration(days: 8)),
        ),
        FornecedorModel(
          id: 'forn-3',
          nomeRazaoSocial: 'UFMA - Mais Gestão (Convênio Estadual)',
          tipoPessoa: 'PJ',
          cpfCnpj: '06.279.103/0001-19',
          tipoOperacao: 'Receita',
          telefone: '(98) 3272-8000',
          email: 'maisgestao@ufma.br',
          criadoEm: DateTime.now().subtract(const Duration(days: 15)),
        ),
      ];
      await _saveFornecedoresList(prefs, initialSeed);
      return initialSeed;
    }

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((item) => FornecedorModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveFornecedor(FornecedorModel fornecedor) async {
    final list = await getFornecedores();
    list.insert(0, fornecedor);
    final prefs = await SharedPreferences.getInstance();
    await _saveFornecedoresList(prefs, list);
  }

  Future<void> _saveFornecedoresList(
      SharedPreferences prefs, List<FornecedorModel> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await prefs.setString(_keyFornecedores, jsonEncode(jsonList));
  }

  @override
  Future<List<FonteRecursoModel>> getFontesRecursos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyFontes);

    if (jsonString == null || jsonString.isEmpty) {
      final initialSeed = [
        FonteRecursoModel(
          id: 'fonte-1',
          nome: 'Termo de Fomento UFMA / Mais Gestão 2026',
          tipoFonte: 'Governamental',
          descricao: 'Recursos destinados ao fortalecimento da gestão de OSCs no Maranhão',
          valorPrevisto: 50000.00,
          criadoEm: DateTime.now().subtract(const Duration(days: 20)),
        ),
        FonteRecursoModel(
          id: 'fonte-2',
          nome: 'Doações Diretas e Mensalidades de Associados',
          tipoFonte: 'Doação Privada',
          descricao: 'Doações espontâneas da comunidade local e apoiadores do projeto',
          valorPrevisto: 12000.00,
          criadoEm: DateTime.now().subtract(const Duration(days: 18)),
        ),
        FonteRecursoModel(
          id: 'fonte-3',
          nome: 'Bazar Beneficente & Eventos Comunitários',
          tipoFonte: 'Evento/Rifa',
          descricao: 'Receita proveniente da venda de produtos doados no bazar anual',
          valorPrevisto: 5000.00,
          criadoEm: DateTime.now().subtract(const Duration(days: 12)),
        ),
      ];
      await _saveFontesList(prefs, initialSeed);
      return initialSeed;
    }

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((item) => FonteRecursoModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveFonteRecurso(FonteRecursoModel fonte) async {
    final list = await getFontesRecursos();
    list.insert(0, fonte);
    final prefs = await SharedPreferences.getInstance();
    await _saveFontesList(prefs, list);
  }

  Future<void> _saveFontesList(
      SharedPreferences prefs, List<FonteRecursoModel> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await prefs.setString(_keyFontes, jsonEncode(jsonList));
  }
}
