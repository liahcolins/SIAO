import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/despesa_model.dart';

class ComprovanteViewerDialog extends StatelessWidget {
  final DespesaModel despesa;

  const ComprovanteViewerDialog({
    super.key,
    required this.despesa,
  });

  static void show(BuildContext context, DespesaModel despesa) {
    showDialog(
      context: context,
      builder: (ctx) => ComprovanteViewerDialog(despesa: despesa),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho do Documento
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLightTeal,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.primaryDarkTeal,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Comprovante Fiscal Anexo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDarkTeal,
                          ),
                        ),
                        Text(
                          despesa.tipoComprovante,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Fechar',
                ),
              ],
            ),
            const Divider(height: 24),

            // Pré-visualização do Documento Fiscal (Estilo Nota Fiscal / Recibo Digital)
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBFBFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Cabeçalho da Nota
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTeal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                despesa.tipoComprovante.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDarkTeal,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              despesa.comprovanteTitulo ?? 'Documento Comprobatório Oficial',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(thickness: 1, height: 1),
                      const SizedBox(height: 14),

                      // Dados do Fornecedor / Emissor
                      _buildRowItem('EMISSOR / FORNECEDOR:', despesa.fornecedorNome, isBold: true),
                      if (despesa.fornecedorCpfCnpj.isNotEmpty)
                        _buildRowItem('CNPJ / CPF:', despesa.fornecedorCpfCnpj),
                      _buildRowItem('DESTINATÁRIO (OSC):', 'Associação Comunidade Viva • CNPJ 12.345.678/0001-90'),
                      _buildRowItem('FONTE PAGADORA VINCULADA:', despesa.fonteRecursoNome),
                      _buildRowItem('DATA DO GASTO:', Formatters.formatDate(despesa.dataGasto)),
                      _buildRowItem('FORMA DE LIQUIDAÇÃO:', despesa.formaPagamento),

                      const SizedBox(height: 14),
                      const Divider(thickness: 1, height: 1),
                      const SizedBox(height: 14),

                      // Descrição
                      const Text(
                        'DISCRIMINAÇÃO DOS PRODUTOS / SERVIÇOS:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondaryLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          despesa.descricao,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF334155),
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Totalizador do Documento
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLightTeal,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'VALOR TOTAL COMPROVADO:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDarkTeal,
                              ),
                            ),
                            Text(
                              Formatters.formatCurrency(despesa.valor),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDarkTeal,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Simulação visual de Carimbo Fiscal e Código de Barras
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.qr_code_2_rounded, size: 40, color: Color(0xFF334155)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'DOCUMENTO FISCAL AUTÊNTICO',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.successGreen,
                                        ),
                                      ),
                                      Text(
                                        'Protocolo digital: ${despesa.id.toUpperCase()}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      Text(
                                        'Cadastrado em: ${Formatters.formatDate(despesa.criadoEm)}',
                                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botão Fechar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Concluir Visualização',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowItem(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondaryLight,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
