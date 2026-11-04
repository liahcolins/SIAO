import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../main.dart';
import '../../data/datasources/usuario_local_datasource.dart';
import 'solicitar_acesso_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _dataSource = UsuarioLocalDataSource();

  final _identificadorController =
      TextEditingController(text: 'sergio.pinto@ufma.br');
  final _senhaController = TextEditingController(text: '123456');
  bool _obscurePassword = true;
  bool _isAutenticando = false;

  @override
  void dispose() {
    _identificadorController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _realizarLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isAutenticando = true);
    final (usuario, erro) = await _dataSource.autenticar(
      _identificadorController.text,
      _senhaController.text,
    );

    if (!mounted) return;
    setState(() => _isAutenticando = false);

    if (erro != null || usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro ?? 'Falha na autenticação.'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    _navegarParaHome(usuario.nome, usuario.perfilLabel);
  }

  Future<void> _entrarComPerfilDemo(String perfil) async {
    setState(() => _isAutenticando = true);
    final usuario = await _dataSource.alternarPerfilRapido(perfil);
    if (!mounted) return;
    setState(() => _isAutenticando = false);
    _navegarParaHome(usuario.nome, usuario.perfilLabel);
  }

  void _navegarParaHome(String nome, String perfilLabel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bem-vindo(a), $nome • Perfil: $perfilLabel'),
        backgroundColor: AppColors.primaryTeal,
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // Cabeçalho Institucional UFMA / Mais Gestão
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.logoUfmaSempreMais,
                      height: 52,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'SIAO',
                      style: GoogleFonts.outfit(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3.0,
                        color: AppColors.primaryDarkTeal,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Image.asset(
                      AppAssets.logoMaisGestaoUfma,
                      height: 52,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Autenticação & Controle de Acesso (RBAC)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDarkTeal,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Associação Comunidade Viva • CNPJ 12.345.678/0001-90',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 20),

                // Card de Login Principal
                Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Acesso ao Sistema',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDarkTeal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Entre com seu e-mail ou CPF cadastrado na OSC',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _identificadorController,
                            decoration: const InputDecoration(
                              labelText: 'E-mail ou CPF',
                              hintText: 'sergio.pinto@ufma.br',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Informe seu e-mail ou CPF'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _senhaController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Senha de Acesso',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Informe sua senha'
                                : null,
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _isAutenticando ? null : _realizarLogin,
                            icon: const Icon(Icons.login_rounded),
                            label: _isAutenticando
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Entrar no SIAO',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryDarkTeal,
                              side: const BorderSide(color: AppColors.primaryTeal),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SolicitarAcessoPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                            label: const Text(
                              'Novo Membro? Solicitar Acesso à OSC',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Acesso Rápido por Perfil (Simulador RBAC da Etapa 4)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.primaryTeal.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.switch_account_rounded,
                            color: AppColors.primaryDarkTeal,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Acesso Rápido por Perfil (RBAC • Etapa 4)',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDarkTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Alterne rapidamente entre os 3 perfis previstos no escopo para testar as permissões de cada papel:',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDemoProfileButton(
                        title: 'Administrador • Prof. Sérgio Pinto',
                        subtitle:
                            'Acesso total: aprova usuários, valida despesas e faz transferências.',
                        badge: 'ADMIN',
                        color: AppColors.primaryDarkTeal,
                        icon: Icons.verified_user_rounded,
                        onTap: () => _entrarComPerfilDemo('administrador'),
                      ),
                      const SizedBox(height: 8),
                      _buildDemoProfileButton(
                        title: 'Alimentador • Liah (Equipe Técnica)',
                        subtitle:
                            'Lança fornecedores, fontes, receitas e despesas com comprovantes.',
                        badge: 'ALIMENTADOR',
                        color: const Color(0xFF0284C7),
                        icon: Icons.edit_document,
                        onTap: () => _entrarComPerfilDemo('alimentador'),
                      ),
                      const SizedBox(height: 8),
                      _buildDemoProfileButton(
                        title: 'Visualizador • Érica (Conselho Fiscal)',
                        subtitle:
                            'Consulta e conferência de saldos e comprovantes (somente leitura).',
                        badge: 'VISUALIZADOR',
                        color: const Color(0xFF7C3AED),
                        icon: Icons.visibility_rounded,
                        onTap: () => _entrarComPerfilDemo('visualizador'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoProfileButton({
    required String title,
    required String subtitle,
    required String badge,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

