import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/bank_warning_banner.dart';
import '../../data/datasources/despesa_local_datasource.dart';
import '../../data/models/despesa_model.dart';
import '../widgets/comprovante_viewer_dialog.dart';
import '../widgets/validacao_despesa_bottom_sheet.dart';

class ListaDespesasPage extends StatefulWidget {
  final VoidCallback onNovoCadastroTap;

  const ListaDespesasPage({
    super.key,
    required this.onNovoCadastroTap,
  });

  @override
  State<ListaDespesasPage> createState() => _ListaDespesasPageState();
}

class _ListaDespesasPageState extends State<ListaDespesasPage>
    with SingleTickerProviderStateMixin {
  final _dataSource = DespesaLocalDataSource();
  late TabController _tabController;
  late Future<List<DespesaModel>> _futureList;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _refreshList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshList() {
    setState(() {
      _futureList = _dataSource.getDespesas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Despesas & Comprovações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshList,
            tooltip: 'Atualizar Lista',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Pendentes'),
            Tab(text: 'Aprovadas'),
            Tab(text: 'Rejeitadas'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        onPressed: widget.onNovoCadastroTap,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova Despesa', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<DespesaModel>>(
        future: _futureList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryTeal),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar despesas: ${snapshot.error}'),
            );
          }

          final allDespesas = snapshot.data ?? [];
          final totalAprovado = allDespesas
              .where((d) => d.statusValidaAdmin == 'aprovado')
              .fold<double>(0.0, (sum, d) => sum + d.valor);
          final totalPendente = allDespesas
              .where((d) => d.statusValidaAdmin == 'pendente')
              .fold<double>(0.0, (sum, d) => sum + d.valor);
          final qtdPendentes = allDespesas.where((d) => d.statusValidaAdmin == 'pendente').length;

          // Filtra de acordo com a aba selecionada
          List<DespesaModel> displayedList;
          switch (_tabController.index) {
            case 1:
              displayedList = allDespesas.where((d) => d.statusValidaAdmin == 'pendente').toList();
              break;
            case 2:
              displayedList = allDespesas.where((d) => d.statusValidaAdmin == 'aprovado').toList();
              break;
            case 3:
              displayedList = allDespesas.where((d) => d.statusValidaAdmin == 'rejeitado').toList();
              break;
            default:
              displayedList = allDespesas;
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const BankWarningBanner(),
              const SizedBox(height: 16),

              // Header Analítico de Despesas da Etapa 3
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF991B1B), AppColors.dangerRed],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dangerRed.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL DE DESPESAS DA OSC',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${allDespesas.length} registros',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Formatters.formatCurrency(totalAprovado),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Despesas aprovadas na prestação de contas gerencial',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    if (qtdPendentes > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade400.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$qtdPendentes pendência(s) de validação (${Formatters.formatCurrency(totalPendente)}) aguardando conferência do Administrador.',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Banner de Diretrizes da UFMA para Despesas
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLightTeal,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.primaryDarkTeal, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pilar da Conformidade: Nenhuma despesa existe sem documento comprobatório anexo e sem vínculo a uma Fonte de Recurso.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDarkTeal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (displayedList.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhuma despesa encontrada nesta categoria.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ],
                  ),
                )
              else
                ...displayedList.map((despesa) => _buildDespesaCard(despesa)),

              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDespesaCard(DespesaModel despesa) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: despesa.isPendente
              ? Colors.amber.shade300
              : despesa.isRejeitado
                  ? Colors.red.shade200
                  : Colors.grey.shade200,
          width: despesa.isPendente ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha superior: Valor e Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.formatCurrency(despesa.valor),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dangerRed,
                  ),
                ),
                _buildStatusChip(despesa.statusValidaAdmin),
              ],
            ),
            const SizedBox(height: 8),

            // Fornecedor
            Row(
              children: [
                const Icon(Icons.storefront_rounded, size: 16, color: AppColors.primaryTeal),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    despesa.fornecedorNome,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
            if (despesa.fornecedorCpfCnpj.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 22, top: 2),
                child: Text(
                  'CNPJ/CPF: ${despesa.fornecedorCpfCnpj}',
                  style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 6),

            // Fonte de Recursos
            Row(
              children: [
                const Icon(Icons.account_balance_rounded, size: 15, color: AppColors.primaryDarkTeal),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    despesa.fonteRecursoNome,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDarkTeal,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Descrição do gasto
            Text(
              despesa.descricao,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
            ),

            const SizedBox(height: 8),

            // Dados complementares (Data, Forma e Comprovante)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildInfoBadge(Icons.calendar_today_rounded, Formatters.formatDate(despesa.dataGasto)),
                _buildInfoBadge(Icons.payment_rounded, despesa.formaPagamento),
                _buildInfoBadge(Icons.receipt_rounded, despesa.tipoComprovante),
              ],
            ),

            if (despesa.isRejeitado && despesa.motivoRejeicao != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.dangerRed),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Motivo da rejeição: ${despesa.motivoRejeicao}',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.dangerRed, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Ações do Card
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => ComprovanteViewerDialog.show(context, despesa),
                  icon: const Icon(Icons.attachment_rounded, size: 17, color: AppColors.primaryTeal),
                  label: const Text(
                    'Ver NF / Recibo',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: despesa.isPendente ? const Color(0xFFD97706) : AppColors.primaryDarkTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    ValidacaoDespesaBottomSheet.show(
                      context: context,
                      despesa: despesa,
                      onStatusAlterado: _refreshList,
                    );
                  },
                  icon: Icon(
                    despesa.isPendente ? Icons.fact_check_rounded : Icons.edit_note_rounded,
                    size: 16,
                  ),
                  label: Text(
                    despesa.isPendente ? 'Validar Gasto' : 'Gerenciar',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'aprovado':
        bg = Colors.green.shade50;
        fg = AppColors.successGreen;
        label = 'APROVADO';
        break;
      case 'rejeitado':
        bg = Colors.red.shade50;
        fg = AppColors.dangerRed;
        label = 'REJEITADO';
        break;
      default:
        bg = Colors.amber.shade50;
        fg = const Color(0xFFD97706);
        label = 'PENDENTE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
