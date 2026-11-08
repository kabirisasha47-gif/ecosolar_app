import 'package:flutter/material.dart';
import 'package:ecosolar/core/fmt.dart';
import 'package:ecosolar/core/theme.dart';
import 'package:ecosolar/data/store.dart';
import 'package:ecosolar/screens/home.dart';
import 'package:ecosolar/screens/shell.dart';
import 'package:ecosolar/widgets/charts.dart';
import 'package:ecosolar/widgets/flows.dart';
import 'package:ecosolar/widgets/steps.dart';
import 'package:ecosolar/widgets/ui.dart';

const caseSteps = ['تشکیل پرونده', 'بارگذاری مدارک', 'تأیید اتصال شبکه', 'نصب توسط پیمانکار', 'نصب کنتور دوطرفه', 'امضای قرارداد', 'فعال‌سازی پایش'];

/// SCR-C-30 My plant overview
class PlantTab extends StatelessWidget {
  const PlantTab({super.key});
  static const tiles = [
    (Icons.construction_outlined, 'طراحی فنی', '/plant/design'),
    (Icons.battery_charging_full_outlined, 'باتری', '/plant/battery'),
    (Icons.insights_outlined, 'کانال درآمد', '/plant/channels'),
    (Icons.monitor_heart_outlined, 'پایش زنده', '/plant/monitoring'),
    (Icons.speed_outlined, 'تطبیق کنتور', '/plant/reconciliation'),
    (Icons.description_outlined, 'قرارداد', '/plant/contract'),
    (Icons.folder_special_outlined, 'پرونده مهرسان', '/plant/case'),
    (Icons.settings_outlined, 'سرویس و نگهداری', '/plant/maintenance'),
    (Icons.insert_drive_file_outlined, 'مدارک', '/plant/case'),
  ];
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => TabBody(
          header: const TabHeader('نیروگاه من'),
          children: [
            ECard(
              dark: true,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(app.plantName, style: ts(17, w: FontWeight.w800, c: Colors.white)),
                    gap8,
                    Pill(app.devicePaired ? 'در حال بهره‌برداری' : 'در حال راه‌اندازی', tone: app.devicePaired ? Tone.green : Tone.blue),
                  ])),
                  Container(width: 74, height: 74, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.solar_power, color: Colors.white, size: 40)),
                ]),
                gap16,
                StatRow([
                  Stat('ظرفیت', '${dec(app.kwp, 0)} kWp', dark: true),
                  Stat('باتری', app.storageOn ? '${dec(app.storageKwh, 0)} kWh' : '—', dark: true),
                  const Stat('مدل مالکیت', 'وام ساتبا', dark: true),
                ], dark: true),
              ]),
            ),
            ECard(
              onTap: () => Navigator.pushNamed(context, '/plant/case'),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Text('پرونده مهرسان', style: ts(14, w: FontWeight.w700)), const Spacer(), Text('${fa(app.caseStep)} از ۷', style: ts(13, c: C.muted))]),
                gap16,
                HStepper(steps: List.filled(7, ''), current: app.caseStep, showLabels: false),
                gap12,
                Text('گام فعلی: ${caseSteps[app.caseStep.clamp(0, 6)]}', style: ts(12.5, c: C.muted)),
              ]),
            ),
            const SectionTitle('بخش‌ها'),
            GridView.count(
              crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .95,
              children: [
                for (final t in tiles)
                  ECard(
                    padding: const EdgeInsets.all(10),
                    onTap: () => Navigator.pushNamed(context, t.$3),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      IconCircle(t.$1, size: 46),
                      gap8,
                      Text(t.$2, textAlign: TextAlign.center, maxLines: 2, style: ts(12, w: FontWeight.w600)),
                    ]),
                  ),
              ],
            ),
          ],
        ),
      );
}

/// SCR-C-31 Feasibility & technical design
class DesignScreen extends StatelessWidget {
  const DesignScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          final panels = (app.kwp * 1000 / 550).ceil();
          final monthly = [900.0, 1050, 1350, 1500, 1700, 1800, 1820, 1750, 1550, 1300, 1000, 880].map((v) => v * app.kwp / 10).toList();
          return EPage(
            title: 'طراحی فنی',
            bottom: PrimaryButton(app.requestSubmitted ? 'درخواست ثبت شد' : 'ثبت درخواست نیروگاه',
                onPressed: app.requestSubmitted
                    ? null
                    : () async {
                        if (await confirm(context, 'ثبت درخواست', 'طرح ${dec(app.kwp, 0)} کیلوواتی برای بررسی کارشناس و تشکیل پرونده ارسال می‌شود')) {
                          app.requestSubmitted = true;
                          app.touch();
                        }
                      }),
            children: [
              ECard(
                dark: true,
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Text('ظرفیت پیشنهادی', style: ts(13, c: Colors.white70)), gap8, const ScenarioTag(onDark: true)]),
                    Text('${dec(app.kwp, 0)} kWp', style: ts(32, w: FontWeight.w800, c: Colors.white)),
                    Slider(value: app.kwp, min: 3, max: 20, divisions: 17, onChanged: (v) { app.kwp = v; app.touch(); },
                        activeColor: Colors.white, inactiveColor: Colors.white24, thumbColor: Colors.white),
                    TextButton(
                      onPressed: () => showExplain(context, title: 'ظرفیت ${dec(app.kwp, 0)} کیلووات', inputs: [
                        ('مساحت بام', '${fa(app.roofArea.round())} m²'),
                        ('مصرف سالانه', kwh((app.bill['peak']! + app.bill['mid']! + app.bill['off']!) * 12)),
                        ('سقف وام ساتبا', '۱۰ kW'),
                        ('تابش کاشان', '۲٬۰۵۰ kWh/m²'),
                      ]),
                      child: Text('چرا این ظرفیت؟', style: ts(13, w: FontWeight.w700, c: Colors.white)),
                    ),
                  ])),
                  const Icon(Icons.roofing, color: Colors.white, size: 64),
                ]),
              ),
              GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2, children: [
                ECard(child: Stat('تعداد پنل ۵۵۰ وات', '${fa(panels)} عدد')),
                ECard(child: Stat('اینورتر هیبرید', '${dec(app.kwp, 0)} kW')),
                const ECard(child: Stat('امتیاز سایه', '۹۲٪')),
                const ECard(child: Stat('تطابق MPPT', 'مناسب')),
              ]),
              ECard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Text('شبیه‌سازی تولید ۱۲ ماه', style: ts(14, w: FontWeight.w700)), const Spacer(), const ScenarioTag()]),
                  gap12,
                  BarChart(groups: [for (final m in monthly) [m]], labels: [for (var i = 1; i <= 12; i++) fa(i)], height: 110),
                  gap8,
                  KV('تولید سالانه', kwh(monthly.fold(0.0, (a, b) => a + b)), bold: true),
                ]),
              ),
              ECard(
                child: Row(children: [
                  const IconCircle(Icons.engineering_outlined, size: 42),
                  gap12,
                  Expanded(child: Text('بازبینی کارشناس انرژی', style: ts(14, w: FontWeight.w600))),
                  Pill(app.requestSubmitted ? 'در انتظار بازبینی' : 'ارسال نشده', tone: app.requestSubmitted ? Tone.blue : Tone.grey),
                ]),
              ),
              Row(children: [
                Expanded(child: PrimaryButton('ارزیابی باتری', outlined: true, onPressed: () => Navigator.pushNamed(context, '/plant/battery'))),
                gap8,
                Expanded(child: PrimaryButton('مقایسه کانال‌ها', outlined: true, onPressed: () => Navigator.pushNamed(context, '/plant/channels'))),
              ]),
              PrimaryButton('شبیه‌ساز وام', outlined: true, onPressed: () => Navigator.pushNamed(context, '/finance/simulator')),
            ],
          );
        },
      );
}

/// SCR-C-32 Battery advisor
class BatteryScreen extends StatelessWidget {
  const BatteryScreen({super.key});
  static const all = ['یخچال', 'روشنایی', 'مودم و اینترنت', 'کولر', 'پمپ آب'];
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => EPage(
          title: 'مشاور باتری',
          bottom: PrimaryButton('تأیید پیکربندی', onPressed: () {
            toast(context, 'پیکربندی ذخیره‌ساز ذخیره شد');
            Navigator.pop(context);
          }),
          children: [
            ECard(child: SwitchListTile(contentPadding: EdgeInsets.zero, secondary: const Icon(Icons.battery_charging_full), title: Text('ارزیابی ذخیره‌ساز', style: ts(15, w: FontWeight.w600)), value: app.storageOn, onChanged: (v) { app.storageOn = v; app.touch(); })),
            if (app.storageOn) ...[
              ECard(
                dark: true,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('ظرفیت باتری', style: ts(13, c: Colors.white70)),
                  Text('${dec(app.storageKwh, 1)} kWh', style: ts(32, w: FontWeight.w800, c: Colors.white)),
                  Slider(value: app.storageKwh, min: 2.5, max: 30, divisions: 11, onChanged: (v) { app.storageKwh = v; app.touch(); }, activeColor: Colors.white, inactiveColor: Colors.white24, thumbColor: Colors.white),
                  Text('حداقل مجاز برای تعرفه باتری: ${dec(app.minStorage, 1)} kWh (۱٫۵ برابر ظرفیت)', style: ts(12.5, c: Colors.white70)),
                  gap8,
                  Pill(app.batteryTariffOk ? 'شرط تعرفه باتری برقرار است' : 'کمتر از حد مجاز؛ تعرفه باتری غیرفعال', tone: app.batteryTariffOk ? Tone.green : Tone.red),
                ]),
              ),
              ECard(
                child: Row(children: [
                  const Expanded(child: Column(children: [Stat('FiT پایه', '۱۸۰ م.ت')])),
                  Container(width: 1, height: 40, color: C.line),
                  Expanded(child: Column(children: [Stat('FiT باتری', app.batteryTariffOk ? '۲۳۰ م.ت' : 'غیرمجاز'), if (app.batteryTariffOk) const Pill('پیشنهادی', tone: Tone.green)])),
                ]),
              ),
              ECard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('مدارهای اضطراری (۲ ساعت خاموشی)', style: ts(14, w: FontWeight.w700)),
                  for (final c in all)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading,
                      title: Text(c, style: ts(14)), value: app.circuits.contains(c),
                      onChanged: (v) { v == true ? app.circuits.add(c) : app.circuits.remove(c); app.touch(); },
                    ),
                ]),
              ),
            ],
            const Notice('شارژ باتری از شبکه و فروش با تعرفه باتری ممنوع است'),
          ],
        ),
      );
}
