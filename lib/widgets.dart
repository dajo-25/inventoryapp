// ==================== widgets.dart ====================
import 'dart:async';

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
                  obscureText: true,
                  controller: bearerCtrl,
                  decoration: const InputDecoration(labelText: 'Contrasenya')),
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
  final _debouncer = Debouncer(delay: Duration(milliseconds: 300));

  @override
  void initState() {
    super.initState();
    context.read<ObjectsCubit>().loadObjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showObjectForm(context),
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Objectes'),
        actions: [
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
              onChanged: _searchControllerChanged,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                suffixIcon: Icon(Icons.search),
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
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: _searchController.text != ""
                                ? state.objects.length + 1
                                : state.objects.length,
                            itemBuilder: (_, i) {
                              if (i >= state.objects.length) {
                                final newItemName =
                                    _searchController.text[0].toUpperCase() +
                                        _searchController.text.substring(1);

                                return Center(
                                  child: ElevatedButton(
                                      onPressed: () {},
                                      child: Text("Crear \"$newItemName\"")),
                                );
                              }

                              final obj = state.objects[i];
                              return Dismissible(
                                key: Key(obj.id.toString()),
                                background: Container(
                                  padding: EdgeInsets.all(16),
                                  color: Colors.red,
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: const Icon(Icons.delete,
                                          color: Colors.white)),
                                ),
                                onDismissed: (_) {
                                  context
                                      .read<ObjectsCubit>()
                                      .deleteObject(obj.id);
                                },
                                child: ListTile(
                                  title: Text(obj.nombre),
                                  subtitle: Builder(builder: (context) {
                                    String subtitulo = "";

                                    if (obj.almacenadoEn == "") {
                                      subtitulo = "LLOC PENDENT D'ASSIGNAR";
                                    } else {
                                      subtitulo =
                                          "Es troba a: ${obj.almacenadoEn}";
                                      if (obj.cantidad != "") {
                                        subtitulo +=
                                            "  |  Quantitat: ${obj.cantidad}";
                                      }
                                    }

                                    return Text(subtitulo);
                                  }),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(obj.categoria),
                                      Text(obj.subcategoria)
                                    ],
                                  ),
                                  onTap: () {
                                    context
                                        .read<ObjectDetailCubit>()
                                        .loadDetail(obj.id);
                                    Navigator.pushNamed(
                                        context, '/objects/detail');
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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

  void _searchControllerChanged(String text) {
    _debouncer.run(() async {
      context.read<ObjectsCubit>().loadObjects(_searchController.text);
    });
  }
}

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  /// Crida [action] després de [delay] des de l'última invocació.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancel·la qualsevol invocació pendent.
  void dispose() {
    _timer?.cancel();
  }
}

Future<void> _showObjectForm(BuildContext context, {ObjectItem? obj}) async {
  final isNew = obj == null;
  final nombreCtrl = TextEditingController(text: obj?.nombre);
  final descCtrl = TextEditingController(text: obj?.descripcion);
  final cantidadCtrl = TextEditingController(text: obj?.cantidad.toString());
  final categoriaCtrl = TextEditingController(text: obj?.categoria);
  final subcatCtrl = TextEditingController(text: obj?.subcategoria);
  final almacenCtrl = TextEditingController(text: obj?.almacenadoEn);

  await showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      insetPadding: EdgeInsets.all(8),
      title: Text(isNew ? 'Nou objecte' : 'Editar objecte'),
      content: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: 1000,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nom')),
              TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripció')),
              TextField(
                controller: cantidadCtrl,
                decoration: const InputDecoration(labelText: 'Quantitat'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                  controller: categoriaCtrl,
                  decoration: const InputDecoration(labelText: 'Categoria')),
              TextField(
                  controller: subcatCtrl,
                  decoration: const InputDecoration(labelText: 'Subcategoria')),
              TextField(
                  controller: almacenCtrl,
                  decoration: const InputDecoration(labelText: 'Es troba a')),
            ],
          ),
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
              cantidad: cantidadCtrl.text,
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
        title: const Text("Detall d'Objecte"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final state = context.read<ObjectDetailCubit>().state;
              if (state is ObjectDetailLoaded) {
                await _showObjectForm(context, obj: state.object);
                Navigator.pop(context);
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
                  Text('Nom: ${obj.nombre}',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  Text('Descripció: ${obj.descripcion}'),
                  const SizedBox(height: 8),
                  Text('Quantitat: ${obj.cantidad}'),
                  const SizedBox(height: 8),
                  Text('Categoria: ${obj.categoria}'),
                  const SizedBox(height: 8),
                  Text('Subcategoria: ${obj.subcategoria}'),
                  const SizedBox(height: 8),
                  Text('Es troba a: ${obj.almacenadoEn}'),
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
        title: const Text('Contenidors'),
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
      title: Text(isNew ? 'Nou contenidor' : 'Editar contenidor'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nom')),
            TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descripció')),
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
        title: const Text('Detall del contenidor'),
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
                  Text('Nom: ${ctr.nombre}',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  Text('Descripció: ${ctr.descripcion}'),
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
