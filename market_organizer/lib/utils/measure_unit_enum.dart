enum MeasureUnit {
  g,
  kg,
  l,

  confezione,
  mista,
  scatolone,
  pacco,
}

extension MeasureUnitUtils on MeasureUnit {
  static MeasureUnit translateUnit(String s) {
    switch (s.toLowerCase()) {
      case "g":
        return MeasureUnit.g;
      case "kg":
        return MeasureUnit.kg;
      case "l":
        return MeasureUnit.l;
      case "confezione":
        return MeasureUnit.confezione;
      case "mista":
        return MeasureUnit.mista;
      case "scatolone":
        return MeasureUnit.scatolone;
      case "pacco":
        return MeasureUnit.pacco;
      default:
        return null;
    }
  }
}
