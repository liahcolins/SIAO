import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/datasources/cadastros_local_datasource.dart';
import '../../data/models/fornecedor_model.dart';
import '../../data/models/fonte_recurso_model.dart';

class CadastrosBasePage extends StatefulWidget {
  final VoidCallback onNovoFornecedorTap;
  final VoidCallback onNovaFonteTap;

  const CadastrosBasePage({
    super.key,
    required this.onNovoFornecedorTap,
    required this.onNovaFonteTap,
  });

  @override
  State<CadastrosBasePage> createState() => _CadastrosBasePageState();
}

class _CadastrosBasePageState extends State<CadastrosBasePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _dataSource = CadastrosLocalDataSource();

  late Future<List<FornecedorModel>> _futureFornecedores;
  late Future<List<FonteRecursoModel>> _futureFontes;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      _futureFornecedores = _dataSource.getFornecedores();
      _futureFontes = _dataSource.getFontesRecursos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastros Base'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(
              icon: Icon(Icons.people_alt_rounded, size: 20),
              text: 'Fornecedores (PF/PJ)',
            ),
            Tab(
              icon: Icon(Icons.account_balance_rounded, size: 20),
              text: 'Fontes de Recursos',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshData,
            tooltip: 'Atualizar Lista',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFornecedoresTab(),
          _buildFontesTab(),
        ],
      ),
    );
  }

  Widget _buildFornecedoresTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        onPressed: widget.onNovoFornecedorTap,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Novo Fornecedor', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<FornecedorModel>>(
        future: _futureFornecedores,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('Nenhum fornecedor cadastrado.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item.tipoPessoa == 'PJ'
                              ? AppColors.primaryLightTeal
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.tipoPessoa == 'PJ'
                              ? Icons.business_rounded
                              : Icons.person_rounded,
                          color: item.tipoPessoa == 'PJ'
                              ? AppColors.primaryTeal
                              : Colors.orange.shade800,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nomeRazaoSocial,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.tipoPessoa} • Doc: ${item.cpfCnpj}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            if (item.telefone != null || item.email != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                [
                                  if (item.telefone != null) item.telefone,
                                  if (item.email != null) item.email,
                                ].join(' • '),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.tipoOperacao.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFontesTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        onPressed: widget.onNovaFonteTap,
        icon: const Icon(Icons.add_home_work_rounded),
        label: const Text('Nova Fonte', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<FonteRecursoModel>>(
        future: _futureFontes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_outlined, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('Nenhuma fonte de recurso cadastrada.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
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
                                  Icons.account_balance_wallet_rounded,
                                  color: AppColors.primaryTeal,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDarkTeal.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.tipoFonte.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDarkTeal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (item.valorPrevisto != null)
                            Text(
                              Formatters.formatCurrency(item.valorPrevisto!),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.successGreen,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.nome,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.descricao != null && item.descricao!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.descricao!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
