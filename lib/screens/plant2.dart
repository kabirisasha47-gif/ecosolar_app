import 'package:flutter/material.dart';
import 'package:ecosolar/core/fmt.dart';
import 'package:ecosolar/core/jalali.dart';
import 'package:ecosolar/core/theme.dart';
import 'package:ecosolar/data/store.dart';
import 'package:ecosolar/screens/plant.dart';
import 'package:ecosolar/widgets/flows.dart';
import 'package:ecosolar/widgets/steps.dart';
import 'package:ecosolar/widgets/ui.dart';

/// SCR-C-33 Revenue channel comparison & selection
class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({super.key});
  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  String sel = app.channel ?? 'fit';
  bool agree = false;
  double delay = 3, inflation = 25;

  double adj(double v, String id) {
    if (id == 'self') return v * (1 + (inflation - 25) / 100);
    return v * (1 - (delay - 3) * .012) * (id == 'vpp' ? (1 + (inflation - 25) / 200) : 1);
  }

  @override
  Widget build(BuildContext context) => EPage(
        title: 'انتخاب کانال درآمد',
        bottom: PrimaryButton('انتخاب و تأیید کانال', onPressed: !agree
            ? null
            : () {
                app.acceptChannel(sel);
                toast(context, 'کانال انتخاب شد؛ قرارداد آماده امضاست');
                Navigator.pushReplacementNamed(context, '/plant/contract');
              }),
        children: [
          for (final c in app.channels)
            Opacity(
              opacity: c.eligible ? 1 : .55,
              child: ECard(
                dark: sel == c.id && c.eligible,
                onTap: c.eligible ? () => setState(() => sel = c.id) : null,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(c.name, style: ts(16, w: FontWeight.w800, c: sel == c.id && c.eligible ? Colors.white : C.ink))),
                    if (c.recommended) Pill('پیشنهادی', tone: sel == c.id ? Tone.green : Tone.green),
                    if (!c.eligible) const Icon(Icons.lock_outline, color: C.muted),
                  ]),
                  gap12,
                  if (c.eligible)
                    StatRow([
                      Stat('ارزش خالص سالانه', mt(adj(c.value, c.id)), dark: sel == c.id),
                      Stat('زمان وصول', c.id == 'fit' ? '${fa(delay.round())} ماه' : c.lead, dark: sel == c.id),
                      Stat('ریسک', c.risk, dark: sel == c.id),
                    ], dark: sel == c.id)
                  else
                    Text(c.reason ?? '', style: ts(13, c: C.muted)),
                  if (c.recommended && c.eligible)
                    TextButton(
                      onPressed: () => showExplain(context, title: 'چرا ${c.name}؟', inputs: [
                        ('ظرفیت', '${dec(app.kwp, 0)} kWp'),
                        ('تضمین خرید', '۲۰ سال ساتبا'),
                        ('نسخه جدول نرخ', '۱۴۰۵.۲'),
                        ('شرط وام ساتبا', 'قرارداد FiT فعال'),
                      ]),
                      child: Text('چرا؟', style: ts(13, w: FontWeight.w700, c: sel == c.id ? Colors.white : C.ink)),
                    ),
                ]),
              ),
            ),
          ECard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('حساسیت', style: ts(14, w: FontWeight.w700)),
              KV('تأخیر پرداخت', '${fa(delay.round())} ماه'),
              Slider(value: delay, min: 1, max: 12, divisions: 11, onChanged: (v) => setState(() => delay = v)),
              KV('تورم تعرفه', pct(inflation)),
              Slider(value: inflation, min: 10, max: 45, divisions: 7, onChanged: (v) => setState(() => inflation = v)),
            ]),
          ),
          const Notice('FiT و خودتأمین روی یک کنتور هم‌زمان ممکن نیست. قرارداد FiT ۲۰ ساله و غیرقابل تغییر است.'),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading,
            value: agree, onChanged: (v) => setState(() => agree = v ?? false),
            title: Text('شرایط مقرراتی را خواندم و پذیرفتم', style: ts(14)),
          ),
        ],
      );
}

/// SCR-C-34 Contract signing & telemetry activation
class ContractScreen extends StatefulWidget {
  const ContractScreen({super.key});
  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  final serial = TextEditingController(text: 'INV-10K-22981');
  final dongle = TextEditingController();
  bool testing = false;
  bool? link;

  Future<void> test() async {
    if (dongle.text.trim().length < 6) {
      toast(context, 'شناسه دانگل را وارد کنید');
      return;
    }
    setState(() => testing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      testing = false;
      link = true;
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          final ch = app.channel == null ? null : app.channels.firstWhere((c) => c.id == app.channel);
          return EPage(
            title: 'قرارداد و فعال‌سازی',
            bottom: PrimaryButton(
              app.devicePaired ? 'فعال است' : 'امضا و فعال‌سازی',
              onPressed: ch == null || app.devicePaired || link != true
                  ? null
                  : () async {
                      final otp = await showMfa(context, action: 'امضای قرارداد ${ch.name}', amount: '—');
                      if (otp == null) return;
                      app.contractSigned = true;
                      app.devicePaired = true;
                      app.caseStep = 6;
                      app.touch();
                      if (context.mounted) toast(context, 'قرارداد امضا و پایش فعال شد');
                    },
            ),
            children: [
              if (ch == null)
                ECard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text('هنوز کانال درآمد انتخاب نشده است', style: ts(14, w: FontWeight.w600)),
                  gap12,
                  PrimaryButton('انتخاب کانال', onPressed: () => Navigator.pushReplacementNamed(context, '/plant/channels')),
                ]))
              else
                ECard(
                  dark: true,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Expanded(child: Text('قرارداد ${ch.name}', style: ts(17, w: FontWeight.w800, c: Colors.white))), if (app.contractSigned) const Pill('امضا شده', tone: Tone.green)]),
                    gap8,
                    KV('مدت قرارداد', ch.id == 'fit' ? '۲۴۰ ماه' : '۱۲ ماه', dark: true),
                    const KV('نسخه جدول نرخ', '۱۴۰۵.۲', dark: true),
                    KV('ارزش سالانه به‌روز', mt(ch.value), dark: true),
                    gap12,
                    PrimaryButton('مشاهده متن قرارداد', light: true, icon: Icons.description_outlined, onPressed: () => sheet(context, Text('متن استاندارد قرارداد ${ch.name}: خرید برق تزریقی به شبکه بر اساس قرائت کنتور رسمی و نرخ نسخه ۱۴۰۵.۲ در بازه قرارداد.', style: ts(14)))),
                  ]),
                ),
              ECard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text('اتصال اینورتر', style: ts(15, w: FontWeight.w700)),
                  gap12,
                  TextField(controller: serial, decoration: const InputDecoration(labelText: 'شماره سریال اینورتر', fillColor: Colors.white)),
                  gap12,
                  Row(children: [
                    Expanded(child: TextField(controller: dongle, decoration: const InputDecoration(labelText: 'شناسه دانگل', fillColor: Colors.white))),
                    gap8,
                    InkWell(
                      onTap: () => setState(() => dongle.text = 'WD-7F3A91C2'),
                      child: Container(width: 54, height: 54, decoration: BoxDecoration(color: C.black, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.qr_code_scanner, color: Colors.white)),
                    ),
                  ]),
                  gap12,
                  Row(children: [
                    Icon(Icons.circle, size: 12, color: link == true || app.devicePaired ? C.green : C.grey),
                    gap8,
                    Expanded(child: Text(app.devicePaired ? 'دستگاه متصل و فعال است' : (link == true ? 'ارتباط برقرار شد' : 'متصل نشده'), style: ts(13.5))),
                    SizedBox(width: 130, child: PrimaryButton('تست اتصال', outlined: true, loading: testing, onPressed: app.devicePaired ? null : test)),
                  ]),
                ]),
              ),
            ],
          );
        },
      );
}

/// SCR-C-35 Mehrsam licensing case tracker
class CaseScreen extends StatelessWidget {
  const CaseScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          final base = DateTime(2026, 8, 1);
          return EPage(
            title: 'پرونده مهرسان',
            children: [
              ECard(
                dark: true,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('شماره پرونده', style: ts(13, c: Colors.white70)),
                  Row(children: [
                    Text(fa('1405-87231'), style: ts(22, w: FontWeight.w800, c: Colors.white)),
                    IconButton(onPressed: () => toast(context, 'شماره پرونده کپی شد'), icon: const Icon(Icons.copy, color: Colors.white70, size: 18)),
                    const Spacer(),
                    Pill(app.caseStep >= 6 ? 'تکمیل‌شده' : 'در جریان', tone: app.caseStep >= 6 ? Tone.green : Tone.blue),
                  ]),
                  Text('${fa(app.caseStep)} از ۷ مرحله', style: ts(13, c: Colors.white70)),
                ]),
              ),
              ECard(
                child: VTimeline([
                  for (var i = 0; i < caseSteps.length; i++)
                    TItem(caseSteps[i], i < app.caseStep ? jDate(base.add(Duration(days: i * 9))) : (i == app.caseStep ? 'مسئول: شرکت توزیع' : ''),
                        i < app.caseStep ? 2 : (i == app.caseStep ? 1 : 0),
                        trailing: i == app.caseStep ? const Pill('مهلت ۵ روز', tone: Tone.amber) : null),
                ]),
              ),
              ECard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('مدارک', style: ts(15, w: FontWeight.w700)),
                  for (final d in const ['قبض برق', 'سند مالکیت', 'گواهی شبا', 'کارت ملی'])
                    ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.check_circle, color: C.green), title: Text(d, style: ts(14))),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(app.sharedRoof ? Icons.error_outline : Icons.check_circle, color: app.sharedRoof ? C.red : C.green),
                    title: Text('رضایت مالکان مشاع', style: ts(14)),
                    subtitle: app.sharedRoof ? Text('نیاز به اصلاح: ۲ امضا باقی مانده', style: ts(12, c: C.red)) : null,
                    trailing: app.sharedRoof ? TextButton(onPressed: () => Navigator.pushNamed(context, '/site/co-owners'), child: const Text('پیگیری')) : null,
                  ),
                ]),
              ),
              ECard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text('بازدید شرکت توزیع', style: ts(15, w: FontWeight.w700)),
                  KV('تاریخ بازدید', jLong(DateTime(2026, 11, 11))),
                  const KV('بازرس', 'مهندس نوری'),
                  gap8,
                  PrimaryButton('دانلود مجوز اتصال', outlined: true, icon: Icons.download, onPressed: app.caseStep >= 3 ? () => toast(context, 'مجوز اتصال دریافت شد') : null),
                ]),
              ),
            ],
          );
        },
      );
}
