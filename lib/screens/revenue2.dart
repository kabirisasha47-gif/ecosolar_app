import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ecosolar/core/fmt.dart';
import 'package:ecosolar/core/jalali.dart';
import 'package:ecosolar/core/theme.dart';
import 'package:ecosolar/core/validators.dart';
import 'package:ecosolar/data/store.dart';
import 'package:ecosolar/screens/revenue.dart';
import 'package:ecosolar/widgets/charts.dart';
import 'package:ecosolar/widgets/flows.dart';
import 'package:ecosolar/widgets/ui.dart';

/// SCR-C-43 Multi-year loan & DSCR simulator
class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});
  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  double principal = 400e6;
  int option = 0;
  @override
  Widget build(BuildContext context) {
    final inst = installment(principal);
    final years = [for (var y = 0; y < 5; y++) year1Revenue * math.pow(1.5, y) * math.pow(.995, y)];
    final dscr = [for (final r in years) r / inst];
    const r = loanRate / 12;
    final maxCovered = year1Revenue * (1 - math.pow(1 + r, -loanMonths)) / r;
    const opts = [('الف', 'کاهش مبلغ وام و آورده نقدی'), ('ب', 'افزایش مدت بازپرداخت با بانک دیگر'), ('ج', 'پرداخت کسری در سال‌های اول')];
    return EPage(
      title: 'شبیه‌ساز پوشش قسط',
      bottom: PrimaryButton(app.financePlan == null ? 'تأیید برنامه مالی' : 'برنامه ثبت شد', onPressed: () {
        app.financePlan = opts[option].$2;
        app.touch();
        toast(context, 'برنامه مالی ثبت شد');
        setState(() {});
      }),
      children: [
        ECard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('مشخصات وام', style: ts(15, w: FontWeight.w700)),
          gap12,
          StatRow([Stat('مبلغ', mt(principal)), Stat('سود', pct(loanRate * 100)), Stat('مدت', '${fa(loanMonths)} ماه')]),
          Slider(value: principal, min: 100e6, max: 400e6, divisions: 30, onChanged: (v) => setState(() => principal = v)),
          KV('قسط ماهانه', toman(inst), bold: true),
          KV('درآمد ماهانه سال اول', toman(year1Revenue)),
          KV('حداکثر وام با پوشش ۱۰۰٪', toman(maxCovered)),
        ])),
        ECard(dark: true, child: Column(children: [
          Gauge(value: dscr.first, center: pct(dscr.first * 100), caption: 'پوشش قسط سال اول', dark: true),
          const ScenarioTag(onDark: true),
        ])),
        ECard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('مسیر چندساله', style: ts(14, w: FontWeight.w700)),
          gap8,
          const Legend([('درآمد', C.black), ('قسط', C.muted)]),
          gap12,
          LineChart(series: [Series(years.map((e) => e.toDouble()).toList()), Series(List.filled(5, inst), color: C.muted, dashed: true)], labels: [for (var y = 1; y <= 5; y++) 'سال ${fa(y)}']),
          gap8,
          Wrap(spacing: 8, runSpacing: 8, children: [for (var y = 0; y < 3; y++) Pill('سال ${fa(y + 1)}: ${pct(math.min(dscr[y], 9.99) * 100)}', tone: dscr[y] >= 1 ? Tone.green : Tone.amber)]),
        ])),
        const SectionTitle('چه کنم؟'),
        for (var i = 0; i < opts.length; i++)
          ECard(
            onTap: () => setState(() => option = i),
            border: Border.all(color: option == i ? C.black : Colors.transparent, width: 1.6),
            child: Row(children: [
              CircleAvatar(radius: 16, backgroundColor: option == i ? C.black : Colors.white, child: Text(opts[i].$1, style: ts(13, w: FontWeight.w800, c: option == i ? Colors.white : C.ink))),
              gap12,
              Expanded(child: Text(opts[i].$2, style: ts(14, w: FontWeight.w600))),
            ]),
          ),
      ],
    );
  }
}

/// SCR-C-44 Smart 3-bucket wallet & cash-out
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final amount = TextEditingController();
  bool busy = false;
  String? receipt;
  static const fee = 15000.0;

  Widget jar(String label, double v, double max, Color c) => Expanded(
        child: Column(children: [
          Container(
            height: 120, width: 64,
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(18)),
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(heightFactor: (v / max).clamp(.05, 1).toDouble(), child: Container(decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(18)))),
          ),
          gap8,
          Text(label, style: ts(12, c: Colors.white70)),
          Text(mt(v), style: ts(13.5, w: FontWeight.w800, c: Colors.white)),
        ]),
      );

  Future<void> cashOut() async {
    final a = parseNum(amount.text);
    if (a <= 0 || a + fee > app.b3) {
      toast(context, 'مبلغ باید کمتر از موجودی سود خالص باشد');
      return;
    }
    final otp = await showMfa(context, action: 'برداشت به ${maskSheba(app.sheba)}', amount: toman(a));
    if (otp == null) return;
    setState(() => busy = true);
    final key = 'IDEMP-${DateTime.now().millisecondsSinceEpoch}';
    await Future.delayed(const Duration(seconds: 1));
    app.cashOut(a, fee);
    setState(() {
      busy = false;
      receipt = key;
      amount.clear();
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          final max = [app.b1, app.b2, app.b3].reduce(math.max);
          final inst = installment(400e6);
          return EPage(
            title: 'کیف پول هوشمند',
            children: [
              ECard(dark: true, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('موجودی کل', style: ts(13, c: Colors.white70)),
                Text(toman(app.b1 + app.b2 + app.b3), style: ts(24, w: FontWeight.w800, c: Colors.white)),
                gap16,
                Row(children: [jar('قسط وام', app.b1, max, Colors.white), jar('ذخیره سرویس', app.b2, max, C.blue), jar('سود خالص', app.b3, max, C.green)]),
              ])),
              ECard(child: Row(children: [const IconCircle(Icons.account_balance, size: 38), gap12, Expanded(child: Text('وجوه نزد بانک ملت نگهداری می‌شود؛ پلتفرم وجه نگه نمی‌دارد', style: ts(13))), const Icon(Icons.verified_user_outlined)])),
              ECard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('قواعد تخصیص درآمد', style: ts(14, w: FontWeight.w700)),
                KV('قسط وام', pct(app.a1)),
                Slider(value: app.a1, min: 30, max: 80, onChanged: (v) { app.a1 = v; app.a3 = 100 - app.a1 - app.a2; app.touch(); }),
                KV('ذخیره سرویس', pct(app.a2)),
                Slider(value: app.a2, min: 5, max: 20, onChanged: (v) { app.a2 = v; app.a3 = 100 - app.a1 - app.a2; app.touch(); }),
                KV('سود خالص', pct(app.a3), vc: C.green),
                Text('سهم قسط نمی‌تواند کمتر از قسط بعدی (${toman(inst)}) باشد', style: ts(12, c: C.muted)),
              ])),
              ECard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('برداشت', style: ts(15, w: FontWeight.w700)),
                gap12,
                TextField(controller: amount, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'مبلغ (تومان)', fillColor: Colors.white, helperText: 'قابل برداشت: ${toman(app.b3)}')),
                KV('مقصد', maskSheba(app.sheba)),
                KV('کارمزد', toman(fee)),
                gap8,
                PrimaryButton('ثبت برداشت', icon: Icons.lock_outline, loading: busy, onPressed: cashOut),
              ])),
              if (receipt != null)
                ECard(color: C.greenBg, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [const Icon(Icons.check_circle, color: C.green), gap8, Text('برداشت ثبت شد', style: ts(15, w: FontWeight.w800, c: C.green))]),
                  KV('شناسه پیگیری', receipt!),
                  KV('زمان', '${jDate(DateTime.now())} · ${hm(DateTime.now())}'),
                ])),
            ],
          );
        },
      );
}

/// SCR-C-45 Loan installments & ledger
class LoanScreen extends StatelessWidget {
  const LoanScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          final inst = installment(400e6);
          return EPage(title: 'اقساط و تراکنش‌ها', children: [
            ECard(dark: true, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Text('قسط بعدی · بانک ملت', style: ts(13, c: Colors.white70)), const Spacer(), const Pill('کسر مستقیم فعال', tone: Tone.green)]),
              Text(toman(inst), style: ts(26, w: FontWeight.w800, c: Colors.white)),
              Text(jLong(DateTime(2026, 12, 6)), style: ts(13, c: Colors.white70)),
              gap12,
              const Bar(12 / 60, color: Colors.white, dark: true),
              gap8,
              Text('۱۲ از ۶۰ قسط', style: ts(12, c: Colors.white70)),
            ])),
            ECard(child: Column(children: [
              for (final d in const [('۱۵ شهریور', 'done'), ('۱۵ مهر', 'done'), ('۱۵ آبان', 'due')])
                Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
                  Expanded(child: Text(d.$1, style: ts(14, w: FontWeight.w600))),
                  Text(toman(inst), style: ts(13.5)),
                  gap8,
                  Pill(d.$2 == 'done' ? 'کسر شد' : 'در انتظار', tone: d.$2 == 'done' ? Tone.green : Tone.amber),
                ])),
            ])),
            SectionTitle('دفتر تراکنش‌ها', action: 'خروجی PDF', onAction: () => toast(context, 'فایل دفتر تراکنش‌ها آماده شد')),
            ECard(child: Column(children: [
              for (final t in app.ledger)
                Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
                  IconCircle(t.amount >= 0 ? Icons.south_west : Icons.north_east, size: 38, fg: t.amount >= 0 ? C.green : C.red),
                  gap12,
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t.title, style: ts(14, w: FontWeight.w600)), Text(jDate(t.at), style: ts(12, c: C.muted))])),
                  Text('${t.amount >= 0 ? '+' : ''}${num0(t.amount)}', style: ts(14, w: FontWeight.w800, c: t.amount >= 0 ? C.green : C.red)),
                ])),
            ])),
          ]);
        },
      );
}
