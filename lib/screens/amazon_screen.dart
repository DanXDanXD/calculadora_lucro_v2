import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math'; // Para max

class AmazonScreen extends StatefulWidget {
  const AmazonScreen({super.key});

  @override
  State<AmazonScreen> createState() => _AmazonScreenState();
}

class _AmazonScreenState extends State<AmazonScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _custoProdutoController = TextEditingController();
  final TextEditingController _custoFreteController = TextEditingController();
  final TextEditingController _comissaoPercentualController = TextEditingController(text: '15'); // %
  final TextEditingController _taxaMinimaController = TextEditingController(text: '1.00'); // R$

  double _precoVendaIdeal = 0.0;
  double _lucroEstimado = 0.0;
  double _totalTaxasPlataforma = 0.0;
  String _observacaoCalculo = "";
  final double _lucroPercentualDesejado = 0.15;

  void _limparResultados(){
    setState(() {
      _precoVendaIdeal = 0.0;
      _lucroEstimado = 0.0;
      _totalTaxasPlataforma = 0.0;
      _observacaoCalculo = "";
    });
  }

  void _calcularPreco() {
    _limparResultados();
    if (_formKey.currentState!.validate()) {
      final double custoProduto = double.tryParse(_custoProdutoController.text.replaceAll(',', '.')) ?? 0.0;
      final double custoFrete = double.tryParse(_custoFreteController.text.replaceAll(',', '.')) ?? 0.0;
      final double comissaoInput = double.tryParse(_comissaoPercentualController.text.replaceAll(',', '.')) ?? 0.0;
      final double taxaMinimaInput = double.tryParse(_taxaMinimaController.text.replaceAll(',', '.')) ?? 0.0;

      if (comissaoInput <= 0 || comissaoInput >= (100.0 - (_lucroPercentualDesejado * 100))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Comissão % inválida ou muito alta. Deve ser > 0 e < ${(100 - (_lucroPercentualDesejado * 100)).toStringAsFixed(0)}%')),
        );
        return;
      }
      final double comissaoPercentual = comissaoInput / 100.0;

      double pvCalculado = 0;
      double comissaoValorAplicadaNaPlataforma = 0;

      // --- INÍCIO LÓGICA AMAZON ---
      // Cenário 1: Calcular como se a comissão percentual fosse aplicada
      double denominadorComPercentual = 1.0 - comissaoPercentual - _lucroPercentualDesejado;
      if (denominadorComPercentual <= 0) {
        _observacaoCalculo = "Erro: Comissão + Lucro somam 100% ou mais.";
        setState((){});
        return;
      }
      double pvTempComPercentual = (custoProduto + custoFrete) / denominadorComPercentual;
      double comissaoCalculadaPercentual = pvTempComPercentual * comissaoPercentual;

      // Cenário 2: Verificar se a taxa mínima é maior (e se foi informada)
      if (taxaMinimaInput > 0 && comissaoCalculadaPercentual < taxaMinimaInput) {
        // A taxa mínima será aplicada. O PV deve cobrir CP + CF + TaxaMinima + Lucro
        // PV = (CP + CF + TaxaMinima) / (1 - Lucro%)
        double denominadorComTaxaMinima = 1.0 - _lucroPercentualDesejado;
        if (denominadorComTaxaMinima <= 0) { /* Erro */ _observacaoCalculo = "Erro: Lucro muito alto."; setState((){}); return; }
        pvCalculado = (custoProduto + custoFrete + taxaMinimaInput) / denominadorComTaxaMinima;
        comissaoValorAplicadaNaPlataforma = taxaMinimaInput;
        _observacaoCalculo = "Taxa mínima de R\$ ${taxaMinimaInput.toStringAsFixed(2)} aplicada.";
      } else {
        // A comissão percentual é aplicada (ou não há taxa mínima significativa)
        pvCalculado = pvTempComPercentual;
        comissaoValorAplicadaNaPlataforma = comissaoCalculadaPercentual;
        _observacaoCalculo = "Comissão percentual de ${comissaoInput.toStringAsFixed(0)}% aplicada.";
      }
      // --- FIM LÓGICA AMAZON ---

      _totalTaxasPlataforma = comissaoValorAplicadaNaPlataforma;
      _lucroEstimado = pvCalculado * _lucroPercentualDesejado;

      setState(() {
        _precoVendaIdeal = pvCalculado;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text("Calculadora Amazon Brasil", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
              const SizedBox(height: 8),
              Text("Configure as taxas e custos para um lucro bruto de ${(_lucroPercentualDesejado * 100).toStringAsFixed(0)}% sobre o preço de venda.", style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              _buildTextField(_custoProdutoController, "Custo do Produto", prefix: "R\$"),
              _buildTextField(_custoFreteController, "Custo do Frete (pago por você)", prefix: "R\$"),
              _buildTextField(_comissaoPercentualController, "Comissão da Plataforma", suffix: "%", isPercentage: true),
              _buildTextField(_taxaMinimaController, "Taxa Mínima da Categoria (se houver)", prefix: "R\$"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Info: A taxa cobrada será o MAIOR valor entre (PV * Comissão%) e a Taxa Mínima (se informada e > 0).",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                ),
              ),
              ElevatedButton(
                onPressed: _calcularPreco,
                child: const Text('Calcular Preço Ideal'),
              ),
              const SizedBox(height: 24),
              if (_observacaoCalculo.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(_observacaoCalculo, style: TextStyle(color: _observacaoCalculo.startsWith("Erro") ? Colors.redAccent : Colors.blueAccent, fontStyle: FontStyle.italic)),
                ),
              if (_precoVendaIdeal > 0) _buildResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {String? prefix, String? suffix, bool isPercentage = false}) {
    // Reutilize _buildTextField da tela do Mercado Livre
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, prefixText: prefix, suffixText: suffix),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d{0,2}'))],
        validator: (value) {
          if (value == null || value.isEmpty) return 'Campo obrigatório';
          final numValue = double.tryParse(value.replaceAll(',', '.'));
          if (numValue == null) return 'Número inválido';
          if (isPercentage && (numValue <= 0 || numValue >= (100 - (_lucroPercentualDesejado * 100)))) {
            // Validação específica no _calcularPreco
          }
          return null;
        },
        onChanged: (_) => _limparResultados(),
      ),
    );
  }

  Widget _buildResults() {
    // Reutilize _buildResults da tela do Mercado Livre
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Resultado do Cálculo:', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.teal.shade700)),
            const SizedBox(height: 12),
            _buildResultRow('Preço de Venda Ideal (PV):', 'R\$ ${_precoVendaIdeal.toStringAsFixed(2)}'),
            _buildResultRow('Taxas da Plataforma Estimadas:', 'R\$ ${_totalTaxasPlataforma.toStringAsFixed(2)}'),
            _buildResultRow('Seu Lucro Bruto Estimado:', 'R\$ ${_lucroEstimado.toStringAsFixed(2)} (${(_lucroPercentualDesejado * 100).toStringAsFixed(0)}% do PV)'),
            const SizedBox(height: 8),
            Text(
              'Lembre-se: Este cálculo é uma estimativa. Verifique todas as taxas e impostos aplicáveis.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    // Reutilize _buildResultRow da tela do Mercado Livre
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black87)),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal.shade900)),
        ],
      ),
    );
  }
}