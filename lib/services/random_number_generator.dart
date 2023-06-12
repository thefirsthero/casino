import 'dart:math';

class RandomNumberGenerator {
  List<int> generateNumbers(int count, int min, int max) {
    final random = Random();
    List<int> numbers = [];

    for (int i = 0; i < count; i++) {
      numbers.add(random.nextInt(max - min + 1) + min);
    }

    return numbers;
  }
}
