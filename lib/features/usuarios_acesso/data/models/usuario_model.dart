class UsuarioModel {
  final String id;
  final String nome;
  final String email;
  final String cpf;
  final String cargoFuncao;
  final String organizacaoNome;
  final String organizacaoCnpj;
  final String poloRegional;
  final String perfil; // 'administrador' | 'alimentador' | 'visualizador'
  final String statusAcesso; // 'aprovado' | 'pendente' | 'rejeitado'
  final String? justificativaSolicitacao;
  final String? motivoRejeicao;
  final DateTime dataSolicitacao;
  final DateTime? dataDecisao;
  final String? decididoPor;
  final String senhaDemo;

  const UsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.cpf,
    required this.cargoFuncao,
    this.organizacaoNome = 'Associação Comunidade Viva',
    this.organizacaoCnpj = '12.345.678/0001-90',
    this.poloRegional = 'Maranhão • Polo 01 (São Luís)',
    required this.perfil,
    required this.statusAcesso,
    this.justificativaSolicitacao,
    this.motivoRejeicao,
    required this.dataSolicitacao,
    this.dataDecisao,
    this.decididoPor,
    this.senhaDemo = '123456',
  });

  bool get isAdministrador => perfil == 'administrador';
  bool get isAlimentador => perfil == 'alimentador';
  bool get isVisualizador => perfil == 'visualizador';

  bool get isAprovado => statusAcesso == 'aprovado';
  bool get isPendente => statusAcesso == 'pendente';
  bool get isRejeitado => statusAcesso == 'rejeitado';

  /// Alimentador e Administrador podem cadastrar fornecedores, fontes, receitas e despesas.
  bool get podeRealizarLancamentos => isAdministrador || isAlimentador;

  /// Apenas o Administrador pode aprovar/rejeitar despesas, registrar transferências gerenciais e aprovar usuários.
  bool get podeValidarEAprovar => isAdministrador;

  String get perfilLabel {
    switch (perfil) {
      case 'administrador':
        return 'Administrador';
      case 'alimentador':
        return 'Alimentador';
      case 'visualizador':
        return 'Visualizador';
      default:
        return 'Usuário';
    }
  }

  String get perfilBadge {
    switch (perfil) {
      case 'administrador':
        return 'ADMIN';
      case 'alimentador':
        return 'ALIMENTADOR';
      case 'visualizador':
        return 'VISUALIZADOR';
      default:
        return 'USUÁRIO';
    }
  }

  String get perfilDescricao {
    switch (perfil) {
      case 'administrador':
        return 'Gerencia a OSC, aprova usuários, valida comprovantes de despesas e registra transferências gerenciais.';
      case 'alimentador':
        return 'Realiza o cadastro de fornecedores, fontes de recursos, receitas e despesas com anexação de comprovantes.';
      case 'visualizador':
        return 'Consulta registros, comprovantes e relatórios para conferência e auditoria, sem permissão de alteração.';
      default:
        return '';
    }
  }

  UsuarioModel copyWith({
    String? id,
    String? nome,
    String? email,
    String? cpf,
    String? cargoFuncao,
    String? organizacaoNome,
    String? organizacaoCnpj,
    String? poloRegional,
    String? perfil,
    String? statusAcesso,
    String? justificativaSolicitacao,
    String? motivoRejeicao,
    DateTime? dataSolicitacao,
    DateTime? dataDecisao,
    String? decididoPor,
    String? senhaDemo,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      cargoFuncao: cargoFuncao ?? this.cargoFuncao,
      organizacaoNome: organizacaoNome ?? this.organizacaoNome,
      organizacaoCnpj: organizacaoCnpj ?? this.organizacaoCnpj,
      poloRegional: poloRegional ?? this.poloRegional,
      perfil: perfil ?? this.perfil,
      statusAcesso: statusAcesso ?? this.statusAcesso,
      justificativaSolicitacao:
          justificativaSolicitacao ?? this.justificativaSolicitacao,
      motivoRejeicao: motivoRejeicao ?? this.motivoRejeicao,
      dataSolicitacao: dataSolicitacao ?? this.dataSolicitacao,
      dataDecisao: dataDecisao ?? this.dataDecisao,
      decididoPor: decididoPor ?? this.decididoPor,
      senhaDemo: senhaDemo ?? this.senhaDemo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'cargoFuncao': cargoFuncao,
      'organizacaoNome': organizacaoNome,
      'organizacaoCnpj': organizacaoCnpj,
      'poloRegional': poloRegional,
      'perfil': perfil,
      'statusAcesso': statusAcesso,
      'justificativaSolicitacao': justificativaSolicitacao,
      'motivoRejeicao': motivoRejeicao,
      'dataSolicitacao': dataSolicitacao.toIso8601String(),
      'dataDecisao': dataDecisao?.toIso8601String(),
      'decididoPor': decididoPor,
      'senhaDemo': senhaDemo,
    };
  }

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
      cpf: json['cpf'] as String,
      cargoFuncao: json['cargoFuncao'] as String,
      organizacaoNome:
          (json['organizacaoNome'] as String?) ?? 'Associação Comunidade Viva',
      organizacaoCnpj:
          (json['organizacaoCnpj'] as String?) ?? '12.345.678/0001-90',
      poloRegional:
          (json['poloRegional'] as String?) ?? 'Maranhão • Polo 01 (São Luís)',
      perfil: json['perfil'] as String,
      statusAcesso: json['statusAcesso'] as String,
      justificativaSolicitacao: json['justificativaSolicitacao'] as String?,
      motivoRejeicao: json['motivoRejeicao'] as String?,
      dataSolicitacao: DateTime.parse(json['dataSolicitacao'] as String),
      dataDecisao: json['dataDecisao'] != null
          ? DateTime.parse(json['dataDecisao'] as String)
          : null,
      decididoPor: json['decididoPor'] as String?,
      senhaDemo: (json['senhaDemo'] as String?) ?? '123456',
    );
  }
}

