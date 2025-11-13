import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNavigation({super.key, required this.currentIndex});

  void onItemTapped(BuildContext context, int index) {
    context.go('/home/$index'); // 👈 así nunca sales del HomePage
  }

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
      BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Reportes'),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart),
        label: 'Carrito',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag),
        label: 'Pedidos',
      ), // 👈 Nuevo
    ];

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => onItemTapped(context, index),
      items: items,
      backgroundColor: Colors.white, // color de fondo de la barra
      selectedItemColor: Colors.blueAccent, // color del ítem seleccionado
      unselectedItemColor: Colors.grey, // color de los ítems no seleccionados
      type: BottomNavigationBarType.fixed, // importante si hay más de 3 ítems
    );
  }
}
