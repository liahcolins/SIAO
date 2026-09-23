import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/bank_warning_banner.dart';
import '../../data/datasources/transferencia_local_datasource.dart';
import '../../data/models/transferencia_model.dart';

class CadastroTransferenciaPage extends StatefulWidget {
  final VoidCallback onTransferenciaSalva;

  const CadastroTransferenciaPage({
    super.key,
    required this.onTransferenciaSalva,
  });

  @override
  State<CadastroTransferenciaPage> createState() =>
      _CadastroTransferenciaPageState();
}

class _CadastroTransferenciaPageState
    extends State<CadastroTransferenciaPage> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _contasOrigem = [
    'Banco do Brasil - Convênio 01/2026',
    'Caixa Econômica - Doação Projeto Apoio',
    'Bradesco - Conta Geral da OSC',
  ];

  final List<String> _contasDestino = [
    'Caixa Interno (Fundo Fixo)',
    'Conta Apoio Operacional Sede',
    'Caixa de Eventos / Feiras',
  ];

  late String _selectedOrigem;
  late String _selectedDestino;
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _finalidadeController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedOrigem = _contasOrigem.first;
    _selectedDestino = _contasDestino.first;
  }

  @override
  void dispose() {
    _valorController.dispose();
    _finalidadeController.dispose();
    super.dispose();
  }

  Future<void> _salvarTransferencia() async {
    if (!_formKey.currentState!.validate()) return;

    final valorDouble = Formatters.parseCurrency(_valorController.text);
    if (valorDouble == null || valorDouble <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe um valor válido maior que zero.'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final novaTransferencia = TransferenciaModel(
      id: const Uuid().v4(),
      contaOrigem: _selectedOrigem,
      contaDestino: _selectedDestino,
      valor: valorDouble,
      data: _selectedDate,
      finalidade: _finalidadeController.text.trim(),
      statusValidaAdmin: 'pendente',
      criadoEm: DateTime.now(),
    );

    final dataSource = TransferenciaLocalDataSource();
    await dataSource.saveTransferencia(novaTransferencia);

    setState(() => _isSaving = false);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 28),
            SizedBox(width: 8),
            Text('Registro Salvo!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A movimentação gerencial de transferência foi registrada com sucesso no banco de dados local da OSC.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLightTeal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Origem: $_selectedOrigem', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('Destino: $_selectedDestino', style: const TextStyle(fontSize: 12)),
                  Text('Valor: ${Formatters.formatCurrency(valorDouble)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryTeal)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _valorController.clear();
              _finalidadeController.clear();
              widget.onTransferenciaSalva();
            },
            child: const Text('Ver Lançamentos'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Transferência'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _salvarTransferencia,
            child: const Text(
              'Enviar',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Alerta Obrigatorio
              const BankWarningBanner(
                customMessage:
                    'ATENÇÃO: Este formulário registra a movimentação interna no sistema SIAO. O aplicativo NÃO realiza PIX ou transferência bancária real.',
              ),
              const SizedBox(height: 20),

              const Text(
                'Lançamento Gerencial de Transferência',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDarkTeal),
              ),
              const Text(
                'Preencha os campos para movimentar saldos entre origens/contas internas da OSC.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Conta Origem
              const Text('Conta de Origem (Recurso Pagador)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedOrigem,
                isExpanded: true,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.account_balance_outlined, color: AppColors.primaryTeal)),
                items: _contasOrigem.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (val) => setState(() => _selectedOrigem = val!),
              ),
              const SizedBox(height: 16),

              // Conta Destino
              const Text('Conta / Caixa de Destino', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedDestino,
                isExpanded: true,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.move_to_inbox_outlined, color: AppColors.primaryTeal)),
                items: _contasDestino.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (val) => setState(() => _selectedDestino = val!),
              ),
              const SizedBox(height: 16),

              // Valor R$
              const Text('Valor da Transferência (R\$)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _valorController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.attach_money_rounded, color: AppColors.primaryTeal),
                  hintText: 'Ex: 1500,00',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe o valor da transferência';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Data da Movimentação
              const Text('Data do Registro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, color: AppColors.primaryTeal, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Finalidade / Descrição
              const Text('Finalidade / Descrição Gerencial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _finalidadeController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Ex: Suprimento de fundo fixo para despesas de deslocamento e alimentação...',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe a finalidade da movimentação';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // Botão de Salvar Estilo Pílula Verde Teal do Protótipo
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _isSaving ? null : _salvarTransferencia,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    _isSaving ? 'Enviando...' : 'Enviar Registro de Transferência',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
