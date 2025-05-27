# 💰 Calculadora de Preços para E-commerce (Aprendizado Flutter) 📱

Este repositório contém o código-fonte de um aplicativo Flutter desenvolvido como um projeto de aprendizado para calcular o preço de venda ideal de produtos em diversas plataformas de e-commerce (🛒 Mercado Livre, 🛍️ Shopee, 👚 Shein e 📦 Amazon), visando uma margem de lucro de 15%.

## 🚀 Visão Geral

O aplicativo permite que o usuário insira o custo do produto e o custo de frete pago pelo vendedor. Com base nas taxas específicas de cada plataforma (que podem ser configuradas ou estão embutidas no app), o aplicativo calcula o preço de venda necessário para atingir um lucro bruto de 15% sobre o valor final da venda.

O projeto utiliza uma interface de abas inferiores para facilitar a navegação entre as calculadoras de cada plataforma.

## 📚 Aprendizados e Desafios

Durante o desenvolvimento deste projeto, foram explorados e aprendidos diversos conceitos e técnicas do Flutter, incluindo:

* **🏗️ Estrutura Básica de um Aplicativo Flutter:** Criação de `MaterialApp`, `StatelessWidget` e `StatefulWidget`.
* **↔️ Navegação com `BottomNavigationBar`:** Implementação de uma interface de abas para alternar entre as funcionalidades de cada plataforma.
* **🎨 Criação de Interfaces de Usuário (UI):** Utilização de widgets como `Scaffold`, `AppBar`, `Text`, `TextFormField`, `ElevatedButton`, `Card`, `Column`, `Row`, `Padding`, `SingleChildScrollView`.
* **⌨️ Entrada de Dados com `TextFormField` e `TextEditingController`:** Captura e gerenciamento da entrada de dados do usuário.
* **✅ Validação de Formulários com `Form` e `GlobalKey<FormState>`:** Garantia de que os dados inseridos pelo usuário são válidos.
* **🔄 Gerenciamento de Estado com `setState()`:** Atualização da interface do usuário em resposta às interações do usuário e aos cálculos.
* **🧮 Lógica de Cálculo:** Implementação das fórmulas matemáticas para calcular o preço de venda ideal, considerando as taxas de cada plataforma e a margem de lucro desejada.
* **🔢 Tratamento de Números e Formatação:** Conversão de strings para `double` e formatação de resultados para exibição em formato de moeda e porcentagem.
* **✨ Uso de Temas (`ThemeData`):** Personalização da aparência geral do aplicativo.
* **📐 Layout com `Column`, `Row`, `Expanded`:** Organização dos widgets na tela.
* **📑 Listas e Navegação:** Utilização de `List` para as abas e `IndexedStack` para manter o estado das telas.
* **🐛 Resolução de Erros e Debugging:** O projeto passou por diversas fases de correção de erros, desde problemas de sintaxe básicos até desafios mais complexos relacionados à interpretação de tipos pelo analisador do Flutter e configurações do Gradle para a compilação Android.

## 🤯 Desafios Específicos Enfrentados

* **🧾 Lógica de Taxas Complexas:** A implementação da lógica de cálculo para plataformas como Mercado Livre e Shopee, que possuem taxas variáveis e condições específicas, exigiu atenção aos detalhes e a criação de um código condicional mais elaborado.
* **❓ Erro Persistente com `CardThemeData?`:** Um desafio particularmente intrigante foi a persistência do erro onde o analisador do Flutter parecia esperar um tipo `CardThemeData?` para o parâmetro `cardTheme` do `ThemeData`.
* **⚙️ Configuração do Android Gradle Plugin (AGP):** A necessidade de ajustar a versão do AGP nos arquivos de build do Android para compatibilidade com a versão do Gradle utilizada no projeto.
* **✍️ Erros de Sintaxe e Estrutura:** A correção de erros de sintaxe e a garantia da estrutura correta do código Flutter foram desafios contínuos.

## 🧑‍💻 Próximos Passos (Opcional)

* **💾 Persistência de Dados:** Implementar uma forma de salvar os custos dos produtos e as configurações das taxas localmente.
* **📡 Busca de Taxas Atualizadas:** Explorar a possibilidade de buscar as taxas das plataformas de forma automática.
* **⚙️ Interface de Configuração Avançada:** Permitir que o usuário configure as taxas das plataformas de forma mais detalhada.
* **🧪 Testes Unitários e de Widget:** Adicionar testes automatizados para garantir a correção da lógica e a funcionalidade dos widgets.
* **💅 Melhorias na Interface:** Refinar o design da interface e a experiência do usuário.

## 📱 Como Usar

1.  Clone este repositório para o seu computador.
2.  Certifique-se de ter o Flutter SDK instalado e configurado.
3.  Abra o projeto no Android Studio (ou seu editor Flutter preferido).
4.  Rode o aplicativo em um emulador ou dispositivo físico usando o comando `flutter run` no terminal.
5.  Navegue pelas abas inferiores para acessar a calculadora de cada plataforma.
6.  Insira o custo do produto e o custo de frete.
7.  O aplicativo calculará o preço de venda ideal com uma margem de lucro de 15%.

## 🤝 Contribuições

Sinta-se à vontade para abrir issues e propor melhorias!

