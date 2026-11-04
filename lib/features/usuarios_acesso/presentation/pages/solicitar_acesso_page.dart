import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/usuario_local_datasource.dart';
import '../../data/models/usuario_model.dart';

class SolicitarAcessoPage extends StatefulWidget {
  final VoidCallback? onSolicitacaoEnviada;

  const SolicitarAcessoPage({
    super.key,
    this.onSolicitacaoEnviada,
  });

  @override
  State<SolicitarAcessoPage> createState() => _SolicitarAcessoPageState();
}

class _SolicitarAcessoPageState extends State<SolicitarAcessoPage> {
  final _formKey = GlobalKey<FormState>();
  final _dataSource = UsuarioLocalDataSource();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _cargoController = TextEditingController();
  final _justificativaController = TextEditingController();
  final _senhaController = TextEditingController(text: '123456');

  String _perfilDesejado = 'alimentador';
  String _poloSelecionado = 'Maranhão • Polo 01 (São Luís)';
  bool _isSalvando = false;

  final List<String> _polos = const [
    'Maranhão • Polo 01 (São Luís)',
    'Maranhão • Polo 02 (Bacabal)',
    'Maranhão • Polo 03 (Imperatriz)',
    'Maranhão • Polo 04 (Caxias)',
    'Maranhão • Polo 05 (Pinheiro)',
    'Maranhão • Polo 06 (Chapadinha)',
    'Maranhão • Polo 07 (Balsas)',
    'Pará • Expansão Regional',
    'Piauí • Expansão Regional',
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _cargoController.dispose();
    _justificativaController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _enviarSolicitacao() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSalvando = true);

    final novaSolicitacao = UsuarioModel(
      id: 'usr-req-${DateTime.now().millisecondsSinceEpoch}',
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      cpf: _cpfController.text.trim(),
      cargoFuncao: _cargoController.text.trim(),
      poloRegional: _poloSelecionado,
      perfil: _perfilDesejado,
      statusAcesso: 'pendente',
      justificativaSolicitacao: _justificativaController.text.trim(),
      dataSolicitacao: DateTime.now(),
      senhaDemo: _senhaController.text.trim().isEmpty
          ? '123456'
          : _senhaController.text.trim(),
    );

    await _dataSource.registrarSolicitacaoAcesso(novaSolicitacao);

    if (!mounted) return;
    setState(() => _isSalvando = false);

    widget.onSolicitacaoEnviada?.call();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.mark_email_read_rounded, color: AppColors.primaryTeal),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Solicitação Enviada!',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'A solicitação de acesso para "${novaSolicitacao.nome}" (Perfil solicitado: ${novaSolicitacao.perfilLabel}) foi encaminhada à fila de aprovação do Administrador da OSC.\n\nAssim que aprovada pelo Administrador, o acesso estará liberado.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Acesso à OSC'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner Informativo
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLightTeal,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryTeal.withValues(alpha: 0.25),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.primaryDarkTeal,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilar da Responsabilização (RBAC)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDarkTeal,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Todo acesso ao SIAO é vinculado à Associação Comunidade Viva e passa pela aprovação do Administrador da organização.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryDarkTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1. Identificação do Solicitante',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDarkTeal,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome Completo *',
                          hintText: 'Ex.: Maria Fernanda Oliveira',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (v) => (v == null || v.trim().length < 3)
                            ? 'Informe seu nome completo'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cpfController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'CPF *',
                          hintText: '000.000.000-00',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().length < 11)
                            ? 'Informe um CPF válido'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-mail Institucional ou Pessoal *',
                          hintText: 'nome@organizacao.org.br',
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                        ),
                        validator: (v) =>
                            (v == null || !v.contains('@'))
                                ? 'Informe um e-mail válido'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cargoController,
                        decoration: const InputDecoration(
                          labelText: 'Cargo / Função na OSC *',
                          hintText:
                              'Ex.: Auxiliar Financeiro, Conselheiro Fiscal, Secretária',
                          prefixIcon: Icon(Icons.work_outline_rounded),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Informe sua função na OSC'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _poloSelecionado,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Polo Regional de Atuação *',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        items: _polos
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13.5),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _poloSelecionado = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '2. Perfil de Acesso Solicitado (RBAC)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDarkTeal,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildPerfilSelectorTile(
                        value: 'alimentador',
                        title: 'Alimentador (Operacional)',
                        description:
                            'Registra fornecedores, fontes, receitas e despesas com comprovantes anexos.',
                        icon: Icons.edit_document,
                        color: const Color(0xFF0284C7),
                      ),
                      const SizedBox(height: 8),
                      _buildPerfilSelectorTile(
                        value: 'visualizador',
                        title: 'Visualizador (Conselho Fiscal / Auditoria)',
                        description:
                            'Consulta saldos, documentos fiscais e relatórios sem realizar alterações.',
                        icon: Icons.visibility_rounded,
                        color: const Color(0xFF7C3AED),
                      ),
                      const SizedBox(height: 8),
                      _buildPerfilSelectorTile(
                        value: 'administrador',
                        title: 'Administrador (Gestão e Validação)',
                        description:
                            'Valida despesas, aprova usuários e realiza transferências gerenciais.',
                        icon: Icons.verified_user_rounded,
                        color: AppColors.primaryDarkTeal,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _justificativaController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Justificativa da Solicitação *',
                          hintText:
                              'Descreva brevemente as atividades que realizará no SIAO dentro da OSC...',
                          alignLabelWithHint: true,
                        ),
                        validator: (v) => (v == null || v.trim().length < 8)
                            ? 'Descreva a justificativa para análise do Administrador'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isSalvando ? null : _enviarSolicitacao,
                icon: const Icon(Icons.send_rounded),
                label: _isSalvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Enviar Solicitação ao Administrador',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerfilSelectorTile({
    required String value,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final selected = _perfilDesejado == value;
    return InkWell(
      onTap: () => setState(() => _perfilDesejado = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 1.8 : 1,
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
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? color : Colors.grey.shade400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
