import 'package:equatable/equatable.dart';

class ReceitaModel extends Equatable {
  final String id;
  final String fonteRecursoId;
  final String fonteRecursoNome;
  final bool eProduto; // Sim / Não
  final double valor;
  final DateTime dataRecebimento;
  final String formaPagamento; // 'PIX / Depósito Bancário', 'Cheque', 'Dinheiro em Espécie'
  final bool referenteAnoBase; // Sim / Não
  final String descricao;
  final String statusValidaAdmin; // 'pendente', 'aprovado', 'rejeitado'
  final DateTime criadoEm;

  const ReceitaModel({
    required this.id,
    required this.fonteRecursoId,
    required this.fonteRecursoNome,
    required this.eProduto,
    required this.valor,
    required this.dataRecebimento,
    required this.formaPagamento,
    required this.referenteAnoBase,
    required this.descricao,
    this.statusValidaAdmin = 'aprovado',
    required this.criadoEm,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fonteRecursoId': fonteRecursoId,
      'fonteRecursoNome': fonteRecursoNome,
      'eProduto': eProduto,
      'valor': valor,
      'dataRecebimento': dataRecebimento.toIso8601String(),
      'formaPagamento': formaPagamento,
      'referenteAnoBase': referenteAnoBase,
      'descricao': descricao,
      'statusValidaAdmin': statusValidaAdmin,
      'criadoEm': criadoEm.toIso8601String(),
    };
  }

  factory ReceitaModel.fromJson(Map<String, dynamic> json) {
    return ReceitaModel(
      id: json['id'] as String,
      fonteRecursoId: json['fonteRecursoId'] as String,
      fonteRecursoNome: json['fonteRecursoNome'] as String,
      eProduto: json['eProduto'] as bool? ?? false,
      valor: (json['valor'] as num).toDouble(),
      dataRecebimento: DateTime.parse(json['dataRecebimento'] as String),
      formaPagamento: json['formaPagamento'] as String? ?? 'PIX / Depósito Bancário',
      referenteAnoBase: json['referenteAnoBase'] as bool? ?? true,
      descricao: json['descricao'] as String,
      statusValidaAdmin: json['statusValidaAdmin'] as String? ?? 'aprovado',
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
        eProduto,
        valor,
        dataRecebimento,
        formaPagamento,
        referenteAnoBase,
        descricao,
        statusValidaAdmin,
        criadoEm,
      ];
}
