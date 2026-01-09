final List<String> items = [
  'Overall',
  'Millerz',
  'Scarletz',
  'Expressionz',
];
final List<String> items2 =
    List.generate(8, (index) => (DateTime.now().year - index).toString());

Set<String> generateUnitNumbers() {
  final Set<String> unitNumbers = {};

  for (int i = 1; i <= 25; i++) {
    for (int j = 1; j <= 25; j++) {
      unitNumbers.add(
          '${i.toString().padLeft(2, '0')}-${j.toString().padLeft(2, '0')}');
    }
  }

  return unitNumbers;
}

