class DecimalUtils {
  /**
   * se ritorno null è perchè l'input è null
   * se ritorno true allora il decimale ha una sola virgola ma è valido se sostituita con il punto
   * se ritorno false allora il decimale ha una sola virgola ma non è valido
   */
  static bool? isDoubleValidWithComma(String? decimal) {
    if (decimal == null || !decimal.contains(",")) return null;
    //ho almeno una virgola
    if (decimal.allMatches(",").length == 1) {
      decimal = decimal.replaceAll(",", ".");
      if (double.tryParse(decimal) != null) {
        return true;
      }
      return false;
    }

    return null;
  }
}
