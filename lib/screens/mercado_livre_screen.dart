import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para input formatters

class MercadoLivreScreen extends StatefulWidget {
  const MercadoLivreScreen({super.key});

  @override
  State<MercadoLivreScreen> createState() => _MercadoLivreScreenState();
}

class _MercadoLivreScreenState extends State<MercadoLivreScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _custoProdutoController = TextEditingController();
  final TextEditingController _custoFreteController = TextEditingController();
  final TextEditingController _comissaoPercentualController = TextEditingController(text: '18'); // % (ex: 18 para 18%)
  final TextEditingController _taxaFixaController = TextEditingController(text: '0.00'); // R$

  double _precoVendaIdeal = 0.0;
  double _lucroEstimado = 0.0;
  double _totalTaxasPlataforma = 0.0;
  String _observacaoTaxaFixa =
      "ML: Se PV < R\$79, informe TF = R\$6 (frete) + Custo Fixo Premium (R\$6.25-R\$6.75).\n"
      "Se PV >= R\$79, verifique se há taxa fixa aplicável (geralmente R\$0).";
  final double _lucroPercentualDesejado = 0.15; // 15%

  void _limparResultados() {
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
      final double comissaoInput = double.tryParse(_comissaoPercentualController.text.replaceAll(',', '.')) ?? 0.0;
      final double taxaFixaInput = double.tryParse(_taxaFixaController.text.replaceAll(',', '.')) ?? 0.0;

      if (comissaoInput <= 0 || comissaoInput >= (100.0 - (_lucroPercentualDesejado * 100))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Comissão % inválida ou muito alta. Deve ser > 0 e < ${(100 - (_lucroPercentualDesejado * 100)).toStringAsFixed(0)}%')),
        );
        return;
      }
      final double comissaoPercentual = comissaoInput / 100.0; // Convertendo para decimal

      final double denominador = 1.0 - comissaoPercentual - _lucroPercentualDesejado;

      if (denominador <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: Comissão + Lucro desejado somam 100% ou mais.')),
        );
        return;
      }

      double pvCalculado = (custoProduto + custoFrete + taxaFixaInput) / denominador;

      double taxasPlataforma = (pvCalculado * comissaoPercentual) + taxaFixaInput;
      double lucroVenda = pvCalculado * _lucroPercentualDesejado;
      // Alternativa para lucro: pvCalculado - custoProduto - custoFrete - taxasPlataforma;

      setState(() {
        _precoVendaIdeal = pvCalculado;
        _totalTaxasPlataforma = taxasPlataforma;
        _lucroEstimado = lucroVenda;

        if (pvCalculado < 79 && taxaFixaInput == 0) {
          _observacaoTaxaFixa = "ATENÇÃO: PV calculado < R\$79. Verifique se uma Taxa Fixa (R\$6 + Premium) se aplica e insira acima.";
        } else if (pvCalculado >= 79 && taxaFixaInput > 0) {
          _observacaoTaxaFixa = "INFO: PV calculado >= R\$79. A taxa fixa de R\$${taxaFixaInput.toStringAsFixed(2)} foi aplicada. Verifique se ela ainda é devida.";
        } else {
          _observacaoTaxaFixa = "ML: Se PV < R\$79, informe TF = R\$6 (frete) + Custo Fixo Premium (R\$6.25-R\$6.75).\n"
              "Se PV >= R\$79, verifique se há taxa fixa aplicável (geralmente R\$0).";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Para fechar teclado ao tocar fora
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text("Calculadora Mercado Livre", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
              const SizedBox(height: 8),
              Text("Configure as taxas e custos para um lucro bruto de ${(_lucroPercentualDesejado * 100).toStringAsFixed(0)}% sobre o preço de venda.", style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              _buildTextField(_custoProdutoController, "Custo do Produto", prefix: "R\$"),
              _buildTextField(_custoFreteController, "Custo do Frete (pago por você)", prefix: "R\$"),
              _buildTextField(_comissaoPercentualController, "Comissão da Plataforma", suffix: "%", isPercentage: true),
              _buildTextField(_taxaFixaController, "Taxa Fixa Total Estimada", prefix: "R\$"),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
                child: Text(_observacaoTaxaFixa, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700])),
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

  Widget _buildTextField(TextEditingController controller, String label, {String? prefix, String? suffix, bool isPercentage = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefix,
          suffixText: suffix,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d{0,2}')),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Campo obrigatório';
          }
          final numValue = double.tryParse(value.replaceAll(',', '.'));
          if (numValue == null) {
            return 'Número inválido';
          }
          if (isPercentage && (numValue <= 0 || numValue >= (100 - (_lucroPercentualDesejado * 100)))) {
            // Validação mais específica no _calcularPreco
          }
          return null;
        },
        onChanged: (_) => _limparResultados(),
      ),
    );
  }

  Widget _buildResults() {
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