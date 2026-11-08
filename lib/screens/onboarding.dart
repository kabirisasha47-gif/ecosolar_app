import 'package:flutter/material.dart';
import 'package:ecosolar/core/fmt.dart';
import 'package:ecosolar/core/jalali.dart';
import 'package:ecosolar/core/theme.dart';
import 'package:ecosolar/core/validators.dart';
import 'package:ecosolar/data/models.dart';
import 'package:ecosolar/data/store.dart';
import 'package:ecosolar/widgets/flows.dart';
import 'package:ecosolar/widgets/ui.dart';

/// SCR-C-02 KYC & bank account
class KycScreen extends StatefulWidget {
  const KycScreen({super.key});
  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final f = GlobalKey<FormState>();
  late final nid = TextEditingController(text: fa(app.nationalId));
  late final nm = TextEditingController(text: app.name);
  late final bd = TextEditingController(text: fa(app.birth));
  late final sh = TextEditingController(text: app.sheba);
  bool busy = false;

  Future<void> submit() async {
    if (!f.currentState!.validate()) return;
    final changed = en(sh.text.replaceAll(' ', '').toUpperCase()) != app.sheba;
    if (changed && app.kyc == 'verified') {
      final ok = await showMfa(context, action: 'تغییر شماره شبا', amount: '—');
      if (ok == null) return;
    }
    setState(() => busy = true);
    app.name = nm.text.trim();
    app.nationalId = en(nid.text.trim());
    app.birth = en(bd.text.trim());
    app.sheba = en(sh.text.replaceAll(' ', '').toUpperCase());
    app.kyc = 'pending';
    app.touch();
    await Future.delayed(const Duration(milliseconds: 1200));
    app.kyc = 'verified';
    app.touch();
    if (!mounted) return;
    setState(() => busy = false);
    toast(context, 'هویت شما تأیید شد');
    Navigator.pushReplacementNamed(context, app.legal ? '/onboarding/organization' : '/onboarding/consents');
  }

  @override
  Widget build(BuildContext context) => EPage(
        title: 'تکمیل هویت',
        bottom: PrimaryButton('ثبت و استعلام', loading: busy, onPressed: submit),
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Bar(.66), gap8, Text('مرحله ۲ از ۳', style: ts(12, c: C.muted))]),
          Form(
            key: f,
            child: Column(children: [
              ECard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [
                    Expanded(child: Text(app.legal ? 'اطلاعات شرکت' : 'اطلاعات هویتی', style: ts(16, w: FontWeight.w700))),
                    ListenableBuilder(
                        listenable: app,
                        builder: (_, __) => switch (app.kyc) {
                              'verified' => const Pill('تأییدشده', tone: Tone.green, icon: Icons.check),
                              'pending' => const Pill('در انتظار تأیید', tone: Tone.amber),
                              _ => const Pill('تکمیل نشده'),
                            }),
                  ]),
                  gap12,
                  TextFormField(
                    controller: nid,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: app.legal ? 'شناسه ملی شرکت' : 'کد ملی', fillColor: Colors.white),
                    validator: (v) => app.legal
                        ? (RegExp(r'^\d{11}$').hasMatch(en(v ?? '')) ? null : 'شناسه ملی ۱۱ رقمی است')
                        : (validNationalId(v ?? '') ? null : 'کد ملی معتبر نیست'),
                  ),
                  gap12,
                  TextFormField(controller: nm, decoration: InputDecoration(labelText: app.legal ? 'نام شرکت' : 'نام و نام خانوادگی', fillColor: Colors.white),
                      validator: (v) => (v ?? '').trim().length < 3 ? 'نام را کامل وارد کنید' : null),
                  gap12,
                  TextFormField(
                    controller: bd,
                    readOnly: true,
                    decoration: InputDecoration(labelText: app.legal ? 'تاریخ ثبت' : 'تاریخ تولد', fillColor: Colors.white, suffixIcon: const Icon(Icons.calendar_month_outlined)),
                    onTap: () async {
                      final d = await showDatePicker(context: context, initialDate: DateTime(1991, 8, 3), firstDate: DateTime(1930), lastDate: DateTime.now());
                      if (d != null) bd.text = jDate(d);
                    },
                  ),
                ]),
              ),
              gap16,
              ECard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text('حساب بانکی', style: ts(16, w: FontWeight.w700)),
                  gap12,
                  TextFormField(
                    controller: sh,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(labelText: 'شماره شبا', hintText: 'IR...', fillColor: Colors.white),
                    onChanged: (_) => setState(() {}),
                    validator: (v) => validSheba(v ?? '') ? null : 'شماره شبا معتبر نیست',
                  ),
                  gap12,
                  Row(children: [
                    const IconCircle(Icons.account_balance_outlined, size: 38),
                    gap8,
                    Expanded(child: Text(bankOf(sh.text) ?? 'بانک شناسایی نشد', style: ts(14, w: FontWeight.w600))),
                    if (validSheba(sh.text)) const Pill('معتبر', tone: Tone.green, icon: Icons.check),
                  ]),
                  KV('صاحب حساب', nm.text),
                ]),
              ),
            ]),
          ),
          const Notice('تغییر شبا بعد از تأیید هویت، نیاز به تأیید دومرحله‌ای دارد', tone: Tone.blue, icon: Icons.shield_outlined),
        ],
      );
}

/// SCR-C-03 Organization members & site roles
class OrgScreen extends StatelessWidget {
  const OrgScreen({super.key});
  static const roles = ['مدیر سازمان', 'مدیر انرژی', 'ناظر', 'عضو'];
  static const sites = ['اصفهان', 'کاشان', 'نجف‌آباد', 'شهرضا'];

  Future<void> invite(BuildContext c) async {
    final n = TextEditingController(), m = TextEditingController();
    var role = 3;
    final ok = await sheet<bool>(
      c,
      StatefulBuilder(
        builder: (ctx, set) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('دعوت عضو', style: ts(18, w: FontWeight.w800)),
          gap12,
          TextField(controller: n, decoration: const InputDecoration(labelText: 'نام')),
          gap12,
          TextField(controller: m, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'موبایل')),
          gap12,
          ChipsRow(items: roles, value: role, onChanged: (v) => set(() => role = v)),
          gap16,
          PrimaryButton('ارسال دعوت‌نامه', onPressed: () => Navigator.pop(ctx, n.text.trim().isNotEmpty && RegExp(r'^09\d{9}$').hasMatch(en(m.text)))),
        ]),
      ),
    );
    if (ok == true) {
      app.members.add(Member(n.text.trim(), en(m.text), roles[role], [sites.first]));
      app.touch();
      if (c.mounted) toast(c, 'دعوت‌نامه پیامک شد');
    } else if (ok == false && c.mounted) {
      toast(c, 'نام و شماره موبایل معتبر لازم است');
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => EPage(
          title: 'اعضای سازمان',
          bottom: PrimaryButton('ادامه', onPressed: () => Navigator.pushReplacementNamed(context, '/onboarding/consents')),
          children: [
            ECard(
              dark: true,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(app.name, style: ts(17, w: FontWeight.w800, c: Colors.white)),
                gap16,
                StatRow([Stat('سایت', fa(sites.length), dark: true), Stat('عضو', fa(app.members.length), dark: true), Stat('نقش', fa(roles.length), dark: true)], dark: true),
                gap16,
                PrimaryButton('دعوت عضو', light: true, icon: Icons.person_add_alt, onPressed: () => invite(context)),
              ]),
            ),
            for (final m in app.members)
              ECard(
                child: Row(children: [
                  Avatar(m.name),
                  gap12,
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(m.name, style: ts(15, w: FontWeight.w700)),
                      Text(fa(m.mobile), style: ts(12, c: C.muted)),
                      gap8,
                      Wrap(spacing: 6, runSpacing: 6, children: [Pill(m.role, tone: m.role == roles.first ? Tone.black : Tone.grey), for (final s in m.sites) Pill(s, tone: Tone.blue)]),
                    ]),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (r) {
                      if (r == '_del') {
                        app.members.remove(m);
                      } else {
                        m.role = r;
                      }
                      app.touch();
                      toast(context, 'تغییر در گزارش ممیزی ثبت شد');
                    },
                    itemBuilder: (_) => [for (final r in roles) PopupMenuItem(value: r, child: Text(r)), const PopupMenuItem(value: '_del', child: Text('حذف عضو'))],
                  ),
                ]),
              ),
            Row(children: [const Icon(Icons.history, size: 18, color: C.muted), gap8, Text('همه تغییرات نقش‌ها ثبت می‌شود', style: ts(12, c: C.muted))]),
          ],
        ),
      );
}

/// SCR-C-04 Data sharing consents (also reused from profile)
class ConsentsScreen extends StatelessWidget {
  const ConsentsScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => EPage(
          title: 'رضایت‌نامه‌ها',
          bottom: app.loggedIn && Navigator.canPop(context)
              ? null
              : PrimaryButton('ادامه', onPressed: () => Navigator.pushReplacementNamed(context, '/onboarding/profile')),
          children: [
            Text('برای هر شریک جداگانه تصمیم بگیرید. هر زمان می‌توانید رضایت را لغو کنید.', style: ts(13.5, c: C.muted)),
            for (final c in app.consents)
              ECard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const IconCircle(Icons.handshake_outlined, size: 40),
                    gap12,
                    Expanded(child: Text(c.partner, style: ts(15, w: FontWeight.w700))),
                    if (c.signed) const Pill('امضا شده', tone: Tone.green, icon: Icons.check),
                  ]),
                  gap8,
                  KV('داده‌ها', c.scope),
                  KV('اعتبار', c.validity),
                  if (c.at != null) KV('زمان امضا', '${jDate(c.at!)} · ${hm(c.at!)}'),
                  gap8,
                  Row(children: [
                    TextButton(
                      onPressed: () => sheet(context, Text('متن کامل رضایت‌نامه ${c.partner}: اشتراک ${c.scope} با هدف ارائه خدمات به مدت ${c.validity}.', style: ts(14))),
                      child: Text('مشاهده متن کامل', style: ts(13, w: FontWeight.w700)),
                    ),
                    const Spacer(),
                    c.signed
                        ? TextButton(
                            onPressed: () async {
                              if (await confirm(context, 'لغو رضایت', 'با لغو، اشتراک داده با ${c.partner} قطع می‌شود', ok: 'لغو شود')) app.setConsent(c, false);
                            },
                            child: Text('لغو رضایت', style: ts(13, w: FontWeight.w700, c: C.red)))
                        : SizedBox(width: 150, child: PrimaryButton('امضای دیجیتال', onPressed: () => app.setConsent(c, true))),
                  ]),
                ]),
              ),
          ],
        ),
      );
}
