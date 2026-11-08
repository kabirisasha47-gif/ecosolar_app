import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ecosolar/core/fmt.dart';
import 'package:ecosolar/core/jalali.dart';
import 'package:ecosolar/core/theme.dart';
import 'package:ecosolar/core/validators.dart';
import 'package:ecosolar/data/models.dart';
import 'package:ecosolar/data/store.dart';
import 'package:ecosolar/screens/home.dart';
import 'package:ecosolar/screens/shell.dart';
import 'package:ecosolar/widgets/charts.dart';
import 'package:ecosolar/widgets/flows.dart';
import 'package:ecosolar/widgets/ui.dart';

const loanRate = .14, loanMonths = 60;
double installment(double p) {
  const r = loanRate / 12;
  return p * r / (1 - math.pow(1 + r, -loanMonths));
}

const year1Revenue = 3.8e6; // toman / month

(String, Tone) invStatus(String s) => switch (s) {
      'ISSUED' => ('صادرشده', Tone.amber),
      'ADVANCED' => ('پیش‌پرداخت', Tone.blue),
      'SETTLED' => ('تسویه', Tone.green),
      'OVERDUE' => ('معوق', Tone.red),
      _ => ('پیش‌نویس', Tone.grey),
    };

/// SCR-C-40 Revenue & wallet overview
class RevenueTab extends StatelessWidget {
  const RevenueTab({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          final dscr = year1Revenue / installment(400e6);
          return TabBody(
            header: const TabHeader('درآمد و کیف پول'),
            children: [
              ECard(
                dark: true,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Text('درآمد تسویه‌شده', style: ts(13, c: Colors.white70)), const Spacer(), Pill(app.channel == null ? 'بدون کانال' : app.channels.firstWhere((c) => c.id == app.channel).name, tone: Tone.grey)]),
                  Text(toman(app.settled), style: ts(28, w: FontWeight.w800, c: Colors.white)),
                  gap16,
                  Row(children: [
                    Expanded(child: PrimaryButton('برداشت', light: true, onPressed: () => Navigator.pushNamed(context, '/wallet'))),
                    gap8,
                    Expanded(child: PrimaryButton('صورتحساب‌ها', light: true, onPressed: () => Navigator.pushNamed(context, '/revenue/invoices'))),
                  ]),
                ]),
              ),
              Row(children: [
                Expanded(child: ECard(color: C.greenBg, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('تسویه‌شده', style: ts(12, c: C.green)), Text(mt(app.settled), style: ts(17, w: FontWeight.w800, c: C.green))]))),
                gap12,
                Expanded(child: ECard(color: C.amberBg, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('در انتظار', style: ts(12, c: C.amber)), Text(mt(app.pending), style: ts(17, w: FontWeight.w800, c: C.amber))]))),
              ]),
              ECard(
                child: Column(children: [
                  Gauge(value: dscr, center: pct(dscr * 100), caption: 'پوشش قسط سال اول'),
                  gap8,
                  PrimaryButton('چه کنم؟', outlined: true, onPressed: () => Navigator.pushNamed(context, '/finance/simulator')),
                ]),
              ),
              ECard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Text('پیش‌بینی جریان نقدی', style: ts(14, w: FontWeight.w700)), const Spacer(), const ScenarioTag()]),
                  gap12,
                  const LineChart(series: [Series([3.8, 4.1, 4.6, 5.2, 5.7, 6.3, 7.1], fill: true)], height: 100),
                ]),
              ),
              GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.4, children: [
                for (final t in const [(Icons.receipt_long_outlined, 'صورتحساب‌ها', '/revenue/invoices'), (Icons.fast_forward_outlined, 'پیش‌پرداخت', '/revenue/advance'), (Icons.savings_outlined, 'کیف پول هوشمند', '/wallet'), (Icons.account_balance_outlined, 'اقساط و تراکنش‌ها', '/revenue/loan')])
                  ECard(padding: const EdgeInsets.all(12), onTap: () => Navigator.pushNamed(context, t.$3), child: Row(children: [IconCircle(t.$1, size: 38), gap8, Expanded(child: Text(t.$2, style: ts(13, w: FontWeight.w700)))])),
              ]),
            ],
          );
        },
      );
}

/// SCR-C-41 Invoices & receivables
class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});
  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  int f = 0;
  static const filters = ['همه', 'صادرشده', 'تسویه', 'پیش‌پرداخت'];
  static const codes = ['', 'ISSUED', 'SETTLED', 'ADVANCED'];
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          final list = app.invoices.where((i) => f == 0 || i.status == codes[f]).toList();
          final aging = app.invoices.where((i) => i.status == 'ISSUED' && i.agingDays > 30);
          return EPage(title: 'صورتحساب‌ها', children: [
            ChipsRow(items: filters, value: f, onChanged: (v) => setState(() => f = v)),
            if (aging.isNotEmpty) Notice('${fa(aging.first.agingDays)} روز تأخیر در وصول مطالبات؛ می‌توانید پیش‌پرداخت بگیرید', tone: Tone.amber, icon: Icons.schedule),
            for (final i in list)
              ECard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [
                    Expanded(child: Text(i.period, style: ts(15, w: FontWeight.w800))),
                    if (i.agingDays > 0 && i.status == 'ISSUED') ...[Pill('${fa(i.agingDays)} روز', tone: Tone.amber), gap8],
                    Pill(invStatus(i.status).$1, tone: invStatus(i.status).$2),
                  ]),
                  gap8,
                  KV('انرژی پذیرفته‌شده', kwh(i.kwh)),
                  KV('ناخالص', toman(i.gross)),
                  KV('کسورات', toman(i.deductions)),
                  KV('خالص پرداختی', toman(i.net), bold: true),
                  gap8,
                  Row(children: [
                    if (i.status == 'ISSUED') Expanded(child: PrimaryButton('درخواست پیش‌پرداخت', onPressed: () => Navigator.pushNamed(context, '/revenue/advance', arguments: i))) else const Spacer(),
                    gap8,
                    IconButton.outlined(onPressed: () => toast(context, 'فایل PDF صورتحساب ${i.id} آماده شد'), icon: const Icon(Icons.download)),
                  ]),
                ]),
              ),
          ]);
        },
      );
}

/// SCR-C-42 Early receivable advance
class AdvanceScreen extends StatefulWidget {
  const AdvanceScreen({super.key});
  @override
  State<AdvanceScreen> createState() => _AdvanceScreenState();
}

class _AdvanceScreenState extends State<AdvanceScreen> {
  double? amount;
  bool agree = false;
  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final candidates = app.invoices.where((x) => x.status == 'ISSUED');
    final Invoice? inv = arg is Invoice ? arg : (candidates.isEmpty ? null : candidates.first);
    if (inv == null || inv.status != 'ISSUED') {
      return EPage(title: 'پیش‌پرداخت مطالبات', children: [Text('صورتحساب صادرشده‌ای برای پیش‌پرداخت وجود ندارد', style: ts(14, c: C.muted))]);
    }
    const k = .85, rBank = .23;
    final max = inv.net * k;
    final a = amount ?? max * .9;
    final fee = a * rBank * (inv.agingDays + 60) / 365;
    return EPage(
      title: 'پیش‌پرداخت مطالبات',
      bottom: PrimaryButton('تأیید و درخواست', icon: Icons.lock_outline, onPressed: !agree
          ? null
          : () async {
              final otp = await showMfa(context, action: 'پیش‌پرداخت ${inv.period}', amount: toman(a - fee));
              if (otp == null) return;
              app.advance(inv, a, fee);
              if (!context.mounted) return;
              toast(context, 'درخواست پیش‌پرداخت ثبت شد');
              Navigator.pop(context);
            }),
      children: [
        ECard(
          dark: true,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const IconCircle(Icons.account_balance, size: 36), gap8, Text('بانک ملت', style: ts(14, w: FontWeight.w700, c: Colors.white))]),
            gap12,
            Text('مبلغ درخواستی', style: ts(13, c: Colors.white70)),
            Text(toman(a), style: ts(26, w: FontWeight.w800, c: Colors.white)),
            Slider(value: a, min: max * .2, max: max, onChanged: (v) => setState(() => amount = v), activeColor: Colors.white, inactiveColor: Colors.white24, thumbColor: Colors.white),
            Text('حداکثر ${toman(max)}', style: ts(12.5, c: Colors.white70)),
          ]),
        ),
        ECard(child: Column(children: [
          KV('صورتحساب', '${inv.period} · ${toman(inv.net)}'),
          KV('ضریب تنزیل', pct(k * 100)),
          KV('کارمزد بانک (نرخ ${pct(rBank * 100)})', toman(fee)),
          const Divider(),
          KV('خالص دریافتی', toman(a - fee), bold: true, vc: C.green),
        ])),
        ECard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('واگذاری مطالبه', style: ts(14, w: FontWeight.w700)),
          Text('حق دریافت این صورتحساب از ساتبا به بانک ملت واگذار می‌شود', style: ts(13, c: C.muted)),
          CheckboxListTile(contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading, value: agree, onChanged: (v) => setState(() => agree = v ?? false), title: Text('با واگذاری موافقم', style: ts(14))),
        ])),
      ],
    );
  }
}
