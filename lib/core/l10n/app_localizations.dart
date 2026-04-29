import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const delegate = _AppLocalizationsDelegate();

  static const supportedLocales = [Locale('fr'), Locale('ar')];

  bool get isAr => locale.languageCode == 'ar';

  String _t(String fr, String ar) => isAr ? ar : fr;

  // ── App ──────────────────────────────────────────────────────────────────
  String get appName => 'wetaxi.station';

  // ── Navigation ───────────────────────────────────────────────────────────
  String get navHome => _t('Accueil', 'الرئيسية');
  String get navWallet => _t('Wallet', 'المحفظة');
  String get navOrders => _t('Commandes', 'الطلبات');

  // ── Login ────────────────────────────────────────────────────────────────
  String get login => _t('Connexion', 'تسجيل الدخول');
  String get loginSubtitle =>
      _t('Connectez-vous à votre compte chauffeur', 'سجّل دخولك إلى حساب السائق');
  String get phoneNumber => _t('Numéro de téléphone', 'رقم الهاتف');
  String get password => _t('Mot de passe', 'كلمة المرور');
  String get connect => _t('Se connecter', 'تسجيل الدخول');
  String get connectionError =>
      _t('Erreur de connexion au serveur', 'خطأ في الاتصال بالخادم');

  // ── Home ─────────────────────────────────────────────────────────────────
  String get activeLine => _t('Ligne active', 'الخط النشط');
  String get seatStatus => _t('État des places', 'حالة المقاعد');
  String get rechargeAccount => _t('Recharger un compte', 'شحن حساب عميل');
  String get noLine => _t('Aucune ligne', 'لا يوجد خط');
  String get min => _t(' min', ' دقيقة');
  String get approximately => '~ ';

  // ── Wallet ───────────────────────────────────────────────────────────────
  String get wallet => _t('Wallet', 'المحفظة');
  String get availableBalance => _t('Solde disponible', 'الرصيد المتاح');
  String get withdraw => _t('Retrait', 'سحب');
  String get transfer => _t('Transfert', 'تحويل');
  String get recharge => _t('Recharger', 'شحن');
  String get lastTransactions => _t('Dernières transactions', 'آخر المعاملات');
  String get mad => ' MAD';

  // ── Recharge ─────────────────────────────────────────────────────────────
  String get rechargeClient => _t('Recharger un compte', 'شحن حساب عميل');
  String get nfcCard => _t('Carte NFC', 'بطاقة NFC');
  String get phoneMode => _t('Téléphone', 'الهاتف');
  String get nfcBadgeId => _t('Badge NFC (ID)', 'رقم شارة NFC');
  String get amountMad => _t('Montant (MAD)', 'المبلغ (درهم)');
  String get rechargeViaNfc => _t('Recharger via NFC', 'شحن عبر NFC');
  String get processing => _t('Traitement...', 'جاري المعالجة...');
  String get invalidAmount => _t('Montant invalide', 'مبلغ غير صالح');
  String get nfcIdRequired => _t('Identifiant NFC requis', 'رقم الشارة مطلوب');
  String get phoneRequired =>
      _t('Numéro de téléphone requis', 'رقم الهاتف مطلوب');

  // ── Orders ───────────────────────────────────────────────────────────────
  String get orders => _t('Commandes', 'الطلبات');
  String get accept => _t('Accepter', 'قبول');
  String get refuse => _t('Refuser', 'رفض');
  String get departure => _t('Départ', 'المغادرة');
  String get destination => _t('Destination', 'الوجهة');
  String get passengers => _t('passager(s)', 'راكب');
  String get activeOrders => _t('Commandes actives', 'الطلبات النشطة');
  String get history => _t('Historique', 'السجل');
  String get completeTrip => _t('Terminer la course', 'إنهاء الرحلة');
  String get retry => _t('Réessayer', 'إعادة المحاولة');
  String inMinutes(int n) => _t('Dans $n min', 'خلال $n دقيقة');

  // ── Profile ──────────────────────────────────────────────────────────────
  String get profile => _t('Profile', 'الملف الشخصي');
  String get information => _t('Informations', 'المعلومات');
  String get phone => _t('Téléphone', 'الهاتف');
  String get vehicle => _t('Véhicule', 'المركبة');
  String get stationLabel => _t('Station', 'المحطة');
  String get permit => _t('Permis', 'الرخصة');
  String get driverRole => _t('Chauffeur de Grand Taxi', 'سائق سيارة أجرة');
  String get settings => _t('Paramètres', 'الإعدادات');
  String get logout => _t('Déconnexion', 'تسجيل الخروج');
  String get confirmLogoutTitle => _t('Déconnexion', 'تسجيل الخروج');
  String get confirmLogoutMsg =>
      _t('Voulez-vous vraiment vous déconnecter ?', 'هل تريد تسجيل الخروج؟');
  String get cancel => _t('Annuler', 'إلغاء');
  String get disconnect => _t('Déconnecter', 'خروج');

  // ── Settings ─────────────────────────────────────────────────────────────
  String get language => _t('Langue', 'اللغة');
  String get selectLanguage => _t('Choisir la langue', 'اختر اللغة');
  String get french => 'Français';
  String get arabic => 'العربية';
  String get appearance => _t('Apparence', 'المظهر');
  String get about => _t('À propos', 'حول');
  String get version => _t('Version', 'الإصدار');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['fr', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_) => false;
}
