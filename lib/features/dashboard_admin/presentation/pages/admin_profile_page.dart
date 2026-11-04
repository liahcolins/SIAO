import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../usuarios_acesso/data/datasources/usuario_local_datasource.dart';
import '../../../usuarios_acesso/data/models/usuario_model.dart';
import '../../../usuarios_acesso/presentation/pages/gestao_usuarios_rbac_page.dart';
import '../../../usuarios_acesso/presentation/pages/login_page.dart';
import '../../../usuarios_acesso/presentation/pages/solicitar_acesso_page.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final _usuarioDataSource = UsuarioLocalDataSource();
  int _pendentesCount = 0;

  @override
  void initState() {
    super.initState();
    _carregarPendentes();
  }

  Future<void> _carregarPendentes() async {
    final qtd = await _usuarioDataSource.getQuantidadeSolicitacoesPendentes();
    if (mounted) {
      setState(() => _pendentesCount = qtd);
    }
  }

  Future<void> _trocarPerfilRapido(String perfil) async {
    final novoUsuario = await _usuarioDataSource.alternarPerfilRapido(perfil);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Perfil ativo alterado para: ${novoUsuario.nome} (${novoUsuario.perfilLabel})',
        ),
        backgroundColor: AppColors.primaryTeal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UsuarioModel>(
      valueListenable: UsuarioLocalDataSource.usuarioAtualNotifier,
      builder: (context, usuario, _) {
        final Color roleColor = usuario.isAdministrador
            ? AppColors.primaryDarkTeal
            : usuario.isAlimentador
                ? const Color(0xFF0284C7)
                : const Color(0xFF7C3AED);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Perfil & Controle de Acesso'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Ir para Tela de Autenticação',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Card de Cabeçalho do Usuário Ativo
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: roleColor.withValues(alpha: 0.14),
                          child: Icon(
                            usuario.isAdministrador
                                ? Icons.verified_user_rounded
                                : usuario.isAlimentador
                                    ? Icons.edit_document
                                    : Icons.visibility_rounded,
                            size: 40,
                            color: roleColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          usuario.nome,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          usuario.cargoFuncao,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: roleColor.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            'Perfil RBAC: ${usuario.perfilLabel.toUpperCase()}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: roleColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          usuario.perfilDescricao,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Card da Etapa 4: Simulador de Perfil RBAC e Gestão de Acessos
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: AppColors.primaryTeal,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Etapa 4 • Perfis RBAC & Solicitações',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (_pendentesCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.amber.shade600,
                                  ),
                                ),
                                child: Text(
                                  '$_pendentesCount pendente(s)',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Divider(height: 22),
                        const Text(
                          'Alternar Perfil de Acesso Ativo (Teste Rápido RBAC):',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDarkTeal,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildRoleChipButton(
                                label: 'Admin',
                                isSelected: usuario.isAdministrador,
                                color: AppColors.primaryDarkTeal,
                                onTap: () =>
                                    _trocarPerfilRapido('administrador'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildRoleChipButton(
                                label: 'Alimentador',
                                isSelected: usuario.isAlimentador,
                                color: const Color(0xFF0284C7),
                                onTap: () => _trocarPerfilRapido('alimentador'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildRoleChipButton(
                                label: 'Visualizador',
                                isSelected: usuario.isVisualizador,
                                color: const Color(0xFF7C3AED),
                                onTap: () =>
                                    _trocarPerfilRapido('visualizador'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const GestaoUsuariosRbacPage(),
                                    ),
                                  )
                                  .then((_) => _carregarPendentes());
                            },
                            icon: const Icon(
                              Icons.manage_accounts_rounded,
                              size: 19,
                            ),
                            label: Text(
                              _pendentesCount > 0
                                  ? 'Gerenciar Usuários & Aprovar Acessos ($_pendentesCount)'
                                  : 'Gerenciar Usuários & Permissões RBAC',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryDarkTeal,
                                  side: const BorderSide(
                                    color: AppColors.primaryTeal,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const SolicitarAcessoPage(),
                                        ),
                                      )
                                      .then((_) => _carregarPendentes());
                                },
                                icon: const Icon(
                                  Icons.person_add_alt_1_rounded,
                                  size: 17,
                                ),
                                label: const Text(
                                  'Solicitar Acesso',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryDarkTeal,
                                  side: const BorderSide(
                                    color: AppColors.primaryTeal,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.login_rounded, size: 17),
                                label: const Text(
                                  'Tela de Login',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Card de Dados do Usuário & OSC
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.corporate_fare_rounded,
                              color: AppColors.primaryTeal,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Credenciais & Organização (OSC)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _InfoRow(label: 'E-mail Autenticado', value: usuario.email),
                        _InfoRow(label: 'CPF', value: usuario.cpf),
                        _InfoRow(
                          label: 'Razão Social',
                          value: usuario.organizacaoNome,
                        ),
                        _InfoRow(label: 'CNPJ', value: usuario.organizacaoCnpj),
                        _InfoRow(
                          label: 'Polo Regional',
                          value: usuario.poloRegional,
                        ),
                        const _InfoRow(
                          label: 'Projeto Vinculado',
                          value: 'Projeto Mais Gestão / UFMA 2026',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Card de Status do Sistema e Conexão Híbrida
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.cloud_sync_rounded,
                              color: AppColors.primaryTeal,
                            ),
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
                        _InfoRow(
                          label: 'Modo de Operação',
                          value: 'Offline-First + Nuvem Híbrida',
                        ),
                        _InfoRow(
                          label: 'Controle de Acesso',
                          value: 'RBAC Ativo (Admin / Alimentador / Visualizador)',
                        ),
                        _InfoRow(
                          label: 'Licença da Plataforma',
                          value: '100% Gratuito / Open-Source (BSD)',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleChipButton({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
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
