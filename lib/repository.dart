import 'package:inventoryapp/api_client.dart';
import 'package:inventoryapp/models.dart';

class ObjectsRepository {
  final ApiClient api;
  ObjectsRepository(this.api);

  Future<List<ObjectItem>> fetchObjects({String? query}) async {
    final params = query != null ? {'q': query} : null;
    final res = await api.get('/api/objects', params: params);
    final data = res.data as List;
    return data
        .map((e) => ObjectItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ObjectItem> fetchObjectDetail(int id) async {
    final res = await api.get('/api/objects/\$id');
    return ObjectItem.fromJson(res.data as Map<String, dynamic>);
  }

  Future<int> createObject(ObjectItem obj) async {
    final res = await api.post('/api/objects', obj.toJson());
    return (res.data as Map<String, dynamic>)['id'];
  }

  Future<void> updateObject(ObjectItem obj) async {
    await api.put('/api/objects/\${obj.id}', obj.toJson());
  }

  Future<void> deleteObject(int id) async {
    await api.delete('/api/objects/\$id');
  }
}

class ContainersRepository {
  final ApiClient api;
  ContainersRepository(this.api);

  Future<List<ContainerItem>> fetchContainers({String? query}) async {
    final params = query != null ? {'q': query} : null;
    final res = await api.get('/api/containers', params: params);
    final data = res.data as List;
    return data
        .map((e) => ContainerItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Métodos de detalle, creación, actualización y borrado análogos...
}
