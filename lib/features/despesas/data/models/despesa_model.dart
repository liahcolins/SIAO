import 'package:equatable/equatable.dart';

class DespesaModel extends Equatable {
  final String id;
  final String fonteRecursoId;
  final String fonteRecursoNome;
  final String fornecedorId;
  final String fornecedorNome;
  final String fornecedorCpfCnpj;
  final double valor;
  final DateTime dataGasto;
  final String formaPagamento; // 'PIX / Depósito Bancário', 'Cheque', 'Dinheiro em Espécie'
  final String descricao;
  final String tipoComprovante; // 'Nota Fiscal Eletrônica (NF-e)', 'Cupom Fiscal', 'Recibo Avulso'
  final String? comprovantePath; // Caminho ou identificador do anexo
  final String? comprovanteTitulo; // Título / Identificador do documento
  final String statusValidaAdmin; // 'pendente', 'aprovado', 'rejeitado'
  final String? motivoRejeicao;
  final DateTime? validadoEm;
  final DateTime criadoEm;

  const DespesaModel({
    required this.id,
    required this.fonteRecursoId,
    required this.fonteRecursoNome,
    required this.fornecedorId,
    required this.fornecedorNome,
    required this.fornecedorCpfCnpj,
    required this.valor,
    required this.dataGasto,
    required this.formaPagamento,
    required this.descricao,
    required this.tipoComprovante,
    this.comprovantePath,
    this.comprovanteTitulo,
    this.statusValidaAdmin = 'pendente',
    this.motivoRejeicao,
    this.validadoEm,
    required this.criadoEm,
  });

  bool get isPendente => statusValidaAdmin == 'pendente';
  bool get isAprovado => statusValidaAdmin == 'aprovado';
  bool get isRejeitado => statusValidaAdmin == 'rejeitado';

  DespesaModel copyWith({
    String? id,
    String? fonteRecursoId,
    String? fonteRecursoNome,
    String? fornecedorId,
    String? fornecedorNome,
    String? fornecedorCpfCnpj,
    double? valor,
    DateTime? dataGasto,
    String? formaPagamento,
    String? descricao,
    String? tipoComprovante,
    String? comprovantePath,
    String? comprovanteTitulo,
    String? statusValidaAdmin,
    String? motivoRejeicao,
    DateTime? validadoEm,
    DateTime? criadoEm,
  }) {
    return DespesaModel(
      id: id ?? this.id,
      fonteRecursoId: fonteRecursoId ?? this.fonteRecursoId,
      fonteRecursoNome: fonteRecursoNome ?? this.fonteRecursoNome,
      fornecedorId: fornecedorId ?? this.fornecedorId,
      fornecedorNome: fornecedorNome ?? this.fornecedorNome,
      fornecedorCpfCnpj: fornecedorCpfCnpj ?? this.fornecedorCpfCnpj,
      valor: valor ?? this.valor,
      dataGasto: dataGasto ?? this.dataGasto,
      formaPagamento: formaPagamento ?? this.formaPagamento,
      descricao: descricao ?? this.descricao,
      tipoComprovante: tipoComprovante ?? this.tipoComprovante,
      comprovantePath: comprovantePath ?? this.comprovantePath,
      comprovanteTitulo: comprovanteTitulo ?? this.comprovanteTitulo,
      statusValidaAdmin: statusValidaAdmin ?? this.statusValidaAdmin,
      motivoRejeicao: motivoRejeicao ?? this.motivoRejeicao,
      validadoEm: validadoEm ?? this.validadoEm,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fonteRecursoId': fonteRecursoId,
      'fonteRecursoNome': fonteRecursoNome,
      'fornecedorId': fornecedorId,
      'fornecedorNome': fornecedorNome,
      'fornecedorCpfCnpj': fornecedorCpfCnpj,
      'valor': valor,
      'dataGasto': dataGasto.toIso8601String(),
      'formaPagamento': formaPagamento,
      'descricao': descricao,
      'tipoComprovante': tipoComprovante,
      'comprovantePath': comprovantePath,
      'comprovanteTitulo': comprovanteTitulo,
      'statusValidaAdmin': statusValidaAdmin,
      'motivoRejeicao': motivoRejeicao,
      'validadoEm': validadoEm?.toIso8601String(),
      'criadoEm': criadoEm.toIso8601String(),
    };
  }

  factory DespesaModel.fromJson(Map<String, dynamic> json) {
    return DespesaModel(
      id: json['id'] as String,
      fonteRecursoId: json['fonteRecursoId'] as String,
      fonteRecursoNome: json['fonteRecursoNome'] as String,
      fornecedorId: json['fornecedorId'] as String,
      fornecedorNome: json['fornecedorNome'] as String,
      fornecedorCpfCnpj: json['fornecedorCpfCnpj'] as String? ?? '',
      valor: (json['valor'] as num).toDouble(),
      dataGasto: DateTime.parse(json['dataGasto'] as String),
      formaPagamento: json['formaPagamento'] as String? ?? 'PIX / Depósito Bancário',
      descricao: json['descricao'] as String,
      tipoComprovante: json['tipoComprovante'] as String? ?? 'Nota Fiscal Eletrônica (NF-e)',
      comprovantePath: json['comprovantePath'] as String?,
      comprovanteTitulo: json['comprovanteTitulo'] as String?,
      statusValidaAdmin: json['statusValidaAdmin'] as String? ?? 'pendente',
      motivoRejeicao: json['motivoRejeicao'] as String?,
      validadoEm: json['validadoEm'] != null
          ? DateTime.parse(json['validadoEm'] as String)
          : null,
      criadoEm: json['criadoEm'] != null
          ? DateTime.parse(json['criadoEm'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        fonteRecursoId,
        fonteRecursoNome,
        fornecedorId,
        fornecedorNome,
        fornecedorCpfCnpj,
        valor,
        dataGasto,
        formaPagamento,
        descricao,
        tipoComprovante,
        comprovantePath,
        comprovanteTitulo,
        statusValidaAdmin,
        motivoRejeicao,
        validadoEm,
        criadoEm,
      ];
}
