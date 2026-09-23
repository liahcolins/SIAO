import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard_admin/presentation/pages/admin_dashboard_page.dart';
import 'features/dashboard_admin/presentation/pages/admin_profile_page.dart';
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
  bool _showingCadastroTransferencia = false;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      _showingCadastroTransferencia = false;
    });
  }

  void _openCadastroTransferencia() {
    setState(() {
      _currentIndex = 1;
      _showingCadastroTransferencia = true;
    });
  }

  void _backToListaTransferencias() {
    setState(() {
      _showingCadastroTransferencia = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentBody;

    switch (_currentIndex) {
      case 0:
        currentBody = AdminDashboardPage(onNavigateTab: _onTabSelected);
        break;
      case 1:
        currentBody = _showingCadastroTransferencia
            ? CadastroTransferenciaPage(onTransferenciaSalva: _backToListaTransferencias)
            : ListaTransferenciasPage(onNovoCadastroTap: _openCadastroTransferencia);
        break;
      case 2:
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard Admin',
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
