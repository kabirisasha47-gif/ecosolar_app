import 'package:ecosolar/core/fmt.dart';

/// Iranian national code checksum
bool validNationalId(String raw) {
  final s = en(raw.trim());
  if (!RegExp(r'^\d{10}$').hasMatch(s) || RegExp(r'^(\d)\1{9}$').hasMatch(s)) return false;
  var sum = 0;
  for (var i = 0; i < 9; i++) {
    sum += int.parse(s[i]) * (10 - i);
  }
  final r = sum % 11, c = int.parse(s[9]);
  return r < 2 ? c == r : c == 11 - r;
}

/// IBAN (Sheba) mod-97 check, format IR + 24 digits
bool validSheba(String raw) {
  final s = en(raw.replaceAll(' ', '').toUpperCase());
  if (!RegExp(r'^IR\d{24}$').hasMatch(s)) return false;
  final moved = '${s.substring(4)}1827${s.substring(2, 4)}';
  return BigInt.parse(moved) % BigInt.from(97) == BigInt.one;
}

const _banks = {
  '012': 'بانک ملت', '017': 'بانک ملی', '018': 'بانک تجارت', '019': 'بانک صادرات',
  '054': 'بانک پارسیان', '055': 'بانک اقتصاد نوین', '056': 'بانک سامان', '057': 'بانک پاسارگاد',
  '062': 'بانک آینده', '016': 'بانک کشاورزی', '015': 'بانک سپه',
};

String? bankOf(String raw) {
  final s = en(raw.replaceAll(' ', '').toUpperCase());
  if (s.length < 7) return null;
  return _banks[s.substring(4, 7)];
}

String maskSheba(String s) => 'IR•• •••• ${fa(s.substring(s.length - 4))}';
