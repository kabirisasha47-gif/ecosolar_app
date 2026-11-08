import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ecosolar/core/fmt.dart';
import 'package:ecosolar/core/theme.dart';
import 'package:ecosolar/data/api.dart';
import 'package:ecosolar/data/store.dart';
import 'package:ecosolar/widgets/ui.dart';

/// SCR-C-01 Login & OTP
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phone = TextEditingController(), otp = TextEditingController();
  final otpFocus = FocusNode();
  int type = 0, left = 0;
  bool sent = false, busy = false;
  String? phoneErr, otpErr;
  Timer? t;

  @override
  void dispose() {
    t?.cancel();
    phone.dispose();
    otp.dispose();
    otpFocus.dispose();
    super.dispose();
  }

  void startTimer() {
    left = 85;
    t?.cancel();
    t = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => left = left > 0 ? left - 1 : 0));
  }

  Future<void> send() async {
    final m = en(phone.text.replaceAll(' ', ''));
    if (!RegExp(r'^09\d{9}$').hasMatch(m)) {
      setState(() => phoneErr = 'شماره موبایل باید ۱۱ رقم و با ۰۹ شروع شود');
      return;
    }
    setState(() {
      phoneErr = null;
      busy = true;
    });
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {
      busy = false;
      sent = true;
    });
    startTimer();
    otpFocus.requestFocus();
  }

  Future<void> verify() async {
    if (en(otp.text) != demoOtp) {
      setState(() => otpErr = 'کد نادرست است');
      return;
    }
    setState(() => busy = true);
    await Future.delayed(const Duration(milliseconds: 500));
    app.login(en(phone.text), type == 1);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, app.kyc == 'verified' ? '/home' : '/onboarding/kyc');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), children: [
            Center(
              child: Container(
                width: 180, height: 150,
                decoration: BoxDecoration(color: C.soft, borderRadius: BorderRadius.circular(40)),
                child: const Stack(alignment: Alignment.center, children: [
                  Positioned(top: 18, right: 30, child: Icon(Icons.wb_sunny_rounded, size: 46, color: Color(0xFFF59E0B))),
                  Icon(Icons.solar_power_rounded, size: 86, color: C.black),
                ]),
              ),
            ),
            gap24,
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: C.black, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.eco_outlined, color: Colors.white)),
              gap8,
              Text('EcoSolar', style: ts(24, w: FontWeight.w800)),
            ]),
            gap24,
            Text('ورود به حساب', style: ts(22, w: FontWeight.w800)),
            Text(sent ? 'کد ۶ رقمی ارسال‌شده به ${fa(phone.text)} را وارد کنید' : 'شماره موبایل خود را وارد کنید', style: ts(14, c: C.muted)),
            gap16,
            if (!sent) ...[
              Segmented(items: const ['حقیقی', 'حقوقی'], value: type, onChanged: (v) => setState(() => type = v)),
              gap12,
              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: InputDecoration(counterText: '', hintText: '۰۹۱۲ ۳۴۵ ۶۷۸۹', prefixIcon: const Icon(Icons.phone_iphone), errorText: phoneErr),
              ),
              gap24,
              PrimaryButton('دریافت کد', loading: busy, onPressed: send),
            ] else ...[
              GestureDetector(
                onTap: () => otpFocus.requestFocus(),
                child: Stack(children: [
                  ValueListenableBuilder(
                    valueListenable: otp,
                    builder: (_, v, __) => Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(children: [
                        for (var i = 0; i < 6; i++)
                          Expanded(
                            child: Container(
                              height: 58,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: C.soft,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: i == v.text.length ? C.black : Colors.transparent, width: 1.6),
                              ),
                              child: Text(i < v.text.length ? fa(v.text[i]) : '', style: ts(22, w: FontWeight.w800)),
                            ),
                          ),
                      ]),
                    ),
                  ),
                  Opacity(
                    opacity: 0,
                    child: TextField(controller: otp, focusNode: otpFocus, maxLength: 6, keyboardType: TextInputType.number, onChanged: (_) => setState(() => otpErr = null)),
                  ),
                ]),
              ),
              if (otpErr != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(otpErr!, style: ts(13, c: C.red))),
              gap12,
              Row(children: [
                left > 0
                    ? Text('ارسال مجدد ${mmss(left)}', style: ts(13, c: C.muted))
                    : TextButton(onPressed: startTimer, child: Text('ارسال مجدد کد', style: ts(13, w: FontWeight.w700))),
                const Spacer(),
                TextButton(onPressed: () => setState(() { sent = false; otp.clear(); }), child: Text('ویرایش شماره', style: ts(13, w: FontWeight.w700))),
              ]),
              Text('نسخه نمایشی: کد ${fa(demoOtp)}', style: ts(12, c: C.muted)),
              gap24,
              PrimaryButton('تأیید و ورود', loading: busy, onPressed: verify),
            ],
            gap16,
            Text('ورود شما به معنای پذیرش قوانین و حریم خصوصی EcoSolar است', textAlign: TextAlign.center, style: ts(12, c: C.muted)),
          ]),
        ),
      );
}
