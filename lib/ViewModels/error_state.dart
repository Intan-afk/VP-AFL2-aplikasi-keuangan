sealed class ErrorState {
  const ErrorState();
}

final class NoError extends ErrorState {
  const NoError();

  @override
  bool operator ==(Object other) => other is NoError;

  @override
  int get hashCode => (NoError).hashCode;
}

final class HasError extends ErrorState {
  final String message;

  const HasError(this.message);

  @override
  bool operator ==(Object other) =>
      other is HasError && other.message == message;

  @override
  int get hashCode => message.hashCode;
}
