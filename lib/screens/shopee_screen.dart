import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShopeeScreen extends StatefulWidget {
  const ShopeeScreen({super.key});

  @override
  State<ShopeeScreen> createState() => _ShopeeScreenState();
}

class _ShopeeScreenState extends State<ShopeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _custoProdutoController = TextEditingController();
  final TextEditingController _custoFreteController = TextEditingController();

  // Configurações Shopee (podem ser ajustadas se necessário, mas são mais estáveis)
  final double _comissaoShopeePercentualBase = 0.14; // 14% padrão
  final double _acrescimoComissaoFreteGratis =
      0.06; // 6% se participa do Prog. Frete Grátis
  final double _taxaFixaBaseShopee =
      3.00; // R$3 por item (verificar valor atual)
  final double _tetoComissaoShopee =
      100.00; // R$100 de teto na comissão percentual
  bool _participaFreteGratis = true; // Usuário pode marcar/desmarcar

  double _precoVendaIdeal = 0.0;
  double _lucroEstimado = 0.0;
  double _totalTaxasPlataforma = 0.0;
  String _observacaoCalculo = "";
  final double _lucroPercentualDesejado = 0.15;

  void _limparResultados() {
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
      final double custoProduto =
          double.tryParse(_custoProdutoController.text.replaceAll(',', '.')) ??
              0.0;
      final double custoFrete =
          double.tryParse(_custoFreteController.text.replaceAll(',', '.')) ??
              0.0;

      double comissaoShopeeEfetiva = _comissaoShopeePercentualBase +
          (_participaFreteGratis ? _acrescimoComissaoFreteGratis : 0);

      double pvCalculado = 0;
      double taxaFixaAplicada = _taxaFixaBaseShopee;
      double valorComissaoPercentualCalculada = 0;

      // --- INÍCIO LÓGICA SHOPEE ---
      // PV = (CP + CF + TF_Aplicada + Comissão_Valor_Aplicado_sem_%) / (1 - Lucro%) se comissão % for 0 (devido a teto)
      // PV = (CP + CF + TF_Aplicada) / (1 - Comissão%_Efetiva - Lucro%) se comissão % normal

      // Passo 1: Calcular PV preliminar com taxas base para checar condições
      double denominadorBase =
          1.0 - comissaoShopeeEfetiva - _lucroPercentualDesejado;
      if (denominadorBase <= 0) {
        _observacaoCalculo = "Erro: Comissão + Lucro somam 100% ou mais.";
        setState(() {});
        return;
      }
      double pvPreliminar =
          (custoProduto + custoFrete + _taxaFixaBaseShopee) / denominadorBase;

      // Passo 2: Checar teto da comissão (R$100 para a parte percentual)
      valorComissaoPercentualCalculada = pvPreliminar * comissaoShopeeEfetiva;
      bool tetoAplicado = false;

      if (valorComissaoPercentualCalculada > _tetoComissaoShopee) {
        valorComissaoPercentualCalculada = _tetoComissaoShopee;
        tetoAplicado = true;
        // Se teto aplicado, PV é recalculado usando o valor fixo da comissão.
        // A "comissão percentual efetiva" se torna 0 no denominador para o cálculo do PV.
        double denominadorComTeto = 1.0 - _lucroPercentualDesejado;
        if (denominadorComTeto <= 0) {
          /* Erro */ _observacaoCalculo = "Erro: Lucro muito alto.";
          setState(() {});
          return;
        }
        pvPreliminar = (custoProduto +
                custoFrete +
                _taxaFixaBaseShopee +
                _tetoComissaoShopee) /
            denominadorComTeto;
      }

      // Passo 3: Checar regra de PV < R$8 (usando o pvPreliminar que já considera o teto)
      // NOTA: A regra Shopee de R$3 por item pode mudar para itens de baixo valor.
      // A regra de "50% do PV se PV<R$X" precisa ser confirmada nas políticas atuais da Shopee.
      // Para este exemplo, manteremos a taxa fixa base, mas adicionaremos uma observação.
      pvCalculado = pvPreliminar;
      taxaFixaAplicada = _taxaFixaBaseShopee; // Mantendo R$3 por enquanto

      if (pvCalculado < 8.00 && pvCalculado > 0) {
        _observacaoCalculo =
            "${tetoAplicado ? "Teto de comissão aplicado. " : ""}ATENÇÃO: PV < R\$8. Verifique as políticas da Shopee para taxas em itens de baixo valor (pode haver alteração na taxa fixa de R\$${_taxaFixaBaseShopee.toStringAsFixed(2)}).";
      } else if (tetoAplicado) {
        _observacaoCalculo =
            "Teto de comissão de R\$${_tetoComissaoShopee.toStringAsFixed(2)} aplicado.";
      } else {
        _observacaoCalculo = "Taxas padrão aplicadas.";
      }

      // Se o teto não foi aplicado, a comissão é pvCalculado * comissaoShopeeEfetiva
      // Se o teto foi aplicado, valorComissaoPercentualCalculada já é _tetoComissaoShopee
      // A taxa fixa é _taxaFixaBaseShopee (a menos que a regra de PV<8 mude isso drasticamente)

      _totalTaxasPlataforma =
          valorComissaoPercentualCalculada + taxaFixaAplicada;
      _lucroEstimado = pvCalculado * _lucroPercentualDesejado;
      // --- FIM LÓGICA SHOPEE ---

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
              Text("Calculadora Shopee",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800)),
              const SizedBox(height: 8),
              Text(
                  "Configure os custos para um lucro bruto de ${(_lucroPercentualDesejado * 100).toStringAsFixed(0)}% sobre o preço de venda.",
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              _buildTextField(_custoProdutoController, "Custo do Produto",
                  prefix: "R\$"),
              _buildTextField(
                  _custoFreteController, "Custo do Frete (pago por você)",
                  prefix: "R\$"),
              SwitchListTile(
                title: const Text("Participa do Prog. Frete Grátis?"),
                subtitle: Text(
                    "(+${(_acrescimoComissaoFreteGratis * 100).toStringAsFixed(0)}% de comissão)"),
                value: _participaFreteGratis,
                onChanged: (bool value) {
                  setState(() {
                    _participaFreteGratis = value;
                  });
                  _limparResultados();
                },
                activeColor: Colors.teal.shade600,
                contentPadding: EdgeInsets.zero,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Info: Comissão base: ${(_comissaoShopeePercentualBase * 100).toStringAsFixed(0)}%. Taxa Fixa: R\$${_taxaFixaBaseShopee.toStringAsFixed(2)}/item. Teto comissão: R\$${_tetoComissaoShopee.toStringAsFixed(2)}.\nVerifique sempre os valores atuais na Shopee.",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[700]),
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
                  child: Text(_observacaoCalculo,
                      style: TextStyle(
                          color: _observacaoCalculo.startsWith("Erro")
                              ? Colors.redAccent
                              : Colors.orange.shade800,
                          fontStyle: FontStyle.italic)),
                ),
              if (_precoVendaIdeal > 0) _buildResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {String? prefix, String? suffix}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label, prefixText: prefix, suffixText: suffix),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d{0,2}'))
        ],
        validator: (value) {
          if (value == null || value.isEmpty) return 'Campo obrigatório';
          if (double.tryParse(value.replaceAll(',', '.')) == null)
            return 'Número inválido';
          return null;
        },
        onChanged: (_) => _limparResultados(),
      ),
    );
  }

  Widget _buildResults() {
    // Reutilize a mesma estrutura de _buildResults e _buildResultRow da tela do Mercado Livre
    // Ajustando os textos se necessário.
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Resultado do Cálculo:',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.teal.shade700)),
            const SizedBox(height: 11),
            _buildResultRow('Preço de Venda Ideal (PV):',
                'R\$ ${_precoVendaIdeal.toStringAsFixed(2)}'),
            _buildResultRow('Taxas da Plataforma Estimadas:',
                'R\$ ${_totalTaxasPlataforma.toStringAsFixed(2)}'),
            _buildResultRow('Seu Lucro Bruto Estimado:',
                'R\$ ${_lucroEstimado.toStringAsFixed(2)} (${(_lucroPercentualDesejado * 100).toStringAsFixed(0)}% do PV)'),
            const SizedBox(height: 8),
            Text(
              'Lembre-se: Este cálculo é uma estimativa. Verifique todas as taxas e impostos aplicáveis.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade600),
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
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.black87)),
          Text(value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold, color: Colors.teal.shade900)),
        ],
      ),
    );
  }
}
