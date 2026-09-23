import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Administrador'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card de Cabeçalho do Perfil
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 48,
                        color: AppColors.primaryDarkTeal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Prof. Sérgio Roberto Pinto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLightTeal,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'Perfil: ADMINISTRADOR DA OSC',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card de Dados da OSC
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.corporate_fare_rounded, color: AppColors.primaryTeal),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Dados da Organização (OSC)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    _InfoRow(label: 'Razão Social', value: 'Associação Comunidade Viva'),
                    _InfoRow(label: 'CNPJ', value: '12.345.678/0001-90'),
                    _InfoRow(label: 'Polo Regional', value: 'Maranhão • Polo 01 (São Luís)'),
                    _InfoRow(label: 'Projeto Vinculado', value: 'Projeto Mais Gestão / UFMA 2026'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card de Status do Sistema e Conexão Híbrida
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud_sync_rounded, color: AppColors.primaryTeal),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Status de Sincronização & Armazenamento',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    _InfoRow(label: 'Modo de Operação', value: 'Offline-First + Nuvem Híbrida'),
                    _InfoRow(label: 'Banco Local', value: 'SQLite (Drift) Ativo'),
                    _InfoRow(label: 'Licença da Plataforma', value: '100% Gratuito / Open-Source (BSD)'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

