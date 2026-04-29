import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pro.stations.wetaxi.ma/core/di/injection.dart';
import 'package:pro.stations.wetaxi.ma/core/l10n/app_localizations.dart';
import 'package:pro.stations.wetaxi.ma/core/theme/app_theme.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/presentation/bloc/wallet_bloc.dart';

class RechargePage extends StatelessWidget {
  const RechargePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => sl<WalletBloc>()..add(LoadWallet()),
        child: const _RechargeView(),
      );
}

class _RechargeView extends StatefulWidget {
  const _RechargeView();

  @override
  State<_RechargeView> createState() => _RechargeViewState();
}

class _RechargeViewState extends State<_RechargeView> {
  bool _isNfc = true;
  final _amountCtrl = TextEditingController(text: '0');
  final _phoneCtrl = TextEditingController();
  final _nfcTagCtrl = TextEditingController();
  int _amount = 0;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _phoneCtrl.dispose();
    _nfcTagCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final l = AppLocalizations.of(context);
    final amount = double.tryParse(_amountCtrl.text) ?? _amount.toDouble();
    if (amount <= 0) {
      _showError(l.invalidAmount);
      return;
    }
    if (_isNfc) {
      final tag = _nfcTagCtrl.text.trim();
      if (tag.isEmpty) {
        _showError(l.nfcIdRequired);
        return;
      }
      context.read<WalletBloc>().add(RechargeByNfc(tag, amount));
    } else {
      final phone = _phoneCtrl.text.trim();
      if (phone.isEmpty) {
        _showError(l.phoneRequired);
        return;
      }
      context.read<WalletBloc>().add(RechargeByPhone(phone, amount));
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is RechargeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Compte de ${state.result.clientName} rechargé — Nouveau solde: ${state.result.newBalance.toStringAsFixed(2)} MAD',
            ),
            backgroundColor: AppColors.teal,
            behavior: SnackBarBehavior.floating,
          ));
          _amountCtrl.text = '0';
          _phoneCtrl.clear();
          _nfcTagCtrl.clear();
          setState(() => _amount = 0);
        }
        if (state is WalletError) {
          _showError(state.message);
        }
      },
      child: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          final isProcessing = state is RechargeProcessing;
          final l = AppLocalizations.of(context);
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    l.rechargeClient,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Tab switcher
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(children: [
                      Expanded(child: _Tab(
                        icon: Icons.nfc,
                        label: l.nfcCard,
                        active: _isNfc,
                        onTap: () => setState(() => _isNfc = true),
                      )),
                      Expanded(child: _Tab(
                        icon: Icons.phone,
                        label: l.phoneMode,
                        active: !_isNfc,
                        onTap: () => setState(() => _isNfc = false),
                      )),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // Form card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: _isNfc
                        ? _NfcForm(nfcTagCtrl: _nfcTagCtrl, amountCtrl: _amountCtrl)
                        : _PhoneForm(
                            phoneCtrl: _phoneCtrl,
                            amount: _amount,
                            onAmountChange: (v) => setState(() => _amount = v),
                          ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: isProcessing ? null : _submit,
                      icon: isProcessing
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                            )
                          : Icon(
                              _isNfc ? Icons.wifi_tethering : Icons.send,
                              color: Colors.black,
                              size: 22,
                            ),
                      label: Text(
                        isProcessing ? l.processing : (_isNfc ? l.rechargeViaNfc : l.recharge),
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        disabledBackgroundColor: AppColors.primaryDark.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Tab ─────────────────────────────────────────────────────────────────────

class _Tab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: active ? Colors.black : AppColors.textSecondary, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── NFC Form ─────────────────────────────────────────────────────────────────

class _NfcForm extends StatelessWidget {
  final TextEditingController nfcTagCtrl;
  final TextEditingController amountCtrl;
  const _NfcForm({required this.nfcTagCtrl, required this.amountCtrl});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.nfcBadgeId, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      const SizedBox(height: 10),
      TextField(
        controller: nfcTagCtrl,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'NFC-ABC123',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.inputBg,
          prefixIcon: const Icon(Icons.nfc, color: AppColors.textSecondary, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      const SizedBox(height: 16),
      Text(l.amountMad, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      const SizedBox(height: 10),
      TextField(
        controller: amountCtrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(color: Colors.white, fontSize: 18),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.inputBg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ]);
  }
}

// ─── Phone Form ───────────────────────────────────────────────────────────────

class _PhoneForm extends StatelessWidget {
  final TextEditingController phoneCtrl;
  final int amount;
  final ValueChanged<int> onAmountChange;
  const _PhoneForm({required this.phoneCtrl, required this.amount, required this.onAmountChange});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.phoneNumber, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      const SizedBox(height: 10),
      TextField(
        controller: phoneCtrl,
        keyboardType: TextInputType.phone,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: '0612345678',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.inputBg,
          prefixIcon: const Icon(Icons.phone, color: AppColors.textSecondary, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      const SizedBox(height: 16),
      Text(l.amountMad, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: AppColors.inputBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text('$amount', style: const TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: [
            _SpinBtn(icon: Icons.keyboard_arrow_up, onTap: () => onAmountChange(amount + 1)),
            Container(height: 1, color: AppColors.border),
            _SpinBtn(icon: Icons.keyboard_arrow_down, onTap: () => onAmountChange(amount > 0 ? amount - 1 : 0)),
          ]),
        ]),
      ),
    ]);
  }
}

class _SpinBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SpinBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 27,
          decoration: const BoxDecoration(color: AppColors.border),
          child: Icon(icon, color: AppColors.textSecondary, size: 18),
        ),
      );
}
