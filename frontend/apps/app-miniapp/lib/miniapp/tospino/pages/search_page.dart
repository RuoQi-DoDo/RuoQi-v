import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoSearchPage extends StatefulWidget {
  const TospinoSearchPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  State<TospinoSearchPage> createState() => _TospinoSearchPageState();
}

class _TospinoSearchPageState extends State<TospinoSearchPage> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.controller.searchQuery,
    );
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    widget.controller.search(_textController.text);
    setState(() {});
  }

  @override
  void dispose() {
    _textController
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _textController.text.trim();
    final results = widget.controller.searchResults;
    return ColoredBox(
      key: const Key('tospino-search-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: TextField(
              key: const Key('tospino-search-field'),
              controller: _textController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: widget.controller.search,
              decoration: InputDecoration(
                filled: true,
                fillColor: TospinoColors.resolve(
                  context,
                  TospinoColors.surfaceMuted,
                ),
                hintText: localizeMiniProgramLabel(context, '搜索商品、品牌或关键词'),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        key: const Key('tospino-search-clear'),
                        tooltip: localizeMiniProgramLabel(context, '清空'),
                        onPressed: _textController.clear,
                        icon: const Icon(Icons.close_rounded, size: 19),
                      ),
              ),
            ),
          ),
          Expanded(
            child: query.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 54,
                            color: TospinoColors.resolve(
                              context,
                              TospinoColors.brandPale,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            localizeMiniProgramLabel(context, '搜索商品、品牌或关键词'),
                            textAlign: TextAlign.center,
                            style: TospinoText.secondary(context),
                          ),
                        ],
                      ),
                    ),
                  )
                : widget.controller.loadingSearch
                ? const Center(child: CircularProgressIndicator())
                : widget.controller.searchError != null
                ? _SearchState(
                    message: widget.controller.searchError!,
                    onRetry: () => widget.controller.search(query),
                  )
                : results.isEmpty
                ? _SearchState(
                    key: const Key('tospino-search-empty'),
                    message: localizeMiniProgramLabel(context, '暂无匹配商品'),
                  )
                : _SearchResults(controller: widget.controller),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final results = controller.searchResults;
    return CustomScrollView(
      key: const Key('tospino-search-results'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Text(
              '${results.length} ${localizeMiniProgramLabel(context, '件商品')}',
              style: TospinoText.meta(context),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = results[index];
              return TospinoProductTile(
                product: product,
                artworkHeight: 138,
                onTap: () => controller.openProduct(product),
              );
            }, childCount: results.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 9,
              crossAxisSpacing: 9,
              childAspectRatio: 0.63,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchState extends StatelessWidget {
  const _SearchState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              color: TospinoColors.solidBrand(context),
              size: 46,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRetry,
                child: Text(localizeMiniProgramLabel(context, '重试')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
