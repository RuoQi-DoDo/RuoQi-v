import 'package:html/dom.dart' as dom;

class ProductHtmlStylesheet {
  ProductHtmlStylesheet._(this._rules);

  factory ProductHtmlStylesheet.fromNodes(List<dom.Node> nodes) {
    final rules = <ProductHtmlRule>[];
    var order = 0;

    void collect(dom.Node node) {
      if (node is dom.Element && node.localName == 'style') {
        final source = node.text.replaceAll(
          RegExp(r'/\*[\s\S]*?\*/', multiLine: true),
          '',
        );
        for (final match in RegExp(
          r'([^{}]+)\{([^{}]*)\}',
          multiLine: true,
        ).allMatches(source)) {
          final selectorSource = match.group(1)?.trim() ?? '';
          if (selectorSource.isEmpty || selectorSource.startsWith('@')) {
            continue;
          }
          final declarations = parseProductCssDeclarations(
            match.group(2) ?? '',
          );
          if (declarations.isEmpty) continue;
          for (final selector in selectorSource.split(',')) {
            final normalized = selector.trim();
            if (normalized.isEmpty) continue;
            rules.add(
              ProductHtmlRule(
                selector: normalized,
                declarations: declarations,
                specificity: _selectorSpecificity(normalized),
                order: order++,
              ),
            );
          }
        }
      }
      for (final child in node.nodes) {
        collect(child);
      }
    }

    for (final node in nodes) {
      collect(node);
    }
    return ProductHtmlStylesheet._(rules);
  }

  final List<ProductHtmlRule> _rules;

  Map<String, String> declarationsFor(dom.Element element) {
    final matches =
        _rules
            .where((rule) => _selectorMatches(element, rule.selector))
            .toList()
          ..sort((left, right) {
            final specificity = left.specificity.compareTo(right.specificity);
            return specificity != 0
                ? specificity
                : left.order.compareTo(right.order);
          });
    final declarations = <String, String>{};
    for (final rule in matches) {
      declarations.addAll(rule.declarations);
    }
    declarations.addAll(
      parseProductCssDeclarations(element.attributes['style'] ?? ''),
    );
    return declarations;
  }
}

class ProductHtmlRule {
  const ProductHtmlRule({
    required this.selector,
    required this.declarations,
    required this.specificity,
    required this.order,
  });

  final String selector;
  final Map<String, String> declarations;
  final int specificity;
  final int order;
}

Map<String, String> parseProductCssDeclarations(String source) {
  final declarations = <String, String>{};
  for (final part in source.split(';')) {
    final separator = part.indexOf(':');
    if (separator <= 0) continue;
    final property = part.substring(0, separator).trim().toLowerCase();
    final value = part
        .substring(separator + 1)
        .replaceAll(RegExp(r'!important', caseSensitive: false), '')
        .trim();
    if (property.isNotEmpty && value.isNotEmpty) {
      declarations[property] = value;
    }
  }
  return declarations;
}

bool _selectorMatches(dom.Element element, String source) {
  var selector = source
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
      .replaceAll(RegExp(r'::?[a-zA-Z-]+(?:\([^)]*\))?'), '')
      .trim();
  if (selector.isEmpty) return false;
  selector = selector.replaceFirst(RegExp(r'^(?:html|body)\s+'), '');
  final parts = selector
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty && part != '>')
      .toList(growable: false);
  if (parts.isEmpty) return false;

  bool matchAt(dom.Element? current, int index) {
    if (current == null || !_simpleSelectorMatches(current, parts[index])) {
      return false;
    }
    if (index == 0) return true;
    for (var parent = current.parent; parent != null; parent = parent.parent) {
      if (matchAt(parent, index - 1)) return true;
    }
    return false;
  }

  return matchAt(element, parts.length - 1);
}

bool _simpleSelectorMatches(dom.Element element, String selector) {
  if (selector == '*') return true;
  final attributes = RegExp(
    r'''\[\s*([a-zA-Z0-9_-]+)\s*(?:=\s*["']?([^"'\]\s]+)["']?)?\s*\]''',
  );
  for (final match in attributes.allMatches(selector)) {
    final name = match.group(1)?.toLowerCase() ?? '';
    final value = match.group(2);
    final actual = element.attributes[name];
    if (actual == null || (value != null && actual != value)) return false;
  }
  final simple = selector.replaceAll(attributes, '').trim();
  if (simple.isEmpty) return true;

  final tagMatch = RegExp(r'^[a-zA-Z][a-zA-Z0-9_-]*').firstMatch(simple);
  if (tagMatch != null &&
      tagMatch.group(0)!.toLowerCase() != element.localName) {
    return false;
  }
  final idMatch = RegExp(r'#([a-zA-Z0-9_-]+)').firstMatch(simple);
  if (idMatch != null && element.id != idMatch.group(1)) return false;
  final classes = (element.attributes['class'] ?? '')
      .split(RegExp(r'\s+'))
      .where((value) => value.isNotEmpty)
      .toSet();
  for (final match in RegExp(r'\.([a-zA-Z0-9_-]+)').allMatches(simple)) {
    if (!classes.contains(match.group(1))) return false;
  }
  return true;
}

int _selectorSpecificity(String selector) {
  final ids = RegExp(r'#[\w-]+').allMatches(selector).length;
  final classes = RegExp(r'\.[\w-]+|\[[^\]]+\]').allMatches(selector).length;
  final tags = RegExp(
    r'(?:^|[\s>+~])([a-zA-Z][\w-]*)',
  ).allMatches(selector).length;
  return ids * 100 + classes * 10 + tags;
}
