const _en = '0123456789';
const _fa = '۰۱۲۳۴۵۶۷۸۹';
const _ar = '٠١٢٣٤٥٦٧٨٩';

/// Persian digits
String fa(Object v) {
  final b = StringBuffer();
  for (final ch in v.toString().split('')) {
    final i = _en.indexOf(ch);
    b.write(i < 0 ? ch : _fa[i]);
  }
  return b.toString();
}

/// Latin digits (for parsing user input)
String en(String s) {
  final b = StringBuffer();
  for (final ch in s.split('')) {
    final i = _fa.indexOf(ch), j = _ar.indexOf(ch);
    b.write(i >= 0 ? _en[i] : (j >= 0 ? _en[j] : ch));
  }
  return b.toString();
}

String sep(num n) {
  final s = n.abs().round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('٬');
    b.write(s[i]);
  }
  return (n < 0 ? '-' : '') + b.toString();
}

String num0(num n) => fa(sep(n));
String dec(num n, [int d = 1]) => fa(n.toStringAsFixed(d)).replaceAll('.', '٫');
String pct(num n, [int d = 0]) => '${dec(n, d)}٪';
String toman(num n) => '${num0(n)} تومان';
String mt(num n) => '${dec(n / 1e6, 1)} م.ت';
String kwh(num n) => '${num0(n)} kWh';
String mmss(int s) => fa('${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}');
double parseNum(String s) => double.tryParse(en(s).replaceAll('٫', '.').replaceAll('٬', '').replaceAll(',', '')) ?? 0;
