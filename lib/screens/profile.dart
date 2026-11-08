import 'package:flutter/material.dart';
import 'package:ecosolar/core/fmt.dart';
import 'package:ecosolar/core/jalali.dart';
import 'package:ecosolar/core/theme.dart';
import 'package:ecosolar/core/validators.dart';
import 'package:ecosolar/data/models.dart';
import 'package:ecosolar/data/store.dart';
import 'package:ecosolar/screens/home.dart';
import 'package:ecosolar/screens/shell.dart';
import 'package:ecosolar/widgets/flows.dart';
import 'package:ecosolar/widgets/ui.dart';

/// SCR-C-60 Profile, connections & settings
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  Widget row(BuildContext c, IconData i, String t, String route, {String? sub}) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: IconCircle(i, size: 40),
        title: Text(t, style: ts(14, w: FontWeight.w600)),
        subtitle: sub == null ? null : Text(sub, style: ts(12, c: C.muted)),
        trailing: const Icon(Icons.chevron_left),
        onTap: () => Navigator.pushNamed(c, route),
      );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => TabBody(
          header: const TabHeader('پروفایل'),
          children: [
            ECard(dark: true, child: Row(children: [
              Avatar(app.name, size: 56),
              gap12,
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(app.name, style: ts(17, w: FontWeight.w800, c: Colors.white)),
                Text('کد ملی •••••• ${fa(app.nationalId.substring(app.nationalId.length - 4))}', style: ts(12.5, c: Colors.white70)),
                gap8,
                Pill(app.kyc == 'verified' ? 'هویت تأییدشده' : 'نیاز به تکمیل هویت', tone: app.kyc == 'verified' ? Tone.green : Tone.amber),
              ])),
            ])),
            ECard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('انشعاب‌ها و کنتورها', style: ts(14, w: FontWeight.w700)),
              ListTile(contentPadding: EdgeInsets.zero, leading: const IconCircle(Icons.electric_meter_outlined, size: 40), title: Text('شناسه ${fa('1234567890123')}', style: ts(14)), subtitle: Text('خانگی · دیماند ${dec(app.bill['demand']!, 0)} kW', style: ts(12, c: C.muted)), trailing: const Pill('دوطرفه', tone: Tone.blue)),
            ])),
            ECard(child: Row(children: [
              const IconCircle(Icons.account_balance_outlined, size: 40),
              gap12,
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(bankOf(app.sheba) ?? 'حساب بانکی', style: ts(14, w: FontWeight.w700)), Text(maskSheba(app.sheba), style: ts(12.5, c: C.muted))])),
              TextButton(onPressed: () => Navigator.pushNamed(context, '/onboarding/kyc'), child: Text('تغییر شبا', style: ts(13, w: FontWeight.w700))),
            ])),
            ECard(child: Column(children: [
              row(context, Icons.handshake_outlined, 'رضایت‌نامه‌ها', '/onboarding/consents', sub: '${fa(app.consents.where((c) => c.signed).length)} فعال'),
              row(context, Icons.folder_outlined, 'اسناد و قراردادها', '/plant/case'),
              row(context, Icons.sync_alt, 'بازنگری کانال', '/plant/channel-review'),
              if (app.legal) row(context, Icons.groups_outlined, 'اعضای سازمان', '/onboarding/organization'),
              row(context, Icons.support_agent, 'پشتیبانی', '/support'),
            ])),
            ECard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('اعلان‌ها', style: ts(14, w: FontWeight.w700)),
              for (final e in app.notifPrefs.entries)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e.key, style: ts(14)),
                  subtitle: e.key == 'امنیت' ? Text('اعلان‌های امنیتی همیشه فعال است', style: ts(12, c: C.muted)) : null,
                  value: e.value,
                  onChanged: e.key == 'امنیت' ? null : (v) { app.notifPrefs[e.key] = v; app.touch(); },
                ),
            ])),
            ECard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('بهینه‌سازی خودکار درآمد', style: ts(14, w: FontWeight.w600)),
                subtitle: Text(app.channel == 'fit' ? 'برای قرارداد FiT قفل است' : 'فقط برای ظرفیت منعطف VPP/PPA؛ هر تغییر نیاز به تأیید شما دارد', style: ts(12, c: C.muted)),
                value: app.autoMax && app.channel != 'fit',
                onChanged: app.channel == 'fit' ? null : (v) { app.autoMax = v; app.touch(); },
              ),
            ])),
            PrimaryButton('خروج از حساب', outlined: true, icon: Icons.logout, onPressed: () async {
              if (await confirm(context, 'خروج', 'از حساب خارج می‌شوید؟', ok: 'خروج') && context.mounted) {
                app.logout();
                MainShell.tab.value = 0;
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              }
            }),
          ],
        ),
      );
}

/// SCR-C-61 Periodic channel review
class ChannelReviewScreen extends StatelessWidget {
  const ChannelReviewScreen({super.key});
  Widget split(String title, double vpp, bool hi) => Expanded(
        child: ECard(
          border: Border.all(color: hi ? C.black : Colors.transparent, width: 1.6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: ts(13, w: FontWeight.w700)),
            gap12,
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Row(children: [Expanded(flex: (vpp * 100).round(), child: Container(height: 12, color: C.black)), Expanded(flex: 100 - (vpp * 100).round(), child: Container(height: 12, color: C.blue))])),
            gap8,
            Text('VPP ${pct(vpp * 100)} · PPA ${pct(100 - vpp * 100)}', style: ts(12, c: C.muted)),
          ]),
        ),
      );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => EPage(
          title: 'بازنگری کانال',
          bottom: app.reviewDecision != 0
              ? null
              : Row(children: [
                  Expanded(child: PrimaryButton('حفظ تخصیص فعلی', outlined: true, onPressed: () { app.reviewDecision = 2; app.touch(); })),
                  gap8,
                  Expanded(child: PrimaryButton('پذیرش تخصیص جدید', onPressed: () async {
                    if (await confirm(context, 'پذیرش تخصیص جدید', 'سهم VPP از ۶۰٪ به ۴۰٪ تغییر می‌کند')) { app.reviewDecision = 1; app.touch(); }
                  })),
                ]),
          children: [
            ECard(child: Row(children: [const IconCircle(Icons.event_repeat, size: 40), gap12, Expanded(child: Text('پیشنهاد تخصیص جدید آماده است', style: ts(14, w: FontWeight.w600))), const Pill('سالگرد قرارداد', tone: Tone.blue)])),
            Row(children: [split('تخصیص فعلی', .6, false), gap12, split('تخصیص پیشنهادی', .4, true)]),
            ECard(dark: true, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Text('اثر مالی سالانه', style: ts(13, c: Colors.white70)), const Spacer(), const ScenarioTag(onDark: true)]),
              Text('+${toman(18.5e6)}', style: ts(24, w: FontWeight.w800, c: Colors.white)),
            ])),
            ECard(child: Column(children: const [KV('ظرفیت قفل‌شده (FiT)', '۴ kW'), KV('ظرفیت منعطف', '۶ kW')])),
            if (app.reviewDecision != 0)
              Notice(app.reviewDecision == 1 ? 'تخصیص جدید پذیرفته شد · ${jDate(DateTime.now())} ${hm(DateTime.now())}' : 'تخصیص فعلی حفظ شد · ${jDate(DateTime.now())} ${hm(DateTime.now())}', tone: Tone.green, icon: Icons.check_circle_outline),
          ],
        ),
      );
}

/// SCR-C-63 Support & ticketing
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  Ticket? open;
  final msg = TextEditingController();
  static const topics = ['مغایرت صورتحساب', 'اشکال فنی', 'پرونده مهرسان', 'سایر'];

  Future<void> create() async {
    var t = 0;
    final d = TextEditingController();
    final ok = await sheet<bool>(context, StatefulBuilder(builder: (ctx, set) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('تیکت جدید', style: ts(18, w: FontWeight.w800)),
          gap12,
          ChipsRow(items: topics, value: t, onChanged: (v) => set(() => t = v)),
          gap12,
          TextField(controller: d, maxLines: 4, decoration: const InputDecoration(hintText: 'شرح مشکل')),
          gap16,
          PrimaryButton('ارسال', onPressed: () => Navigator.pop(ctx, d.text.trim().isNotEmpty)),
        ])));
    if (ok == true) setState(() => open = app.newTicket(topics[t], d.text.trim()));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          final t = open;
          if (t == null) {
            return EPage(title: 'پشتیبانی', bottom: PrimaryButton('ثبت تیکت جدید', icon: Icons.add, onPressed: create), children: [
              for (final x in app.tickets)
                ECard(onTap: () => setState(() => open = x), child: Row(children: [
                  const IconCircle(Icons.confirmation_number_outlined, size: 40),
                  gap12,
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('#${fa(x.id)} · ${x.topic}', style: ts(14, w: FontWeight.w700)), Text(x.msgs.last.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(12, c: C.muted))])),
                  Pill(x.status, tone: Tone.blue),
                ])),
            ]);
          }
          return Scaffold(
            appBar: AppBar(title: Text('تیکت #${fa(t.id)}'), leading: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: () => setState(() => open = null))),
            body: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Column(children: [
                  ECard(padding: const EdgeInsets.all(14), child: Row(children: [Expanded(child: Text(t.topic, style: ts(14, w: FontWeight.w700))), Pill(t.status, tone: Tone.blue)])),
                  gap8,
                  const Notice('کارشناس پشتیبانی تا ۲ ساعت به پرونده شما دسترسی دارد؛ این دسترسی ثبت می‌شود', tone: Tone.amber, icon: Icons.visibility_outlined),
                ]),
              ),
              Expanded(
                child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
                  for (final m in t.msgs)
                    Align(
                      alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        constraints: const BoxConstraints(maxWidth: 290),
                        decoration: BoxDecoration(color: m.mine ? C.black : C.soft, borderRadius: BorderRadius.circular(20)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(m.text, style: ts(14, c: m.mine ? Colors.white : C.ink)),
                          Text(hm(m.at), style: ts(11, c: m.mine ? Colors.white54 : C.muted)),
                        ]),
                      ),
                    ),
                ]),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: Row(children: [
                    IconButton(onPressed: () => toast(context, 'پیوست اضافه شد'), icon: const Icon(Icons.attach_file)),
                    Expanded(child: TextField(controller: msg, decoration: const InputDecoration(hintText: 'پیام خود را بنویسید'))),
                    gap8,
                    GestureDetector(
                      onTap: () {
                        if (msg.text.trim().isEmpty) return;
                        app.sendMsg(t, msg.text.trim());
                        msg.clear();
                      },
                      child: const CircleAvatar(radius: 26, backgroundColor: C.black, child: Icon(Icons.send, color: Colors.white)),
                    ),
                  ]),
                ),
              ),
            ]),
          );
        },
      );
}
