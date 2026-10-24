import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/bank_warning_banner.dart';
import '../../../cadastros_base/data/datasources/cadastros_local_datasource.dart';
import '../../../cadastros_base/data/models/fonte_recurso_model.dart';
import '../../../cadastros_base/data/models/fornecedor_model.dart';
import '../../data/datasources/despesa_local_datasource.dart';
import '../../data/models/despesa_model.dart';

class CadastroDespesaPage extends StatefulWidget {
  final VoidCallback onDespesaSalva;

  const CadastroDespesaPage({
    super.key,
    required this.onDespesaSalva,
  });

  @override
  State<CadastroDespesaPage> createState() => _CadastroDespesaPageState();
}

class _CadastroDespesaPageState extends State<CadastroDespesaPage> {
  final _formKey = GlobalKey<FormState>();
  final _despesaDataSource = DespesaLocalDataSource();
  final _cadastrosDataSource = CadastrosLocalDataSource();

  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _dataController = TextEditingController();
  final _comprovanteTituloController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedFonteId;
  String? _selectedFonteNome;
  String? _selectedFornecedorId;
  String? _selectedFornecedorNome;
  String? _selectedFornecedorCpfCnpj;

  String _formaPagamento = 'PIX / Depósito Bancário';
  String _tipoComprovante = 'Nota Fiscal Eletrônica (NF-e)';
  bool _temComprovanteAnexo = true;
  bool _isSaving = false;

  List<FonteRecursoModel> _availableFontes = [];
  List<FornecedorModel> _availableFornecedores = [];
  bool _isLoading = true;

  final List<String> _formasPagamentoList = [
    'PIX / Depósito Bancário',
    'Cheque',
    'Dinheiro em Espécie',
  ];

  final List<String> _tiposComprovanteList = [
    'Nota Fiscal Eletrônica (NF-e)',
    'Cupom Fiscal Eletrônico (NFC-e)',
    'Nota Fiscal de Serviços (NFS-e)',
    'Recibo de Prestação de Serviços',
  ];

  @override
  void initState() {
    super.initState();
    _dataController.text = Formatters.formatDate(_selectedDate);
    _comprovanteTituloController.text = 'NF-e ${_gerarProtocoloExemplo()}';
    _loadDependencies();
  }

  String _gerarProtocoloExemplo() {
    return '00${DateTime.now().millisecondsSinceEpoch.toString().substring(7, 12)}';
  }

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    _dataController.dispose();
    _comprovanteTituloController.dispose();
    super.dispose();
  }

  Future<void> _loadDependencies() async {
    try {
      final fontes = await _cadastrosDataSource.getFontesRecursos();
      final fornecedores = await _cadastrosDataSource.getFornecedores();

      setState(() {
        _availableFontes = fontes;
        _availableFornecedores = fornecedores;

        if (fontes.isNotEmpty) {
          _selectedFonteId = fontes.first.id;
          _selectedFonteNome = fontes.first.nome;
        }

        if (fornecedores.isNotEmpty) {
          _selectedFornecedorId = fornecedores.first.id;
          _selectedFornecedorNome = fornecedores.first.nomeRazaoSocial;
          _selectedFornecedorCpfCnpj = fornecedores.first.cpfCnpj;
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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

  Future<void> _salvarDespesa() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFonteId == null || _selectedFonteNome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione obrigatoriamente a Fonte de Recursos vinculada.'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    if (_selectedFornecedorId == null || _selectedFornecedorNome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione obrigatoriamente o Fornecedor (PF ou PJ).'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    if (!_temComprovanteAnexo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilar da Conformidade: Todo gasto exige comprovante documental anexo.'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final valorNumerico = Formatters.parseCurrency(_valorController.text) ?? 0.0;
      if (valorNumerico <= 0) {
        throw Exception('O valor do gasto deve ser maior que zero.');
      }

      final novaDespesa = DespesaModel(
        id: const Uuid().v4(),
        fonteRecursoId: _selectedFonteId!,
        fonteRecursoNome: _selectedFonteNome!,
        fornecedorId: _selectedFornecedorId!,
        fornecedorNome: _selectedFornecedorNome!,
        fornecedorCpfCnpj: _selectedFornecedorCpfCnpj ?? '',
        valor: valorNumerico,
        dataGasto: _selectedDate,
        formaPagamento: _formaPagamento,
        descricao: _descricaoController.text.trim(),
        tipoComprovante: _tipoComprovante,
        comprovanteTitulo: _comprovanteTituloController.text.trim(),
        comprovantePath: 'local://docs/${DateTime.now().millisecondsSinceEpoch}_comprovante.pdf',
        statusValidaAdmin: 'pendente', // Entra como pendente na esteira do Admin!
        criadoEm: DateTime.now(),
      );

      await _despesaDataSource.salvarDespesa(novaDespesa);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Despesa registrada com sucesso! Encaminhada para a esteira de validação do Administrador.',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryTeal,
            duration: Duration(seconds: 4),
          ),
        );
        widget.onDespesaSalva();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar despesa: $e'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Nova Despesa'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BankWarningBanner(),
                    const SizedBox(height: 16),

                    // Card de Vínculo Obrigatório da Accountability
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLightTeal,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_rounded, color: AppColors.primaryDarkTeal, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vínculo Legal Inegociável',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.primaryDarkTeal,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Cada despesa deve ter um Fornecedor cadastrado, Fonte de Recursos correspondente e Comprovante anexo.',
                                  style: TextStyle(fontSize: 11.5, color: Color(0xFF334155)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 1. FORNECEDOR (PF OU PJ)
                    const Text(
                      'Fornecedor / Favorecido *',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                    const SizedBox(height: 6),
                    if (_availableFornecedores.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Nenhum fornecedor cadastrado. Cadastre primeiro em "Cadastros Base".',
                          style: TextStyle(color: Colors.deepOrange, fontSize: 12),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _selectedFornecedorId,
                        decoration: InputDecoration(
                          hintText: 'Selecione o fornecedor',
                          prefixIcon: const Icon(Icons.storefront_rounded, color: AppColors.primaryTeal),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _availableFornecedores.map((f) {
                          return DropdownMenuItem<String>(
                            value: f.id,
                            child: Text(
                              '${f.nomeRazaoSocial} (${f.tipoPessoa})',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final selected = _availableFornecedores.firstWhere((f) => f.id == val);
                            setState(() {
                              _selectedFornecedorId = selected.id;
                              _selectedFornecedorNome = selected.nomeRazaoSocial;
                              _selectedFornecedorCpfCnpj = selected.cpfCnpj;
                            });
                          }
                        },
                      ),

                    const SizedBox(height: 18),

                    // 2. FONTE DE RECURSOS
                    const Text(
                      'Fonte de Recursos (Origem do Recurso) *',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                    const SizedBox(height: 6),
                    if (_availableFontes.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Nenhuma fonte de recursos cadastrada.',
                          style: TextStyle(color: Colors.deepOrange, fontSize: 12),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _selectedFonteId,
                        decoration: InputDecoration(
                          hintText: 'Selecione a fonte de recursos',
                          prefixIcon: const Icon(Icons.account_balance_rounded, color: AppColors.primaryTeal),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _availableFontes.map((fonte) {
                          return DropdownMenuItem<String>(
                            value: fonte.id,
                            child: Text(
                              fonte.nome,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final selected = _availableFontes.firstWhere((f) => f.id == val);
                            setState(() {
                              _selectedFonteId = selected.id;
                              _selectedFonteNome = selected.nome;
                            });
                          }
                        },
                      ),

                    const SizedBox(height: 18),

                    // 3. VALOR (R$) e DATA DO GASTO
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Valor do Gasto (R\$) *',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _valorController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  hintText: '0,00',
                                  prefixText: 'R\$ ',
                                  prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) return 'Informe o valor';
                                  final numVal = Formatters.parseCurrency(value) ?? 0.0;
                                  if (numVal <= 0) return 'Maior que zero';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Data do Gasto *',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _dataController,
                                readOnly: true,
                                onTap: _pickDate,
                                decoration: InputDecoration(
                                  suffixIcon: const Icon(Icons.calendar_month_rounded, color: AppColors.primaryTeal),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // 4. FORMA DE PAGAMENTO / REPASSE
                    const Text(
                      'Forma de Liquidação / Pagamento *',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _formaPagamento,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.payment_rounded, color: AppColors.primaryTeal),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _formasPagamentoList.map((forma) {
                        return DropdownMenuItem<String>(
                          value: forma,
                          child: Text(forma, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _formaPagamento = val);
                      },
                    ),

                    const SizedBox(height: 18),

                    // 5. COMPROVANTE ANEXO (OBRIGATÓRIO)
                    const Text(
                      'Documento Comprobatório Fiscal (Obrigatório) *',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _tipoComprovante,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.receipt_long_rounded, color: AppColors.primaryTeal),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _tiposComprovanteList.map((tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Text(tipo, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _tipoComprovante = val);
                      },
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _comprovanteTituloController,
                      decoration: InputDecoration(
                        labelText: 'Número / Identificador do Comprovante *',
                        hintText: 'Ex.: NF-e 004.892, Cupom 12481, Recibo nº 12',
                        prefixIcon: const Icon(Icons.tag_rounded, color: AppColors.primaryTeal),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Informe o número do comprovante';
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Caixa de Captura do Anexo
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _temComprovanteAnexo ? AppColors.primaryTeal : Colors.grey.shade300,
                          width: _temComprovanteAnexo ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLightTeal,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.document_scanner_rounded, color: AppColors.primaryDarkTeal, size: 24),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Comprovante Fiscal Digitalizado',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      'Foto da Câmera ou Arquivo PDF/Imagem anexado',
                                      style: TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _temComprovanteAnexo,
                                activeTrackColor: AppColors.primaryTeal,
                                onChanged: (val) {
                                  setState(() => _temComprovanteAnexo = val);
                                },
                              ),
                            ],
                          ),
                          if (_temComprovanteAnexo) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_outline, color: AppColors.successGreen, size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                    'Documento validado para conferência do Administrador',
                                    style: TextStyle(fontSize: 11, color: AppColors.successGreen, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 6. DESCRIÇÃO DETALHADA
                    const Text(
                      'Descrição / Finalidade do Gasto *',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descricaoController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Descreva os itens adquiridos ou serviço contratado conforme o plano de trabalho da OSC...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Informe a descrição do gasto';
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // BOTÃO SALVAR
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        onPressed: _isSaving ? null : _salvarDespesa,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(
                          _isSaving ? 'Gravando Despesa...' : 'Salvar e Encaminhar para Validação',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}
