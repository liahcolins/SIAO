import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/datasources/transferencia_local_datasource.dart';
import '../../data/models/transferencia_model.dart';

class ListaTransferenciasPage extends StatefulWidget {
  final VoidCallback onNovoCadastroTap;

  const ListaTransferenciasPage({
    super.key,
    required this.onNovoCadastroTap,
  });

  @override
  State<ListaTransferenciasPage> createState() =>
      _ListaTransferenciasPageState();
}

class _ListaTransferenciasPageState extends State<ListaTransferenciasPage> {
  final _dataSource = TransferenciaLocalDataSource();
  late Future<List<TransferenciaModel>> _futureList;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _futureList = _dataSource.getTransferencias();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferências Gerenciais'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshList,
            tooltip: 'Atualizar Lista',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        onPressed: widget.onNovoCadastroTap,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova Transferência', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<TransferenciaModel>>(
        future: _futureList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryTeal),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar registros: ${snapshot.error}'),
            );
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma transferência cadastrada ainda.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return _buildTransferenciaCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildTransferenciaCard(TransferenciaModel item) {
    final isAprovado = item.statusValidaAdmin == 'aprovado';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        Icons.swap_horiz_rounded,
                        color: AppColors.primaryTeal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transferência Gerencial',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          Formatters.formatDate(item.data),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAprovado
                        ? AppColors.successGreen.withValues(alpha: 0.12)
                        : AppColors.accentOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isAprovado ? 'VALIDADO' : 'PENDENTE ADMIN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isAprovado ? AppColors.successGreen : AppColors.accentOrange,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            Row(
              children: [
                const Icon(Icons.arrow_upward_rounded, size: 14, color: AppColors.dangerRed),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'De: ${item.contaOrigem}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.arrow_downward_rounded, size: 14, color: AppColors.successGreen),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Para: ${item.contaDestino}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    item.finalidade,
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  Formatters.formatCurrency(item.valor),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
