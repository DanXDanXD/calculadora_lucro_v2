import 'package:flutter/material.dart';
import 'screens/mercado_livre_screen.dart';
import 'screens/shopee_screen.dart';
import 'screens/shein_screen.dart';
import 'screens/amazon_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Preços',
      theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.grey[100],
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.teal.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.teal.shade700, width: 2.0),
            ),
            filled: true,
            fillColor: Colors.white,
            labelStyle: TextStyle(color: Colors.teal.shade800),
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixStyle: TextStyle(color: Colors.teal.shade800, fontSize: 16),
            suffixStyle: TextStyle(color: Colors.teal.shade800, fontSize: 16),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          // VAMOS COMENTAR ESTA SEÇÃO INTEIRA PARA O TESTE:
          /*
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          color: Colors.white,
        ),
        */
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: Colors.teal.shade700,
            unselectedItemColor: Colors.grey.shade500,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          ),
          textTheme: TextTheme(
            headlineSmall: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.teal.shade900),
            titleLarge: TextStyle(
                color: Colors.teal.shade800, fontWeight: FontWeight.w600),
            titleMedium: const TextStyle(color: Colors.black87, fontSize: 16),
            bodyMedium: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            bodySmall: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          )),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    MercadoLivreScreen(),
    ShopeeScreen(),
    SheinScreen(),
    AmazonScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Mercado Livre';
      case 1:
        return 'Shopee';
      case 2:
        return 'Shein';
      case 3:
        return 'Amazon';
      default:
        return 'Calculadora de Preços';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_selectedIndex)),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon:
                Icon(Icons.store_mall_directory_outlined), // Mercado Livre Icon
            label: 'Mercado Livre',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined), // Shopee Icon
            label: 'Shopee',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom_outlined), // Shein Icon
            label: 'Shein',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined), // Amazon Icon
            label: 'Amazon',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType
            .fixed, // Para garantir que todos os labels apareçam
      ),
    );
  }
}
