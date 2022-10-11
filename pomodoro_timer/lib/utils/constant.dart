class Constant {
  static List<int> getStudyOptions() {
    List<int> values = [];
    for (var i = 1; i < 601; i++) {
      values.add(i);
    }

    return values;
  }

  static List<int> getPausaOptions() {
    List<int> values = [];
    for (var i = 5; i < 61; i++) {
      values.add(i);
    }

    return values;
  }

  static List<int> getRipetiOptions() {
    List<int> values = [];
    for (var i = 1; i < 101; i++) {
      values.add(i);
    }
    return values;
  }
}
