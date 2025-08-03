class ObjectItem {
  final int id;
  final String nombre;
  final String descripcion;
  final String cantidad;
  final String categoria;
  final String subcategoria;
  final String almacenadoEn;

  ObjectItem({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.cantidad,
    required this.categoria,
    required this.subcategoria,
    required this.almacenadoEn,
  });

  factory ObjectItem.fromJson(Map<String, dynamic> json) {
    return ObjectItem(
      id: int.tryParse(json["id"].toString()) ?? 0,
      nombre: json['nombre'].toString(),
      descripcion: json['descripcion'].toString(),
      cantidad: json['cantidad'].toString(),
      categoria: json['categoria'].toString(),
      subcategoria: json['subcategoria'].toString(),
      almacenadoEn: json['almacenado_en'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'cantidad': cantidad,
      'categoria': categoria,
      'subcategoria': subcategoria,
      'almacenado_en': almacenadoEn,
    };
  }
}

class ContainerItem {
  final int id;
  final String nombre;
  final String descripcion;

  ContainerItem({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  factory ContainerItem.fromJson(Map<String, dynamic> json) {
    return ContainerItem(
      id: int.tryParse(json['id']) ?? 0,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}
