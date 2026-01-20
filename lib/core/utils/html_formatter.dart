import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

class HtmlFormatter {
  /// Converts HTML string to plain text
  static String htmlToText(String htmlString) {
    dom.Document document = parse(htmlString);
    return document.body?.text ?? '';
  }
}
