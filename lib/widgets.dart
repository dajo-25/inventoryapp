// ==================== widgets.dart ====================
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventoryapp/repository.dart';
import 'models.dart';
import 'cubits.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  final bearerCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: bearerCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre')),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    final authRepo = context.read<AuthRepository>();
                    authRepo.setBearer(bearerCtrl.text);
                    Navigator.pushReplacementNamed(context, "/objects");
                  },
                  child: Text("Endavant")),
            ],
          ),
        ),
      ),
    );
  }
}

// -------- ObjectsPage --------
class ObjectsPage extends StatefulWidget {
  const ObjectsPage({super.key});

  @override
  State<ObjectsPage> createState() => _ObjectsPageState();
}

class _ObjectsPageState extends State<ObjectsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ObjectsCubit>().loadObjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showObjectForm(context),
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Mis Objetos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ObjectsCubit>().loadObjects();
            },
          ),
          IconButton(
            icon: const Icon(Icons.storage),
            onPressed: () => Navigator.pushNamed(context, '/containers'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    context
                        .read<ObjectsCubit>()
                        .loadObjects(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => context.read<ObjectsCubit>().loadObjects(),
              child: BlocBuilder<ObjectsCubit, ObjectsState>(
                builder: (_, state) {
                  if (state is ObjectsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ObjectsLoaded) {
                    return ListView.builder(
                      itemCount: state.objects.length,
                      itemBuilder: (_, i) {
                        final obj = state.objects[i];
                        return Dismissible(
                          key: Key(obj.id.toString()),
                          background: Container(
                            color: Colors.red,
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            context.read<ObjectsCubit>().deleteObject(obj.id);
                          },
                          child: ListTile(
                            title: Text(obj.nombre),
                            subtitle: Text('Cantidad: ${obj.cantidad}'),
                            onTap: () {
                              context
                                  .read<ObjectDetailCubit>()
                                  .loadDetail(obj.id);
                              Navigator.pushNamed(context, '/objects/detail');
                            },
                          ),
                        );
                      },
                    );
                  } else if (state is ObjectsError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showObjectForm(BuildContext context, {ObjectItem? obj}) {
  final isNew = obj == null;
  final nombreCtrl = TextEditingController(text: obj?.nombre);
  final descCtrl = TextEditingController(text: obj?.descripcion);
  final cantidadCtrl = TextEditingController(text: obj?.cantidad.toString());
  final categoriaCtrl = TextEditingController(text: obj?.categoria);
  final subcatCtrl = TextEditingController(text: obj?.subcategoria);
  final almacenCtrl = TextEditingController(text: obj?.almacenadoEn);

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(isNew ? 'Nuevo Objeto' : 'Editar Objeto'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción')),
            TextField(
              controller: cantidadCtrl,
              decoration: const InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
            ),
            TextField(
                controller: categoriaCtrl,
                decoration: const InputDecoration(labelText: 'Categoría')),
            TextField(
                controller: subcatCtrl,
                decoration: const InputDecoration(labelText: 'Subcategoría')),
            TextField(
                controller: almacenCtrl,
                decoration: const InputDecoration(labelText: 'Almacenado en')),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            final newObj = ObjectItem(
              id: obj?.id ?? 0,
              nombre: nombreCtrl.text,
              descripcion: descCtrl.text,
              cantidad: int.tryParse(cantidadCtrl.text) ?? 0,
              categoria: categoriaCtrl.text,
              subcategoria: subcatCtrl.text,
              almacenadoEn: almacenCtrl.text,
            );
            final cubit = context.read<ObjectsCubit>();
            if (isNew) {
              await cubit.createObject(newObj);
            } else {
              await cubit.updateObject(newObj);
            }
            Navigator.pop(dialogContext);
          },
          child: Text(isNew ? 'Crear' : 'Guardar'),
        ),
      ],
    ),
  );
}

// -------- ObjectDetailPage --------
class ObjectDetailPage extends StatelessWidget {
  const ObjectDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Objeto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final state = context.read<ObjectDetailCubit>().state;
              if (state is ObjectDetailLoaded) {
                _showObjectForm(context, obj: state.object);
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<ObjectDetailCubit, ObjectDetailState>(
        builder: (_, state) {
          if (state is ObjectDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ObjectDetailLoaded) {
            final obj = state.object;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre: ${obj.nombre}',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  Text('Descripción: ${obj.descripcion}'),
                  const SizedBox(height: 8),
                  Text('Cantidad: ${obj.cantidad}'),
                  const SizedBox(height: 8),
                  Text('Categoría: ${obj.categoria}'),
                  const SizedBox(height: 8),
                  Text('Subcategoría: ${obj.subcategoria}'),
                  const SizedBox(height: 8),
                  Text('Almacenado en: ${obj.almacenadoEn}'),
                ],
              ),
            );
          } else if (state is ObjectDetailError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// -------- ContainersPage --------

class ContainersPage extends StatefulWidget {
  const ContainersPage({super.key});

  @override
  State<ContainersPage> createState() => _ContainersPageState();
}

class _ContainersPageState extends State<ContainersPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ContainersCubit>().loadContainers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Contenedores'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContainerForm(context),
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    context
                        .read<ContainersCubit>()
                        .loadContainers(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async =>
                  context.read<ContainersCubit>().loadContainers(),
              child: BlocBuilder<ContainersCubit, ContainersState>(
                builder: (_, state) {
                  if (state is ContainersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ContainersLoaded) {
                    return ListView.builder(
                      itemCount: state.containers.length,
                      itemBuilder: (_, i) {
                        final ctr = state.containers[i];
                        return Dismissible(
                          key: Key(ctr.id.toString()),
                          background: Container(
                            color: Colors.red,
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            context
                                .read<ContainersCubit>()
                                .deleteContainer(ctr.id);
                          },
                          child: ListTile(
                            title: Text(ctr.nombre),
                            subtitle: Text(ctr.descripcion),
                            onTap: () {
                              context
                                  .read<ContainerDetailCubit>()
                                  .loadDetail(ctr.id);
                              Navigator.pushNamed(
                                  context, '/containers/detail');
                            },
                          ),
                        );
                      },
                    );
                  } else if (state is ContainersError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showContainerForm(BuildContext context, {ContainerItem? ctr}) {
  final isNew = ctr == null;
  final nombreCtrl = TextEditingController(text: ctr?.nombre);
  final descCtrl = TextEditingController(text: ctr?.descripcion);

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(isNew ? 'Nuevo Contenedor' : 'Editar Contenedor'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción')),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            final newCtr = ContainerItem(
              id: ctr?.id ?? 0,
              nombre: nombreCtrl.text,
              descripcion: descCtrl.text,
            );
            final cubit = context.read<ContainersCubit>();
            if (isNew) {
              await cubit.createContainer(newCtr);
            } else {
              await cubit.updateContainer(newCtr);
            }
            Navigator.pop(dialogContext);
          },
          child: Text(isNew ? 'Crear' : 'Guardar'),
        ),
      ],
    ),
  );
}

// -------- ContainerDetailPage --------
class ContainerDetailPage extends StatelessWidget {
  const ContainerDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Contenedor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final state = context.read<ContainerDetailCubit>().state;
              if (state is ContainerDetailLoaded) {
                Navigator.pop(context);

                _showContainerForm(context, ctr: state.container);
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<ContainerDetailCubit, ContainerDetailState>(
        builder: (_, state) {
          if (state is ContainerDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ContainerDetailLoaded) {
            final ctr = state.container;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre: ${ctr.nombre}',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  Text('Descripción: ${ctr.descripcion}'),
                ],
              ),
            );
          } else if (state is ContainerDetailError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
