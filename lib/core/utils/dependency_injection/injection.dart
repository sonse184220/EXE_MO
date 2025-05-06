import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/data/repositories/auth_repository.dart';
import 'package:inner_child_app/domain/repositories/i_auth_repository.dart';
import 'package:inner_child_app/domain/usecases/register_usecase.dart';
import '../../../data/datasources/remote/authentication/authentication_api_service.dart';

// API Service Provider
final authApiServiceProvider = Provider((ref) => AuthApiService());

// Repository Provider
final authRepositoryProvider = Provider<IAuthRepository>(
      (ref) => AuthRepository(ref.read(authApiServiceProvider)),
);

// UseCase Provider
final registerUseCaseProvider = Provider(
      (ref) => RegisterUseCase(ref.read(authRepositoryProvider)),
);