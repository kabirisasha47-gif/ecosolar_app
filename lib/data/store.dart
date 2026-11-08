import 'package:flutter/foundation.dart';
import 'package:ecosolar/data/models.dart';

/// In-memory application state with demo data (Isfahan pilot). Swap mutations for [Api] calls in production.
class AppState extends ChangeNotifier {
  // auth / identity
  String mobile = '';
  bool legal = false, loggedIn = false;
  String name = 'سارا محمدی', nationalId = '1270000004', birth = '1370/05/12';
  String sheba = 'IR770120000000000000004821';
  String kyc = 'none'; // none, pending, verified
  final consents = <Consent>[
    Consent('شرکت توزیع برق', 'قرائت کنتور', '۱۲ ماه'),
    Consent('ساتبا', 'پرونده و صورتحساب', '۲۰ سال'),
    Consent('بانک ملت', 'هویت و حساب', 'مدت وام'),
    Consent('درگاه پرداخت', 'تراکنش‌ها', '۱۲ ماه'),
    Consent('سکوی تأمین مالی جمعی', 'گزارش تولید خوشه', '۱۲ ماه'),
  ];
  final members = <Member>[
    Member('سارا محمدی', '09123456789', 'مدیر سازمان', ['همه']),
    Member('رضا کریمی', '09132214560', 'مدیر انرژی', ['اصفهان', 'کاشان']),
    Member('مریم احمدی', '09158801234', 'ناظر', ['نجف‌آباد']),
  ];

  // onboarding profile
  int sector = 0;
  String city = 'کاشان';
  final bill = <String, double>{'peak': 210, 'mid': 320, 'off': 140, 'demand': 5, 'amount': 1850000};
  final appliances = <(String, double, double)>[('کولر آبی', 0.4, 10.0), ('کولر گازی', 2.5, 6.0)];
  double roofArea = 120, slope = 25;
  bool sharedRoof = false;

  // AI recommendations
  final recs = <Rec>[
    Rec('r1', 'دمای کولر ۲۵ درجه', 'از ساعت ۱۲ تا ۱۷ دمای هدف ۲۵ درجه باشد', 'هر ۱ درجه افزایش دمای هدف حدود ۶٪ مصرف سرمایش را کم می‌کند', 140),
    Rec('r2', 'جابجایی بار به کم‌باری', 'ماشین لباسشویی و ظرفشویی بعد از ساعت ۲۳', 'تعرفه کم‌باری نصف تعرفه پایه است', 90),
    Rec('r3', 'سایبان پنجره‌های غربی', 'نصب سایبان بیرونی با بازگشت سرمایه حدود ۲ سال', 'بار حرارتی عصر بیشترین سهم مصرف تابستان را دارد', 90),
  ];

  // plant
  final plantName = 'نیروگاه بام کاشان';
  double kwp = 10, storageKwh = 15;
  bool storageOn = true;
  final circuits = <String>{'یخچال', 'روشنایی', 'مودم و اینترنت'};
  int caseStep = 4; // 0..6
  bool requestSubmitted = false;
  String? channel; // accepted channel id
  bool contractSigned = false, devicePaired = false;
  final channels = const <Channel>[
    Channel('fit', 'FiT تضمینی', 240e6, '۳ ماه', 'کم', recommended: true),
    Channel('self', 'خودتأمین', 210e6, 'فوری', 'کم'),
    Channel('vpp', 'نیروگاه مجازی VPP', 265e6, '۲ ماه', 'متوسط'),
    Channel('ppa', 'قرارداد دوجانبه', 0, '—', '—', eligible: false, reason: 'برای ظرفیت کمتر از ۱ مگاوات مجاز نیست'),
  ];

  // revenue & wallet
  final invoices = <Invoice>[
    Invoice('INV-1405-07', 'مهر ۱۴۰۵', 820, 13.1e6, 0.7e6, 'ISSUED', agingDays: 45),
    Invoice('INV-1405-06', 'شهریور ۱۴۰۵', 910, 14.5e6, 0.78e6, 'ADVANCED'),
    Invoice('INV-1405-05', 'مرداد ۱۴۰۵', 960, 15.3e6, 0.82e6, 'SETTLED'),
  ];
  double b1 = 9.3e6, b2 = 2.1e6, b3 = 13.2e6;
  double a1 = 50, a2 = 15, a3 = 35;
  final ledger = <Tx>[
    Tx('واریز ساتبا', 12.4e6, DateTime(2026, 10, 20)),
    Tx('کسر قسط', -9.3e6, DateTime(2026, 10, 6)),
    Tx('پیش‌پرداخت', 9.08e6, DateTime(2026, 9, 28)),
    Tx('کارمزد پلتفرم', -0.12e6, DateTime(2026, 9, 22)),
  ];
  String? financePlan;

  // O&M
  final workOrders = <WorkOrder>[
    WorkOrder('WO-301', 'شست‌وشوی پنل‌ها', 'علی رضایی', '۱۶ آبان', 850000, 'awaiting'),
    WorkOrder('WO-302', 'بازرسی برقی', 'آفتاب گستر سپاهان', '۲۵ آبان', 1200000, 'scheduled'),
    WorkOrder('WO-288', 'به‌روزرسانی نرم‌افزار', 'آفتاب گستر سپاهان', '۲ مهر', 0, 'done'),
  ];

  // marketplace
  final products = const <Product>[
    Product('پنل ۵۵۰ وات', 'پنل', 12.5e6, true),
    Product('پنل ۴۵۰ وات', 'پنل', 10.2e6, false),
    Product('اینورتر هیبرید ۱۰ kW', 'اینورتر', 98e6, false),
    Product('باتری ۵ kWh', 'باتری', 75e6, true),
    Product('سازه آلومینیومی', 'سازه', 4.2e6, true),
  ];
  final bids = const <Bid>[
    Bid('آفتاب گستر سپاهان', 4.8, 85e6, 14, 24),
    Bid('نیرو پاک کاشان', 4.6, 79e6, 20, 18),
    Bid('سانا انرژی', 4.3, 92e6, 10, 36),
  ];
  String? installer;
  int installStage = 2;
  bool rfqSent = false, poLocked = false, loanSubmitted = false;
  int roofModel = 1;
  bool vppJoined = false;
  final coOwners = <CoOwner>[
    CoOwner(1, 'حسین نوری', '0912•••451', true),
    CoOwner(2, 'زهرا کاظمی', '0913•••820', true),
    CoOwner(3, 'محمد صادقی', '0915•••107', true),
    CoOwner(4, 'نرگس اکبری', '0919•••663', true),
    CoOwner(5, 'امیر حسینی', '0935•••294', false),
    CoOwner(6, 'لیلا رحیمی', '0936•••588', false),
  ];

  // profile / notifications / support
  bool autoMax = false;
  final notifPrefs = <String, bool>{'هشدار فنی': true, 'صورتحساب و پرداخت': true, 'مهلت‌های مقرراتی': true, 'امنیت': true};
  int reviewDecision = 0; // 0 pending, 1 accepted, 2 kept
  final notifs = <Notif>[
    Notif('افت عملکرد پنل‌ها', 'تولید امروز ۱۸٪ کمتر از انتظار است', 'فنی', '/plant/monitoring', DateTime.now().subtract(const Duration(hours: 1))),
    Notif('صورتحساب مهر صادر شد', 'مبلغ خالص ۱۲٬۴۰۰٬۰۰۰ تومان', 'مالی', '/revenue/invoices', DateTime.now().subtract(const Duration(hours: 2))),
    Notif('امضای قرارداد لازم است', 'برای فعال‌سازی کانال درآمد', 'اقدام لازم', '/plant/contract', DateTime.now().subtract(const Duration(hours: 3))),
    Notif('مرحله ۴ پرونده مهرسان تکمیل شد', 'نصب توسط پیمانکار تأیید شد', 'مقرراتی', '/plant/case', DateTime.now().subtract(const Duration(days: 1)), read: true),
  ];
  final tickets = <Ticket>[
    Ticket('1048', 'مغایرت صورتحساب', 'در حال بررسی', [
      Msg('مبلغ صورتحساب با کنتور مطابقت ندارد', true, DateTime.now().subtract(const Duration(hours: 5))),
      Msg('در حال بررسی قرائت کنتور هستیم', false, DateTime.now().subtract(const Duration(hours: 4))),
    ]),
  ];

  void touch() => notifyListeners();

  int get unread => notifs.where((n) => !n.read).length;
  double get savingKwh => recs.where((r) => r.state == 'accepted').fold(0.0, (a, r) => a + r.kwhSaving);
  double get settled => invoices.where((i) => i.status == 'SETTLED').fold(0.0, (a, i) => a + i.net) + 69.1e6;
  double get pending => invoices.where((i) => i.status == 'ISSUED' || i.status == 'OVERDUE').fold(0.0, (a, i) => a + i.net);
  double get minStorage => kwp * 1.5;
  bool get batteryTariffOk => storageOn && storageKwh >= minStorage;

  void login(String m, bool isLegal) {
    mobile = m;
    legal = isLegal;
    loggedIn = true;
    notifyListeners();
  }

  void logout() {
    loggedIn = false;
    notifyListeners();
  }

  void setRec(Rec r, String s) {
    r.state = s;
    notifyListeners();
  }

  void setConsent(Consent c, bool v) {
    c.signed = v;
    c.at = v ? DateTime.now() : null;
    notifyListeners();
  }

  void acceptChannel(String id) {
    channel = id;
    notifyListeners();
  }

  void approveWorkOrder(WorkOrder w) {
    w.status = 'done';
    b2 -= w.cost;
    ledger.insert(0, Tx('پرداخت ${w.type}', -w.cost, DateTime.now()));
    notifyListeners();
  }

  void advance(Invoice inv, double amount, double fee) {
    inv.status = 'ADVANCED';
    ledger.insert(0, Tx('پیش‌پرداخت ${inv.period}', amount - fee, DateTime.now()));
    notifyListeners();
  }

  void cashOut(double amount, double fee) {
    b3 -= amount;
    ledger.insert(0, Tx('برداشت به شبا', -amount, DateTime.now()));
    ledger.insert(0, Tx('کارمزد برداشت', -fee, DateTime.now()));
    notifyListeners();
  }

  void readAll() {
    for (final n in notifs) {
      n.read = true;
    }
    notifyListeners();
  }

  void sendMsg(Ticket t, String text) {
    t.msgs.add(Msg(text, true, DateTime.now()));
    notifyListeners();
  }

  Ticket newTicket(String topic, String text) {
    final t = Ticket('${1049 + tickets.length}', topic, 'باز', [Msg(text, true, DateTime.now())]);
    tickets.insert(0, t);
    notifyListeners();
    return t;
  }
}

final app = AppState();
