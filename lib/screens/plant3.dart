import 'package:flutter/material.dart';
import 'package:ecosolar/core/fmt.dart';
import 'package:ecosolar/core/jalali.dart';
import 'package:ecosolar/core/theme.dart';
import 'package:ecosolar/data/models.dart';
import 'package:ecosolar/data/store.dart';
import 'package:ecosolar/screens/home.dart';
import 'package:ecosolar/widgets/charts.dart';
import 'package:ecosolar/widgets/flows.dart';
import 'package:ecosolar/widgets/steps.dart';
import 'package:ecosolar/widgets/ui.dart';

/// SCR-C-36 Live generation monitoring
class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});
  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  int period = 0;
  static const List<double> day = [0.0, 0, 0, 0, 0, .2, .9, 2.1, 3.4, 4.5, 5.3, 5.9, 6.2, 6.1, 5.7, 4.9, 3.8, 2.4, 1, .2, 0, 0, 0, 0];
  static const List<double> temp = [22.0, 21, 20, 20, 21, 23, 26, 28, 31, 33, 35, 37, 38, 39, 39, 38, 36, 34, 31, 29, 27, 25, 24, 23];
  List<double> get data => switch (period) {
        0 => day,
        1 => const <double>[38, 41, 36, 44, 29, 40, 26],
        2 => [for (var i = 0; i < 30; i++) 30 + (i * 7 % 13).toDouble()],
        _ => const <double>[900, 1050, 1350, 1500, 1700, 1800, 1820, 1750, 1550, 1300, 1000, 880],
      };
  @override
  Widget build(BuildContext context) {
    final total = data.fold(0.0, (a, b) => a + b);
    return ListenableBuilder(
      listenable: app,
      builder: (_, __) {
        final dust = app.notifs.any((n) => n.cat == 'فنی' && !n.read) || app.workOrders.any((w) => w.status == 'awaiting');
        return EPage(
          title: 'پایش تولید',
          children: [
            Segmented(items: const ['امروز', 'هفته', 'ماه', 'سال'], value: period, onChanged: (v) => setState(() => period = v)),
            ECard(
              dark: true,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(period == 0 ? '${dec(Live.kw)} kW' : kwh(total), style: ts(30, w: FontWeight.w800, c: Colors.white)),
                  const Spacer(),
                  if (period == 0) const Pill('زنده', tone: Tone.green, icon: Icons.circle),
                ]),
                gap8,
                if (period == 0) const Legend([('تولید', Colors.white), ('دمای محیط', C.blue)], dark: true),
                gap12,
                period == 0
                    ? LineChart(series: const [Series(day, color: Colors.white, fill: true), Series(temp, color: C.blue, dashed: true)], labels: [for (final h in [0, 6, 12, 18, 24]) fa(h)], dark: true)
                    : BarChart(groups: [for (final v in data) [v]], colors: const [Colors.white], dark: true, height: 140),
              ]),
            ),
            Row(children: [
              Expanded(child: ECard(padding: const EdgeInsets.all(14), child: Stat('تولید امروز', '${dec(Live.today)} kWh'))),
              gap8,
              const Expanded(child: ECard(padding: EdgeInsets.all(14), child: Stat('نسبت عملکرد', '۸۲٪'))),
              gap8,
              const Expanded(child: ECard(padding: EdgeInsets.all(14), child: Stat('دما', '۳۱°'))),
            ]),
            ECard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const IconCircle(Icons.developer_board, size: 40), gap12, Expanded(child: Text('اینورتر', style: ts(15, w: FontWeight.w700))), Pill(app.devicePaired ? 'آنلاین' : 'متصل نشده', tone: app.devicePaired ? Tone.green : Tone.grey)]),
                gap8,
                KV('آخرین ارتباط', hm(Live.at)),
                const KV('کد وضعیت', 'نرمال (۰)'),
                Align(alignment: Alignment.centerRight, child: Freshness(Live.at)),
              ]),
            ),
            if (dust)
              ECard(
                color: C.redBg,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [const Icon(Icons.warning_amber_rounded, color: C.red), gap8, Expanded(child: Text('گرد و غبار روی پنل‌ها؛ افت ۱۸٪', style: ts(14, w: FontWeight.w700, c: C.red)))]),
                  gap12,
                  PrimaryButton('ثبت دستور کار سرویس', onPressed: () => Navigator.pushNamed(context, '/plant/maintenance')),
                ]),
              ),
            ECard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('رویدادها', style: ts(15, w: FontWeight.w700)),
                gap12,
                VTimeline([
                  TItem('شروع تولید', '۰۶:۱۲', 2),
                  TItem('اوج تولید ۶٫۲ kW', '۱۲:۰۵', 2),
                  TItem('هشدار افت عملکرد', '۱۴:۳۰', dust ? 1 : 2),
                ]),
              ]),
            ),
          ],
        );
      },
    );
  }
}

/// SCR-C-37 Meter reconciliation (MRV)
class ReconScreen extends StatelessWidget {
  const ReconScreen({super.key});
  @override
  Widget build(BuildContext context) {
    const List<double> inv = [310.0, 295, 330, 305];
    const List<double> meter = [306.0, 290, 327, 299];
    const List<double> bill = [306.0, 290, 327, 299];
    final ti = inv.fold(0.0, (a, b) => a + b), tm = meter.fold(0.0, (a, b) => a + b);
    final diff = (ti - tm) / tm * 100;
    final ok = diff.abs() <= 3;
    return EPage(
      title: 'تطبیق کنتور',
      children: [
        const Align(alignment: Alignment.centerRight, child: Pill('مهر ۱۴۰۵', icon: Icons.calendar_month_outlined)),
        ECard(
          dark: true,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Pill(ok ? 'منطبق' : 'مغایرت', tone: ok ? Tone.green : Tone.red),
            gap8,
            Text('اختلاف ${pct(diff.abs(), 1)}', style: ts(30, w: FontWeight.w800, c: Colors.white)),
            Text('حد مجاز ۳٪', style: ts(13, c: Colors.white70)),
          ]),
        ),
        ECard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('مقایسه سه‌گانه', style: ts(14, w: FontWeight.w700)),
            gap8,
            const Legend([('اینورتر', C.black), ('کنتور شبکه', C.blue), ('صورتحساب', C.grey)]),
            gap12,
            BarChart(groups: [for (var i = 0; i < 4; i++) [inv[i], meter[i], bill[i]]], colors: const [C.black, C.blue, C.grey], labels: const ['هفته ۱', 'هفته ۲', 'هفته ۳', 'هفته ۴']),
          ]),
        ),
        GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2, children: [
          const ECard(child: Stat('واردات', '۱۲۰ kWh')),
          ECard(child: Stat('صادرات', kwh(tm - 980))),
          const ECard(child: Stat('مصرف محلی', '۵۴۰ kWh')),
          ECard(child: Stat('تزریق خالص', kwh(tm - 980 - 120))),
        ]),
        const Notice('مبنای تسویه فقط قرائت کنتور رسمی شرکت توزیع است', tone: Tone.blue, icon: Icons.info_outline),
        PrimaryButton('گزارش مغایرت', outlined: true, onPressed: () => Navigator.pushNamed(context, '/support')),
      ],
    );
  }
}

/// SCR-C-38 Service & maintenance (O&M)
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  Widget photo(String label, bool clean) => Expanded(
        child: Column(children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: clean ? const [Color(0xFF1E3A8A), Color(0xFF3B82F6)] : const [Color(0xFF8B7355), Color(0xFFC4A57B)]),
            ),
            child: GridView.count(crossAxisCount: 4, padding: const EdgeInsets.all(10), mainAxisSpacing: 4, crossAxisSpacing: 4, physics: const NeverScrollableScrollPhysics(),
                children: List.generate(8, (_) => Container(decoration: BoxDecoration(color: Colors.white.withOpacity(clean ? .25 : .1), borderRadius: BorderRadius.circular(3))))),
          ),
          gap8,
          Text(label, style: ts(12.5, w: FontWeight.w600)),
        ]),
      );

  Tone tone(String s) => s == 'done' ? Tone.green : (s == 'awaiting' ? Tone.amber : Tone.blue);
  String label(String s) => s == 'done' ? 'انجام‌شده' : (s == 'awaiting' ? 'منتظر تأیید' : 'برنامه‌ریزی‌شده');

  Future<void> approve(BuildContext c, WorkOrder w) async {
    if (await confirm(c, 'تأیید کار و آزادسازی پرداخت', '${toman(w.cost)} از ذخیره سرویس به ${w.installer} پرداخت می‌شود')) {
      app.approveWorkOrder(w);
      for (final n in app.notifs) {
        if (n.cat == 'فنی') n.read = true;
      }
      app.touch();
      if (c.mounted) toast(c, 'پرداخت آزاد شد');
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          final pending = app.workOrders.where((w) => w.status == 'awaiting').toList();
          final recovered = pending.isEmpty;
          return EPage(
            title: 'سرویس و نگهداری',
            children: [
              ECard(
                dark: true,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('شاخص سلامت نیروگاه', style: ts(13, c: Colors.white70)),
                  Row(children: [Text(recovered ? '۹۴٪' : '۸۲٪', style: ts(32, w: FontWeight.w800, c: Colors.white)), gap12, if (recovered) const Pill('+۱۲٪ پس از شست‌وشو', tone: Tone.green)]),
                  gap8,
                  LineChart(series: [Series(recovered ? const <double>[94, 92, 88, 84, 82, 83, 94, 95] : const <double>[94, 92, 88, 84, 82, 83, 82, 82], color: Colors.white, fill: true)], height: 70, dark: true),
                  const KV('میانگین زمان تعمیر', '۱٫۸ روز', dark: true),
                ]),
              ),
              for (final w in pending)
                ECard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Row(children: [Expanded(child: Text(w.type, style: ts(15, w: FontWeight.w700))), Pill(label(w.status), tone: tone(w.status))]),
                    gap12,
                    Row(children: [photo('قبل', false), gap12, photo('بعد', true)]),
                    gap12,
                    Row(children: [Avatar(w.installer, size: 36), gap8, Expanded(child: Text('نصاب: ${w.installer}', style: ts(13.5))), const Pill('تأیید ساتبا', tone: Tone.blue)]),
                    KV('هزینه', toman(w.cost), bold: true),
                    gap8,
                    PrimaryButton('تأیید و آزادسازی پرداخت', onPressed: () => approve(context, w)),
                  ]),
                ),
              const SectionTitle('دستور کارها'),
              for (final w in app.workOrders.where((w) => w.status != 'awaiting'))
                ECard(
                  child: Row(children: [
                    IconCircle(w.status == 'done' ? Icons.check : Icons.build_outlined, size: 40),
                    gap12,
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(w.type, style: ts(14, w: FontWeight.w700)), Text('${w.installer} · ${w.date}', style: ts(12, c: C.muted))])),
                    Pill(label(w.status), tone: tone(w.status)),
                  ]),
                ),
              PrimaryButton('درخواست سرویس جدید', outlined: true, icon: Icons.add, onPressed: () {
                app.workOrders.insert(0, WorkOrder('WO-${310 + app.workOrders.length}', 'شست‌وشوی پنل‌ها', 'علی رضایی', jLong(DateTime.now().add(const Duration(days: 3))), 850000, 'scheduled'));
                app.touch();
                toast(context, 'درخواست ثبت و به نصاب ارجاع شد');
              }),
            ],
          );
        },
      );
}
