import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pro.stations.wetaxi.ma/core/di/injection.dart';
import 'package:pro.stations.wetaxi.ma/core/l10n/app_localizations.dart';
import 'package:pro.stations.wetaxi.ma/core/l10n/locale_notifier.dart';
import 'package:pro.stations.wetaxi.ma/core/theme/app_theme.dart';
import 'package:pro.stations.wetaxi.ma/features/auth/domain/entities/driver_entity.dart';
import 'package:pro.stations.wetaxi.ma/features/auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final driver = state is AuthAuthenticated ? state.driver : null;
        return _ProfileView(driver: driver);
      },
    );
  }
}

class _ProfileView extends StatelessWidget {
  final DriverEntity? driver;
  const _ProfileView({this.driver});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final name = driver?.name ?? '—';
    final phone = driver?.phone ?? '—';
    final vehicle = driver != null
        ? '${driver!.taxiNumber} — ${driver!.plateNumber}'
        : '—';
    final station = driver?.station?.name ?? '—';
    final permit = driver?.permitNumber;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              l.profile,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Profile card (yellow gradient)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF5A300), Color(0xFFE08800)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.black87,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.driverRole,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ]),
            ),
            const SizedBox(height: 28),

            // Informations section
            Text(
              l.information,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),

            _InfoRow(icon: Icons.phone, label: l.phone, value: phone),
            _InfoRow(
              icon: Icons.directions_car,
              label: l.vehicle,
              value: vehicle,
            ),
            _InfoRow(
              icon: Icons.location_on,
              label: l.stationLabel,
              value: station,
            ),
            if (permit != null)
              _InfoRow(icon: Icons.badge, label: l.permit, value: permit),

            const SizedBox(height: 28),

            Text(
              l.language,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            _LanguageSelector(),
            const SizedBox(height: 28),

            // Settings button
            _ActionButton(
              icon: Icons.settings_outlined,
              label: l.settings,
              onTap: () => context.push('/settings'),
            ),
            const SizedBox(height: 12),

            // Logout button
            _ActionButton(
              icon: Icons.logout,
              label: l.logout,
              isDestructive: true,
              onTap: () => _confirmLogout(context, l),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppLocalizations l) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l.confirmLogoutTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l.confirmLogoutMsg,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutEvent());
            },
            child: Text(
              l.disconnect,
              style: const TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = sl<LocaleNotifier>();
    final l = AppLocalizations.of(context);

    return ValueListenableBuilder<Locale>(
      valueListenable: notifier,
      builder: (_, current, __) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: [
            _LangOption(
              flag: '🇫🇷',
              label: l.french,
              subtitle: 'Français',
              selected: current.languageCode == 'fr',
              onTap: () => notifier.setLocale(const Locale('fr')),
            ),
            const Divider(height: 1, color: AppColors.border),
            _LangOption(
              flag: '🇲🇦',
              label: l.arabic,
              subtitle: 'العربية',
              selected: current.languageCode == 'ar',
              onTap: () => notifier.setLocale(const Locale('ar')),
              isRtlLabel: true,
            ),
          ]),
        );
      },
    );
  }
}

class _LangOption extends StatelessWidget {
  final String flag;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool isRtlLabel;

  const _LangOption({
    required this.flag,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.isRtlLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Text(flag, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : Colors.white,
                fontSize: 15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              textDirection: isRtlLabel ? TextDirection.rtl : TextDirection.ltr,
            ),
          ),
          if (selected)
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.black, size: 14),
            )
          else
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
            ),
        ]),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.red : Colors.white;
    final bgColor = isDestructive
        ? AppColors.red.withValues(alpha: 0.12)
        : AppColors.surface;
    final borderColor = isDestructive
        ? AppColors.red.withValues(alpha: 0.3)
        : AppColors.border;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (!isDestructive)
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
        ]),
      ),
    );
  }
}
