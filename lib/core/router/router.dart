import 'package:go_router/go_router.dart';
import 'package:pro.stations.wetaxi.ma/core/shell/main_shell.dart';
import 'package:pro.stations.wetaxi.ma/features/auth/presentation/pages/login_page.dart';
import 'package:pro.stations.wetaxi.ma/features/home/presentation/pages/home_page.dart';
import 'package:pro.stations.wetaxi.ma/features/orders/presentation/pages/orders_page.dart';
import 'package:pro.stations.wetaxi.ma/features/profile/presentation/pages/profile_page.dart';
import 'package:pro.stations.wetaxi.ma/features/settings/presentation/pages/settings_page.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/presentation/pages/nfc_manager_1.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/presentation/pages/recharge_page.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/presentation/pages/wallet_page.dart';

GoRouter createRouter(String initialLocation) => GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/login',
          builder: (c, s) => const LoginPage(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(path: '/home', builder: (c, s) => const HomePage()),
            GoRoute(path: '/wallet', builder: (c, s) => const WalletPage()),
            GoRoute(path: '/orders', builder: (c, s) => const OrdersPage()),
            GoRoute(path: '/recharge', builder: (c, s) => const RechargePage()),
            GoRoute(path: '/recharge1', builder: (c, s) => const NfcScanScreen()),
            GoRoute(path: '/profile', builder: (c, s) => const ProfilePage()),
            GoRoute(path: '/settings', builder: (c, s) => const SettingsPage()),
          ],
        ),
      ],
    );
