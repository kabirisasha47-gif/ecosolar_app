import 'package:flutter/material.dart';
import 'package:ecosolar/core/fmt.dart';
import 'package:ecosolar/core/theme.dart';
import 'package:ecosolar/data/store.dart';
import 'package:ecosolar/screens/home.dart';
import 'package:ecosolar/screens/shell.dart';
import 'package:ecosolar/widgets/flows.dart';
import 'package:ecosolar/widgets/steps.dart';
import 'package:ecosolar/widgets/ui.dart';

/// SCR-C-50 Marketplace landing
class MarketTab extends StatelessWidget {
  const MarketTab({super.key});
  static const hubs = [
    (Icons.solar_power_outlined, 'تجهیزات و بسته‌ها', '/market/equipment'),
    (Icons.engineering_outlined, 'نصابان تأییدشده', '/market/installers'),
    (Icons.payments_outlined, 'تأمین مالی', '/market/finance'),
    (Icons.roofing_outlined, 'میزبانی بام', '/market/roof-host'),
    (Icons.apartment_outlined, 'نیروگاه مجتمع', '/site/co-owners'),
    (Icons.hub_outlined, 'نیروگاه مجازی', '/market/vpp'),
  ];
  @override
  Widget build(BuildContext context) => TabBody(
        header: const TabHeader('بازارگاه'),
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/market/equipment'),
            child: Container(
              height: 52,
              padding: const EdgeInsets.only(right: 18, left: 6),
              decoration: BoxDecoration(border: Border.all(color: C.line), borderRadius: BorderRadius.circular(R.pill)),
              child: Row(children: [
                const Icon(Icons.search, color: C.muted),
                gap8,
                Expanded(child: Text('جستجوی تجهیزات', style: ts(14, c: C.muted))),
                const CircleAvatar(radius: 20, backgroundColor: C.black, child: Icon(Icons.tune, color: Colors.white, size: 20)),
              ]),
            ),
          ),
          ECard(
            dark: true,
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('وام یارانه‌ای ساتبا', style: ts(17, w: FontWeight.w800, c: Colors.white)),
                Text('تا ۴۰۰ میلیون تومان · سود ۱۴٪', style: ts(13, c: Colors.white70)),
                gap12,
                SizedBox(width: 150, child: PrimaryButton('ثبت درخواست', light: true, onPressed: () => Navigator.pushNamed(context, '/market/finance'))),
              ])),
              const Icon(Icons.solar_power, color: Colors.white, size: 70),
            ]),
          ),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.35,
            children: [
              for (final h in hubs)
                ECard(
                  onTap: () => Navigator.pushNamed(context, h.$3),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [IconCircle(h.$1, size: 48), gap8, Text(h.$2, textAlign: TextAlign.center, style: ts(13.5, w: FontWeight.w700))]),
                ),
            ],
          ),
          SectionTitle('نصاب پیشنهادی', action: 'همه', onAction: () => Navigator.pushNamed(context, '/market/installers')),
          ECard(
            child: Row(children: [
              Avatar(app.bids.first.company),
              gap12,
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(app.bids.first.company, style: ts(14.5, w: FontWeight.w700)),
                Row(children: [const Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)), Text(' ${dec(app.bids.first.rating)}', style: ts(12.5)), gap8, const Pill('تأیید ساتبا', tone: Tone.blue)]),
              ])),
              GestureDetector(
                onTap: () => toast(context, 'در حال تماس با نصاب...'),
                child: const CircleAvatar(radius: 22, backgroundColor: C.black, child: Icon(Icons.call, color: Colors.white)),
              ),
            ]),
          ),
          TextButton(onPressed: () => MainShell.tab.value = 2, child: Text('بازگشت به نیروگاه من', style: ts(13, w: FontWeight.w700))),
        ],
      );
}

/// SCR-C-51 Equipment catalog, RFQ & BOM comparison
class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});
  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  int cat = 0, pay = 1;
  String q = '';
  static const cats = ['همه', 'پنل', 'اینورتر', 'باتری', 'سازه'];
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          final list = app.products.where((p) => (cat == 0 || p.cat == cats[cat]) && p.name.contains(q)).toList();
          return EPage(
            title: 'تجهیزات',
            bottom: app.rfqSent
                ? PrimaryButton(app.poLocked ? 'سفارش ثبت شد' : 'قفل و ثبت سفارش خرید', icon: Icons.lock_outline, onPressed: app.poLocked
                    ? null
                    : () async {
                        final otp = await showMfa(context, action: 'ثبت سفارش بسته الف (${pay == 1 ? 'وام ساتبا' : 'خودتأمین'})', amount: toman(420e6));
                        if (otp == null) return;
                        app.poLocked = true;
                        app.touch();
                        if (context.mounted) toast(context, 'سفارش خرید به تأمین‌کننده ارسال شد');
                      })
                : PrimaryButton('درخواست استعلام رسمی', onPressed: () async {
                    await Future.delayed(const Duration(milliseconds: 800));
                    app.rfqSent = true;
                    app.touch();
                    if (context.mounted) toast(context, 'استعلام بر اساس پرونده مهندسی ارسال شد');
                  }),
            children: [
              TextField(onChanged: (v) => setState(() => q = v), decoration: const InputDecoration(hintText: 'جستجوی کالا', prefixIcon: Icon(Icons.search))),
              ChipsRow(items: cats, value: cat, onChanged: (v) => setState(() => cat = v)),
              for (final p in list)
                ECard(
                  child: Row(children: [
                    Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Icon(p.cat == 'باتری' ? Icons.battery_full : (p.cat == 'اینورتر' ? Icons.developer_board : (p.cat == 'سازه' ? Icons.view_column : Icons.solar_power)), size: 34)),
                    gap12,
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.name, style: ts(14.5, w: FontWeight.w700)),
                      Text(toman(p.price), style: ts(13)),
                      gap8,
                      Row(children: [if (p.domestic) ...[const Pill('ساخت داخل', tone: Tone.green), gap8], const Countdown(Duration(hours: 47, minutes: 59))]),
                    ])),
                  ]),
                ),
              if (app.rfqSent) ...[
                ECard(
                  dark: true,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('مقایسه بسته‌ها', style: ts(15, w: FontWeight.w800, c: Colors.white)),
                    gap12,
                    Row(children: [const Expanded(child: SizedBox()), Expanded(child: Text('بسته الف', textAlign: TextAlign.center, style: ts(13, w: FontWeight.w700, c: Colors.white))), Expanded(child: Text('بسته ب', textAlign: TextAlign.center, style: ts(13, w: FontWeight.w700, c: Colors.white)))]),
                    for (final r in const [('جمع کل', '۴۲۰ م.ت', '۴۴۵ م.ت'), ('کارمزد پلتفرم', '۲٪', '۲٪'), ('گارانتی', '۱۰ سال', '۵ سال'), ('تحویل', '۷ روز', '۱۴ روز')])
                      Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
                        Expanded(child: Text(r.$1, style: ts(13, c: Colors.white60))),
                        Expanded(child: Text(r.$2, textAlign: TextAlign.center, style: ts(13.5, w: FontWeight.w700, c: Colors.white))),
                        Expanded(child: Text(r.$3, textAlign: TextAlign.center, style: ts(13.5, c: Colors.white70))),
                      ])),
                    gap8,
                    const Row(children: [Spacer(), Pill('پیشنهادی: بسته الف', tone: Tone.green), Spacer()]),
                  ]),
                ),
                Segmented(items: const ['خودتأمین', 'وام ساتبا'], value: pay, onChanged: (v) => setState(() => pay = v)),
              ],
            ],
          );
        },
      );
}

/// SCR-C-52 Installer selection & execution tracker
class InstallersScreen extends StatelessWidget {
  const InstallersScreen({super.key});
  static const stages = ['بازدید', 'نصب سازه', 'سیم‌کشی', 'بازرسی', 'اتصال'];
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => EPage(title: 'انتخاب نصاب', children: [
          if (app.installer != null)
            ECard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Expanded(child: Text('پیگیری اجرا · ${app.installer}', style: ts(14, w: FontWeight.w700))), Pill('مرحله ${fa(app.installStage + 1)} از ۵', tone: Tone.blue)]),
              gap16,
              HStepper(steps: stages, current: app.installStage),
              gap12,
              Row(children: [
                for (var i = 0; i < 3; i++) ...[
                  Expanded(child: Container(height: 64, decoration: BoxDecoration(color: i < app.installStage ? C.black : C.grey, borderRadius: BorderRadius.circular(12)), child: Icon(i < app.installStage ? Icons.photo : Icons.hourglass_empty, color: Colors.white))),
                  if (i < 2) gap8,
                ],
              ]),
              gap8,
              Text('عکس‌های موقعیت‌دار هر مرحله توسط اپراتور تأیید می‌شود', style: ts(12, c: C.muted)),
            ])),
          const SectionTitle('پیشنهادهای مناقصه'),
          for (final b in app.bids)
            ECard(
              border: Border.all(color: app.installer == b.company ? C.black : Colors.transparent, width: 1.6),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Avatar(b.company),
                  gap12,
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(b.company, style: ts(14.5, w: FontWeight.w700)),
                    Row(children: [const Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)), Text(' ${dec(b.rating)}', style: ts(12.5)), gap8, const Pill('تأیید ساتبا', tone: Tone.blue, icon: Icons.verified)]),
                  ])),
                ]),
                gap12,
                StatRow([Stat('مبلغ', mt(b.amount)), Stat('مدت اجرا', '${fa(b.days)} روز'), Stat('گارانتی', '${fa(b.warrantyMonths)} ماه')]),
                gap12,
                Row(children: [
                  Expanded(
                    child: PrimaryButton(app.installer == b.company ? 'انتخاب شد' : 'انتخاب نصاب', outlined: app.installer != null && app.installer != b.company, onPressed: app.installer == b.company
                        ? null
                        : () async {
                            if (await confirm(context, 'انتخاب ${b.company}', 'قرارداد اجرا به مبلغ ${toman(b.amount)} انعقاد می‌شود')) {
                              app.installer = b.company;
                              app.touch();
                            }
                          }),
                  ),
                  gap8,
                  GestureDetector(onTap: () => toast(context, 'در حال تماس...'), child: const CircleAvatar(radius: 24, backgroundColor: C.black, child: Icon(Icons.call, color: Colors.white))),
                ]),
              ]),
            ),
        ]),
      );
}
