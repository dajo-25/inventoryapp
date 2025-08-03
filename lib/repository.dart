import 'package:inventoryapp/api_client.dart';
import 'package:inventoryapp/models.dart';

class ObjectsRepository {
  final ApiClient api;
  ObjectsRepository(this.api);

  Future<List<ObjectItem>> fetchObjects(
      {String? query, required String bearer}) async {
    final params = query != null ? {'q': query} : null;
    final res = await api.get('/api/objects', params: params, bearer: bearer);
    final data = res.data as List;
    return data
        .map((e) => ObjectItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ObjectItem> fetchObjectDetail(int id, {required String bearer}) async {
    final res = await api.get('/api/objects/$id', bearer: bearer);
    return ObjectItem.fromJson(res.data as Map<String, dynamic>);
  }

  Future<int> createObject(ObjectItem obj, {required String bearer}) async {
    final res = await api.post('/api/objects', obj.toJson(), bearer: bearer);
    return (res.data as Map<String, dynamic>)['id'];
  }

  Future<void> updateObject(ObjectItem obj, {required String bearer}) async {
    await api.put('/api/objects/${obj.id}', obj.toJson(), bearer: bearer);
  }

  Future<void> deleteObject(int id, {required String bearer}) async {
    await api.delete('/api/objects/$id', bearer: bearer);
  }
}

class ContainersRepository {
  final ApiClient api;
  ContainersRepository(this.api);

  Future<List<ContainerItem>> fetchContainers(
      {String? query, required String bearer}) async {
    final params = query != null ? {'q': query} : null;
    final res =
        await api.get('/api/containers', params: params, bearer: bearer);
    final data = res.data as List;
    return data
        .map((e) => ContainerItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ContainerItem> fetchContainerDetail(int id,
      {required String bearer}) async {
    final res = await api.get('/api/containers/$id', bearer: bearer);
    return ContainerItem.fromJson(res.data as Map<String, dynamic>);
  }

  Future<int> createContainer(ContainerItem ctr,
      {required String bearer}) async {
    final res = await api.post('/api/containers', ctr.toJson(), bearer: bearer);
    return (res.data as Map<String, dynamic>)['id'];
  }

  Future<void> updateContainer(ContainerItem ctr,
      {required String bearer}) async {
    await api.put('/api/containers/${ctr.id}', ctr.toJson(), bearer: bearer);
  }

  Future<void> deleteContainer(int id, {required String bearer}) async {
    await api.delete('/api/containers/$id', bearer: bearer);
  }
}

class AuthRepository {
  String? _bearer;
  AuthRepository();

  void setBearer(String bearer) {
    _bearer = bearer;
  }

  String get getBearer => _bearer ?? "holii<3";
}
