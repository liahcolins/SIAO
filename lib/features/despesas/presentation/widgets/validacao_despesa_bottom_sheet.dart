import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/datasources/despesa_local_datasource.dart';
import '../../data/models/despesa_model.dart';
import 'comprovante_viewer_dialog.dart';

class ValidacaoDespesaBottomSheet extends StatefulWidget {
  final DespesaModel despesa;
  final VoidCallback onStatusAlterado;

  const ValidacaoDespesaBottomSheet({
    super.key,
    required this.despesa,
    required this.onStatusAlterado,
  });

  static Future<void> show({
    required BuildContext context,
    required DespesaModel despesa,
    required VoidCallback onStatusAlterado,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ValidacaoDespesaBottomSheet(
        despesa: despesa,
        onStatusAlterado: onStatusAlterado,
      ),
    );
  }

  @override
  State<ValidacaoDespesaBottomSheet> createState() => _ValidacaoDespesaBottomSheetState();
}

class _ValidacaoDespesaBottomSheetState extends State<ValidacaoDespesaBottomSheet> {
  final _dataSource = DespesaLocalDataSource();
  final _motivoController = TextEditingController();
  bool _mostrarCampoRejeicao = false;
  bool _isProcessando = false;

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _aprovarDespesa() async {
    setState(() => _isProcessando = true);
    await _dataSource.atualizarStatus(widget.despesa.id, 'aprovado');
    if (mounted) {
      Navigator.pop(context);
      widget.onStatusAlterado();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Despesa aprovada com sucesso e integrada à prestação de contas!')),
            ],
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  Future<void> _rejeitarDespesa() async {
    final motivo = _motivoController.text.trim();
    if (motivo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe a justificativa da rejeição.'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    setState(() => _isProcessando = true);
    await _dataSource.atualizarStatus(
      widget.despesa.id,
      'rejeitado',
      motivoRejeicao: motivo,
    );
    if (mounted) {
      Navigator.pop(context);
      widget.onStatusAlterado();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.cancel_rounded, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Despesa marcada como rejeitada. O responsável foi notificado para correção.')),
            ],
          ),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final d = widget.despesa;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 24 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra de arraste superior
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.primaryDarkTeal,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Esteira de Validação do Administrador',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDarkTeal,
                        ),
                      ),
                      Text(
                        'Conferência documental e conformidade legal da despesa',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Informações Resumidas do Lançamento
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Formatters.formatCurrency(d.valor),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dangerRed,
                        ),
                      ),
                      _buildStatusBadge(d.statusValidaAdmin),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    d.fornecedorNome,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (d.fornecedorCpfCnpj.isNotEmpty)
                    Text(
                      'CPF/CNPJ: ${d.fornecedorCpfCnpj}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_rounded, size: 14, color: AppColors.primaryTeal),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          d.fonteRecursoNome,
                          style: const TextStyle(fontSize: 12, color: AppColors.primaryDarkTeal, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Data: ${Formatters.formatDate(d.dataGasto)} • ${d.formaPagamento}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Botão Ver Comprovante
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryDarkTeal,
                side: const BorderSide(color: AppColors.primaryTeal),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => ComprovanteViewerDialog.show(context, d),
              icon: const Icon(Icons.image_search_rounded, size: 20),
              label: const Text(
                'Visualizar Comprovante / NF Anexa',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // Se for rejeitada, exibe o motivo anterior
            if (d.motivoRejeicao != null && d.motivoRejeicao!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.dangerRed),
                        SizedBox(width: 6),
                        Text(
                          'Justificativa de Rejeição Registrada:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.dangerRed),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      d.motivoRejeicao!,
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF7F1D1D)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Campo de Justificativa ao clicar em rejeitar
            if (_mostrarCampoRejeicao) ...[
              TextField(
                controller: _motivoController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Motivo / Justificativa da Rejeição *',
                  hintText: 'Ex.: Comprovante fiscal ilegível ou sem carimbo de recebimento.',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _mostrarCampoRejeicao = false),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dangerRed,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isProcessando ? null : _rejeitarDespesa,
                      child: _isProcessando
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Confirmar Rejeição', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Botões de Ação para o Administrador
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.dangerRed,
                        side: const BorderSide(color: AppColors.dangerRed),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() => _mostrarCampoRejeicao = true);
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text(
                        'Rejeitar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isProcessando ? null : _aprovarDespesa,
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: _isProcessando
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Aprovar Gasto',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status) {
      case 'aprovado':
        bg = Colors.green.shade50;
        fg = AppColors.successGreen;
        label = 'APROVADO';
        icon = Icons.check_circle_rounded;
        break;
      case 'rejeitado':
        bg = Colors.red.shade50;
        fg = AppColors.dangerRed;
        label = 'REJEITADO';
        icon = Icons.cancel_rounded;
        break;
      default:
        bg = Colors.amber.shade50;
        fg = const Color(0xFFD97706);
        label = 'PENDENTE';
        icon = Icons.hourglass_top_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
          ),
        ],
      ),
    );
  }
}
