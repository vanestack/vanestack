import 'dart:math';

String generateRandomName({bool withNumber = true}) {
  final adjectives = [
    'brave',
    'calm',
    'frosty',
    'mighty',
    'silent',
    'sunny',
    'eager',
    'gentle',
    'wild',
    'bold',
    'lively',
    'bright',
  ];

  final nouns = [
    'mountain',
    'forest',
    'river',
    'sky',
    'ocean',
    'breeze',
    'fire',
    'cloud',
    'shadow',
    'storm',
    'meadow',
    'sunrise',
  ];

  final random = Random();
  final adjective = adjectives[random.nextInt(adjectives.length)];
  final noun = nouns[random.nextInt(nouns.length)];

  String name = '$adjective-$noun';

  if (withNumber) {
    final number = random.nextInt(9000) + 1000; // 1000–9999
    name = '$name-$number';
  }

  return name;
}
