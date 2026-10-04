import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/datasources/cadastros_local_datasource.dart';
import '../../data/models/fonte_recurso_model.dart';

class CadastroFonteRecursoPage extends StatefulWidget {
  final VoidCallback onFonteSalva;

  const CadastroFonteRecursoPage({
    super.key,
    required this.onFonteSalva,
  });

  @override
  State<CadastroFonteRecursoPage> createState() => _CadastroFonteRecursoPageState();
}

class _CadastroFonteRecursoPageState extends State<CadastroFonteRecursoPage> {
  final _formKey = GlobalKey<FormState>();
  final _dataSource = CadastrosLocalDataSource();

  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorPrevistoController = TextEditingController();

  String _tipoFonte = 'Governamental';
  bool _isSaving = false;

  final List<String> _tiposFonteOptions = [
    'Governamental',
    'Doação Privada',
    'Convênio',
    'Recursos Próprios',
    'Evento/Rifa',
    'Outras Origens',
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _valorPrevistoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final double? valor = _valorPrevistoController.text.trim().isNotEmpty
          ? Formatters.parseCurrency(_valorPrevistoController.text.trim())
          : null;

      final novaFonte = FonteRecursoModel(
        id: const Uuid().v4(),
        nome: _nomeController.text.trim(),
        tipoFonte: _tipoFonte,
        descricao: _descricaoController.text.trim().isNotEmpty
            ? _descricaoController.text.trim()
            : null,
        valorPrevisto: valor,
        criadoEm: DateTime.now(),
      );

      await _dataSource.saveFonteRecurso(novaFonte);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Fonte de Recursos cadastrada com sucesso!'),
            ],
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );

      widget.onFonteSalva();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar fonte de recursos: $e'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Fonte de Recurso'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onFonteSalva,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Origem dos Recursos da OSC',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDarkTeal,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Cadastre convênios, editais, doações ou eventos aos quais os ingressos financeiros serão vinculados.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Nome da Fonte
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Fonte de Recursos *',
                  hintText: 'Ex: Convênio 01/2026 - UFMA / Mais Gestão',
                  prefixIcon: Icon(Icons.account_balance_rounded, color: AppColors.primaryTeal),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe o nome da fonte de recursos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tipo de Fonte (Dropdown)
              DropdownButtonFormField<String>(
                initialValue: _tipoFonte,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Categoria / Tipo de Origem *',
                  prefixIcon: Icon(Icons.layers_rounded, color: AppColors.primaryTeal),
                ),
                items: _tiposFonteOptions.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _tipoFonte = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Valor Previsto / Teto Orçamentário (Opcional)
              TextFormField(
                controller: _valorPrevistoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor Total Previsto / Teto R\$ (Opcional)',
                  hintText: 'Ex: 50.000,00',
                  prefixIcon: Icon(Icons.attach_money_rounded, color: AppColors.primaryTeal),
                ),
              ),
              const SizedBox(height: 16),

              // Descrição / Observação
              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição / Objeto do Recurso (Opcional)',
                  hintText: 'Descreva a finalidade, objeto do edital ou observações sobre esta fonte...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isSaving ? null : _salvar,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_rounded, color: Colors.white),
                  label: Text(
                    _isSaving ? 'Salvação...' : 'Cadastrar Fonte de Recursos',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
