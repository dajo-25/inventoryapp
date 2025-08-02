import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventoryapp/api_client.dart';
import 'package:inventoryapp/cubits.dart';
import 'package:inventoryapp/repository.dart';

void main() {
  final apiClient = ApiClient();
  final objectsRepo = ObjectsRepository(apiClient);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ObjectsCubit(objectsRepo)..loadObjects(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ObjectsPage(),
    );
  }
}

class ObjectsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis Objetos')),
      body: Stack(
        children: [
          BlocBuilder<ObjectsCubit, ObjectsState>(
            builder: (_, state) {
              if (state is ObjectsLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is ObjectsLoaded) {
                return ListView.builder(
                  itemCount: state.objects.length,
                  itemBuilder: (_, i) {
                    final obj = state.objects[i];
                    return ListTile(
                      title: Text(obj.nombre),
                      subtitle: Text('Cantidad: \${obj.cantidad}'),
                      onTap: () {
                        // Navegar a detalle usando ObjectDetailCubit
                      },
                    );
                  },
                );
              } else if (state is ObjectsError) {
                return Center(child: Text('Error: ' + state.message));
              }
              return SizedBox.shrink();
            },
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
                onPressed: () {
                  BlocProvider.of<ObjectsCubit>(context).loadObjects();
                },
                icon: Icon(Icons.refresh)),
          )
        ],
      ),
    );
  }
}
