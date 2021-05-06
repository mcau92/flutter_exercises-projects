class Highlight {
  String id;
  String highlightText;

  Highlight(this.id, this.highlightText);

  Highlight.fromMap(Map snapshot, String id)
      : id = id ?? '',
        highlightText = snapshot['highlightText'] ?? '';

  toJson() {
    return {"id": id, "highlightText": highlightText};
  }
}
