// ignore_for_file: non_constant_identifier_names

// class ProductoModel {
//   final int? id;
//   final int? subcategoria_id;
//   final String? subcategoria_nombre;
//   final int? marca_id;
//   final String? marca_nombre;
//   final int? categoria_id;
//   final String? categoria_nombre;
//   final String? nombre;
//   final String? descripcion;
//   final String? modelo;
//   final double? precio_contado;
//   final double? precio_cuota;
//   final int? stock;
//   final int? garantia_meses;

//   ProductoModel({
//     this.id,
//     this.subcategoria_id,
//     this.subcategoria_nombre,
//     this.marca_id,
//     this.marca_nombre,
//     this.categoria_id,
//     this.categoria_nombre,
//     this.nombre,
//     this.descripcion,
//     this.modelo,
//     this.precio_contado,
//     this.precio_cuota,
//     this.stock,
//     this.garantia_meses,
//   });

//   factory ProductoModel.fromJson(Map<String, dynamic> json) {
//     return ProductoModel(
//       id: json['id'] is int
//           ? json['id'] as int
//           : (json['id'] != null ? int.tryParse('${json['id']}') : null),
//       subcategoria_id: json['subcategoria_id'] is int
//           ? json['subcategoria_id'] as int
//           : (json['subcategoria_id'] != null
//                 ? int.tryParse('${json['subcategoria_id']}')
//                 : null),
//       subcategoria_nombre: json['subcategoria_nombre'] as String?,
//       marca_id: json['marca_id'] is int
//           ? json['marca_id'] as int
//           : (json['marca_id'] != null
//                 ? int.tryParse('${json['marca_id']}')
//                 : null),
//       marca_nombre: json['marca_nombre'] as String?,
//       categoria_id: json['categoria_id'] is int
//           ? json['categoria_id'] as int
//           : (json['categoria_id'] != null
//                 ? int.tryParse('${json['categoria_id']}')
//                 : null),
//       categoria_nombre: json['categoria_nombre'] as String?,
//       nombre: json['nombre'] as String?,
//       descripcion: json['descripcion'] as String?,
//       modelo: json['modelo'] as String?,
//       precio_contado: json['precio_contado'] != null
//           ? (json['precio_contado'] is num
//                 ? (json['precio_contado'] as num).toDouble()
//                 : double.tryParse('${json['precio_contado']}'))
//           : null,
//       precio_cuota: json['precio_cuota'] != null
//           ? (json['precio_cuota'] is num
//                 ? (json['precio_cuota'] as num).toDouble()
//                 : double.tryParse('${json['precio_cuota']}'))
//           : null,
//       stock: json['stock'] is int
//           ? json['stock'] as int
//           : (json['stock'] != null ? int.tryParse('${json['stock']}') : null),
//       garantia_meses: json['garantia_meses'] is int
//           ? json['garantia_meses'] as int
//           : (json['garantia_meses'] != null
//                 ? int.tryParse('${json['garantia_meses']}')
//                 : null),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'subcategoria_id': subcategoria_id,
//     'subcategoria_nombre': subcategoria_nombre,
//     'marca_id': marca_id,
//     'marca_nombre': marca_nombre,
//     'categoria_id': categoria_id,
//     'categoria_nombre': categoria_nombre,
//     'nombre': nombre,
//     'descripcion': descripcion,
//     'modelo': modelo,
//     'precio_contado': precio_contado,
//     'precio_cuota': precio_cuota,
//     'stock': stock,
//     'garantia_meses': garantia_meses,
//   };
// }

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
