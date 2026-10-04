import 'package:equatable/equatable.dart';

class FonteRecursoModel extends Equatable {
  final String id;
  final String nome;
  final String tipoFonte; // 'Governamental', 'Doação Privada', 'Convênio', 'Recursos Próprios', 'Evento/Rifa'
  final String? descricao;
  final double? valorPrevisto;
  final DateTime criadoEm;

  const FonteRecursoModel({
    required this.id,
    required this.nome,
    required this.tipoFonte,
    this.descricao,
    this.valorPrevisto,
    required this.criadoEm,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipoFonte': tipoFonte,
      'descricao': descricao,
      'valorPrevisto': valorPrevisto,
      'criadoEm': criadoEm.toIso8601String(),
    };
  }

  factory FonteRecursoModel.fromJson(Map<String, dynamic> json) {
    return FonteRecursoModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      tipoFonte: json['tipoFonte'] as String? ?? 'Governamental',
      descricao: json['descricao'] as String?,
      valorPrevisto: (json['valorPrevisto'] as num?)?.toDouble(),
      criadoEm: json['criadoEm'] != null
          ? DateTime.parse(json['criadoEm'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        tipoFonte,
        descricao,
        valorPrevisto,
        criadoEm,
      ];
}
