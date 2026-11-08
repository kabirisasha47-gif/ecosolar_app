import 'package:flutter/material.dart';
import 'package:ecosolar/core/fmt.dart';
import 'package:ecosolar/core/theme.dart';
import 'package:ecosolar/data/models.dart';
import 'package:ecosolar/data/store.dart';
import 'package:ecosolar/screens/home.dart';
import 'package:ecosolar/screens/shell.dart';
import 'package:ecosolar/widgets/charts.dart';
import 'package:ecosolar/widgets/flows.dart';
import 'package:ecosolar/widgets/ui.dart';

/// SCR-C-20 Consumption & temperature (Agent service 1)
class ConsumptionTab extends StatelessWidget {
  const ConsumptionTab({super.key});

  static const bills = [('مهر ۱۴۰۵', 670, 1850000), ('شهریور ۱۴۰۵', 910, 2640000), ('مرداد ۱۴۰۵', 980, 2910000)];

  Future<void> custom(BuildContext c, Rec r) async {
    var v = 25.0;
    final ok = await sheet<bool>(
      c,
      StatefulBuilder(
        builder: (ctx, set) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('شخصی‌سازی: ${r.title}', style: ts(17, w: FontWeight.w800)),
          gap12,
          KV('دمای هدف', '${fa(v.round())} درجه'),
          Slider(value: v, min: 22, max: 28, divisions: 6, onChanged: (x) => set(() => v = x)),
          gap12,
          PrimaryButton('ذخیره', onPressed: () => Navigator.pop(ctx, true)),
        ]),
      ),
    );
    if (ok == true) app.setRec(r, 'custom');
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          final total = app.bill['peak']! + app.bill['mid']! + app.bill['off']!;
          final pctSave = (app.savingKwh / total * 100).clamp(0, 35);
          return TabBody(
            header: const TabHeader('مصرف و دما'),
            children: [
              ECard(
                dark: true,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Text('صرفه‌جویی پیش‌بینی‌شده', style: ts(13, c: Colors.white70)), const Spacer(), const ScenarioTag(onDark: true)]),
                  Text(pct(pctSave == 0 ? 28 : pctSave), style: ts(36, w: FontWeight.w800, c: Colors.white)),
                  Text(app.savingKwh == 0 ? 'با پذیرش پیشنهادها تا ۳۲۰ kWh در ماه' : '${kwh(app.savingKwh)} در ماه · ${toman(app.savingKwh * 2750)}',
                      style: ts(13, c: Colors.white70)),
                  gap16,
                  PrimaryButton('اسکن قبض جدید', light: true, icon: Icons.photo_camera_outlined, onPressed: () => Navigator.pushNamed(context, '/onboarding/profile')),
                ]),
              ),
              ECard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('پروفایل ۲۴ ساعته', style: ts(14, w: FontWeight.w700)),
                  gap8,
                  const Legend([('مصرف', C.black), ('دمای هوا', C.blue)]),
                  gap12,
                  LineChart(series: const [
                    Series([.6, .5, .5, .5, .6, .8, 1, 1.1, 1.2, 1.3, 1.6, 1.9, 2.3, 2.5, 2.6, 2.5, 2.2, 1.9, 1.8, 1.9, 1.7, 1.4, 1, .8]),
                    Series([24, 23, 22, 22, 23, 25, 27, 29, 31, 33, 35, 37, 38, 39, 39, 38, 36, 34, 32, 30, 28, 27, 26, 25], color: C.blue, dashed: true),
                  ], labels: [for (final h in [0, 6, 12, 18, 24]) fa(h)]),
                ]),
              ),
              const SectionTitle('پیشنهادهای هوشمند'),
              for (final r in app.recs)
                ECard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Row(children: [
                      IconCircle(r.id == 'r1' ? Icons.thermostat : (r.id == 'r2' ? Icons.schedule : Icons.wb_shade), size: 42),
                      gap12,
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r.title, style: ts(14.5, w: FontWeight.w700)),
                        Text(r.desc, style: ts(12.5, c: C.muted)),
                      ])),
                    ]),
                    gap12,
                    if (r.state == 'new')
                      Row(children: [
                        Expanded(child: PrimaryButton('پذیرش', onPressed: () => app.setRec(r, 'accepted'))),
                        gap8,
                        Expanded(child: PrimaryButton('شخصی‌سازی', outlined: true, onPressed: () => custom(context, r))),
                        gap8,
                        Expanded(
                          child: PrimaryButton('چرا؟', outlined: true, onPressed: () async {
                            final res = await showExplain(context, title: r.title, inputs: [
                              ('داده ورودی', 'قبض ۳ ماه اخیر و دمای کاشان'),
                              ('صرفه‌جویی برآوردی', kwh(r.kwhSaving)),
                              ('نسخه جدول نرخ', '۱۴۰۵.۲'),
                            ], note: r.why);
                            if (res == 'accept') app.setRec(r, 'accepted');
                            if (res == 'reject') app.setRec(r, 'rejected');
                            if (res == 'custom' && context.mounted) custom(context, r);
                          }),
                        ),
                      ])
                    else
                      Row(children: [
                        Pill(switch (r.state) { 'accepted' => 'پذیرفته شد', 'custom' => 'شخصی‌سازی شد', _ => 'رد شد' },
                            tone: r.state == 'rejected' ? Tone.grey : Tone.green),
                        const Spacer(),
                        TextButton(onPressed: () => app.setRec(r, 'new'), child: Text('تغییر تصمیم', style: ts(13, w: FontWeight.w700))),
                      ]),
                  ]),
                ),
              ECard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('صرفه‌جویی محقق‌شده', style: ts(14, w: FontWeight.w700)),
                  gap8,
                  const Legend([('رفتاری', C.green), ('اثر آب‌وهوا', C.grey)]),
                  gap12,
                  const BarChart(groups: [[40, 10], [55, 12], [70, 18], [62, 20], [80, 15], [95, 14]], colors: [C.green, C.grey], labels: ['فر', 'ار', 'خر', 'تی', 'مر', 'شه'], height: 100),
                ]),
              ),
              const SectionTitle('قبض‌های اخیر'),
              ECard(
                child: Column(children: [
                  for (final b in bills) KV('${b.$1} · ${kwh(b.$2)}', toman(b.$3)),
                ]),
              ),
              TextButton(onPressed: () => MainShell.tab.value = 2, child: Text('برای کاهش بیشتر، نیروگاه خورشیدی را بررسی کنید', style: ts(13, w: FontWeight.w700))),
            ],
          );
        },
      );
}
