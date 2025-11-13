// models/product_response.dart
class ProductoResponse {
  final int status;
  final int error;
  final String message;
  final ProductoValues values;

  ProductoResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.values,
  });

  factory ProductoResponse.fromJson(Map<String, dynamic> json) {
    return ProductoResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      values: ProductoValues.fromJson(json['values']),
    );
  }
}

class ProductoValues {
  final List<Producto> productos;
  final Pagination pagination;
  final FiltersApplied filtersApplied;

  ProductoValues({
    required this.productos,
    required this.pagination,
    required this.filtersApplied,
  });

  factory ProductoValues.fromJson(Map<String, dynamic> json) {
    return ProductoValues(
      productos: (json['productos'] as List)
          .map((product) => Producto.fromJson(product))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
      filtersApplied: FiltersApplied.fromJson(json['filters_applied']),
    );
  }
}

class Producto {
  final int id;
  final int subcategoriaId;
  final int marcaId;
  final String nombre;
  final String descripcion;
  final String modelo;
  final double precioContado;
  final double precioCuota;
  final int stock;
  final int garantiaMeses;
  final bool isActive;
  final List<dynamic> imagenesData;
  final String categoriaNombre;
  final String marcaNombre;
  final String subcategoriaNombre;
  final int categoriaId;

  Producto({
    required this.id,
    required this.subcategoriaId,
    required this.marcaId,
    required this.nombre,
    required this.descripcion,
    required this.modelo,
    required this.precioContado,
    required this.precioCuota,
    required this.stock,
    required this.garantiaMeses,
    required this.isActive,
    required this.imagenesData,
    required this.categoriaNombre,
    required this.marcaNombre,
    required this.subcategoriaNombre,
    required this.categoriaId,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      subcategoriaId: json['subcategoria_id'],
      marcaId: json['marca_id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      modelo: json['modelo'],
      precioContado: double.parse(json['precio_contado'].toString()),
      precioCuota: double.parse(json['precio_cuota'].toString()),
      stock: json['stock'],
      garantiaMeses: json['garantia_meses'],
      isActive: json['is_active'],
      imagenesData: json['imagenes_data'] ?? [],
      categoriaNombre: json['categoria_nombre'],
      marcaNombre: json['marca_nombre'],
      subcategoriaNombre: json['subcategoria_nombre'],
      categoriaId: json['categoria_id'],
    );
  }
}

class Pagination {
  final int count;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;
  final int? nextPage;
  final int? previousPage;

  Pagination({
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
    required this.nextPage,
    required this.previousPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      count: json['count'],
      totalPages: json['total_pages'],
      currentPage: json['current_page'],
      pageSize: json['page_size'],
      hasNext: json['has_next'],
      hasPrevious: json['has_previous'],
      nextPage: json['next_page'],
      previousPage: json['previous_page'],
    );
  }
}

class FiltersApplied {
  final String search;
  final dynamic categoria;
  final dynamic subcategoria;
  final dynamic marca;
  final dynamic minPrecio;
  final dynamic maxPrecio;
  final dynamic enStock;
  final bool activos;

  FiltersApplied({
    required this.search,
    required this.categoria,
    required this.subcategoria,
    required this.marca,
    required this.minPrecio,
    required this.maxPrecio,
    required this.enStock,
    required this.activos,
  });

  factory FiltersApplied.fromJson(Map<String, dynamic> json) {
    return FiltersApplied(
      search: json['search'] ?? '',
      categoria: json['categoria'],
      subcategoria: json['subcategoria'],
      marca: json['marca'],
      minPrecio: json['min_precio'],
      maxPrecio: json['max_precio'],
      enStock: json['en_stock'],
      activos: json['activos'],
    );
  }
}

// models/respuesta_detalle_producto.dart
class DetalleProductoResponse {
  final int status;
  final int error;
  final String mensaje;
  final DetalleProductoValues valores;

  DetalleProductoResponse({
    required this.status,
    required this.error,
    required this.mensaje,
    required this.valores,
  });

  factory DetalleProductoResponse.fromJson(Map<String, dynamic> json) {
    return DetalleProductoResponse(
      status: json['status'],
      error: json['error'],
      mensaje: json['message'],
      valores: DetalleProductoValues.fromJson(json['values']),
    );
  }
}

class DetalleProductoValues {
  final Producto producto;

  DetalleProductoValues({required this.producto});

  factory DetalleProductoValues.fromJson(Map<String, dynamic> json) {
    return DetalleProductoValues(producto: Producto.fromJson(json['producto']));
  }
}

// models/producto/producto_model.dart

class ProductoListResponse {
  final int status;
  final int error;
  final String message;
  final ProductoListValues valores;

  ProductoListResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.valores,
  });

  factory ProductoListResponse.fromJson(Map<String, dynamic> json) {
    return ProductoListResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      valores: ProductoListValues.fromJson(json['values']),
    );
  }
}

class ProductoListValues {
  final List<Producto> productos;
  final ProductoPagination pagination;
  final ProductoFiltersApplied filtersApplied;

  ProductoListValues({
    required this.productos,
    required this.pagination,
    required this.filtersApplied,
  });

  factory ProductoListValues.fromJson(Map<String, dynamic> json) {
    return ProductoListValues(
      productos: (json['productos'] as List)
          .map((producto) => Producto.fromJson(producto))
          .toList(),
      pagination: ProductoPagination.fromJson(json['pagination']),
      filtersApplied: ProductoFiltersApplied.fromJson(json['filters_applied']),
    );
  }
}

class ProductoPagination {
  final int count;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;
  final int? nextPage;
  final int? previousPage;

  ProductoPagination({
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
    this.nextPage,
    this.previousPage,
  });

  factory ProductoPagination.fromJson(Map<String, dynamic> json) {
    return ProductoPagination(
      count: json['count'],
      totalPages: json['total_pages'],
      currentPage: json['current_page'],
      pageSize: json['page_size'],
      hasNext: json['has_next'],
      hasPrevious: json['has_previous'],
      nextPage: json['next_page'],
      previousPage: json['previous_page'],
    );
  }
}

class ProductoFiltersApplied {
  final String? search;
  final String? categoria;
  final String? subcategoria;
  final String? marca;
  final double? minPrecio;
  final double? maxPrecio;
  final String? enStock;
  final bool activos;

  ProductoFiltersApplied({
    this.search,
    this.categoria,
    this.subcategoria,
    this.marca,
    this.minPrecio,
    this.maxPrecio,
    this.enStock,
    required this.activos,
  });

  factory ProductoFiltersApplied.fromJson(Map<String, dynamic> json) {
    return ProductoFiltersApplied(
      search: json['search'],
      categoria: json['categoria'],
      subcategoria: json['subcategoria'],
      marca: json['marca'],
      minPrecio: json['min_precio'] != null
          ? double.parse(json['min_precio'].toString())
          : null,
      maxPrecio: json['max_precio'] != null
          ? double.parse(json['max_precio'].toString())
          : null,
      enStock: json['en_stock'],
      activos: json['activos'],
    );
  }
}
