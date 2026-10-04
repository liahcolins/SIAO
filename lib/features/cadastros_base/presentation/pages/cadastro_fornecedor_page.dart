import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/cadastros_local_datasource.dart';
import '../../data/models/fornecedor_model.dart';

class CadastroFornecedorPage extends StatefulWidget {
  final VoidCallback onFornecedorSalvo;

  const CadastroFornecedorPage({
    super.key,
    required this.onFornecedorSalvo,
  });

  @override
  State<CadastroFornecedorPage> createState() => _CadastroFornecedorPageState();
}

class _CadastroFornecedorPageState extends State<CadastroFornecedorPage> {
  final _formKey = GlobalKey<FormState>();
  final _dataSource = CadastrosLocalDataSource();

  final _nomeController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();

  String _tipoPessoa = 'PJ'; // 'PF' ou 'PJ'
  String _tipoOperacao = 'Despesa'; // 'Despesa', 'Receita' ou 'Ambos'
  bool _isSaving = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfCnpjController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final novoFornecedor = FornecedorModel(
        id: const Uuid().v4(),
        nomeRazaoSocial: _nomeController.text.trim(),
        tipoPessoa: _tipoPessoa,
        cpfCnpj: _cpfCnpjController.text.trim(),
        tipoOperacao: _tipoOperacao,
        telefone: _telefoneController.text.trim().isNotEmpty
            ? _telefoneController.text.trim()
            : null,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        criadoEm: DateTime.now(),
      );

      await _dataSource.saveFornecedor(novoFornecedor);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Cadastro de Fornecedor realizado com sucesso!'),
            ],
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );

      widget.onFornecedorSalvo();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar fornecedor: $e'),
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
        title: const Text('Novo Fornecedor / Parceiro'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onFornecedorSalvo,
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
                'Identificação do Fornecedor / Origem',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDarkTeal,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Cadastre pessoas físicas ou jurídicas fornecedoras de bens/serviços ou doadoras.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Tipo de Pessoa (PF / PJ)
              const Text(
                'Tipo de Pessoa *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Pessoa Jurídica (PJ)')),
                      selected: _tipoPessoa == 'PJ',
                      selectedColor: AppColors.primaryLightTeal,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _tipoPessoa = 'PJ';
                            _cpfCnpjController.clear();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Pessoa Física (PF)')),
                      selected: _tipoPessoa == 'PF',
                      selectedColor: AppColors.primaryLightTeal,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _tipoPessoa = 'PF';
                            _cpfCnpjController.clear();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Nome / Razão Social
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: _tipoPessoa == 'PJ'
                      ? 'Razão Social / Nome Fantasia *'
                      : 'Nome Completo da Pessoa *',
                  hintText: _tipoPessoa == 'PJ'
                      ? 'Ex: Papelaria Silva & Cia Ltda'
                      : 'Ex: Maria das Dores Silva',
                  prefixIcon: Icon(
                    _tipoPessoa == 'PJ'
                        ? Icons.business_rounded
                        : Icons.person_rounded,
                    color: AppColors.primaryTeal,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe o nome ou razão social';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CPF ou CNPJ
              TextFormField(
                controller: _cpfCnpjController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _tipoPessoa == 'PJ' ? 'CNPJ *' : 'CPF *',
                  hintText: _tipoPessoa == 'PJ'
                      ? '00.000.000/0000-00'
                      : '000.000.000-00',
                  prefixIcon: const Icon(
                    Icons.badge_rounded,
                    color: AppColors.primaryTeal,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe o ${_tipoPessoa == 'PJ' ? 'CNPJ' : 'CPF'}';
                  }
                  if (_tipoPessoa == 'PJ' && val.trim().length < 14) {
                    return 'CNPJ incompleto';
                  }
                  if (_tipoPessoa == 'PF' && val.trim().length < 11) {
                    return 'CPF incompleto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Tipo de Operação
              const Text(
                'Vínculo de Operação *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _tipoOperacao,
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_rounded, color: AppColors.primaryTeal),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Despesa',
                    child: Text('Fornecedor de Despesas (Saídas)', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'Receita',
                    child: Text('Origem de Receitas (Doações/Incentivos)', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'Ambos',
                    child: Text('Ambos (Receitas e Despesas)', overflow: TextOverflow.ellipsis),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _tipoOperacao = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Telefone / Contato
              TextFormField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone / WhatsApp (Opcional)',
                  hintText: '(98) 99999-9999',
                  prefixIcon: Icon(Icons.phone_rounded, color: AppColors.primaryTeal),
                ),
              ),
              const SizedBox(height: 16),

              // E-mail
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail de Contato (Opcional)',
                  hintText: 'contato@empresa.com.br',
                  prefixIcon: Icon(Icons.email_rounded, color: AppColors.primaryTeal),
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
                    _isSaving ? 'Gravando...' : 'Cadastrar Fornecedor',
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
