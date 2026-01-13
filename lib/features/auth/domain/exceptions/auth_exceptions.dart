/// Custom authentication exceptions
abstract class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when credentials are invalid
class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException({String message = 'Email ou mot de passe invalide'})
      : super(message);
}

/// Exception thrown when email already exists
class EmailAlreadyExistsException extends AuthException {
  EmailAlreadyExistsException({String message = 'Cet email est déjà utilisé'})
      : super(message);
}

/// Exception thrown when validation fails
class ValidationException extends AuthException {
  ValidationException(String message) : super(message);
}

/// Exception thrown when network error occurs
class NetworkException extends AuthException {
  NetworkException({String message = 'Erreur réseau'}) : super(message);
}

/// Generic authentication error
class AuthErrorException extends AuthException {
  AuthErrorException(String message) : super(message);
}
