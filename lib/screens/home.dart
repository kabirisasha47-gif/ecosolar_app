import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ecosolar/core/fmt.dart';
import 'package:ecosolar/core/jalali.dart';
import 'package:ecosolar/core/theme.dart';
import 'package:ecosolar/data/store.dart';
import 'package:ecosolar/screens/shell.dart';
import 'package:ecosolar/widgets/charts.dart';
import 'package:ecosolar/widgets/ui.dart';

class Live {
  static double kw = 4.8, today = 26, load = 18;
  static DateTime at = DateTime.now();
  static double get export => math.max(0, today - load);
}

class BellButton extends StatelessWidget {
  const BellButton({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/notifications'),
          child: Stack(clipBehavior: Clip.none, children: [
            Container(width: 46, height: 46, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: C.line)), child: const Icon(Icons.notifications_none_rounded)),
            if (app.unread > 0) Positioned(top: 10, left: 12, child: Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFFFF4D4D), shape: BoxShape.circle))),
          ]),
        ),
      );
}

class TabHeader extends StatelessWidget {
  final String title;
  const TabHeader(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: Text(title, style: ts(22, w: FontWeight.w800))), const BellButton()]);
}

/// CMP-07 DataFreshnessIndicator
class Freshness extends StatelessWidget {
  final DateTime at;
  const Freshness(this.at, {super.key});
  @override
  Widget build(BuildContext context) {
    final stale = DateTime.now().difference(at).inMinutes > 15;
    return Pill(stale ? 'آخرین داده ${hm(at)}' : 'به‌روز ${hm(at)}', tone: stale ? Tone.amber : Tone.green, icon: Icons.circle);
  }
}

/// SCR-C-10 Home dashboard
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Timer? t;
  final rnd = math.Random();
  @override
  void initState() {
    super.initState();
    t = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {
        Live.kw = (4.2 + rnd.nextDouble() * 1.2);
        Live.today += Live.kw * 5 / 3600;
        Live.at = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  Widget nextAction() {
    final (String title, String btn, String route) = !app.contractSigned
        ? ('برای شروع درآمد، قرارداد کانال را امضا کنید', 'امضای قرارداد', app.channel == null ? '/plant/channels' : '/plant/contract')
        : app.workOrders.any((w) => w.status == 'awaiting')
            ? ('سفارش شست‌وشوی پنل‌ها منتظر تأیید شماست', 'تأیید سفارش شست‌وشو', '/plant/maintenance')
            : ('پرونده مهرسان را پیگیری کنید', 'مشاهده پرونده', '/plant/case');
    return ECard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [const IconCircle(Icons.bolt_outlined), gap12, Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('اقدام بعدی', style: ts(12, c: C.muted)), Text(title, style: ts(14, w: FontWeight.w700))]))]),
        gap12,
        PrimaryButton(btn, onPressed: () => Navigator.pushNamed(context, route)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => TabBody(
          header: Row(children: [
            Avatar(app.name, size: 46),
            gap12,
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('سلام، ${app.name.split(' ').first}', style: ts(17, w: FontWeight.w800)),
              Row(children: [const Icon(Icons.location_on_outlined, size: 15, color: C.muted), Text(app.city, style: ts(12.5, c: C.muted))]),
            ])),
            const BellButton(),
          ]),
          children: [
            Align(alignment: Alignment.centerRight, child: Freshness(Live.at)),
            ECard(
              dark: true,
              onTap: () => Navigator.pushNamed(context, '/plant/monitoring'),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Text('توان لحظه‌ای', style: ts(13, c: Colors.white70)), const Spacer(), const Icon(Icons.wb_sunny_outlined, color: Color(0xFFF59E0B))]),
                Text('${dec(Live.kw)} kW', style: ts(34, w: FontWeight.w800, c: Colors.white)),
                gap16,
                StatRow([
                  Stat('تولید امروز', '${dec(Live.today)} kWh', dark: true),
                  Stat('مصرف', '${dec(Live.load)} kWh', dark: true),
                  Stat('صادرات', '${dec(Live.export)} kWh', dark: true),
                ], dark: true),
                gap16,
                PrimaryButton('پایش زنده', light: true, icon: Icons.monitor_heart_outlined, onPressed: () => Navigator.pushNamed(context, '/plant/monitoring')),
              ]),
            ),
            ECard(
              onTap: () => MainShell.tab.value = 3,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Text('درآمد این ماه', style: ts(13, c: C.muted)), const Spacer(), const ScenarioTag()]),
                Text(toman(12.4e6), style: ts(22, w: FontWeight.w800)),
                gap8,
                Wrap(spacing: 8, children: [Pill('تسویه‌شده ${mt(app.settled)}', tone: Tone.green), Pill('در انتظار ${mt(app.pending)}', tone: Tone.amber)]),
                gap12,
                const Bar(.62),
                gap8,
                Text('پرداخت بعدی: ۱۵ آذر · کانال ${app.channel == null ? 'انتخاب نشده' : app.channels.firstWhere((c) => c.id == app.channel).name}', style: ts(12, c: C.muted)),
              ]),
            ),
            ECard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('تولید ۷ روز اخیر', style: ts(14, w: FontWeight.w700)),
                gap12,
                BarChart(groups: const [[38], [41], [36], [44], [29], [40], [26]], labels: const ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'], height: 90),
              ]),
            ),
            if (app.notifs.any((n) => !n.read && n.cat == 'فنی'))
              ECard(
                color: C.redBg,
                onTap: () => Navigator.pushNamed(context, '/plant/monitoring'),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded, color: C.red),
                  gap12,
                  Expanded(child: Text(app.notifs.firstWhere((n) => !n.read && n.cat == 'فنی').title, style: ts(14, w: FontWeight.w700, c: C.red))),
                  const Icon(Icons.chevron_left, color: C.red),
                ]),
              ),
            nextAction(),
          ],
        ),
      );
}

/// SCR-C-62 Notifications center
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int f = 0;
  static const cats = ['همه', 'فنی', 'مالی', 'مقرراتی', 'اقدام لازم'];
  Tone tone(String c) => switch (c) { 'فنی' => Tone.red, 'مالی' => Tone.amber, 'مقرراتی' => Tone.blue, _ => Tone.black };
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          final list = app.notifs.where((n) => f == 0 || n.cat == cats[f]).toList();
          return EPage(
            title: 'اعلان‌ها',
            actions: [TextButton(onPressed: app.readAll, child: Text('خواندن همه', style: ts(13, w: FontWeight.w700)))],
            children: [
              ChipsRow(items: cats, value: f, onChanged: (v) => setState(() => f = v)),
              if (list.isEmpty) Padding(padding: const EdgeInsets.all(40), child: Text('اعلانی وجود ندارد', textAlign: TextAlign.center, style: ts(14, c: C.muted))),
              for (final n in list)
                ECard(
                  onTap: () {
                    n.read = true;
                    app.touch();
                    Navigator.pushNamed(context, n.route);
                  },
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    IconCircle(n.cat == 'فنی' ? Icons.warning_amber_rounded : (n.cat == 'مالی' ? Icons.receipt_long_outlined : Icons.assignment_outlined), size: 42),
                    gap12,
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(n.title, style: ts(14.5, w: n.read ? FontWeight.w500 : FontWeight.w800)),
                      Text(n.body, style: ts(12.5, c: C.muted)),
                      gap8,
                      Row(children: [Pill(n.cat, tone: tone(n.cat)), const Spacer(), Text('${jDate(n.at)} · ${hm(n.at)}', style: ts(11.5, c: C.muted))]),
                    ])),
                    if (!n.read) Container(margin: const EdgeInsets.only(right: 8, top: 6), width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFFFF4D4D), shape: BoxShape.circle)),
                  ]),
                ),
            ],
          );
        },
      );
}
