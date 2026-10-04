import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/bank_warning_banner.dart';
import '../../../cadastros_base/data/datasources/cadastros_local_datasource.dart';
import '../../../cadastros_base/data/models/fonte_recurso_model.dart';
import '../../data/datasources/receita_local_datasource.dart';
import '../../data/models/receita_model.dart';

class CadastroReceitaPage extends StatefulWidget {
  final VoidCallback onReceitaSalva;

  const CadastroReceitaPage({
    super.key,
    required this.onReceitaSalva,
  });

  @override
  State<CadastroReceitaPage> createState() => _CadastroReceitaPageState();
}

class _CadastroReceitaPageState extends State<CadastroReceitaPage> {
  final _formKey = GlobalKey<FormState>();
  final _receitaDataSource = ReceitaLocalDataSource();
  final _cadastrosDataSource = CadastrosLocalDataSource();

  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _dataController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedFonteId;
  String? _selectedFonteNome;
  bool _eProduto = false;
  bool _referenteAnoBase = true;
  String _formaPagamento = 'PIX / Depósito Bancário';
  bool _isSaving = false;

  List<FonteRecursoModel> _availableFontes = [];
  bool _isLoadingFontes = true;

  final List<String> _formasPagamentoList = [
    'PIX / Depósito Bancário',
    'Cheque',
    'Dinheiro em Espécie',
  ];

  @override
  void initState() {
    super.initState();
    _dataController.text = Formatters.formatDate(_selectedDate);
    _loadFontes();
  }

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _loadFontes() async {
    try {
      final fontes = await _cadastrosDataSource.getFontesRecursos();
      setState(() {
        _availableFontes = fontes;
        if (fontes.isNotEmpty) {
          _selectedFonteId = fontes.first.id;
          _selectedFonteNome = fontes.first.nome;
        }
        _isLoadingFontes = false;
      });
    } catch (e) {
      setState(() => _isLoadingFontes = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryTeal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dataController.text = Formatters.formatDate(picked);
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFonteId == null || _selectedFonteNome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma Fonte de Recursos válida.'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final double? valorParsed = Formatters.parseCurrency(_valorController.text.trim());
      if (valorParsed == null || valorParsed <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, digite um valor monetário válido.'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
        setState(() => _isSaving = false);
        return;
      }

      final novaReceita = ReceitaModel(
        id: const Uuid().v4(),
        fonteRecursoId: _selectedFonteId!,
        fonteRecursoNome: _selectedFonteNome!,
        eProduto: _eProduto,
        valor: valorParsed,
        dataRecebimento: _selectedDate,
        formaPagamento: _formaPagamento,
        referenteAnoBase: _referenteAnoBase,
        descricao: _descricaoController.text.trim(),
        statusValidaAdmin: 'aprovado',
        criadoEm: DateTime.now(),
      );

      await _receitaDataSource.saveReceita(novaReceita);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Lançamento de Receita salvo com sucesso!'),
            ],
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );

      widget.onReceitaSalva();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao registrar receita: $e'),
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
        title: const Text('Lançamento de Receita (Ingresso)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onReceitaSalva,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BankWarningBanner(
                customMessage:
                    'O SIAO realiza o registro gerencial das receitas recebidas pela OSC. Não realiza cobranças nem operações bancárias ativas.',
              ),
              const SizedBox(height: 20),

              Text(
                'Dados do Ingresso Financeiro',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDarkTeal,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Preencha as informações do recurso recebido para prestação de contas.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Dropdown de Fonte de Recurso
              const Text(
                'Fonte do Recurso Vinculada *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              _isLoadingFontes
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal))
                  : _availableFontes.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.amber),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Nenhuma Fonte cadastrada. Cadastre uma fonte em "Cadastros Base" antes.',
                                  style: TextStyle(fontSize: 12, color: Colors.amber),
                                ),
                              ),
                            ],
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          initialValue: _selectedFonteId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.account_balance_rounded, color: AppColors.primaryTeal),
                          ),
                          items: _availableFontes.map((fonte) {
                            return DropdownMenuItem(
                              value: fonte.id,
                              child: Text(
                                fonte.nome,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final f = _availableFontes.firstWhere((element) => element.id == val);
                              setState(() {
                                _selectedFonteId = f.id;
                                _selectedFonteNome = f.nome;
                              });
                            }
                          },
                          validator: (val) => val == null ? 'Selecione uma fonte' : null,
                        ),
              const SizedBox(height: 18),

              // É um produto? (Switch / Radio)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.shopping_bag_outlined, color: AppColors.primaryTeal),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'É um produto / doação em bens?',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  'Marque "Sim" se for artesanato, produtos de bazar, etc.',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _eProduto,
                      activeTrackColor: AppColors.primaryTeal,
                      onChanged: (val) => setState(() => _eProduto = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Valor R$
              TextFormField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor do Recebimento (R\$) *',
                  hintText: 'Ex: 1.500,00',
                  prefixIcon: Icon(Icons.attach_money_rounded, color: AppColors.primaryTeal),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe o valor recebido';
                  }
                  final parsed = Formatters.parseCurrency(val);
                  if (parsed == null || parsed <= 0) {
                    return 'Insira um valor numérico válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Data do Recebimento
              TextFormField(
                controller: _dataController,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: 'Data do Recebimento *',
                  prefixIcon: Icon(Icons.calendar_today_rounded, color: AppColors.primaryTeal),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
              ),
              const SizedBox(height: 18),

              // Forma de Repasse / Pagamento
              const Text(
                'Forma de Repasse / Recebimento *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _formaPagamento,
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.payment_rounded, color: AppColors.primaryTeal),
                ),
                items: _formasPagamentoList.map((forma) {
                  return DropdownMenuItem(
                    value: forma,
                    child: Text(forma, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _formaPagamento = val);
                  }
                },
              ),
              const SizedBox(height: 18),

              // Referente ao Ano Base?
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.date_range_rounded, color: AppColors.primaryTeal),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Referente ao Ano Base Vigente?',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  'Para fins de prestação de contas do exercício',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _referenteAnoBase,
                      activeTrackColor: AppColors.primaryTeal,
                      onChanged: (val) => setState(() => _referenteAnoBase = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Descrição / Observação
              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição / Histórico da Receita *',
                  hintText: 'Descreva a origem, projeto associado ou finalidade do repasse...',
                  alignLabelWithHint: true,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Descreva o histórico do recebimento';
                  }
                  return null;
                },
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
                      : const Icon(Icons.check_circle_rounded, color: Colors.white),
                  label: Text(
                    _isSaving ? 'Registrando...' : 'Confirmar Lançamento de Receita',
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
