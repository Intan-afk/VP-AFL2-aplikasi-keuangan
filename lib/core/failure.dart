/// Kegagalan yang pesannya sudah siap ditampilkan ke pengguna.
class Failure implements Exception {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}