import 'package:equatable/equatable.dart';

class TransferenciaModel extends Equatable {
  final String id;
  final String contaOrigem;
  final String contaDestino;
  final double valor;
  final DateTime data;
  final String finalidade;
  final String statusValidaAdmin;
  final DateTime criadoEm;

  const TransferenciaModel({
    required this.id,
    required this.contaOrigem,
    required this.contaDestino,
    required this.valor,
    required this.data,
    required this.finalidade,
    this.statusValidaAdmin = 'pendente',
    required this.criadoEm,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contaOrigem': contaOrigem,
      'contaDestino': contaDestino,
      'valor': valor,
      'data': data.toIso8601String(),
      'finalidade': finalidade,
      'statusValidaAdmin': statusValidaAdmin,
      'criadoEm': criadoEm.toIso8601String(),
    };
  }

  factory TransferenciaModel.fromJson(Map<String, dynamic> json) {
    return TransferenciaModel(
      id: json['id'] as String,
      contaOrigem: json['contaOrigem'] as String,
      contaDestino: json['contaDestino'] as String,
      valor: (json['valor'] as num).toDouble(),
      data: DateTime.parse(json['data'] as String),
      finalidade: json['finalidade'] as String,
      statusValidaAdmin: json['statusValidaAdmin'] as String? ?? 'pendente',
      criadoEm: DateTime.parse(json['criadoEm'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        contaOrigem,
        contaDestino,
        valor,
        data,
        finalidade,
        statusValidaAdmin,
        criadoEm,
      ];
}
