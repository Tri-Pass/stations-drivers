import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pro.stations.wetaxi.ma/core/di/injection.dart';
import 'package:pro.stations.wetaxi.ma/core/l10n/app_localizations.dart';
import 'package:pro.stations.wetaxi.ma/core/theme/app_theme.dart';
import 'package:pro.stations.wetaxi.ma/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pro.stations.wetaxi.ma/features/home/presentation/bloc/home_bloc.dart';
import 'package:pro.stations.wetaxi.ma/features/orders/presentation/bloc/order_bloc.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/presentation/bloc/wallet_bloc.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final HomeBloc _homeBloc;
  late final WalletBloc _walletBloc;
  late final OrderBloc _orderBloc;

  @override
  void initState() {
    super.initState();
    // Blocs created once per session — fire initial loads here only
    _homeBloc = sl<HomeBloc>()..add(LoadHomeData());
    _walletBloc = sl<WalletBloc>()..add(LoadWallet());
    _orderBloc = sl<OrderBloc>()..add(LoadOrders());
  }

  @override
  void dispose() {
    _homeBloc.close();
    _walletBloc.close();
    _orderBloc.close();
    super.dispose();
  }

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    if (loc.startsWith('/wallet')) return 1;
    if (loc.startsWith('/orders')) return 2;
    if (loc.startsWith('/home')) return 0;
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _selectedIndex(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _homeBloc),
        BlocProvider.value(value: _walletBloc),
        BlocProvider.value(value: _orderBloc),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) context.go('/login');
        },
        child: Scaffold(
          body: widget.child,
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppColors.navBg,
              border:
                  Border(top: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: AppLocalizations.of(context).navHome,
                      selected: idx == 0,
                      onTap: () => context.go('/home'),
                    ),
                    _NavItem(
                      icon: Icons.account_balance_wallet,
                      label: AppLocalizations.of(context).navWallet,
                      selected: idx == 1,
                      onTap: () => context.go('/wallet'),
                    ),
                    _NavItem(
                      icon: Icons.shopping_bag_outlined,
                      label: AppLocalizations.of(context).navOrders,
                      selected: idx == 2,
                      onTap: () => context.go('/orders'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
        decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? AppColors.primary : Colors.transparent)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            icon,
            color: selected ? AppColors.primary : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ]),
      ),
    );
  }
}
