// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventoryapp/widgets.dart';
import 'api_client.dart';
import 'repository.dart';
import 'cubits.dart';

void main() {
  final apiClient = ApiClient();
  final objectsRepo = ObjectsRepository(apiClient);
  final containersRepo = ContainersRepository(apiClient);
  final authRepo = AuthRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ObjectsRepository>.value(value: objectsRepo),
        RepositoryProvider<ContainersRepository>.value(value: containersRepo),
        RepositoryProvider<AuthRepository>.value(value: authRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) => ObjectsCubit(
                ctx.read<ObjectsRepository>(), ctx.read<AuthRepository>())
              ..loadObjects(),
          ),
          BlocProvider(
            create: (ctx) => ObjectDetailCubit(
                ctx.read<ObjectsRepository>(), ctx.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (ctx) => ContainersCubit(
                ctx.read<ContainersRepository>(), ctx.read<AuthRepository>())
              ..loadContainers(),
          ),
          BlocProvider(
            create: (ctx) => ContainerDetailCubit(
                ctx.read<ContainersRepository>(), ctx.read<AuthRepository>()),
          )
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/objects',
      routes: {
        '/objects': (_) => ObjectsPage(),
        '/objects/detail': (_) => ObjectDetailPage(),
        '/containers': (_) => ContainersPage(),
        '/containers/detail': (_) => ContainerDetailPage(),
      },
    );
  }
}
