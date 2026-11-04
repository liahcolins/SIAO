import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/datasources/usuario_local_datasource.dart';
import '../../data/models/usuario_model.dart';
import '../widgets/aprovacao_acesso_bottom_sheet.dart';
import 'solicitar_acesso_page.dart';

class GestaoUsuariosRbacPage extends StatefulWidget {
  const GestaoUsuariosRbacPage({super.key});

  @override
  State<GestaoUsuariosRbacPage> createState() => _GestaoUsuariosRbacPageState();
}

class _GestaoUsuariosRbacPageState extends State<GestaoUsuariosRbacPage>
    with SingleTickerProviderStateMixin {
  final _dataSource = UsuarioLocalDataSource();
  late TabController _tabController;
  late Future<List<UsuarioModel>> _futureUsuarios;

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
      _futureUsuarios = _dataSource.getUsuarios();
    });
  }

  void _abrirNovaSolicitacao() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => SolicitarAcessoPage(
              onSolicitacaoEnviada: _refreshList,
            ),
          ),
        )
        .then((_) => _refreshList());
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UsuarioModel>(
      valueListenable: UsuarioLocalDataSource.usuarioAtualNotifier,
      builder: (context, usuarioLogado, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Usuários & Permissões (RBAC)'),
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
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
              tabs: const [
                Tab(text: 'Todos'),
                Tab(text: 'Solicitações Pendentes'),
                Tab(text: 'Ativos (RBAC)'),
                Tab(text: 'Rejeitados'),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primaryTeal,
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            onPressed: _abrirNovaSolicitacao,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text(
              'Solicitar Acesso',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: FutureBuilder<List<UsuarioModel>>(
            future: _futureUsuarios,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryTeal),
                );
              }

              final allUsers = snapshot.data ?? [];
              final pendentes = allUsers.where((u) => u.isPendente).toList();
              final aprovados = allUsers.where((u) => u.isAprovado).toList();
              final rejeitados = allUsers.where((u) => u.isRejeitado).toList();

              final qtdAdmins = aprovados
                  .where((u) => u.isAdministrador)
                  .length;
              final qtdAlimentadores = aprovados
                  .where((u) => u.isAlimentador)
                  .length;
              final qtdVisualizadores = aprovados
                  .where((u) => u.isVisualizador)
                  .length;

              List<UsuarioModel> displayedList;
              switch (_tabController.index) {
                case 1:
                  displayedList = pendentes;
                  break;
                case 2:
                  displayedList = aprovados;
                  break;
                case 3:
                  displayedList = rejeitados;
                  break;
                default:
                  displayedList = allUsers;
              }

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Header Analítico da Etapa 4 (RBAC + Solicitações)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryDarkTeal,
                          AppColors.primaryTeal,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryTeal.withValues(alpha: 0.25),
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
                              'CONTROLE DE ACESSO E RESPONSABILIZAÇÃO',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${aprovados.length} ativos • ${pendentes.length} pendentes',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildRoleCounter(
                                count: '$qtdAdmins',
                                label: 'Admin',
                                icon: Icons.verified_user_rounded,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildRoleCounter(
                                count: '$qtdAlimentadores',
                                label: 'Alimentador',
                                icon: Icons.edit_document,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildRoleCounter(
                                count: '$qtdVisualizadores',
                                label: 'Visualizador',
                                icon: Icons.visibility_rounded,
                              ),
                            ),
                          ],
                        ),
                        if (pendentes.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () => _tabController.animateTo(1),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade400.withValues(
                                  alpha: 0.22,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.amber.shade300,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.notification_important_rounded,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${pendentes.length} solicitação(ões) de acesso aguardando deliberação do Administrador.',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Matriz de Permissões (Pilar 2 da Accountability)
                  _buildMatrizRbacCard(),

                  const SizedBox(height: 16),

                  if (displayedList.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 24,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Nenhum usuário encontrado neste filtro.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...displayedList.map(
                      (u) => _buildUsuarioCard(u, usuarioLogado),
                    ),

                  const SizedBox(height: 80),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRoleCounter({
    required String count,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrizRbacCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryTeal.withValues(alpha: 0.2),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: AppColors.primaryDarkTeal,
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Matriz RBAC • 2º Pilar da Accountability (Responsabilização)',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarkTeal,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Administrador: Gerencia a OSC, aprova acessos, valida despesas e faz transferências.\n'
            '• Alimentador: Registra fornecedores, fontes, receitas e despesas com comprovantes.\n'
            '• Visualizador: Consulta saldos, comprovantes e relatórios sem alterar registros.',
            style: TextStyle(
              fontSize: 11.5,
              color: Color(0xFF475569),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsuarioCard(UsuarioModel u, UsuarioModel usuarioLogado) {
    final isCurrentSession = u.id == usuarioLogado.id;
    final Color roleColor = u.isAdministrador
        ? AppColors.primaryDarkTeal
        : u.isAlimentador
            ? const Color(0xFF0284C7)
            : const Color(0xFF7C3AED);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: u.isPendente
              ? Colors.amber.shade400
              : isCurrentSession
                  ? AppColors.primaryTeal
                  : Colors.grey.shade200,
          width: (u.isPendente || isCurrentSession) ? 1.6 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha Superior: Perfil + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        u.perfilBadge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: roleColor,
                        ),
                      ),
                    ),
                    if (isCurrentSession) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'SESSÃO ATIVA',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                _buildStatusChip(u.statusAcesso),
              ],
            ),
            const SizedBox(height: 10),

            // Nome e Cargo
            Text(
              u.nome,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              u.cargoFuncao,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: roleColor,
              ),
            ),
            const SizedBox(height: 6),

            // E-mail, CPF, Polo
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildBadgeInfo(Icons.email_outlined, u.email),
                _buildBadgeInfo(Icons.badge_outlined, 'CPF: ${u.cpf}'),
                _buildBadgeInfo(Icons.location_on_outlined, u.poloRegional),
                _buildBadgeInfo(
                  Icons.calendar_today_rounded,
                  Formatters.formatDate(u.dataSolicitacao),
                ),
              ],
            ),

            if (u.justificativaSolicitacao != null &&
                u.justificativaSolicitacao!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Atribuição / Justificativa: "${u.justificativaSolicitacao!}"',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF475569),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],

            if (u.isRejeitado && u.motivoRejeicao != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  'Motivo da rejeição: ${u.motivoRejeicao}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.dangerRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (u.isAprovado && !isCurrentSession)
                  TextButton.icon(
                    onPressed: () async {
                      await _dataSource.definirUsuarioAtivo(u);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Sessão alternada para ${u.nome} (${u.perfilLabel})',
                            ),
                            backgroundColor: AppColors.primaryTeal,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.switch_account_rounded, size: 16),
                    label: const Text(
                      'Usar este Perfil',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                if (usuarioLogado.isAdministrador)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: u.isPendente
                          ? const Color(0xFFD97706)
                          : AppColors.primaryDarkTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      AprovacaoAcessoBottomSheet.show(
                        context: context,
                        usuario: u,
                        onAlterado: _refreshList,
                      );
                    },
                    icon: Icon(
                      u.isPendente
                          ? Icons.how_to_reg_rounded
                          : Icons.manage_accounts_rounded,
                      size: 16,
                    ),
                    label: Text(
                      u.isPendente ? 'Avaliar Solicitação' : 'Gerenciar RBAC',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const Text(
                    'Somente Administrador altera RBAC',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeInfo(IconData icon, String text) {
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
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
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
        label = 'AGUARDANDO ADMIN';
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

