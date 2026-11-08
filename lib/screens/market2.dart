import 'package:flutter/material.dart';
import 'package:ecosolar/core/fmt.dart';
import 'package:ecosolar/core/theme.dart';
import 'package:ecosolar/data/store.dart';
import 'package:ecosolar/widgets/charts.dart';
import 'package:ecosolar/widgets/flows.dart';
import 'package:ecosolar/widgets/steps.dart';
import 'package:ecosolar/widgets/ui.dart';

/// SCR-C-53 SATBA loan & crowdfunding
class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});
  static const loanSteps = ['پرونده', 'مهرسان', 'اعتبارسنجی', 'تأیید', 'پرداخت', 'کسر مستقیم'];
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => EPage(title: 'تأمین مالی', children: [
          ECard(
            dark: true,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [Expanded(child: Text('وام یارانه‌ای ساتبا', style: ts(17, w: FontWeight.w800, c: Colors.white))), const Pill('بانک ملت', tone: Tone.grey)]),
              gap16,
              const StatRow([Stat('ظرفیت', 'تا ۱۰ kW', dark: true), Stat('سقف', '۴۰۰ م.ت', dark: true), Stat('سود', '۱۴٪', dark: true), Stat('مدت', '۶۰ ماه', dark: true)], dark: true),
              gap12,
              Text('شرط: قرارداد FiT فعال و طرح مهندسی تأییدشده', style: ts(12.5, c: Colors.white70)),
              gap12,
              PrimaryButton(app.loanSubmitted ? 'پرونده ارسال شد' : 'ثبت پرونده وام', light: true, onPressed: app.loanSubmitted
                  ? null
                  : () async {
                      if (app.channel != 'fit') {
                        toast(context, 'ابتدا کانال FiT را انتخاب کنید');
                        return;
                      }
                      final otp = await showMfa(context, action: 'ارسال پرونده وام ساتبا', amount: toman(400e6));
                      if (otp == null) return;
                      app.loanSubmitted = true;
                      app.touch();
                    }),
            ]),
          ),
          if (app.loanSubmitted)
            ECard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('وضعیت پرونده وام', style: ts(14, w: FontWeight.w700)),
              gap16,
              const HStepper(steps: loanSteps, current: 2),
            ])),
          const SectionTitle('تأمین مالی جمعی'),
          for (final c in const [('خوشه بام‌های مدارس اصفهان', .68, '۱٫۲ میلیارد'), ('خوشه سوله‌های نجف‌آباد', .42, '۳٫۵ میلیارد')])
            ECard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [const IconCircle(Icons.groups_outlined, size: 40), gap12, Expanded(child: Text(c.$1, style: ts(14.5, w: FontWeight.w700)))]),
              gap12,
              Bar(c.$2, color: C.green),
              gap8,
              Row(children: [Text('${pct(c.$2 * 100)} جذب شده', style: ts(12.5)), const Spacer(), Text('هدف ${c.$3} تومان', style: ts(12.5, c: C.muted))]),
              gap12,
              PrimaryButton('مشاهده در سکوی مجاز فرابورس', outlined: true, icon: Icons.open_in_new, onPressed: () => toast(context, 'انتقال به سکوی تأمین مالی جمعی'))),
            ])),
          const Notice('هیچ سود تضمینی وعده داده نمی‌شود؛ ارقام بازده سناریو هستند', tone: Tone.amber, icon: Icons.info_outline),
        ]),
      );
}

/// SCR-C-54 Roof host listing & income
class RoofHostScreen extends StatelessWidget {
  const RoofHostScreen({super.key});
  static const models = ['اجاره ثابت', 'سهم درآمد', 'کمپین خیر'];
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => EPage(title: 'میزبانی بام', children: [
          ECard(dark: true, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.school_outlined, color: Colors.white), gap8, Expanded(child: Text('مدرسه شهید بهشتی، کاشان', style: ts(16, w: FontWeight.w800, c: Colors.white)))]),
            gap8,
            const Pill('قرارداد فعال ۲۰ ساله', tone: Tone.blue),
            gap16,
            const StatRow([Stat('مساحت', '۴۲۰ m²', dark: true), Stat('سهم میزبان', '۱۵٪', dark: true), Stat('تولید ماه', '۶٬۲۰۰ kWh', dark: true)], dark: true),
          ])),
          ECard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('سهم میزبان این ماه', style: ts(13, c: C.muted)),
            Text(toman(9.8e6), style: ts(22, w: FontWeight.w800)),
            gap12,
            const BarChart(groups: [[7.9], [8.6], [9.4], [10.1], [9.9], [9.8]], labels: ['فر', 'ار', 'خر', 'تی', 'مر', 'شه'], height: 80),
          ])),
          ECard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('مدل درآمد', style: ts(14, w: FontWeight.w700)),
            gap12,
            Segmented(items: models, value: app.roofModel, onChanged: (v) { app.roofModel = v; app.touch(); }),
          ])),
          ECard(child: Column(children: [
            for (final p in const [('مهر', '۹٬۹۰۰٬۰۰۰', true), ('شهریور', '۱۰٬۱۰۰٬۰۰۰', true), ('آبان', '۹٬۸۰۰٬۰۰۰', false)])
              Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
                Expanded(child: Text(p.$1, style: ts(14, w: FontWeight.w600))),
                Text('${p.$2} تومان', style: ts(13.5)),
                gap8,
                Pill(p.$3 ? 'پرداخت شد' : 'در انتظار', tone: p.$3 ? Tone.green : Tone.amber),
              ])),
          ])),
          PrimaryButton('ثبت بام جدید', outlined: true, icon: Icons.add, onPressed: () => sheet(context, Builder(builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('ثبت بام', style: ts(18, w: FontWeight.w800)),
                gap12,
                const TextField(decoration: InputDecoration(labelText: 'نام ساختمان (مدرسه، مسجد، اداره، سوله)')),
                gap12,
                const TextField(keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'مساحت (m²)')),
                gap12,
                PrimaryButton('بارگذاری سند مالکیت', outlined: true, icon: Icons.upload_file, onPressed: () => toast(ctx, 'سند بارگذاری شد')),
                gap12,
                PrimaryButton('ثبت', onPressed: () { Navigator.pop(ctx); toast(context, 'بام برای بازدید سازه‌ای ثبت شد'); }),
              ]))),
        ]),
      );
}

/// SCR-C-55 Shared complex & co-owner consents
class CoOwnersScreen extends StatelessWidget {
  const CoOwnersScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          final signed = app.coOwners.where((c) => c.signed).length, total = app.coOwners.length;
          return EPage(title: 'رضایت مالکان مشاع', children: [
            ECard(dark: true, child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('مجتمع مسکونی گلستان', style: ts(16, w: FontWeight.w800, c: Colors.white)),
                Text('محل واریز سهم: صندوق نگهداری ساختمان', style: ts(12.5, c: Colors.white70)),
                gap12,
                PrimaryButton('ارسال یادآوری پیامکی', light: true, onPressed: signed == total ? null : () => toast(context, 'یادآوری برای ${fa(total - signed)} مالک ارسال شد')),
              ])),
              gap12,
              Donut(values: [signed.toDouble(), (total - signed).toDouble()], colors: const [Colors.white, Colors.white24], center: '${fa(signed)}/${fa(total)}', size: 100, dark: true),
            ])),
            if (signed < total) const Notice('پروژه تا ثبت رضایت ۱۰۰٪ مالکان قفل است', icon: Icons.lock_outline)
            else const Notice('رضایت همه مالکان ثبت شد؛ پروژه آزاد است', tone: Tone.green, icon: Icons.lock_open),
            ECard(child: Column(children: [
              for (final o in app.coOwners)
                Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
                  Pill('واحد ${fa(o.unit)}', tone: Tone.grey),
                  gap8,
                  Avatar(o.name, size: 34),
                  gap8,
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(o.name, style: ts(13.5, w: FontWeight.w700)), Text(fa(o.mobile), style: ts(11.5, c: C.muted))])),
                  o.signed
                      ? const Pill('امضا شد', tone: Tone.green)
                      : TextButton(onPressed: () { o.signed = true; app.touch(); toast(context, 'رضایت ${o.name} با تأیید پیامکی ثبت شد'); }, child: const Pill('در انتظار', tone: Tone.amber, icon: Icons.notifications_active_outlined)),
                ])),
            ])),
          ]);
        },
      );
}

/// SCR-C-56 VPP pool membership
class VppScreen extends StatelessWidget {
  const VppScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          const ei = 920.0, pool = 109500.0, gross = 21e6, fee = .5e6;
          final inst = app.loanSubmitted ? 9.3e6 : 0.0;
          return EPage(
            title: 'نیروگاه مجازی',
            bottom: PrimaryButton(app.vppJoined ? 'عضو استخر هستید' : 'امضای وکالت‌نامه و عضویت', onPressed: app.vppJoined
                ? null
                : () async {
                    if (app.channel == 'fit') {
                      toast(context, 'ظرفیت تحت قرارداد FiT قفل است؛ برای عضویت کانال VPP را انتخاب کنید');
                      return;
                    }
                    final otp = await showMfa(context, action: 'وکالت فروش به تجمیع‌کننده', amount: '—');
                    if (otp == null) return;
                    app.vppJoined = true;
                    app.touch();
                  }),
            children: [
              ECard(dark: true, child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('سهم من از استخر', style: ts(13, c: Colors.white70)),
                  Text(pct(ei / pool * 100, 2), style: ts(30, w: FontWeight.w800, c: Colors.white)),
                  Text('تزریق من ${kwh(ei)} · ۱٬۲۴۰ عضو', style: ts(12.5, c: Colors.white70)),
                ])),
                const Donut(values: [ei, pool - ei], colors: [C.green, Colors.white24], size: 90, dark: true),
              ])),
              ECard(child: Row(children: [
                Expanded(child: Column(children: [const Stat('FiT', '۹٫۸ م.ت'), Text('ماهانه', style: ts(11, c: C.muted))])),
                Container(width: 1, height: 46, color: C.line),
                Expanded(child: Column(children: [const Stat('استخر VPP', '۱۱٫۲ م.ت'), const Pill('بازده بالاتر', tone: Tone.green)])),
              ])),
              Row(children: [const ScenarioTag(), gap8, Expanded(child: Text('تضمین خرید ۷۰٪ ساتبا برای حجم فروش‌نرفته', style: ts(12.5, c: C.muted)))]),
              ECard(child: Column(children: [
                const KV('درآمد ناخالص سهم من', '۲۱٬۰۰۰٬۰۰۰'),
                const KV('کارمزد تجمیع‌کننده', '۵۰۰٬۰۰۰'),
                KV('کسر قسط وام', num0(inst)),
                const Divider(),
                KV('خالص پرداختی من', toman(gross - fee - inst), bold: true, vc: C.green),
              ])),
              ECard(child: Row(children: [const IconCircle(Icons.hub_outlined, size: 40), gap12, Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('انرژی سبز سپاهان', style: ts(14, w: FontWeight.w700)), Text('مجوز تجمیع‌کنندگی ۱۴۰۳-۰۱۲', style: ts(12, c: C.muted))])), const Pill('دارای مجوز', tone: Tone.blue)])),
            ],
          );
        },
      );
}
