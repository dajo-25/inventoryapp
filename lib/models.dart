import 'package:equatable/equatable.dart';

class ObjectItem extends Equatable {
  final int id;
  final String nombre;
  final String descripcion;
  final String cantidad;
  final String categoria;
  final String subcategoria;
  final String almacenadoEn;

  const ObjectItem({
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

  ObjectItem copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? cantidad,
    String? categoria,
    String? subcategoria,
    String? almacenadoEn,
  }) {
    return ObjectItem(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      cantidad: cantidad ?? this.cantidad,
      categoria: categoria ?? this.categoria,
      subcategoria: subcategoria ?? this.subcategoria,
      almacenadoEn: almacenadoEn ?? this.almacenadoEn,
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

  @override
  List<Object?> get props => [
        nombre,
        descripcion,
        cantidad,
        categoria,
        subcategoria,
        almacenadoEn,
        id
      ];
}

class ContainerItem extends Equatable {
  final int id;
  final String nombre;
  final String descripcion;

  const ContainerItem({
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

  ContainerItem copyWith({int? id, String? nombre, String? descripcion}) {
    return ContainerItem(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }

  @override
  List<Object?> get props => [nombre, descripcion, id];
}
