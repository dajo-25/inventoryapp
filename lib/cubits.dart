import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:inventoryapp/models.dart';
import 'package:inventoryapp/repository.dart';

// States for objects list
abstract class ObjectsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ObjectsInitial extends ObjectsState {}

class ObjectsLoading extends ObjectsState {}

class ObjectsLoaded extends ObjectsState {
  final List<ObjectItem> objects;
  ObjectsLoaded(this.objects);
  @override
  List<Object?> get props => [objects];
}

class ObjectsError extends ObjectsState {
  final String message;
  ObjectsError(this.message);
  @override
  List<Object?> get props => [message];
}

class ObjectsCubit extends Cubit<ObjectsState> {
  final ObjectsRepository repo;
  ObjectsCubit(this.repo) : super(ObjectsInitial());

  Future<void> loadObjects([String? filter]) async {
    try {
      emit(ObjectsLoading());
      final list = await repo.fetchObjects(query: filter);
      emit(ObjectsLoaded(list));
    } catch (e) {
      emit(ObjectsError(e.toString()));
    }
  }
}

// States & Cubit for object detail
abstract class ObjectDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ObjectDetailInitial extends ObjectDetailState {}

class ObjectDetailLoading extends ObjectDetailState {}

class ObjectDetailLoaded extends ObjectDetailState {
  final ObjectItem object;
  ObjectDetailLoaded(this.object);
  @override
  List<Object?> get props => [object];
}

class ObjectDetailError extends ObjectDetailState {
  final String message;
  ObjectDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class ObjectDetailCubit extends Cubit<ObjectDetailState> {
  final ObjectsRepository repo;
  ObjectDetailCubit(this.repo) : super(ObjectDetailInitial());

  Future<void> loadDetail(int id) async {
    try {
      emit(ObjectDetailLoading());
      final obj = await repo.fetchObjectDetail(id);
      emit(ObjectDetailLoaded(obj));
    } catch (e) {
      emit(ObjectDetailError(e.toString()));
    }
  }
}

// Similar Cubit for Containers
abstract class ContainersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ContainersInitial extends ContainersState {}

class ContainersLoading extends ContainersState {}

class ContainersLoaded extends ContainersState {
  final List<ContainerItem> containers;
  ContainersLoaded(this.containers);
  @override
  List<Object?> get props => [containers];
}

class ContainersError extends ContainersState {
  final String message;
  ContainersError(this.message);
  @override
  List<Object?> get props => [message];
}

class ContainersCubit extends Cubit<ContainersState> {
  final ContainersRepository repo;
  ContainersCubit(this.repo) : super(ContainersInitial());

  Future<void> loadContainers([String? filter]) async {
    try {
      emit(ContainersLoading());
      final list = await repo.fetchContainers(query: filter);
      emit(ContainersLoaded(list));
    } catch (e) {
      emit(ContainersError(e.toString()));
    }
  }
}
