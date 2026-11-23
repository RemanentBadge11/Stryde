import 'dart:convert';
import 'dart:math';

String generateUuidV4() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(256));
  values[6] = (values[6] & 0x0f) | 0x40; // Version 4
  values[8] = (values[8] & 0x3f) | 0x80; // Variant 10xx

  final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).toList();

  return '${hex.sublist(0, 4).join()}-'
      '${hex.sublist(4, 6).join()}-'
      '${hex.sublist(6, 8).join()}-'
      '${hex.sublist(8, 10).join()}-'
      '${hex.sublist(10, 16).join()}';
}

String deterministicUuid(String input) {
  final bytes = utf8.encode(input);
  var h1 = 0x811c9dc5;
  var h2 = 0x5a7c2a17;
  var h3 = 0x3c6ef372;
  var h4 = 0xbb40e64d;

  for (final b in bytes) {
    h1 = (h1 ^ b) * 0x01000193;
    h2 = (h2 ^ (b + 17)) * 0x01000193;
    h3 = (h3 ^ (b + 31)) * 0x01000193;
    h4 = (h4 ^ (b + 47)) * 0x01000193;
  }

  final values = <int>[
    (h1 >> 24) & 0xff,
    (h1 >> 16) & 0xff,
    (h1 >> 8) & 0xff,
    h1 & 0xff,
    (h2 >> 24) & 0xff,
    (h2 >> 16) & 0xff,
    (h2 >> 8) & 0xff,
    h2 & 0xff,
    (h3 >> 24) & 0xff,
    (h3 >> 16) & 0xff,
    (h3 >> 8) & 0xff,
    h3 & 0xff,
    (h4 >> 24) & 0xff,
    (h4 >> 16) & 0xff,
    (h4 >> 8) & 0xff,
    h4 & 0xff,
  ];

  values[6] = (values[6] & 0x0f) | 0x40; // Version 4
  values[8] = (values[8] & 0x3f) | 0x80; // Variant 10xx

  final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).toList();

  return '${hex.sublist(0, 4).join()}-'
      '${hex.sublist(4, 6).join()}-'
      '${hex.sublist(6, 8).join()}-'
      '${hex.sublist(8, 10).join()}-'
      '${hex.sublist(10, 16).join()}';
}
