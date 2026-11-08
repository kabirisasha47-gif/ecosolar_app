import 'package:flutter/material.dart';
import 'package:ecosolar/core/fmt.dart';
import 'package:ecosolar/core/theme.dart';
import 'package:ecosolar/data/store.dart';
import 'package:ecosolar/widgets/charts.dart';
import 'package:ecosolar/widgets/flows.dart';
import 'package:ecosolar/widgets/steps.dart';
import 'package:ecosolar/widgets/ui.dart';

/// SCR-C-05 Four-sector profile wizard (6 steps)
class WizardScreen extends StatefulWidget {
  const WizardScreen({super.key});
  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  int step = 0;
  double ocr = -1;
  bool located = false;
  final billId = TextEditingController();
  int azimuth = 0;
  bool shading = false;
  static const steps = ['بخش', 'قبض', 'بررسی', 'تجهیزات', 'بام', 'خلاصه'];
  static const sectors = [(Icons.home_outlined, 'خانگی'), (Icons.store_outlined, 'تجاری'), (Icons.business_outlined, 'اداری'), (Icons.factory_outlined, 'صنعتی')];
  static const cities = ['اصفهان', 'کاشان', 'نجف‌آباد', 'شهرضا', 'نائین', 'گلپایگان'];

  bool get canNext => switch (step) {
        0 => located,
        1 => ocr >= 1 || en(billId.text).length == 13,
        _ => true,
      };

  Future<void> scan() async {
    for (var i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      setState(() => ocr = i / 10);
    }
  }

  Widget field(String label, String key, String unit, {bool low = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          initialValue: fa(sep(app.bill[key]!)),
          keyboardType: TextInputType.number,
          onChanged: (v) => app.bill[key] = parseNum(v),
          decoration: InputDecoration(
            labelText: label,
            suffixText: unit,
            fillColor: low ? C.amberBg : Colors.white,
            helperText: low ? 'اطمینان خوانش پایین است؛ بررسی شود' : null,
            helperStyle: ts(11.5, c: C.amber),
          ),
        ),
      );

  List<Widget> body() {
    switch (step) {
      case 0:
        return [
          Text('بخش مصرف', style: ts(16, w: FontWeight.w700)),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.6,
            children: [
              for (var i = 0; i < sectors.length; i++)
                ECard(
                  dark: app.sector == i,
                  onTap: () => setState(() => app.sector = i),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(sectors[i].$1, color: app.sector == i ? Colors.white : C.ink, size: 30),
                    gap8,
                    Text(sectors[i].$2, style: ts(14, w: FontWeight.w700, c: app.sector == i ? Colors.white : C.ink)),
                  ]),
                ),
            ],
          ),
          DropdownButtonFormField<String>(
            value: app.city,
            decoration: const InputDecoration(labelText: 'شهر (استان اصفهان)'),
            items: [for (final c in cities) DropdownMenuItem(value: c, child: Text(c))],
            onChanged: (v) => setState(() => app.city = v!),
          ),
          ECard(
            onTap: () => setState(() => located = true),
            child: Row(children: [
              IconCircle(located ? Icons.check : Icons.location_on_outlined, bg: located ? C.black : Colors.white, fg: located ? Colors.white : C.ink),
              gap12,
              Expanded(child: Text(located ? 'موقعیت ثبت شد: ${fa('33.98, 51.43')}' : 'ثبت موقعیت روی نقشه', style: ts(14, w: FontWeight.w600))),
            ]),
          ),
        ];
      case 1:
        return [
          Text('قبض برق', style: ts(16, w: FontWeight.w700)),
          Row(children: [
            Expanded(child: PrimaryButton('عکس از قبض', icon: Icons.photo_camera_outlined, onPressed: scan)),
            gap8,
            Expanded(child: PrimaryButton('گالری', icon: Icons.photo_outlined, outlined: true, onPressed: scan)),
          ]),
          if (ocr >= 0)
            ECard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ocr < 1 ? 'در حال خواندن قبض... ${pct(ocr * 100)}' : 'قبض خوانده شد', style: ts(14, w: FontWeight.w600)),
              gap8,
              Bar(ocr, color: ocr < 1 ? C.black : C.green),
            ])),
          Text('یا شناسه انشعاب ۱۳ رقمی را وارد کنید', style: ts(13, c: C.muted)),
          TextField(controller: billId, keyboardType: TextInputType.number, maxLength: 13, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'شناسه انشعاب', counterText: '')),
        ];
      case 2:
        return [
          Row(children: [Expanded(child: Text('اطلاعات استخراج‌شده', style: ts(16, w: FontWeight.w700))), const Pill('خوانده شد', tone: Tone.green, icon: Icons.check)]),
          ECard(child: Column(children: [
            field('مصرف اوج', 'peak', 'kWh'),
            field('مصرف میان‌باری', 'mid', 'kWh'),
            field('مصرف کم‌باری', 'off', 'kWh', low: true),
            field('دیماند قراردادی', 'demand', 'kW'),
            field('مبلغ قبض', 'amount', 'تومان'),
          ])),
        ];
      case 3:
        return [
          SectionTitle('تجهیزات سرمایش و گرمایش', action: '+ افزودن', onAction: addAppliance),
          for (final a in app.appliances)
            ECard(
              child: Row(children: [
                const IconCircle(Icons.ac_unit, size: 40),
                gap12,
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.$1, style: ts(14.5, w: FontWeight.w700)),
                  Text('${dec(a.$2)} kW · ${fa(a.$3.round())} ساعت در روز', style: ts(12, c: C.muted)),
                ])),
                IconButton(onPressed: () => setState(() => app.appliances.remove(a)), icon: const Icon(Icons.delete_outline, color: C.red)),
              ]),
            ),
        ];
      case 4:
        return [
          Text('مشخصات بام', style: ts(16, w: FontWeight.w700)),
          ECard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            KV('مساحت قابل استفاده', '${fa(app.roofArea.round())} m²'),
            Slider(value: app.roofArea, min: 20, max: 600, onChanged: (v) => setState(() => app.roofArea = v)),
            KV('شیب بام', '${fa(app.slope.round())} درجه'),
            Slider(value: app.slope, min: 0, max: 45, onChanged: (v) => setState(() => app.slope = v)),
            gap8,
            Text('جهت', style: ts(13, c: C.muted)),
            gap8,
            Segmented(items: const ['جنوب', 'جنوب شرقی', 'جنوب غربی'], value: azimuth, onChanged: (v) => setState(() => azimuth = v)),
          ])),
          ECard(child: Column(children: [
            SwitchListTile(contentPadding: EdgeInsets.zero, title: Text('مانع سایه‌انداز دارد', style: ts(14)), value: shading, onChanged: (v) => setState(() => shading = v)),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: Text('بام مشاع است', style: ts(14)), value: app.sharedRoof, onChanged: (v) => setState(() => app.sharedRoof = v)),
          ])),
          if (app.sharedRoof) const Notice('برای بام مشاع، رضایت ۱۰۰٪ مالکان لازم است و از بخش بازارگاه پیگیری می‌شود', tone: Tone.amber),
        ];
      default:
        final base = (app.bill['peak']! + app.bill['mid']! + app.bill['off']!) / 30 / 24;
        final curve = [for (var h = 0; h < 24; h++) base * (h >= 12 && h <= 17 ? 1.9 : (h >= 19 && h <= 23 ? 1.4 : (h < 6 ? .55 : 1)))];
        return [
          Text('پروفایل بار پایه', style: ts(16, w: FontWeight.w700)),
          ECard(child: Column(children: [
            LineChart(series: [Series(curve, fill: true)], labels: [for (final h in [0, 6, 12, 18, 24]) fa(h)]),
            gap12,
            KV('مصرف ماهانه', kwh(app.bill['peak']! + app.bill['mid']! + app.bill['off']!)),
            KV('ضریب حساسیت دمایی (α)', '${dec(0.042, 3)} به ازای هر درجه'),
            KV('ظرفیت بام', '${dec(app.roofArea / 7, 1)} kWp'),
          ])),
        ];
    }
  }

  Future<void> addAppliance() async {
    final n = TextEditingController(text: 'کولر اسپلیت'), p = TextEditingController(text: '1.8'), h = TextEditingController(text: '8');
    final ok = await sheet<bool>(
      context,
      Builder(builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('افزودن تجهیز', style: ts(18, w: FontWeight.w800)),
            gap12,
            TextField(controller: n, decoration: const InputDecoration(labelText: 'نوع تجهیز')),
            gap12,
            TextField(controller: p, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'توان (kW)')),
            gap12,
            TextField(controller: h, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ساعت کار در روز')),
            gap16,
            PrimaryButton('افزودن', onPressed: () => Navigator.pop(ctx, true)),
          ])),
    );
    if (ok == true) setState(() => app.appliances.add((n.text, parseNum(p.text), parseNum(h.text))));
  }

  @override
  Widget build(BuildContext context) => EPage(
        title: 'پروفایل مصرف',
        bottom: Row(children: [
          if (step > 0) ...[Expanded(child: PrimaryButton('قبلی', outlined: true, onPressed: () => setState(() => step--))), gap8],
          Expanded(
            flex: 2,
            child: PrimaryButton(step == 5 ? 'مشاهده گزارش صرفه‌جویی' : 'تأیید و ادامه', onPressed: !canNext
                ? null
                : () {
                    if (step < 5) {
                      setState(() => step++);
                    } else {
                      app.touch();
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
                    }
                  }),
          ),
        ]),
        children: [
          HStepper(steps: steps, current: step),
          Text('مرحله ${fa(step + 1)} از ۶', style: ts(12, c: C.muted)),
          ...body(),
        ],
      );
}
