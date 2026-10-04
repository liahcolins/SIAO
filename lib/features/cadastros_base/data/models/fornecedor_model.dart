import 'package:equatable/equatable.dart';

class FornecedorModel extends Equatable {
  final String id;
  final String nomeRazaoSocial;
  final String tipoPessoa; // 'PF' (Pessoa Física) ou 'PJ' (Pessoa Jurídica)
  final String cpfCnpj;
  final String tipoOperacao; // 'Despesa' (Fornecedor) ou 'Receita' (Fonte/Cliente) ou 'Ambos'
  final String? telefone;
  final String? email;
  final DateTime criadoEm;

  const FornecedorModel({
    required this.id,
    required this.nomeRazaoSocial,
    required this.tipoPessoa,
    required this.cpfCnpj,
    required this.tipoOperacao,
    this.telefone,
    this.email,
    required this.criadoEm,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomeRazaoSocial': nomeRazaoSocial,
      'tipoPessoa': tipoPessoa,
      'cpfCnpj': cpfCnpj,
      'tipoOperacao': tipoOperacao,
      'telefone': telefone,
      'email': email,
      'criadoEm': criadoEm.toIso8601String(),
    };
  }

  factory FornecedorModel.fromJson(Map<String, dynamic> json) {
    return FornecedorModel(
      id: json['id'] as String,
      nomeRazaoSocial: json['nomeRazaoSocial'] as String,
      tipoPessoa: json['tipoPessoa'] as String? ?? 'PJ',
      cpfCnpj: json['cpfCnpj'] as String,
      tipoOperacao: json['tipoOperacao'] as String? ?? 'Despesa',
      telefone: json['telefone'] as String?,
      email: json['email'] as String?,
      criadoEm: json['criadoEm'] != null
          ? DateTime.parse(json['criadoEm'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        nomeRazaoSocial,
        tipoPessoa,
        cpfCnpj,
        tipoOperacao,
        telefone,
        email,
        criadoEm,
      ];
}
