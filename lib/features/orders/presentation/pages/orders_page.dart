import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pro.stations.wetaxi.ma/core/l10n/app_localizations.dart';
import 'package:pro.stations.wetaxi.ma/core/theme/app_theme.dart';
import 'package:pro.stations.wetaxi.ma/features/orders/domain/entities/taxi_order.dart';
import 'package:pro.stations.wetaxi.ma/features/orders/presentation/bloc/order_bloc.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) => const _OrdersView();
}

class _OrdersView extends StatelessWidget {
  const _OrdersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (state is OrderError) {
              return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.error_outline, color: AppColors.red, size: 48),
                const SizedBox(height: 16),
                Text(state.message, style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<OrderBloc>().add(LoadOrders()),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text(AppLocalizations.of(context).retry, style: const TextStyle(color: Colors.black)),
                ),
              ]));
            }

            final orders = state is OrderLoaded ? state.orders
                : state is OrderActionLoading ? state.orders : <TaxiOrder>[];

            final active  = orders.where((o) => o.status == OrderStatus.pending || o.status == OrderStatus.active).toList();
            final history = orders.where((o) => o.status == OrderStatus.completed || o.status == OrderStatus.cancelled).toList();

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => context.read<OrderBloc>().add(LoadOrders()),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(AppLocalizations.of(context).orders,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  if (active.isNotEmpty) ...[
                    Row(children: [
                      Text(AppLocalizations.of(context).activeOrders,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                        child: Text('${active.length}',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    ...active.map((o) => _OrderCard(
                          order: o,
                          isLoading: state is OrderActionLoading && state.orderId == o.id,
                        )),
                  ],

                  if (history.isNotEmpty) ...[
                    if (active.isNotEmpty) const SizedBox(height: 8),
                    Text(AppLocalizations.of(context).history,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 14),
                    ...history.map((o) => _OrderCard(order: o, isHistory: true)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Order Card ───────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final TaxiOrder order;
  final bool isHistory;
  final bool isLoading;
  const _OrderCard({required this.order, this.isHistory = false, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OrderBloc>();
    final isPending = order.status == OrderStatus.pending;
    final l = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? AppColors.primary.withValues(alpha: 0.5) : AppColors.border,
          width: isPending ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Top row: name + price + seats
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(order.abbreviatedName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.access_time, color: AppColors.textSecondary, size: 13),
                const SizedBox(width: 4),
                Text(l.inMinutes(order.estimatedMinutes),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ]),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                Text(
                  '${order.fare.toInt()} ',
                  style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Text('MAD', style: TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.bold)),
              ]),
              Text('${order.numberOfPassengers} ${l.passengers}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
          ]),

          const SizedBox(height: 14),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),

          // Departure
          Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: AppColors.teal.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.location_on, color: AppColors.teal, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.departure, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              Text(order.pickupAddress,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            ])),
          ]),

          const SizedBox(height: 10),

          // Destination
          Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.location_on, color: AppColors.red, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.destination, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              Text(order.dropoffAddress,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            ])),
          ]),

          if (!isHistory && isPending) ...[
            const SizedBox(height: 14),
            if (isLoading)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else
              Row(children: [
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => bloc.add(CancelOrder(order.id)),
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  label: Text(l.refuse, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => bloc.add(AcceptOrder(order.id)),
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                  label: Text(l.accept, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                )),
              ]),
          ],

          if (order.status == OrderStatus.active && !isLoading) ...[
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: () => bloc.add(CompleteOrder(order.id)),
              icon: const Icon(Icons.check_circle, color: Colors.black),
              label: Text(l.completeTrip, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
            )),
          ],
        ]),
      ),
    );
  }
}
