import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario_model.dart';

class UsuarioLocalDataSource {
  static const String _keyUsuarios = 'siao_usuarios_list_v1';
  static const String _keyUsuarioAtivoId = 'siao_usuario_ativo_id_v1';

  static final ValueNotifier<UsuarioModel> usuarioAtualNotifier =
      ValueNotifier<UsuarioModel>(_defaultAdminUser());

  static UsuarioModel get usuarioAtual => usuarioAtualNotifier.value;

  static UsuarioModel _defaultAdminUser() {
    return UsuarioModel(
      id: 'usr-admin-01',
      nome: 'Prof. Sérgio Roberto Pinto',
      email: 'sergio.pinto@ufma.br',
      cpf: '123.456.789-00',
      cargoFuncao: 'Coordenador Geral • Gestor da OSC',
      perfil: 'administrador',
      statusAcesso: 'aprovado',
      dataSolicitacao: DateTime(2026, 9, 10),
      dataDecisao: DateTime(2026, 9, 10),
      decididoPor: 'Instalação Inicial OSC',
    );
  }

  Future<void> inicializarSessao() async {
    final usuarios = await getUsuarios();
    final prefs = await SharedPreferences.getInstance();
    final ativoId = prefs.getString(_keyUsuarioAtivoId);

    if (ativoId != null) {
      final encontrado = usuarios.where((u) => u.id == ativoId && u.isAprovado);
      if (encontrado.isNotEmpty) {
        usuarioAtualNotifier.value = encontrado.first;
        return;
      }
    }

    final adminPadrao = usuarios.firstWhere(
      (u) => u.isAdministrador && u.isAprovado,
      orElse: _defaultAdminUser,
    );
    usuarioAtualNotifier.value = adminPadrao;
    await prefs.setString(_keyUsuarioAtivoId, adminPadrao.id);
  }

  Future<List<UsuarioModel>> getUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyUsuarios);

    if (jsonString == null || jsonString.isEmpty) {
      final initial = _getInitialUsuarios();
      await salvarListaUsuarios(initial);
      return initial;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => UsuarioModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      final initial = _getInitialUsuarios();
      await salvarListaUsuarios(initial);
      return initial;
    }
  }

  Future<void> salvarListaUsuarios(List<UsuarioModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((u) => u.toJson()).toList();
    await prefs.setString(_keyUsuarios, jsonEncode(jsonList));
  }

  Future<void> definirUsuarioAtivo(UsuarioModel usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsuarioAtivoId, usuario.id);
    usuarioAtualNotifier.value = usuario;
  }

  Future<UsuarioModel> alternarPerfilRapido(String perfilDesejado) async {
    final list = await getUsuarios();
    final target = list.firstWhere(
      (u) => u.perfil == perfilDesejado && u.isAprovado,
      orElse: _defaultAdminUser,
    );
    await definirUsuarioAtivo(target);
    return target;
  }

  /// Retorna `(usuario, mensagemErro)`.
  Future<(UsuarioModel?, String?)> autenticar(
    String identificador,
    String senha,
  ) async {
    final idLimpo = identificador.trim().toLowerCase();
    final cpfNumeros = identificador.replaceAll(RegExp(r'[^0-9]'), '');
    final list = await getUsuarios();

    for (final u in list) {
      final emailMatch = u.email.toLowerCase() == idLimpo;
      final cpfUserNumeros = u.cpf.replaceAll(RegExp(r'[^0-9]'), '');
      final cpfMatch = cpfNumeros.isNotEmpty && cpfUserNumeros == cpfNumeros;

      if (emailMatch || cpfMatch) {
        if (u.senhaDemo != senha.trim() && senha.trim() != '123456') {
          return (null, 'Senha incorreta. Para demonstração use 123456.');
        }
        if (u.isPendente) {
          return (
            null,
            'Sua solicitação de acesso ainda está PENDENTE de aprovação pelo Administrador da OSC.',
          );
        }
        if (u.isRejeitado) {
          return (
            null,
            'Solicitação de acesso não aprovada: ${u.motivoRejeicao ?? "Contate o Administrador da OSC."}',
          );
        }
        await definirUsuarioAtivo(u);
        return (u, null);
      }
    }

    return (
      null,
      'Usuário não encontrado para o e-mail ou CPF informado.',
    );
  }

  Future<void> registrarSolicitacaoAcesso(UsuarioModel novoUsuario) async {
    final list = await getUsuarios();
    list.insert(0, novoUsuario);
    await salvarListaUsuarios(list);
  }

  Future<void> decidirSolicitacao({
    required String usuarioId,
    required String novoStatus, // 'aprovado' | 'rejeitado'
    required String perfilAtribuido,
    String? motivoRejeicao,
  }) async {
    final list = await getUsuarios();
    final index = list.indexWhere((u) => u.id == usuarioId);
    if (index != -1) {
      final atualizado = list[index].copyWith(
        statusAcesso: novoStatus,
        perfil: perfilAtribuido,
        motivoRejeicao: novoStatus == 'rejeitado' ? motivoRejeicao : null,
        dataDecisao: DateTime.now(),
        decididoPor: usuarioAtual.nome,
      );
      list[index] = atualizado;
      await salvarListaUsuarios(list);

      if (usuarioAtual.id == atualizado.id) {
        usuarioAtualNotifier.value = atualizado;
      }
    }
  }

  Future<void> alterarPerfilUsuario({
    required String usuarioId,
    required String novoPerfil,
  }) async {
    final list = await getUsuarios();
    final index = list.indexWhere((u) => u.id == usuarioId);
    if (index != -1) {
      final atualizado = list[index].copyWith(
        perfil: novoPerfil,
        dataDecisao: DateTime.now(),
        decididoPor: usuarioAtual.nome,
      );
      list[index] = atualizado;
      await salvarListaUsuarios(list);

      if (usuarioAtual.id == atualizado.id) {
        usuarioAtualNotifier.value = atualizado;
      }
    }
  }

  Future<int> getQuantidadeSolicitacoesPendentes() async {
    final list = await getUsuarios();
    return list.where((u) => u.isPendente).length;
  }

  List<UsuarioModel> _getInitialUsuarios() {
    final agora = DateTime.now();
    return [
      UsuarioModel(
        id: 'usr-admin-01',
        nome: 'Prof. Sérgio Roberto Pinto',
        email: 'sergio.pinto@ufma.br',
        cpf: '123.456.789-00',
        cargoFuncao: 'Coordenador Geral • Gestor da OSC',
        perfil: 'administrador',
        statusAcesso: 'aprovado',
        dataSolicitacao: agora.subtract(const Duration(days: 30)),
        dataDecisao: agora.subtract(const Duration(days: 30)),
        decididoPor: 'Administração Central UFMA / OSC',
      ),
      UsuarioModel(
        id: 'usr-alim-01',
        nome: 'Liah • Equipe Técnica OSC',
        email: 'liah.gestao@comunidadeviva.org.br',
        cpf: '234.567.890-11',
        cargoFuncao: 'Analista de Lançamentos e Documentação',
        perfil: 'alimentador',
        statusAcesso: 'aprovado',
        justificativaSolicitacao:
            'Responsável pelo lançamento diário de notas fiscais, recibos, fornecedores e ingressos de receitas.',
        dataSolicitacao: agora.subtract(const Duration(days: 20)),
        dataDecisao: agora.subtract(const Duration(days: 19)),
        decididoPor: 'Prof. Sérgio Roberto Pinto',
      ),
      UsuarioModel(
        id: 'usr-vis-01',
        nome: 'Érica • Conselho Fiscal',
        email: 'erica.conselho@comunidadeviva.org.br',
        cpf: '345.678.901-22',
        cargoFuncao: 'Conselheira Fiscal e Auditoria Interna',
        perfil: 'visualizador',
        statusAcesso: 'aprovado',
        justificativaSolicitacao:
            'Conferência periódica de extratos gerenciais, notas fiscais e relatórios por competência sem alteração de dados.',
        dataSolicitacao: agora.subtract(const Duration(days: 15)),
        dataDecisao: agora.subtract(const Duration(days: 14)),
        decididoPor: 'Prof. Sérgio Roberto Pinto',
      ),
      UsuarioModel(
        id: 'usr-pend-01',
        nome: 'Guilherme • Apoio Operacional',
        email: 'guilherme.apoio@comunidadeviva.org.br',
        cpf: '456.789.012-33',
        cargoFuncao: 'Auxiliar Financeiro • Polo Regional Bacabal',
        poloRegional: 'Maranhão • Polo 02 (Bacabal)',
        perfil: 'alimentador',
        statusAcesso: 'pendente',
        justificativaSolicitacao:
            'Solicito perfil de Alimentador para registrar comprovantes de despesas e fornecedores das oficinas capacitadoras no Polo Regional.',
        dataSolicitacao: agora.subtract(const Duration(hours: 6)),
      ),
      UsuarioModel(
        id: 'usr-pend-02',
        nome: 'Dra. Helena Costa • Auditoria Externa',
        email: 'helena.auditoria@parceiro.org.br',
        cpf: '567.890.123-44',
        cargoFuncao: 'Representante do Conselho Consultivo',
        perfil: 'visualizador',
        statusAcesso: 'pendente',
        justificativaSolicitacao:
            'Solicito acesso de Visualizador para acompanhamento da execução financeira do Termo de Fomento 2026.',
        dataSolicitacao: agora.subtract(const Duration(hours: 2)),
      ),
    ];
  }
}

