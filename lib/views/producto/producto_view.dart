// views/products_page.dart
import 'package:flutter/material.dart';
import 'package:ecommerce_movil/services/Producto/producto_service.dart';
import 'package:ecommerce_movil/models/producto/producto_model.dart';
import './detalle_producto_view.dart';

class ProductosView extends StatefulWidget {
  const ProductosView({Key? key}) : super(key: key);

  @override
  State<ProductosView> createState() => _ProductosViewState();
}

class _ProductosViewState extends State<ProductosView> {
  final ProductoService _productService = ProductoService();
  late Future<ProductoResponse> _productsFuture;
  int _currentPage = 1;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = _productService.getProducts(
        page: _currentPage,
        search: _searchQuery,
      );
    });
  }

  void _loadPage(int page) {
    setState(() {
      _currentPage = page;
      _productsFuture = _productService.getProducts(page: page);
    });
  }

  void _searchProducts(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
      _productsFuture = _productService.getProducts(search: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electrodomésticos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _searchProducts,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Products List
          Expanded(
            child: FutureBuilder<ProductoResponse>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshProducts,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasData) {
                  final response = snapshot.data!;
                  final products = response.values.productos;
                  final pagination = response.values.pagination;

                  if (products.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No se encontraron productos',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Products Count
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${pagination.count} productos encontrados',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Página ${pagination.currentPage} de ${pagination.totalPages}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Products Grid
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio:
                                    0.52, // Aumentado para más altura
                              ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return ProductoCard(product: products[index]);
                          },
                        ),
                      ),
                      // Pagination
                      if (pagination.totalPages > 1)
                        _buildPaginationControls(pagination),
                    ],
                  );
                } else {
                  return const Center(child: Text('No hay datos disponibles'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(Pagination pagination) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (pagination.hasPrevious)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => _loadPage(pagination.previousPage!),
            ),
          const SizedBox(width: 16),
          Text(
            'Página ${pagination.currentPage} de ${pagination.totalPages}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          if (pagination.hasNext)
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => _loadPage(pagination.nextPage!),
            ),
        ],
      ),
    );
  }
}

class ProductoCard extends StatelessWidget {
  final Producto product;

  const ProductoCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navegar a detalle del producto
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleProductoView(idProducto: product.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.imagenesData.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        // child: Image.network(product.imagenesData[0]['url'], fit: BoxFit.cover),
                      )
                    : const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
              const SizedBox(height: 8),

              // Product Name - Limitado a 2 líneas
              SizedBox(
                height: 40, // Altura fija para el nombre
                child: Text(
                  product.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),

              // Brand and Category
              Text(
                '${product.marcaNombre} • ${product.subcategoriaNombre}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Prices
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bs. ${product.precioContado.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'Bs. ${product.precioCuota.toStringAsFixed(2)} cuota',
                    style: TextStyle(
                      fontSize: 11, // Reducido ligeramente
                      color: Colors.grey[600],
                      // decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),

              const Spacer(), // Este spacer puede causar problemas
              // Stock and Warranty - En una sola línea
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Stock: ${product.stock}',
                      style: TextStyle(
                        fontSize: 11,
                        color: product.stock > 0 ? Colors.green : Colors.red,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${product.garantiaMeses} meses',
                      style: const TextStyle(fontSize: 11, color: Colors.blue),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
