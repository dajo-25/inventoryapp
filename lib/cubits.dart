import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:inventoryapp/models.dart';
import 'package:inventoryapp/repository.dart';

// -------- Objects List Cubit --------
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
  final ObjectsRepository _repo;
  final AuthRepository _authRepo;
  ObjectsCubit(this._repo, this._authRepo) : super(ObjectsInitial());

  Future<void> loadObjects([String? filter]) async {
    try {
      emit(ObjectsLoading());
      final list =
          await _repo.fetchObjects(query: filter, bearer: _authRepo.getBearer);
      emit(ObjectsLoaded(list));
    } catch (e) {
      emit(ObjectsError(e.toString()));
    }
  }

  Future<void> createObject(ObjectItem obj) async {
    try {
      await _repo.createObject(obj, bearer: _authRepo.getBearer);
      loadObjects();
    } catch (e) {
      emit(ObjectsError(e.toString()));
    }
  }

  Future<void> updateObject(ObjectItem obj) async {
    try {
      await _repo.updateObject(obj, bearer: _authRepo.getBearer);
      loadObjects();
    } catch (e) {
      emit(ObjectsError(e.toString()));
    }
  }

  Future<void> deleteObject(int id) async {
    try {
      await _repo.deleteObject(id, bearer: _authRepo.getBearer);
      loadObjects();
    } catch (e) {
      emit(ObjectsError(e.toString()));
    }
  }
}

// -------- Object Detail Cubit --------
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
  final ObjectsRepository _repo;
  final AuthRepository _authRepo;
  ObjectDetailCubit(this._repo, this._authRepo) : super(ObjectDetailInitial());

  Future<void> loadDetail(int id) async {
    try {
      emit(ObjectDetailLoading());
      if (!isClosed) {
        final obj =
            await _repo.fetchObjectDetail(id, bearer: _authRepo.getBearer);
        emit(ObjectDetailLoaded(obj));
      }
    } catch (e) {
      emit(ObjectDetailError(e.toString()));
    }
  }
}

// -------- Containers List Cubit --------
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
  final ContainersRepository _repo;
  final AuthRepository _authRepo;
  ContainersCubit(this._repo, this._authRepo) : super(ContainersInitial());

  Future<void> loadContainers([String? filter]) async {
    try {
      emit(ContainersLoading());
      final list = await _repo.fetchContainers(
          query: filter, bearer: _authRepo.getBearer);
      emit(ContainersLoaded(list));
    } catch (e) {
      emit(ContainersError(e.toString()));
    }
  }

  Future<void> createContainer(ContainerItem ctr) async {
    try {
      await _repo.createContainer(ctr, bearer: _authRepo.getBearer);
      loadContainers();
    } catch (e) {
      emit(ContainersError(e.toString()));
    }
  }

  Future<void> updateContainer(ContainerItem ctr) async {
    try {
      await _repo.updateContainer(ctr, bearer: _authRepo.getBearer);
      loadContainers();
    } catch (e) {
      emit(ContainersError(e.toString()));
    }
  }

  Future<void> deleteContainer(int id) async {
    try {
      await _repo.deleteContainer(id, bearer: _authRepo.getBearer);
      loadContainers();
    } catch (e) {
      emit(ContainersError(e.toString()));
    }
  }
}

// -------- Container Detail Cubit --------
abstract class ContainerDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ContainerDetailInitial extends ContainerDetailState {}

class ContainerDetailLoading extends ContainerDetailState {}

class ContainerDetailLoaded extends ContainerDetailState {
  final ContainerItem container;
  ContainerDetailLoaded(this.container);
  @override
  List<Object?> get props => [container];
}

class ContainerDetailError extends ContainerDetailState {
  final String message;
  ContainerDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class ContainerDetailCubit extends Cubit<ContainerDetailState> {
  final ContainersRepository _repo;
  final AuthRepository _authRepo;
  ContainerDetailCubit(this._repo, this._authRepo)
      : super(ContainerDetailInitial());

  Future<void> loadDetail(int id) async {
    try {
      emit(ContainerDetailLoading());
      final ctr =
          await _repo.fetchContainerDetail(id, bearer: _authRepo.getBearer);
      emit(ContainerDetailLoaded(ctr));
    } catch (e) {
      emit(ContainerDetailError(e.toString()));
    }
  }
}
