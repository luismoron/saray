// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Bazar de Saray';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get name => 'Nombre';

  @override
  String get loginButton => 'Iniciar Sesión';

  @override
  String get registerButton => 'Registrarse';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get viewProducts => 'Ver Productos';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get dontHaveAccount => '¿No tienes cuenta? Regístrate';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? Inicia Sesión';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get catalog => 'Catálogo de Productos';

  @override
  String get searchProducts => 'Buscar productos...';

  @override
  String get allCategories => 'Todas';

  @override
  String get productsFound => 'productos encontrados';

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String get stock => 'Stock';

  @override
  String get cart => 'Carrito';
}
