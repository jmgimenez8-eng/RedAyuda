import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';

class RecuperarPassword {
  final AuthRepository repository;

  RecuperarPassword(this.repository);

  Future<Either<String, void>> call({required String email}) {
    return repository.recuperarPassword(email: email);
  }
}