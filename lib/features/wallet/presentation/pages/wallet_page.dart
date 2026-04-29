import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pro.stations.wetaxi.ma/core/l10n/app_localizations.dart';
import 'package:pro.stations.wetaxi.ma/core/theme/app_theme.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/presentation/bloc/wallet_bloc.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) => const _WalletView();
}

class _WalletView extends StatelessWidget {
  const _WalletView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            if (state is WalletLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (state is WalletError) {
              return Center(child: Text(state.message, style: const TextStyle(color: AppColors.red)));
            }

            final wallet = state is WalletLoaded ? state.wallet : null;
            if (wallet == null) return const SizedBox();

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => context.read<WalletBloc>().add(LoadWallet()),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(AppLocalizations.of(context).wallet,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // Balance card
                  _BalanceCard(balance: wallet.balance, onRecharge: () => context.push('/recharge')),
                  const SizedBox(height: 28),

                  Text(AppLocalizations.of(context).lastTransactions,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),

                  ...wallet.transactions.map((t) => _TransactionCard(transaction: t)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Balance Card ─────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final double balance;
  final VoidCallback onRecharge;
  const _BalanceCard({required this.balance, required this.onRecharge});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5A300), Color(0xFFE08000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.account_balance_wallet_outlined, color: Colors.black54, size: 18),
          const SizedBox(width: 8),
          Text(l.availableBalance, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        ]),
        const SizedBox(height: 10),
        Text(
          '${NumberFormat('#,##0.00').format(balance)} MAD',
          style: const TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: _CardAction(icon: Icons.south_west, label: l.withdraw, onTap: () {})),
          const SizedBox(width: 10),
          Expanded(child: _CardAction(icon: Icons.send, label: l.transfer, onTap: () {})),
          const SizedBox(width: 10),
          Expanded(child: _CardAction(icon: Icons.credit_card, label: l.recharge, onTap: onRecharge)),
        ]),
      ]),
    );
  }
}

class _CardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _CardAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Icon(icon, color: Colors.black87, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// ─── Transaction Card ─────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final WalletTransaction transaction;
  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final color = transaction.isCredit ? AppColors.teal : AppColors.red;
    final sign  = transaction.isCredit ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(
            transaction.isCredit ? Icons.south_west : Icons.north_east,
            color: color, size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(transaction.description,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 2),
          Text(
            DateFormat('HH:mm').format(transaction.date),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ])),
        Text(
          '$sign${NumberFormat('#,##0.00').format(transaction.amount)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ]),
    );
  }
}
