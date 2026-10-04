import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/cadastros_base/presentation/pages/cadastro_fonte_recurso_page.dart';
import 'features/cadastros_base/presentation/pages/cadastro_fornecedor_page.dart';
import 'features/cadastros_base/presentation/pages/cadastros_base_page.dart';
import 'features/dashboard_admin/presentation/pages/admin_dashboard_page.dart';
import 'features/dashboard_admin/presentation/pages/admin_profile_page.dart';
import 'features/receitas/presentation/pages/cadastro_receita_page.dart';
import 'features/receitas/presentation/pages/lista_receitas_page.dart';
import 'features/transferencias/presentation/pages/cadastro_transferencia_page.dart';
import 'features/transferencias/presentation/pages/lista_transferencias_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const SIAOMaisGestaoApp());
}

class SIAOMaisGestaoApp extends StatelessWidget {
  const SIAOMaisGestaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIAO / Mais Gestão',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Sub-navigation states
  bool _showingCadastroReceita = false;
  bool _showingCadastroFornecedor = false;
  bool _showingCadastroFonte = false;
  bool _showingCadastroTransferencia = false;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      _resetSubPages();
    });
  }

  void _resetSubPages() {
    _showingCadastroReceita = false;
    _showingCadastroFornecedor = false;
    _showingCadastroFonte = false;
    _showingCadastroTransferencia = false;
  }

  @override
  Widget build(BuildContext context) {
    Widget currentBody;

    switch (_currentIndex) {
      case 0:
        currentBody = AdminDashboardPage(onNavigateTab: _onTabSelected);
        break;
      case 1:
        currentBody = _showingCadastroReceita
            ? CadastroReceitaPage(
                onReceitaSalva: () {
                  setState(() => _showingCadastroReceita = false);
                },
              )
            : ListaReceitasPage(
                onNovoCadastroTap: () {
                  setState(() => _showingCadastroReceita = true);
                },
              );
        break;
      case 2:
        if (_showingCadastroFornecedor) {
          currentBody = CadastroFornecedorPage(
            onFornecedorSalvo: () {
              setState(() => _showingCadastroFornecedor = false);
            },
          );
        } else if (_showingCadastroFonte) {
          currentBody = CadastroFonteRecursoPage(
            onFonteSalva: () {
              setState(() => _showingCadastroFonte = false);
            },
          );
        } else {
          currentBody = CadastrosBasePage(
            onNovoFornecedorTap: () {
              setState(() => _showingCadastroFornecedor = true);
            },
            onNovaFonteTap: () {
              setState(() => _showingCadastroFonte = true);
            },
          );
        }
        break;
      case 3:
        currentBody = _showingCadastroTransferencia
            ? CadastroTransferenciaPage(
                onTransferenciaSalva: () {
                  setState(() => _showingCadastroTransferencia = false);
                },
              )
            : ListaTransferenciasPage(
                onNovoCadastroTap: () {
                  setState(() => _showingCadastroTransferencia = true);
                },
              );
        break;
      case 4:
        currentBody = const AdminProfilePage();
        break;
      default:
        currentBody = AdminDashboardPage(onNavigateTab: _onTabSelected);
    }

    return Scaffold(
      body: currentBody,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        selectedItemColor: AppColors.primaryTeal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Receitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Cadastros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_rounded),
            label: 'Transferências',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Perfil Admin',
          ),
        ],
      ),
    );
  }
}
