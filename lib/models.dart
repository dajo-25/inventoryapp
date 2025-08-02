class ObjectItem {
  final int id;
  final String nombre;
  final String descripcion;
  final int cantidad;
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
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      cantidad: json['cantidad'],
      categoria: json['categoria'],
      subcategoria: json['subcategoria'],
      almacenadoEn: json['almacenado_en'],
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
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}
