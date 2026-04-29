import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pro.stations.wetaxi.ma/core/di/injection.dart';
import 'package:pro.stations.wetaxi.ma/core/l10n/app_localizations.dart';
import 'package:pro.stations.wetaxi.ma/core/l10n/locale_notifier.dart';
import 'package:pro.stations.wetaxi.ma/core/router/router.dart';
import 'package:pro.stations.wetaxi.ma/core/storage/local_storage.dart';
import 'package:pro.stations.wetaxi.ma/core/theme/app_theme.dart';
import 'package:pro.stations.wetaxi.ma/features/auth/domain/repositories/auth_repository.dart';
import 'package:pro.stations.wetaxi.ma/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await setupDependencies();

  // Only check token existence here — AuthCheckEvent loads the full profile
  String initialLocation = '/login';
  try {
    final isAuth = await sl<AuthRepository>().isAuthenticated();
    if (isAuth) initialLocation = '/home';
  } catch (_) {
    await sl<LocalStorage>().clear();
  }

  sl<AuthBloc>().add(AuthCheckEvent());

  runApp(TaxiDriverApp(initialLocation: initialLocation));
}

class TaxiDriverApp extends StatefulWidget {
  final String initialLocation;
  const TaxiDriverApp({super.key, required this.initialLocation});

  @override
  State<TaxiDriverApp> createState() => _TaxiDriverAppState();
}

class _TaxiDriverAppState extends State<TaxiDriverApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Create router once — never recreated on locale or state changes
    _router = createRouter(widget.initialLocation);
    Future.microtask(() async {
      await WakelockPlus.enable();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthBloc>(),
      child: ValueListenableBuilder<Locale>(
        valueListenable: sl<LocaleNotifier>(),
        builder: (_, locale, __) => MaterialApp.router(
          title: 'wetaxi.station',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _router,
        ),
      ),
    );
  }
}
