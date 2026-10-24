import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/despesa_model.dart';

class DespesaLocalDataSource {
  static const String _keyDespesas = 'siao_despesas_list';

  Future<List<DespesaModel>> getDespesas() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyDespesas);

    if (jsonString == null || jsonString.isEmpty) {
      // Carrega dados iniciais realistas se a base estiver vazia
      final initialData = _getInitialDespesas();
      await salvarListaDespesas(initialData);
      return initialData;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => DespesaModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _getInitialDespesas();
    }
  }

  Future<List<DespesaModel>> getDespesasPorStatus(String status) async {
    final list = await getDespesas();
    if (status == 'todas') return list;
    return list.where((item) => item.statusValidaAdmin == status).toList();
  }

  Future<void> salvarDespesa(DespesaModel despesa) async {
    final list = await getDespesas();
    // Insere no início para aparecer primeiro na cronologia
    list.insert(0, despesa);
    await salvarListaDespesas(list);
  }

  Future<void> atualizarStatus(
    String id,
    String novoStatus, {
    String? motivoRejeicao,
  }) async {
    final list = await getDespesas();
    final index = list.indexWhere((item) => item.id == id);
    if (index != -1) {
      final updated = list[index].copyWith(
        statusValidaAdmin: novoStatus,
        motivoRejeicao: novoStatus == 'rejeitado' ? motivoRejeicao : null,
        validadoEm: DateTime.now(),
      );
      list[index] = updated;
      await salvarListaDespesas(list);
    }
  }

  Future<void> salvarListaDespesas(List<DespesaModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((item) => item.toJson()).toList();
    await prefs.setString(_keyDespesas, jsonEncode(jsonList));
  }

  Future<double> getTotalDespesasAprovadas() async {
    final list = await getDespesas();
    return list
        .where((d) => d.statusValidaAdmin == 'aprovado')
        .fold<double>(0.0, (sum, d) => sum + d.valor);
  }

  Future<double> getTotalDespesasPendentes() async {
    final list = await getDespesas();
    return list
        .where((d) => d.statusValidaAdmin == 'pendente')
        .fold<double>(0.0, (sum, d) => sum + d.valor);
  }

  List<DespesaModel> _getInitialDespesas() {
    final agora = DateTime.now();
    return [
      DespesaModel(
        id: 'desp-001',
        fonteRecursoId: 'fonte-01',
        fonteRecursoNome: 'Emenda Parlamentar Federal 2026 / UFMA Mais Gestão',
        fornecedorId: 'forn-01',
        fornecedorNome: 'Supermercado Central LTDA',
        fornecedorCpfCnpj: '12.345.678/0001-90',
        valor: 6350.00,
        dataGasto: agora.subtract(const Duration(days: 4)),
        formaPagamento: 'PIX / Depósito Bancário',
        descricao: 'Alimentos e refeições para formação de líderes comunitários e agentes locais de desenvolvimento da OSC.',
        tipoComprovante: 'Nota Fiscal Eletrônica (NF-e)',
        comprovanteTitulo: 'DANFE NF-e nº 004.892 • Chave 2126.0912.3456.7800.0190.5500.1000.0489.2109',
        statusValidaAdmin: 'aprovado',
        validadoEm: agora.subtract(const Duration(days: 3)),
        criadoEm: agora.subtract(const Duration(days: 4)),
      ),
      DespesaModel(
        id: 'desp-002',
        fonteRecursoId: 'fonte-02',
        fonteRecursoNome: 'Doação Fundo Solidário OSC',
        fornecedorId: 'forn-02',
        fornecedorNome: 'Gráfica & Editora Universitária LTDA',
        fornecedorCpfCnpj: '98.765.432/0001-11',
        valor: 3500.00,
        dataGasto: agora.subtract(const Duration(days: 8)),
        formaPagamento: 'Cheque',
        descricao: 'Impressão de cartilhas formativas, apostilas didáticas e relatórios impressos para prestação de contas aos conselhos.',
        tipoComprovante: 'Nota Fiscal de Serviços (NFS-e)',
        comprovanteTitulo: 'NFS-e nº 2026/0891 • Prefeitura Municipal',
        statusValidaAdmin: 'aprovado',
        validadoEm: agora.subtract(const Duration(days: 7)),
        criadoEm: agora.subtract(const Duration(days: 8)),
      ),
      DespesaModel(
        id: 'desp-003',
        fonteRecursoId: 'fonte-01',
        fonteRecursoNome: 'Emenda Parlamentar Federal 2026 / UFMA Mais Gestão',
        fornecedorId: 'forn-03',
        fornecedorNome: 'Silva Papelaria & Informática EIRELI',
        fornecedorCpfCnpj: '45.123.890/0001-77',
        valor: 420.00,
        dataGasto: agora.subtract(const Duration(hours: 5)),
        formaPagamento: 'Dinheiro em Espécie',
        descricao: 'Aquisição de papéis A4, pastas organizadoras de arquivos fiscais e toners para arquivo permanente dos convênios.',
        tipoComprovante: 'Cupom Fiscal Eletrônico (NFC-e)',
        comprovanteTitulo: 'NFC-e nº 012.349 • Protocolo de Autorização 321260004921',
        statusValidaAdmin: 'pendente',
        criadoEm: agora.subtract(const Duration(hours: 5)),
      ),
    ];
  }
}
