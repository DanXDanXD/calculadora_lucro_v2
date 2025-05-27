import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SheinScreen extends StatefulWidget {
  const SheinScreen({super.key});

  @override
  State<SheinScreen> createState() => _SheinScreenState();
}

class _SheinScreenState extends State<SheinScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _custoProdutoController = TextEditingController();
  final TextEditingController _custoFreteController = TextEditingController();
  // Shein: Comissão padrão de 16% (verificar valor atual)
  final double _comissaoSheinPercentual = 0.16;

  double _precoVendaIdeal = 0.0;
  double _lucroEstimado = 0.0;
  double _totalTaxasPlataforma = 0.0;
  final double _lucroPercentualDesejado = 0.15;

  void _limparResultados(){
    setState(() {
      _precoVendaIdeal = 0.0;
      _lucroEstimado = 0.0;
      _totalTaxasPlataforma = 0.0;
    });
  }

  void _calcularPreco() {
    _limparResultados();
    if (_formKey.currentState!.validate()) {
      final double custoProduto = double.tryParse(_custoProdutoController.text.replaceAll(',', '.')) ?? 0.0;
      final double custoFrete = double.tryParse(_custoFreteController.text.replaceAll(',', '.')) ?? 0.0;

      final double denominador = 1.0 - _comissaoSheinPercentual - _lucroPercentualDesejado;

      if (denominador <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: Comissão + Lucro desejado somam 100% ou mais.')),
        );
        return;
      }

      // Shein geralmente não tem taxa fixa por item além da comissão percentual
      double taxaFixaShein = 0.0;
      _precoVendaIdeal = (custoProduto + custoFrete + taxaFixaShein) / denominador;
      _totalTaxasPlataforma = _precoVendaIdeal * _comissaoSheinPercentual;
      _lucroEstimado = _precoVendaIdeal * _lucroPercentualDesejado;

      setState(() {});
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
              Text("Calculadora Shein", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
              const SizedBox(height: 8),
              Text("Configure os custos para um lucro bruto de ${(_lucroPercentualDesejado * 100).toStringAsFixed(0)}% sobre o preço de venda.", style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              _buildTextField(_custoProdutoController, "Custo do Produto", prefix: "R\$"),
              _buildTextField(_custoFreteController, "Custo do Frete (pago por você)", prefix: "R\$"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Info: Comissão Padrão Shein: ${(_comissaoSheinPercentual * 100).toStringAsFixed(0)}%.\nVerifique sempre o valor atual na Shein.",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                ),
              ),
              ElevatedButton(
                onPressed: _calcularPreco,
                child: const Text('Calcular Preço Ideal'),
              ),
              const SizedBox(height: 24),
              if (_precoVendaIdeal > 0) _buildResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {String? prefix, String? suffix}) {
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
          if (double.tryParse(value.replaceAll(',', '.')) == null) return 'Número inválido';
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