// views/products_page.dart
import 'package:flutter/material.dart';
import 'package:ecommerce_movil/services/Producto/producto_service.dart';
import 'package:ecommerce_movil/models/producto/producto_model.dart';
import 'package:ecommerce_movil/services/voice_service.dart';
import './detalle_producto_view.dart';

class ProductosView extends StatefulWidget {
  const ProductosView({Key? key}) : super(key: key);

  @override
  State<ProductosView> createState() => _ProductosViewState();
}

class _ProductosViewState extends State<ProductosView> {
  final ProductoService _productService = ProductoService();
  final VoiceService _voiceService = VoiceService();
  final TextEditingController _searchController = TextEditingController();

  late Future<ProductoResponse> _productsFuture;
  int _currentPage = 1;
  String _searchQuery = '';
  bool _busquedaConIA = false;
  bool _cargandoBusqueda = false;
  bool _isListening = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getProducts();
    _initializeVoice();
  }

  void _initializeVoice() async {
    await _voiceService.initialize();
  }

  void _startListening() async {
    if (!_voiceService.isInitialized) {
      bool initialized = await _voiceService.initialize();
      if (!initialized) {
        _mostrarError('El reconocimiento de voz no está disponible');
        return;
      }
    }

    if (_voiceService.isListening) {
      _stopListening();
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
    });

    _voiceService.listen(
      onResult: (text) {
        setState(() {
          _recognizedText = text;
        });

        // Detectar automáticamente cuando el usuario termina de hablar
        if (text.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (_isListening && _recognizedText == text) {
              _stopListening();
            }
          });
        }
      },
      onError: () {
        setState(() {
          _isListening = false;
        });
        _mostrarError('Error en el reconocimiento de voz');
      },
    );
  }

  void _stopListening() {
    _voiceService.stop();
    setState(() {
      _isListening = false;
    });

    // Solo ejecutar búsqueda si hay texto reconocido
    if (_recognizedText.trim().isNotEmpty) {
      _searchController.text = _recognizedText;
      _ejecutarBusqueda(_recognizedText);
    }
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

  void _ejecutarBusqueda(String query) {
    if (query.isEmpty) {
      _limpiarBusqueda();
      return;
    }

    setState(() {
      _searchQuery = query;
      _currentPage = 1;
      _cargandoBusqueda = true;
    });

    if (_busquedaConIA) {
      _busquedaInteligente(query);
    } else {
      _busquedaNormal(query);
    }
  }

  void _buscarConLupa() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _ejecutarBusqueda(query);
    } else {
      _mostrarError('Por favor ingresa un término de búsqueda');
    }
  }

  Future<void> _busquedaNormal(String query) async {
    try {
      final response = await _productService.getProducts(
        search: query,
        page: _currentPage,
      );

      setState(() {
        _productsFuture = Future.value(response);
        _cargandoBusqueda = false;
      });
    } catch (e) {
      _mostrarError('Error en búsqueda normal: $e');
      setState(() {
        _cargandoBusqueda = false;
      });
    }
  }

  Future<void> _busquedaInteligente(String query) async {
    try {
      final responseIA = await _productService.busquedaNatural(query: query);

      if (responseIA.status == 1 && responseIA.valores.productos.isNotEmpty) {
        setState(() {
          _productsFuture = Future.value(
            _convertirARespuestaProducto(responseIA),
          );
          _cargandoBusqueda = false;
        });
      } else {
        _busquedaNormal(query);
      }
    } catch (e) {
      _mostrarError('Error en búsqueda IA: $e');
      _busquedaNormal(query);
    }
  }

  ProductoResponse _convertirARespuestaProducto(
    ProductoListResponse responseIA,
  ) {
    return ProductoResponse(
      status: responseIA.status,
      error: 0,
      message: responseIA.message,
      values: ProductoValues(
        productos: responseIA.valores.productos,
        pagination: Pagination(
          count: responseIA.valores.pagination.count,
          totalPages: responseIA.valores.pagination.totalPages,
          currentPage: responseIA.valores.pagination.currentPage,
          pageSize: responseIA.valores.pagination.pageSize,
          hasNext: responseIA.valores.pagination.hasNext,
          hasPrevious: responseIA.valores.pagination.hasPrevious,
          nextPage: responseIA.valores.pagination.nextPage,
          previousPage: responseIA.valores.pagination.previousPage,
        ),
        filtersApplied: FiltersApplied(
          search: responseIA.valores.filtersApplied.search?.toString() ?? '',
          categoria: responseIA.valores.filtersApplied.categoria,
          subcategoria: responseIA.valores.filtersApplied.subcategoria,
          marca: responseIA.valores.filtersApplied.marca,
          minPrecio: responseIA.valores.filtersApplied.minPrecio,
          maxPrecio: responseIA.valores.filtersApplied.maxPrecio,
          enStock: responseIA.valores.filtersApplied.enStock,
          activos: responseIA.valores.filtersApplied.activos,
        ),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _toggleTipoBusqueda() {
    setState(() {
      _busquedaConIA = !_busquedaConIA;
    });

    if (_searchQuery.isNotEmpty) {
      _ejecutarBusqueda(_searchQuery);
    }
  }

  void _limpiarBusqueda() {
    setState(() {
      _searchQuery = '';
      _currentPage = 1;
      _busquedaConIA = false;
      _cargandoBusqueda = false;
      _searchController.clear();
    });
    _refreshProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_isListening) {
      _voiceService.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electrodomésticos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              onPressed: _limpiarBusqueda,
              icon: const Icon(Icons.clear),
              tooltip: 'Limpiar búsqueda',
            ),
        ],
      ),
      body: Column(
        children: [
          _construirBarraBusqueda(),
          Expanded(
            child: FutureBuilder<ProductoResponse>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (_cargandoBusqueda) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !_cargandoBusqueda) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
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
                    return _construirVistaSinResultados();
                  }

                  return Column(
                    children: [
                      _construirInfoBusqueda(response),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.52,
                              ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return ProductoCard(product: products[index]);
                          },
                        ),
                      ),
                      if (pagination.totalPages > 1 && !_busquedaConIA)
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

  Widget _construirBarraBusqueda() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                        IconButton(
                          icon: Icon(
                            _isListening ? Icons.mic_off : Icons.mic,
                            color: _isListening ? Colors.red : Colors.blue,
                          ),
                          onPressed: _startListening,
                          tooltip: 'Búsqueda por voz',
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _ejecutarBusqueda(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _buscarConLupa,
                  icon: const Icon(Icons.search, color: Colors.white),
                  tooltip: 'Buscar productos',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_isListening)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mic, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _recognizedText.isEmpty
                          ? 'Escuchando... Di algo'
                          : _recognizedText,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          _construirSelectorTipoBusqueda(),
        ],
      ),
    );
  }

  Widget _construirSelectorTipoBusqueda() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Búsqueda:', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 12),
        ChoiceChip(
          label: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, size: 16),
              SizedBox(width: 4),
              Text('Normal'),
            ],
          ),
          selected: !_busquedaConIA,
          onSelected: (_) {
            if (_busquedaConIA) _toggleTipoBusqueda();
          },
          selectedColor: Colors.blue[100],
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.smart_toy, size: 16),
              SizedBox(width: 4),
              Text('IA'),
            ],
          ),
          selected: _busquedaConIA,
          onSelected: (_) {
            if (!_busquedaConIA) _toggleTipoBusqueda();
          },
          selectedColor: Colors.green[100],
        ),
      ],
    );
  }

  Widget _construirInfoBusqueda(ProductoResponse response) {
    final products = response.values.productos;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _busquedaConIA ? Colors.green[50] : Colors.blue[50],
      child: Row(
        children: [
          Icon(
            _busquedaConIA ? Icons.smart_toy : Icons.search,
            color: _busquedaConIA ? Colors.green : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _busquedaConIA
                  ? '🤖 IA encontró ${products.length} productos'
                  : '🔍 ${response.values.pagination.count} productos encontrados',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: _busquedaConIA ? Colors.green[800] : Colors.blue[800],
              ),
            ),
          ),
          if (!_busquedaConIA)
            Text(
              'Página ${response.values.pagination.currentPage} de ${response.values.pagination.totalPages}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _construirVistaSinResultados() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _busquedaConIA ? Icons.smart_toy_outlined : Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _busquedaConIA && _searchQuery.isNotEmpty
                ? 'La IA no encontró productos para "$_searchQuery"'
                : _searchQuery.isNotEmpty
                ? 'No hay resultados para "$_searchQuery"'
                : 'No hay productos disponibles',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (_searchQuery.isNotEmpty)
            ElevatedButton(
              onPressed: _limpiarBusqueda,
              child: const Text('Ver todos los productos'),
            ),
          const SizedBox(height: 16),
          _construirSugerenciasBusqueda(),
        ],
      ),
    );
  }

  Widget _construirSugerenciasBusqueda() {
    final sugerencias = [
      'Refrigerador',
      'Televisor',
      'Lavadora',
      'Microondas',
      'Licuadora',
      'Computadora',
    ];

    return Column(
      children: [
        const Text(
          'Sugerencias:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sugerencias.map((sugerencia) {
            return ActionChip(
              label: Text(sugerencia),
              onPressed: () {
                _searchController.text = sugerencia;
                _ejecutarBusqueda(sugerencia);
              },
            );
          }).toList(),
        ),
      ],
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
              // Imagen del producto con manejo de errores
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildProductImage(),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
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
              Text(
                '${product.marcaNombre} • ${product.subcategoriaNombre}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
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
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
              const Spacer(),
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

  Widget _buildProductImage() {
    print('=== DEBUG IMAGEN ===');
    print('Producto: ${product.nombre}');
    print('Tiene imagenesData: ${product.imagenesData.isNotEmpty}');

    if (product.imagenesData.isEmpty) {
      print('❌ Lista de imágenes vacía');
      return _buildPlaceholder();
    }

    final primeraImagen = product.imagenesData[0];
    print('Primera imagen: $primeraImagen');
    print('Tipo de primeraImagen: ${primeraImagen.runtimeType}');

    // Verificar que sea un Map
    if (primeraImagen is! Map) {
      print('❌ primeraImagen no es un Map, es: ${primeraImagen.runtimeType}');
      return _buildPlaceholder();
    }

    final imageUrl = primeraImagen['url_imagen'];
    print('URL obtenida: $imageUrl');
    print('Tipo de URL: ${imageUrl.runtimeType}');

    if (imageUrl == null) {
      print('❌ URL es null');
      print('Claves disponibles en primeraImagen: ${primeraImagen.keys}');
      return _buildPlaceholder();
    }

    if (imageUrl.isEmpty) {
      print('❌ URL está vacía');
      return _buildPlaceholder();
    }

    if (imageUrl is! String) {
      print('❌ URL no es String, es: ${imageUrl.runtimeType}');
      return _buildPlaceholder();
    }

    print('✅ URL válida: $imageUrl');
    print('=== FIN DEBUG ===');

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ ERROR loading image for ${product.nombre}');
          print('Error: $error');
          print('URL: $imageUrl');
          return _buildPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            print('✅ SUCCESS loading image for ${product.nombre}');
            return child;
          }
          print('📥 Loading image for ${product.nombre}: $loadingProgress');
          return _buildLoadingPlaceholder();
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image, size: 40, color: Colors.grey),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
