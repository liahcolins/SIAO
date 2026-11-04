import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/datasources/usuario_local_datasource.dart';
import '../../data/models/usuario_model.dart';

class AprovacaoAcessoBottomSheet extends StatefulWidget {
  final UsuarioModel usuario;
  final VoidCallback onAlterado;

  const AprovacaoAcessoBottomSheet({
    super.key,
    required this.usuario,
    required this.onAlterado,
  });

  static Future<void> show({
    required BuildContext context,
    required UsuarioModel usuario,
    required VoidCallback onAlterado,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AprovacaoAcessoBottomSheet(
        usuario: usuario,
        onAlterado: onAlterado,
      ),
    );
  }

  @override
  State<AprovacaoAcessoBottomSheet> createState() =>
      _AprovacaoAcessoBottomSheetState();
}

class _AprovacaoAcessoBottomSheetState
    extends State<AprovacaoAcessoBottomSheet> {
  final _dataSource = UsuarioLocalDataSource();
  final _motivoController = TextEditingController();
  late String _perfilSelecionado;
  bool _mostrarCampoRejeicao = false;
  bool _isProcessando = false;

  @override
  void initState() {
    super.initState();
    _perfilSelecionado = widget.usuario.perfil;
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _aprovarOuSalvarPerfil() async {
    setState(() => _isProcessando = true);
    await _dataSource.decidirSolicitacao(
      usuarioId: widget.usuario.id,
      novoStatus: 'aprovado',
      perfilAtribuido: _perfilSelecionado,
    );
    if (mounted) {
      Navigator.pop(context);
      widget.onAlterado();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Acesso de ${widget.usuario.nome} aprovado com perfil ${_labelPerfil(_perfilSelecionado)}!',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  Future<void> _rejeitarSolicitacao() async {
    final motivo = _motivoController.text.trim();
    if (motivo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o motivo da rejeição da solicitação.'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    setState(() => _isProcessando = true);
    await _dataSource.decidirSolicitacao(
      usuarioId: widget.usuario.id,
      novoStatus: 'rejeitado',
      perfilAtribuido: _perfilSelecionado,
      motivoRejeicao: motivo,
    );
    if (mounted) {
      Navigator.pop(context);
      widget.onAlterado();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.cancel_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Solicitação de ${widget.usuario.nome} marcada como rejeitada.',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  String _labelPerfil(String perfil) {
    switch (perfil) {
      case 'administrador':
        return 'Administrador';
      case 'alimentador':
        return 'Alimentador';
      default:
        return 'Visualizador';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final u = widget.usuario;

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

            // Cabeçalho
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: AppColors.primaryDarkTeal,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u.isPendente
                            ? 'Aprovação de Solicitação de Acesso'
                            : 'Gerenciar Permissões RBAC do Usuário',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDarkTeal,
                        ),
                      ),
                      const Text(
                        'Pilar da Responsabilização • Controle de Acesso da OSC',
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

            // Dados do Solicitante / Usuário
            Container(
              padding: const EdgeInsets.all(14),
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
                      Expanded(
                        child: Text(
                          u.nome,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      _buildStatusBadge(u.statusAcesso),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    u.cargoFuncao,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDarkTeal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'E-mail: ${u.email}',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  Text(
                    'CPF: ${u.cpf} • ${u.poloRegional}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Solicitado em: ${Formatters.formatDate(u.dataSolicitacao)}',
                    style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                  ),
                  if (u.justificativaSolicitacao != null &&
                      u.justificativaSolicitacao!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Justificativa de Acesso à OSC:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDarkTeal,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            u.justificativaSolicitacao!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Seleção do Perfil RBAC
            const Text(
              'Definir Perfil de Permissão (RBAC):',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDarkTeal,
              ),
            ),
            const SizedBox(height: 8),

            _buildRoleOption(
              roleKey: 'administrador',
              title: 'Administrador',
              subtitle:
                  'Gerencia a OSC, aprova usuários, valida despesas e registra transferências gerenciais.',
              icon: Icons.verified_user_rounded,
              color: AppColors.primaryDarkTeal,
            ),
            const SizedBox(height: 8),
            _buildRoleOption(
              roleKey: 'alimentador',
              title: 'Alimentador',
              subtitle:
                  'Cadastra fornecedores, fontes, receitas e despesas com foto de comprovantes (sujeitas à validação).',
              icon: Icons.edit_document,
              color: const Color(0xFF0284C7),
            ),
            const SizedBox(height: 8),
            _buildRoleOption(
              roleKey: 'visualizador',
              title: 'Visualizador (Conselho / Auditoria)',
              subtitle:
                  'Acesso somente leitura para conferência de saldos, comprovantes e relatórios sem alterar registros.',
              icon: Icons.visibility_rounded,
              color: const Color(0xFF7C3AED),
            ),

            const SizedBox(height: 18),

            if (_mostrarCampoRejeicao) ...[
              TextField(
                controller: _motivoController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Motivo da Rejeição / Revogação *',
                  hintText:
                      'Ex.: Vínculo institucional pendente de confirmação pela diretoria da OSC.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          setState(() => _mostrarCampoRejeicao = false),
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
                      onPressed: _isProcessando ? null : _rejeitarSolicitacao,
                      child: const Text(
                        'Confirmar Rejeição',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.dangerRed,
                        side: const BorderSide(color: AppColors.dangerRed),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () =>
                          setState(() => _mostrarCampoRejeicao = true),
                      icon: const Icon(Icons.block_rounded, size: 18),
                      label: Text(
                        u.isPendente ? 'Rejeitar' : 'Revogar',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isProcessando ? null : _aprovarOuSalvarPerfil,
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 18,
                      ),
                      label: Text(
                        u.isPendente
                            ? 'Aprovar Solicitação'
                            : 'Salvar Perfil RBAC',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildRoleOption({
    required String roleKey,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _perfilSelecionado == roleKey;
    return InkWell(
      onTap: () => setState(() => _perfilSelecionado = roleKey),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? color : Colors.grey.shade400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'aprovado':
        bg = Colors.green.shade50;
        fg = AppColors.successGreen;
        label = 'ATIVO';
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
