import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventoryapp/repository.dart';
import 'models.dart';
import 'cubits.dart';

class AuthPage extends StatelessWidget {
  AuthPage({Key? key}) : super(key: key);

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
                decoration: const InputDecoration(labelText: 'Contrasenya'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  final authRepo = context.read<AuthRepository>();
                  authRepo.setBearer(bearerCtrl.text);
                  Navigator.pushReplacementNamed(context, "/objects");
                },
                child: const Text("Endavant"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------- ObjectsPage --------
class ObjectsPage extends StatefulWidget {
  const ObjectsPage({Key? key}) : super(key: key);

  @override
  State<ObjectsPage> createState() => _ObjectsPageState();
}

class _ObjectsPageState extends State<ObjectsPage> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 300));

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
      appBar: AppBar(
        title: const Text('Objectes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.storage),
            onPressed: () => Navigator.pushNamed(context, '/containers'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Initialize a new object
          Navigator.pushNamed(context, '/objects/detail');
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              onChanged: _searchControllerChanged,
              decoration: const InputDecoration(
                hintText: 'Buscar...',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => context.read<ObjectsCubit>().loadObjects(),
              child: BlocBuilder<ObjectsCubit, ObjectsState>(
                builder: (context, state) {
                  if (state is ObjectsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ObjectsLoaded) {
                    final list = state.objects;
                    return ListView.builder(
                      itemCount: _searchController.text != ""
                          ? state.objects.length + 1
                          : state.objects.length,
                      itemBuilder: (context, i) {
                        if (i >= state.objects.length) {
                          final newItemName =
                              _searchController.text[0].toUpperCase() +
                                  _searchController.text.substring(1);

                          return Center(
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/objects/detail',
                                      arguments: newItemName);
                                },
                                child: Text("Crear \"$newItemName\"")),
                          );
                        }
                        final obj = list[i];
                        return Dismissible(
                          key: Key(obj.id.toString()),
                          confirmDismiss: (direction) {
                            return showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(
                                    "Segur que vols esborrar ${obj.nombre}?"),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: Text("Cancelar")),
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: Text(
                                        "Esborrar",
                                        style: TextStyle(color: Colors.red),
                                      ))
                                ],
                              ),
                            );
                          },
                          background: Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.red,
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                          onDismissed: (_) {
                            context.read<ObjectsCubit>().deleteObject(obj.id);
                          },
                          child: ListTile(
                            title: Text(obj.nombre),
                            subtitle: Text(
                              obj.almacenadoEn.isEmpty
                                  ? 'LLOC PENDENT D\'ASSIGNAR'
                                  : 'Es troba a: ${obj.almacenadoEn}' +
                                      (obj.cantidad.isNotEmpty
                                          ? '  |  Quantitat: ${obj.cantidad}'
                                          : ''),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(obj.categoria),
                                Text(obj.subcategoria),
                              ],
                            ),
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

  void _searchControllerChanged(String text) {
    _debouncer.run(() {
      context.read<ObjectsCubit>().loadObjects(text);
    });
  }
}

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

// -------- ObjectDetailPage --------
class ObjectDetailPage extends StatefulWidget {
  const ObjectDetailPage({Key? key}) : super(key: key);

  @override
  State<ObjectDetailPage> createState() => _ObjectDetailPageState();
}

class _ObjectDetailPageState extends State<ObjectDetailPage> {
  late ObjectItem _original;
  late ObjectItem _editing;
  late TextEditingController _nombreCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _cantidadCtrl;
  late TextEditingController _categoriaCtrl;
  late TextEditingController _subcatCtrl;
  late TextEditingController _almacenCtrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? name =
          ModalRoute.of(context)!.settings.arguments?.toString();
      if (name != null) _nombreCtrl.text = name;
      setState(() {});
    });

    final cubit = context.read<ObjectDetailCubit>();
    final state = cubit.state;
    if (state is ObjectDetailLoaded) {
      _original = state.object;
    } else {
      _original = ObjectItem(
        id: 0,
        nombre: '',
        descripcion: '',
        cantidad: '',
        categoria: '',
        subcategoria: '',
        almacenadoEn: '',
      );
    }
    _editing = _original.copyWith();
    _initControllers();

    // If loading an existing object, listen for when it's loaded
    cubit.stream.listen((s) {
      if (s is ObjectDetailLoaded) {
        setState(() {
          _original = s.object;
          _editing = _original.copyWith();
          _initControllers();
        });
      }
    });
  }

  void _initControllers() {
    _nombreCtrl = TextEditingController(text: _editing.nombre);
    _descCtrl = TextEditingController(text: _editing.descripcion);
    _cantidadCtrl = TextEditingController(text: _editing.cantidad);
    _categoriaCtrl = TextEditingController(text: _editing.categoria);
    _subcatCtrl = TextEditingController(text: _editing.subcategoria);
    _almacenCtrl = TextEditingController(text: _editing.almacenadoEn);
  }

  bool get _hasChanged {
    return _nombreCtrl.text != _original.nombre ||
        _descCtrl.text != _original.descripcion ||
        _cantidadCtrl.text != _original.cantidad ||
        _categoriaCtrl.text != _original.categoria ||
        _subcatCtrl.text != _original.subcategoria ||
        _almacenCtrl.text != _original.almacenadoEn;
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanged) return true;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Canvis no desats'),
            content: const Text(
                'Hi ha canvis sense desar. Estàs segur que vols sortir?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel·lar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Sortir'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _save() async {
    final cubit = context.read<ObjectsCubit>();
    final updated = ObjectItem(
      id: _original.id,
      nombre: _nombreCtrl.text,
      descripcion: _descCtrl.text,
      cantidad: _cantidadCtrl.text,
      categoria: _categoriaCtrl.text,
      subcategoria: _subcatCtrl.text,
      almacenadoEn: _almacenCtrl.text,
    );
    if (_original.id == 0) {
      await cubit.createObject(updated);
    } else {
      await cubit.updateObject(updated);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_original.id == 0 ? 'Nou Objecte' : 'Editar Objecte'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _hasChanged ? _save : null,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  onChanged: (_) => setState(() {}),
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                TextField(
                  onChanged: (_) => setState(() {}),
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripció'),
                ),
                TextField(
                  onChanged: (_) => setState(() {}),
                  controller: _cantidadCtrl,
                  decoration: const InputDecoration(labelText: 'Quantitat'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  onChanged: (_) => setState(() {}),
                  controller: _categoriaCtrl,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                ),
                TextField(
                  onChanged: (_) => setState(() {}),
                  controller: _subcatCtrl,
                  decoration: const InputDecoration(labelText: 'Subcategoria'),
                ),
                TextField(
                  onChanged: (_) => setState(() {}),
                  controller: _almacenCtrl,
                  decoration: const InputDecoration(labelText: 'Es troba a'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------- ContainersPage --------
class ContainersPage extends StatefulWidget {
  const ContainersPage({Key? key}) : super(key: key);

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
      appBar: AppBar(title: const Text('Contenidors')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/containers/detail');
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar...',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (q) =>
                  context.read<ContainersCubit>().loadContainers(q),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async =>
                  context.read<ContainersCubit>().loadContainers(),
              child: BlocBuilder<ContainersCubit, ContainersState>(
                builder: (context, state) {
                  if (state is ContainersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ContainersLoaded) {
                    return ListView.builder(
                      itemCount: state.containers.length,
                      itemBuilder: (context, i) {
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

// -------- ContainerDetailPage --------
class ContainerDetailPage extends StatefulWidget {
  const ContainerDetailPage({Key? key}) : super(key: key);

  @override
  State<ContainerDetailPage> createState() => _ContainerDetailPageState();
}

class _ContainerDetailPageState extends State<ContainerDetailPage> {
  late ContainerItem _original;
  late ContainerItem _editing;
  late TextEditingController _nombreCtrl;
  late TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ContainerDetailCubit>();
    final state = cubit.state;
    if (state is ContainerDetailLoaded) {
      _original = state.container;
    } else {
      _original = ContainerItem(id: 0, nombre: '', descripcion: '');
    }
    _editing = _original.copyWith();
    _initControllers();
    cubit.stream.listen((s) {
      if (s is ContainerDetailLoaded) {
        setState(() {
          _original = s.container;
          _editing = _original.copyWith();
          _initControllers();
        });
      }
    });
  }

  void _initControllers() {
    _nombreCtrl = TextEditingController(text: _editing.nombre);
    _descCtrl = TextEditingController(text: _editing.descripcion);
  }

  bool get _hasChanged {
    return _nombreCtrl.text != _original.nombre ||
        _descCtrl.text != _original.descripcion;
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanged) return true;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Canvis no desats'),
            content: const Text(
                'Hi ha canvis sense desar. Estàs segur que vols sortir?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel·lar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Sortir'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _save() async {
    final cubit = context.read<ContainersCubit>();
    final updated = ContainerItem(
      id: _original.id,
      nombre: _nombreCtrl.text,
      descripcion: _descCtrl.text,
    );
    if (_original.id == 0) {
      await cubit.createContainer(updated);
    } else {
      await cubit.updateContainer(updated);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title:
              Text(_original.id == 0 ? 'Nou Contenidor' : 'Editar Contenidor'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _hasChanged ? _save : null,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                onChanged: (_) => setState(() {}),
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                onChanged: (_) => setState(() {}),
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Descripció'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
