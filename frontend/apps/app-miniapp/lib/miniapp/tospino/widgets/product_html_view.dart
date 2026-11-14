import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import '../api/tospino_api.dart';
import '../tospino_style.dart';

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
    final renderer = _ProductHtmlRenderer(context);
    return Column(
      key: const Key('tospino-product-html'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: renderer.buildBlocks(fragment.nodes),
    );
  }
}

class _ProductHtmlRenderer {
  _ProductHtmlRenderer(this.context);

  final BuildContext context;

  TextStyle get _bodyStyle =>
      TospinoText.body(context).copyWith(fontSize: 13.5, height: 1.65);

  List<Widget> buildBlocks(List<dom.Node> nodes) {
    final widgets = <Widget>[];
    var inlineBuffer = <dom.Node>[];

    void flushInline() {
      if (inlineBuffer.isEmpty) return;
      final spans = _inlineSpans(inlineBuffer, _bodyStyle);
      if (spans.any(
        (span) =>
            span is TextSpan &&
            (span.text?.isNotEmpty == true ||
                (span.children?.isNotEmpty ?? false)),
      )) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text.rich(
              TextSpan(style: _bodyStyle, children: spans),
              textAlign: TextAlign.left,
            ),
          ),
        );
      }
      inlineBuffer = <dom.Node>[];
    }

    for (final node in nodes) {
      if (_isBlock(node)) {
        flushInline();
        final widget = _buildBlock(node);
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
    return const {
      'html',
      'body',
      'div',
      'section',
      'article',
      'header',
      'footer',
      'p',
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
      'br',
      'img',
      'figure',
      'script',
      'style',
    }.contains(node.localName);
  }

  Widget? _buildBlock(dom.Node node) {
    if (node is dom.Text) {
      final text = _cleanText(node.text);
      if (text.trim().isEmpty) return null;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: _bodyStyle),
      );
    }
    if (node is! dom.Element) return null;
    final tag = node.localName;
    switch (tag) {
      case 'script':
      case 'style':
        return null;
      case 'br':
        return const SizedBox(height: 6);
      case 'hr':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(
            height: 1,
            color: TospinoColors.resolve(context, TospinoColors.line),
          ),
        );
      case 'img':
        return _buildImage(node);
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
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 9),
          child: Text.rich(
            TextSpan(
              style: _bodyStyle.copyWith(
                fontSize: size,
                fontWeight: TospinoText.strong,
                height: 1.3,
              ),
              children: _inlineSpans(node.nodes, _bodyStyle),
            ),
          ),
        );
      case 'ul':
      case 'ol':
        return _buildList(node, ordered: tag == 'ol');
      case 'blockquote':
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: buildBlocks(node.nodes),
          ),
        );
      case 'table':
        return _buildTable(node);
      case 'p':
      case 'div':
      case 'section':
      case 'article':
      case 'header':
      case 'footer':
      case 'figure':
        final children = buildBlocks(node.nodes);
        if (children.isEmpty) return null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      default:
        final hasBlock = node.nodes.any(_isBlock);
        if (hasBlock) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: buildBlocks(node.nodes),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text.rich(
            TextSpan(
              style: _bodyStyle,
              children: _inlineSpans(node.nodes, _bodyStyle),
            ),
          ),
        );
    }
  }

  Widget _buildList(dom.Element element, {required bool ordered}) {
    final items = element.children
        .where((child) => child.localName == 'li')
        .toList(growable: false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
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
                      style: _bodyStyle.copyWith(
                        color: TospinoColors.solidBrand(context),
                        fontWeight: TospinoText.emphasis,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: _bodyStyle,
                        children: _inlineSpans(items[index].nodes, _bodyStyle),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(dom.Element element) {
    final source = _firstAttribute(element, const [
      'src',
      'data-src',
      'data-original',
      'data-lazy-src',
    ]);
    if (source.isEmpty) return const SizedBox.shrink();
    final url = _normalizeHtmlUrl(source);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ColoredBox(
          color: TospinoColors.resolve(context, TospinoColors.imagePlaceholder),
          child: Image.network(
            url,
            width: double.infinity,
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
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 40,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 72,
          columnSpacing: 18,
          horizontalMargin: 8,
          columns: [
            for (final cell in rows.first.children.where(
              (cell) => cell.localName == 'td' || cell.localName == 'th',
            ))
              DataColumn(
                label: Text(
                  _cleanText(cell.text).trim(),
                  style: _bodyStyle.copyWith(fontWeight: TospinoText.emphasis),
                ),
              ),
          ],
          rows: [
            for (final row in rows.skip(1))
              DataRow(
                cells: [
                  for (final cell in row.children.where(
                    (cell) => cell.localName == 'td' || cell.localName == 'th',
                  ))
                    DataCell(
                      Text(_cleanText(cell.text).trim(), style: _bodyStyle),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<InlineSpan> _inlineSpans(
    List<dom.Node> nodes,
    TextStyle baseStyle, {
    bool bold = false,
    bool italic = false,
    bool underline = false,
    Color? color,
  }) {
    final spans = <InlineSpan>[];
    for (final node in nodes) {
      if (node is dom.Text) {
        final text = _cleanText(node.text);
        if (text.isEmpty) continue;
        spans.add(
          TextSpan(
            text: text,
            style: baseStyle.copyWith(
              fontWeight: bold ? TospinoText.strong : baseStyle.fontWeight,
              fontStyle: italic ? FontStyle.italic : baseStyle.fontStyle,
              decoration: underline
                  ? TextDecoration.underline
                  : baseStyle.decoration,
              color: color ?? baseStyle.color,
            ),
          ),
        );
        continue;
      }
      if (node is! dom.Element) continue;
      final tag = node.localName;
      switch (tag) {
        case 'br':
          spans.add(const TextSpan(text: '\n'));
        case 'strong':
        case 'b':
          spans.addAll(
            _inlineSpans(
              node.nodes,
              baseStyle,
              bold: true,
              italic: italic,
              underline: underline,
              color: color,
            ),
          );
        case 'em':
        case 'i':
          spans.addAll(
            _inlineSpans(
              node.nodes,
              baseStyle,
              bold: bold,
              italic: true,
              underline: underline,
              color: color,
            ),
          );
        case 'u':
          spans.addAll(
            _inlineSpans(
              node.nodes,
              baseStyle,
              bold: bold,
              italic: italic,
              underline: true,
              color: color,
            ),
          );
        case 'a':
          spans.addAll(
            _inlineSpans(
              node.nodes,
              baseStyle,
              bold: bold,
              italic: italic,
              underline: true,
              color: TospinoColors.solidBrand(context),
            ),
          );
        case 'img':
          break;
        default:
          spans.addAll(
            _inlineSpans(
              node.nodes,
              baseStyle,
              bold: bold,
              italic: italic,
              underline: underline,
              color: color,
            ),
          );
      }
    }
    return spans;
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

  String _cleanText(String value) =>
      value.replaceAll(RegExp(r'[\t\r\n ]+'), ' ');
}
