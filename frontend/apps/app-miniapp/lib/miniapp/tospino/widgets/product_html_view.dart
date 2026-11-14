import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import '../api/tospino_api.dart';
import '../tospino_style.dart';
import 'product_html_css.dart';

class TospinoProductHtmlView extends StatelessWidget {
  const TospinoProductHtmlView({
    super.key,
    required this.description,
    required this.fallback,
  });

  final String description;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final source = description.trim().isEmpty ? fallback : description;
    final fragment = html_parser.parseFragment(source);
    final styles = ProductHtmlStylesheet.fromNodes(fragment.nodes);
    final renderer = _ProductHtmlRenderer(context, styles);
    return Column(
      key: const Key('tospino-product-html'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: renderer.buildBlocks(fragment.nodes),
    );
  }
}

class _ProductHtmlRenderer {
  _ProductHtmlRenderer(this.context, this.styles);

  final BuildContext context;
  final ProductHtmlStylesheet styles;

  static const _blockTags = <String>{
    'html',
    'body',
    'div',
    'section',
    'article',
    'header',
    'footer',
    'main',
    'aside',
    'center',
    'p',
    'pre',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'ul',
    'ol',
    'li',
    'blockquote',
    'table',
    'hr',
    'img',
    'figure',
    'script',
    'style',
  };

  TextStyle get _bodyStyle =>
      TospinoText.body(context).copyWith(fontSize: 13.5, height: 1.65);

  List<Widget> buildBlocks(
    List<dom.Node> nodes, {
    TextStyle? inheritedStyle,
    TextAlign inheritedAlign = TextAlign.left,
  }) {
    final baseStyle = inheritedStyle ?? _bodyStyle;
    final widgets = <Widget>[];
    var inlineBuffer = <dom.Node>[];

    void flushInline() {
      if (inlineBuffer.isEmpty) return;
      final widget = _buildInlineText(
        inlineBuffer,
        baseStyle,
        inheritedAlign,
        defaultBottom: 8,
      );
      if (widget != null) widgets.add(widget);
      inlineBuffer = <dom.Node>[];
    }

    for (final node in nodes) {
      if (_isBlock(node)) {
        flushInline();
        final widget = _buildBlock(
          node,
          inheritedStyle: baseStyle,
          inheritedAlign: inheritedAlign,
        );
        if (widget != null) widgets.add(widget);
      } else {
        inlineBuffer.add(node);
      }
    }
    flushInline();
    return widgets;
  }

  bool _isBlock(dom.Node node) {
    if (node is! dom.Element) return false;
    final tag = node.localName ?? '';
    if (_blockTags.contains(tag)) return true;
    final display = _declarations(node)['display']?.toLowerCase() ?? '';
    return display == 'block' ||
        display == 'table' ||
        display == 'list-item' ||
        display == 'flex' ||
        display == 'grid';
  }

  Widget? _buildBlock(
    dom.Node node, {
    required TextStyle inheritedStyle,
    required TextAlign inheritedAlign,
  }) {
    if (node is dom.Text) {
      final text = _cleanText(node.text);
      if (text.trim().isEmpty) return null;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, textAlign: inheritedAlign, style: inheritedStyle),
      );
    }
    if (node is! dom.Element) return null;

    final declarations = _declarations(node);
    if (declarations['display']?.toLowerCase() == 'none' ||
        declarations['visibility']?.toLowerCase() == 'hidden') {
      return null;
    }

    final tag = node.localName ?? '';
    final align = _alignment(declarations) ?? inheritedAlign;
    switch (tag) {
      case 'script':
      case 'style':
        return null;
      case 'hr':
        return _decorateBlock(
          node,
          Divider(
            height: 1,
            color: TospinoColors.resolve(context, TospinoColors.line),
          ),
          defaultTop: 10,
          defaultBottom: 10,
        );
      case 'img':
        return _buildImage(node, declarations);
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        final size = switch (tag) {
          'h1' => 22.0,
          'h2' => 20.0,
          'h3' => 18.0,
          'h4' => 16.0,
          _ => 15.0,
        };
        final headingBase = inheritedStyle.copyWith(
          fontSize: size,
          fontWeight: TospinoText.strong,
          height: 1.3,
        );
        return _buildInlineText(
          node.nodes,
          _styledElement(node, headingBase),
          align,
          element: node,
          defaultTop: 4,
          defaultBottom: 9,
        );
      case 'ul':
      case 'ol':
        return _buildList(node, ordered: tag == 'ol');
      case 'blockquote':
        final children = buildBlocks(
          node.nodes,
          inheritedStyle: _styledElement(node, inheritedStyle),
          inheritedAlign: align,
        );
        if (children.isEmpty) return null;
        return _decorateBlock(
          node,
          Container(
            padding: const EdgeInsets.fromLTRB(11, 8, 10, 8),
            decoration: BoxDecoration(
              color: TospinoColors.resolve(context, TospinoColors.surfaceMuted),
              border: Border(
                left: BorderSide(
                  color: TospinoColors.solidBrand(context),
                  width: 3,
                ),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
          defaultBottom: 10,
        );
      case 'table':
        return _buildTable(node);
      case 'p':
        return _buildInlineText(
          node.nodes,
          _styledElement(node, inheritedStyle),
          align,
          element: node,
          defaultBottom: 8,
        );
      case 'pre':
        return _buildPreformatted(node, inheritedStyle, align);
      case 'div':
      case 'section':
      case 'article':
      case 'header':
      case 'footer':
      case 'main':
      case 'aside':
      case 'center':
      case 'figure':
        final children = buildBlocks(
          node.nodes,
          inheritedStyle: _styledElement(node, inheritedStyle),
          inheritedAlign: tag == 'center' ? TextAlign.center : align,
        );
        if (children.isEmpty) return null;
        return _decorateBlock(
          node,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        );
      default:
        final hasBlock = node.nodes.any(_isBlock);
        if (hasBlock) {
          final children = buildBlocks(
            node.nodes,
            inheritedStyle: _styledElement(node, inheritedStyle),
            inheritedAlign: align,
          );
          if (children.isEmpty) return null;
          return _decorateBlock(
            node,
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          );
        }
        return _buildInlineText(
          node.nodes,
          _styledElement(node, inheritedStyle),
          align,
          element: node,
          defaultBottom: 8,
        );
    }
  }

  Widget? _buildInlineText(
    List<dom.Node> nodes,
    TextStyle style,
    TextAlign align, {
    dom.Element? element,
    double defaultTop = 0,
    double defaultBottom = 0,
  }) {
    final spans = _inlineSpans(nodes, style);
    if (!_spansHaveContent(spans)) return null;
    final child = Text.rich(
      TextSpan(style: style, children: spans),
      textAlign: align,
      textScaler: MediaQuery.textScalerOf(context),
    );
    if (element == null) {
      return Padding(
        padding: EdgeInsets.only(top: defaultTop, bottom: defaultBottom),
        child: child,
      );
    }
    return _decorateBlock(
      element,
      child,
      defaultTop: defaultTop,
      defaultBottom: defaultBottom,
    );
  }

  Widget _buildPreformatted(
    dom.Element element,
    TextStyle inheritedStyle,
    TextAlign align,
  ) {
    final text = element.text.replaceAll('\u00A0', ' ').trimRight();
    final style = _styledElement(
      element,
      inheritedStyle.copyWith(
        fontFamily: 'monospace',
        fontSize: inheritedStyle.fontSize,
      ),
    );
    return _decorateBlock(
      element,
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(text, textAlign: align, style: style),
      ),
      defaultBottom: 10,
    );
  }

  Widget _buildList(dom.Element element, {required bool ordered}) {
    final items = element.children
        .where((child) => child.localName == 'li')
        .toList(growable: false);
    if (items.isEmpty) return const SizedBox.shrink();
    final listStyle = _styledElement(element, _bodyStyle);
    final listAlign = _alignment(_declarations(element)) ?? TextAlign.left;
    return _decorateBlock(
      element,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < items.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      ordered ? '${index + 1}.' : '•',
                      textAlign: listAlign,
                      style: listStyle.copyWith(
                        color: TospinoColors.solidBrand(context),
                        fontWeight: TospinoText.emphasis,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: _styledElement(items[index], listStyle),
                        children: _inlineSpans(
                          items[index].nodes,
                          _styledElement(items[index], listStyle),
                        ),
                      ),
                      textAlign: listAlign,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      defaultBottom: 8,
    );
  }

  Widget? _buildImage(dom.Element element, Map<String, String> declarations) {
    final source = _firstAttribute(element, const [
      'src',
      'data-src',
      'data-original',
      'data-lazy-src',
      'data-url',
    ]);
    if (source.isEmpty) return null;
    final url = _normalizeHtmlUrl(source);
    final radius = _length(
      declarations['border-radius'] ?? element.attributes['border-radius'],
      fallback: 10,
    );
    final height = _length(declarations['height']);
    final widthSource =
        declarations['width'] ?? element.attributes['width'] ?? '100%';
    final widthPercent = _percentage(widthSource);
    final fixedWidth = widthPercent == null ? _length(widthSource) : null;

    Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(
        (radius ?? 0).clamp(0, 24).toDouble(),
      ),
      child: ColoredBox(
        color: TospinoColors.resolve(context, TospinoColors.imagePlaceholder),
        child: Image.network(
          url,
          width: double.infinity,
          height: height,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                ),
          errorBuilder: (_, _, _) => const SizedBox(
            height: 100,
            child: Center(child: Icon(Icons.image_not_supported_outlined)),
          ),
        ),
      ),
    );
    if (widthPercent != null && widthPercent < 1) {
      image = FractionallySizedBox(
        widthFactor: widthPercent,
        alignment: Alignment.center,
        child: image,
      );
    } else if (fixedWidth != null) {
      image = Center(
        child: SizedBox(width: fixedWidth, child: image),
      );
    }
    return _decorateBlock(element, image, defaultBottom: 10);
  }

  Widget? _buildTable(dom.Element table) {
    final rows = table
        .querySelectorAll('tr')
        .where(
          (row) => row.children.any(
            (cell) => cell.localName == 'td' || cell.localName == 'th',
          ),
        )
        .toList(growable: false);
    if (rows.isEmpty) return null;
    final headingRow = rows.firstWhere(
      (row) => row.children.any((cell) => cell.localName == 'th'),
      orElse: () => rows.first,
    );
    final headings = headingRow.children
        .where((cell) => cell.localName == 'td' || cell.localName == 'th')
        .toList(growable: false);
    final bodyRows = rows.where((row) => row != headingRow);
    return _decorateBlock(
      table,
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 40,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 96,
          columnSpacing: 18,
          horizontalMargin: 8,
          columns: [
            for (final cell in headings)
              DataColumn(
                label: Text.rich(
                  TextSpan(
                    style: _bodyStyle.copyWith(
                      fontWeight: TospinoText.emphasis,
                    ),
                    children: _inlineSpans(
                      cell.nodes,
                      _bodyStyle.copyWith(fontWeight: TospinoText.emphasis),
                    ),
                  ),
                ),
              ),
          ],
          rows: [
            for (final row in bodyRows)
              DataRow(
                cells: [
                  for (final cell in row.children.where(
                    (cell) => cell.localName == 'td' || cell.localName == 'th',
                  ))
                    DataCell(
                      Text.rich(
                        TextSpan(
                          style: _bodyStyle,
                          children: _inlineSpans(cell.nodes, _bodyStyle),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
      defaultBottom: 10,
    );
  }

  Widget _decorateBlock(
    dom.Element element,
    Widget child, {
    double defaultTop = 0,
    double defaultBottom = 0,
  }) {
    final declarations = _declarations(element);
    final padding = _boxEdges(declarations, 'padding');
    final margin = _boxEdges(declarations, 'margin');
    final background =
        _cssColor(declarations['background-color']) ??
        _cssColor(declarations['background']);
    final radius = _length(declarations['border-radius'], fallback: 0);
    final hasInnerSurface =
        background != null ||
        padding.left > 0 ||
        padding.top > 0 ||
        padding.right > 0 ||
        padding.bottom > 0;
    final content = hasInnerSurface
        ? Container(
            padding: EdgeInsets.fromLTRB(
              padding.left,
              padding.top,
              padding.right,
              padding.bottom,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(
                (radius ?? 0).clamp(0, 24).toDouble(),
              ),
            ),
            child: child,
          )
        : child;
    return Padding(
      padding: EdgeInsets.only(
        left: margin.left.clamp(0, 24),
        top: margin.top.isFinite
            ? math.max(defaultTop, margin.top)
            : defaultTop,
        right: margin.right.clamp(0, 24),
        bottom: margin.bottom.isFinite
            ? math.max(defaultBottom, margin.bottom)
            : defaultBottom,
      ),
      child: content,
    );
  }

  TextStyle _styledElement(dom.Element element, TextStyle inherited) {
    var style = inherited;
    final tag = element.localName;
    if (tag == 'strong' || tag == 'b') {
      style = style.copyWith(fontWeight: TospinoText.strong);
    } else if (tag == 'em' || tag == 'i') {
      style = style.copyWith(fontStyle: FontStyle.italic);
    } else if (tag == 'u') {
      style = style.copyWith(decoration: TextDecoration.underline);
    } else if (tag == 's' || tag == 'strike' || tag == 'del') {
      style = style.copyWith(decoration: TextDecoration.lineThrough);
    } else if (tag == 'code' || tag == 'kbd') {
      style = style.copyWith(fontFamily: 'monospace');
    } else if (tag == 'small') {
      style = style.copyWith(fontSize: (style.fontSize ?? 13.5) * 0.84);
    } else if (tag == 'a') {
      style = style.copyWith(
        color: TospinoColors.solidBrand(context),
        decoration: TextDecoration.underline,
      );
    }

    final declarations = _declarations(element);
    final weight = _fontWeight(declarations['font-weight']);
    if (weight != null) style = style.copyWith(fontWeight: weight);
    final fontStyle = declarations['font-style']?.toLowerCase();
    if (fontStyle == 'italic' || fontStyle == 'oblique') {
      style = style.copyWith(fontStyle: FontStyle.italic);
    }
    final decoration = declarations['text-decoration']?.toLowerCase() ?? '';
    if (decoration.contains('underline')) {
      style = style.copyWith(decoration: TextDecoration.underline);
    } else if (decoration.contains('line-through')) {
      style = style.copyWith(decoration: TextDecoration.lineThrough);
    } else if (decoration.contains('none')) {
      style = style.copyWith(decoration: TextDecoration.none);
    }
    final fontSize = _fontSize(
      declarations['font-size'],
      style.fontSize ?? 13.5,
    );
    if (fontSize != null) style = style.copyWith(fontSize: fontSize);
    final color =
        _cssColor(declarations['color']) ??
        _cssColor(element.attributes['color']);
    if (color != null) style = style.copyWith(color: color);
    final background = _cssColor(declarations['background-color']);
    if (background != null) style = style.copyWith(backgroundColor: background);
    final letterSpacing = _fontSize(
      declarations['letter-spacing'],
      style.fontSize ?? 13.5,
    );
    if (letterSpacing != null) {
      style = style.copyWith(letterSpacing: letterSpacing.clamp(-2, 5));
    }
    final lineHeight = _lineHeight(
      declarations['line-height'],
      style.fontSize ?? 13.5,
    );
    if (lineHeight != null) style = style.copyWith(height: lineHeight);
    final family = declarations['font-family']?.toLowerCase() ?? '';
    if (family.contains('monospace') || family.contains('courier')) {
      style = style.copyWith(fontFamily: 'monospace');
    }
    return style;
  }

  List<InlineSpan> _inlineSpans(List<dom.Node> nodes, TextStyle style) {
    final spans = <InlineSpan>[];
    var lastWasBreak = false;
    for (final node in nodes) {
      if (node is dom.Text) {
        final text = _cleanText(node.text);
        if (text.trim().isEmpty) {
          if (spans.isNotEmpty && !lastWasBreak) {
            spans.add(TextSpan(text: ' ', style: style));
            lastWasBreak = false;
          }
          continue;
        }
        spans.add(TextSpan(text: text, style: style));
        lastWasBreak = false;
        continue;
      }
      if (node is! dom.Element) continue;
      final tag = node.localName;
      if (tag == 'script' || tag == 'style' || tag == 'img') continue;
      final declarations = _declarations(node);
      if (declarations['display']?.toLowerCase() == 'none') continue;
      if (tag == 'br') {
        if (spans.isNotEmpty && !lastWasBreak) {
          spans.add(TextSpan(text: '\n', style: style));
          lastWasBreak = true;
        }
        continue;
      }
      final childStyle = _styledElement(node, style);
      final children = _inlineSpans(node.nodes, childStyle);
      if (children.isNotEmpty) {
        spans.addAll(children);
        lastWasBreak = false;
      }
    }
    while (spans.isNotEmpty) {
      final last = spans.last;
      if (last is TextSpan && last.text?.trim().isEmpty == true) {
        spans.removeLast();
      } else {
        break;
      }
    }
    return spans;
  }

  bool _spansHaveContent(List<InlineSpan> spans) {
    for (final span in spans) {
      if (span is! TextSpan) continue;
      if (span.text?.trim().isNotEmpty == true) return true;
      if (span.children != null && _spansHaveContent(span.children!)) {
        return true;
      }
    }
    return false;
  }

  Map<String, String> _declarations(dom.Element element) =>
      styles.declarationsFor(element);

  TextAlign? _alignment(Map<String, String> declarations) {
    return switch (declarations['text-align']?.toLowerCase()) {
      'left' || 'start' => TextAlign.left,
      'center' => TextAlign.center,
      'right' || 'end' => TextAlign.right,
      'justify' => TextAlign.justify,
      _ => null,
    };
  }

  FontWeight? _fontWeight(String? source) {
    final value = source?.trim().toLowerCase() ?? '';
    if (value.isEmpty) return null;
    if (value == 'bold' || value == 'bolder') return TospinoText.strong;
    if (value == 'normal' || value == 'lighter') return FontWeight.w400;
    final number = int.tryParse(value);
    if (number == null) return null;
    return switch (number) {
      <= 300 => FontWeight.w300,
      <= 400 => FontWeight.w400,
      <= 500 => FontWeight.w500,
      <= 600 => FontWeight.w600,
      _ => FontWeight.w700,
    };
  }

  double? _fontSize(String? source, double relativeTo) {
    final value = source?.trim().toLowerCase() ?? '';
    if (value.isEmpty) return null;
    if (value.endsWith('%')) {
      final percent = double.tryParse(
        value.substring(0, value.length - 1).trim(),
      );
      return percent == null ? null : (relativeTo * percent / 100).clamp(8, 40);
    }
    if (value.endsWith('em')) {
      final factor = double.tryParse(value.substring(0, value.length - 2));
      return factor == null ? null : (relativeTo * factor).clamp(8, 40);
    }
    if (value.endsWith('rem')) {
      final factor = double.tryParse(value.substring(0, value.length - 3));
      return factor == null ? null : (13.5 * factor).clamp(8, 40);
    }
    if (value.endsWith('pt')) {
      final points = double.tryParse(value.substring(0, value.length - 2));
      return points == null ? null : (points * 1.333).clamp(8, 40);
    }
    final numeric = double.tryParse(
      value.replaceFirst(RegExp(r'(px|pc|in|cm|mm)$'), ''),
    );
    return numeric?.clamp(8, 40);
  }

  double? _lineHeight(String? source, double fontSize) {
    final value = source?.trim().toLowerCase() ?? '';
    if (value.isEmpty || value == 'normal') return null;
    final numeric = double.tryParse(value);
    if (numeric != null) return numeric.clamp(1, 2.4);
    final length = _length(value);
    return length == null
        ? null
        : (length / math.max(fontSize, 1)).clamp(1, 2.4);
  }

  Color? _cssColor(String? source) {
    final value = source?.trim().toLowerCase() ?? '';
    if (value.isEmpty ||
        value == 'transparent' ||
        value == 'inherit' ||
        value == 'initial') {
      return null;
    }
    const named = <String, Color>{
      'black': Colors.black,
      'white': Colors.white,
      'red': Color(0xFFFF0000),
      'green': Color(0xFF008000),
      'blue': Color(0xFF0000FF),
      'orange': Color(0xFFFFA500),
      'yellow': Color(0xFFFFFF00),
      'purple': Color(0xFF800080),
      'gray': Color(0xFF808080),
      'grey': Color(0xFF808080),
    };
    if (named[value] != null) return named[value];
    final rgb = RegExp(
      r'rgba?\(\s*([0-9.]+)\s*,\s*([0-9.]+)\s*,\s*([0-9.]+)(?:\s*,\s*([0-9.]+))?\s*\)',
    ).firstMatch(value);
    if (rgb != null) {
      final red = int.tryParse(rgb.group(1) ?? '');
      final green = int.tryParse(rgb.group(2) ?? '');
      final blue = int.tryParse(rgb.group(3) ?? '');
      if (red == null || green == null || blue == null) return null;
      final alpha = (double.tryParse(rgb.group(4) ?? '1') ?? 1)
          .clamp(0, 1)
          .toDouble();
      return Color.fromRGBO(
        red.clamp(0, 255).toInt(),
        green.clamp(0, 255).toInt(),
        blue.clamp(0, 255).toInt(),
        alpha,
      );
    }
    final hex = value.replaceFirst('#', '');
    if (!RegExp(r'^[0-9a-f]+$').hasMatch(hex)) return null;
    try {
      if (hex.length == 3 || hex.length == 4) {
        final expanded = hex.split('').map((part) => '$part$part').join();
        return _colorFromHex(expanded);
      }
      if (hex.length == 6 || hex.length == 8) return _colorFromHex(hex);
    } on FormatException {
      return null;
    }
    return null;
  }

  Color? _colorFromHex(String value) {
    final normalized = value.length == 6
        ? 'FF$value'
        : '${value.substring(6, 8)}${value.substring(0, 6)}';
    return Color(int.parse(normalized, radix: 16));
  }

  _BoxEdges _boxEdges(Map<String, String> declarations, String prefix) {
    final values = <double?>[null, null, null, null];
    final shorthand = declarations[prefix];
    if (shorthand != null) {
      final parts = shorthand.trim().split(RegExp(r'\s+'));
      final parsed = parts.map(_length).toList(growable: false);
      if (parsed.length == 1) {
        values.fillRange(0, 4, parsed[0]);
      } else if (parsed.length == 2) {
        values[0] = parsed[0];
        values[1] = parsed[1];
        values[2] = parsed[0];
        values[3] = parsed[1];
      } else if (parsed.length == 3) {
        values[0] = parsed[0];
        values[1] = parsed[1];
        values[2] = parsed[0];
        values[3] = parsed[2];
      } else {
        for (var index = 0; index < math.min(parsed.length, 4); index++) {
          values[index] = parsed[index];
        }
      }
    }
    const sides = ['top', 'right', 'bottom', 'left'];
    for (var index = 0; index < sides.length; index++) {
      values[index] =
          _length(declarations['$prefix-${sides[index]}']) ?? values[index];
    }
    return _BoxEdges(
      top: (values[0] ?? 0).clamp(0, 32),
      right: (values[1] ?? 0).clamp(0, 32),
      bottom: (values[2] ?? 0).clamp(0, 32),
      left: (values[3] ?? 0).clamp(0, 32),
    );
  }

  double? _percentage(String source) {
    final value = source.trim();
    if (!value.endsWith('%')) return null;
    final percent = double.tryParse(value.substring(0, value.length - 1));
    return percent == null ? null : (percent / 100).clamp(0, 1);
  }

  double? _length(String? source, {double? fallback}) {
    final value = source?.trim().toLowerCase() ?? '';
    if (value.isEmpty || value == 'auto' || value == 'normal') return fallback;
    if (value.endsWith('%')) return fallback;
    if (value.endsWith('rem')) {
      final factor = double.tryParse(value.substring(0, value.length - 3));
      return factor == null ? fallback : factor * 13.5;
    }
    if (value.endsWith('em')) {
      final factor = double.tryParse(value.substring(0, value.length - 2));
      return factor == null ? fallback : factor * 13.5;
    }
    if (value.endsWith('pt')) {
      final points = double.tryParse(value.substring(0, value.length - 2));
      return points == null ? fallback : points * 1.333;
    }
    final numeric = double.tryParse(
      value.replaceFirst(RegExp(r'(px|pc|in|cm|mm)$'), ''),
    );
    return numeric ?? fallback;
  }

  String _firstAttribute(dom.Element element, List<String> names) {
    for (final name in names) {
      final value = element.attributes[name]?.trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  String _normalizeHtmlUrl(String value) {
    if (value.startsWith('//')) return 'https:$value';
    if (value.startsWith('/')) return '${TospinoConfig.apiBaseUrl}$value';
    return value;
  }

  String _cleanText(String value) {
    return value
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '')
        .replaceAll(
          RegExp(r'[\u00A0\u1680\u2000-\u200A\u202F\u205F\u3000]'),
          ' ',
        )
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}

class _BoxEdges {
  const _BoxEdges({
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
  });

  final double top;
  final double right;
  final double bottom;
  final double left;
}
