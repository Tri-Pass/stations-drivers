import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pro.stations.wetaxi.ma/core/l10n/app_localizations.dart';
import 'package:pro.stations.wetaxi.ma/core/theme/app_theme.dart';
import 'package:pro.stations.wetaxi.ma/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pro.stations.wetaxi.ma/features/home/presentation/bloc/home_bloc.dart';
import 'package:pro.stations.wetaxi.ma/features/seats/domain/entities/passenger_entity.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const _HomeView();
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (state is HomeError) {
              return Center(child: Text(state.message, style: const TextStyle(color: AppColors.red)));
            }
            if (state is HomeLoaded) {
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async =>
                    context.read<HomeBloc>().add(LoadHomeData()),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    // Header
                    _DriverHeader(
                      onProfileTap: () => context.push('/profile'),
                    ),
                    const SizedBox(height: 20),

                    // Ligne active card
                    _ActiveLineCard(line: state.line, destination: state.destination),
                    const SizedBox(height: 14),

                    // Queue position card
                    _QueueCard(position: state.myPosition, total: state.totalInQueue, minutes: state.estimatedMinutes),
                    const SizedBox(height: 14),

                    // Seat grid card
                    _SeatGridCard(
                      occupied: state.occupiedSeats,
                      total: state.totalSeats,
                      passengers: state.passengers,
                    ),
                    const SizedBox(height: 20),

                    // Recharge button
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/recharge'),
                          icon: const Icon(Icons.credit_card, color: Colors.black, size: 22),
                          label: Text(
                            AppLocalizations.of(context).rechargeAccount,
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

// ─── Driver Header ────────────────────────────────────────────────────────────

class _DriverHeader extends StatelessWidget {
  final VoidCallback onProfileTap;
  const _DriverHeader({required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final driver =
            authState is AuthAuthenticated ? authState.driver : null;
        final name = driver?.name ?? '—';
        final station = driver?.station?.name ?? '';
        return Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (station.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  station,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ]),
          ),
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.iconBg,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(12))
              ),
              child: const Icon(Icons.person_outline, color: AppColors.primary, size: 24),
            ),
          ),
        ]);
      },
    );
  }
}

// ─── Active Line Card ─────────────────────────────────────────────────────────

class _ActiveLineCard extends StatelessWidget {
  final String line;
  final String destination;
  const _ActiveLineCard({required this.line, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(AppLocalizations.of(context).activeLine,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
          const Spacer(),
          Container(decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15),borderRadius: BorderRadius.circular(8)) ,padding: const EdgeInsets.all(8),child: const Icon(Icons.lock, color: AppColors.primary, size: 18)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.teal.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.location_on, color: AppColors.teal, size: 18),
          ),
          const SizedBox(width: 12),
          Text(line, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
           Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.arrow_forward, color: AppColors.primary.withValues(alpha: 0.9), size: 18),
          ),
          Text(destination, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }
}

// ─── Queue Position Card ──────────────────────────────────────────────────────

class _QueueCard extends StatelessWidget {
  final int position;
  final int total;
  final int minutes;
  const _QueueCard({required this.position, required this.total, required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        // Car icon circle
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
          ),
          child: const Icon(Icons.directions_car, color: AppColors.teal, size: 22),
        ),
        const SizedBox(width: 14),

        // Position number
        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Text(
            '$position',
            style: const TextStyle(color: AppColors.primary, fontSize: 52, fontWeight: FontWeight.bold, height: 1),
          ),
          const SizedBox(width: 2),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
            Text('/$total', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
            ),
          ]),
        ]),

        const Spacer(),

        // Time pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.iconBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border)
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.access_time, color: AppColors.primary, size: 16),
            const SizedBox(width: 6),
            const Text('~ ', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            Text(
              '$minutes',
              style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(AppLocalizations.of(context).min, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ]),
        ),
      ]),
    );
  }
}

// ─── Seat Grid Card ───────────────────────────────────────────────────────────

class _SeatGridCard extends StatelessWidget {
  final int occupied;
  final int total;
  final List<PassengerEntity> passengers;
  const _SeatGridCard({
    required this.occupied,
    required this.total,
    required this.passengers,
  });

  @override
  Widget build(BuildContext context) {
    final available = total - occupied;
    // Build a map from seatNumber → passenger for quick lookup
    final passengerMap = {for (final p in passengers) p.seatNumber: p};

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 15),
            children: [
              TextSpan(text: '${AppLocalizations.of(context).seatStatus}: ', style: const TextStyle(color: Colors.white)),
              TextSpan(text: '$available', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              TextSpan(text: '/$total', style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 1, mainAxisSpacing: 10, crossAxisSpacing: 10,
          ),
          itemCount: total,
          itemBuilder: (ctx, i) {
            final seatNumber = i + 1;
            final passenger = passengerMap[seatNumber];
            final isOccupied = passenger != null || i < occupied;
            final name = passenger?.name ?? '';

            return Container(
              decoration: BoxDecoration(
                color: isOccupied ? AppColors.teal.withValues(alpha: 0.1) : AppColors.inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isOccupied ? AppColors.teal.withValues(alpha: 0.5) : AppColors.border,
                ),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.person, color: isOccupied ? AppColors.teal : AppColors.textSecondary, size: 28),
                const SizedBox(height: 2),
                Text(
                  '#$seatNumber',
                  style: TextStyle(
                    color: isOccupied ? AppColors.teal : AppColors.textSecondary,
                    fontSize: 11, fontWeight: FontWeight.w600,
                  ),
                ),
                if (isOccupied && name.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ]),
            );
          },
        ),
      ]),
    );
  }
}
