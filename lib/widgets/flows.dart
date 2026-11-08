import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ecosolar/core/fmt.dart';
import 'package:ecosolar/core/theme.dart';
import 'package:ecosolar/data/api.dart';
import 'package:ecosolar/widgets/ui.dart';

Future<T?> sheet<T>(BuildContext c, Widget child) => showModalBottomSheet<T>(
      context: c,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: C.grey, borderRadius: BorderRadius.circular(9)))),
              gap16,
              child,
            ]),
          ),
        ),
      ),
    );

/// CMP-04 ExplainabilityPanel. Returns 'accept' | 'custom' | 'reject' | null
Future<String?> showExplain(BuildContext c, {required String title, required List<(String, String)> inputs, String? note}) =>
    sheet<String>(
      c,
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Text('چرا این پیشنهاد؟', style: ts(13, c: C.muted)),
        Text(title, style: ts(18, w: FontWeight.w800)),
        gap12,
        ECard(child: Column(children: [for (final i in inputs) KV(i.$1, i.$2)])),
        if (note != null) ...[gap12, Text(note, style: ts(13, c: C.muted))],
        gap16,
        Builder(builder: (ctx) => PrimaryButton('پذیرش', onPressed: () => Navigator.pop(ctx, 'accept'))),
        gap8,
        Builder(
          builder: (ctx) => Row(children: [
            Expanded(child: PrimaryButton('شخصی‌سازی', outlined: true, onPressed: () => Navigator.pop(ctx, 'custom'))),
            gap8,
            Expanded(child: PrimaryButton('رد', outlined: true, onPressed: () => Navigator.pop(ctx, 'reject'))),
          ]),
        ),
      ]),
    );

/// CMP-08 MFAChallengeModal. Returns the OTP when verified, otherwise null.
Future<String?> showMfa(BuildContext c, {required String action, required String amount}) =>
    sheet<String>(c, _Mfa(action: action, amount: amount));

class _Mfa extends StatefulWidget {
  final String action, amount;
  const _Mfa({required this.action, required this.amount});
  @override
  State<_Mfa> createState() => _MfaState();
}

class _MfaState extends State<_Mfa> {
  final ctrl = TextEditingController();
  int left = 120;
  String? err;
  Timer? t;
  @override
  void initState() {
    super.initState();
    t = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => left = left > 0 ? left - 1 : 0));
  }

  @override
  void dispose() {
    t?.cancel();
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [const IconCircle(Icons.lock_outline, bg: C.soft), gap12, Expanded(child: Text('تأیید دومرحله‌ای', style: ts(18, w: FontWeight.w800)))]),
        gap12,
        ECard(child: Column(children: [KV('عملیات', widget.action), KV('مبلغ', widget.amount, bold: true)])),
        gap12,
        Text('کد ۶ رقمی پیامک‌شده را وارد کنید (نسخه نمایشی: ${fa(demoOtp)})', style: ts(13, c: C.muted)),
        gap8,
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: ts(22, w: FontWeight.w800).copyWith(letterSpacing: 10),
          decoration: InputDecoration(counterText: '', errorText: err, hintText: '• • • • • •'),
        ),
        gap8,
        Row(children: [
          Text(left > 0 ? 'ارسال مجدد ${mmss(left)}' : 'ارسال مجدد', style: ts(13, c: C.muted)),
          const Spacer(),
          if (left == 0) TextButton(onPressed: () => setState(() => left = 120), child: Text('ارسال دوباره', style: ts(13, w: FontWeight.w700))),
        ]),
        gap12,
        PrimaryButton('تأیید', onPressed: () {
          final code = en(ctrl.text.trim());
          if (code == demoOtp) {
            Navigator.pop(context, code);
          } else {
            setState(() => err = 'کد نادرست است');
          }
        }),
      ]);
}

/// CMP-16 CountdownTimer chip
class Countdown extends StatefulWidget {
  final Duration left;
  const Countdown(this.left, {super.key});
  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  late Duration d = widget.left;
  Timer? t;
  @override
  void initState() {
    super.initState();
    t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => d = d.inSeconds > 0 ? d - const Duration(seconds: 1) : Duration.zero);
    });
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = d.inHours, m = d.inMinutes % 60;
    return Pill(fa('${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}'), tone: Tone.amber, icon: Icons.timer_outlined);
  }
}

Future<bool> confirm(BuildContext c, String title, String body, {String ok = 'تأیید'}) async =>
    await sheet<bool>(
      c,
      Builder(
        builder: (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: ts(18, w: FontWeight.w800)),
          gap8,
          Text(body, style: ts(14, c: C.muted)),
          gap16,
          PrimaryButton(ok, onPressed: () => Navigator.pop(ctx, true)),
          gap8,
          PrimaryButton('انصراف', outlined: true, onPressed: () => Navigator.pop(ctx, false)),
        ]),
      ),
    ) ??
    false;
