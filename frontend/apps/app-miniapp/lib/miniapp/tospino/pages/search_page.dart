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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: TospinoColors.solidBrand(
                    context,
                  ).withValues(alpha: 0.42),
                ),
                boxShadow: [
                  BoxShadow(
                    color: TospinoColors.solidBrand(
                      context,
                    ).withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
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
                    TospinoColors.surface,
                  ),
                  hintText: localizeMiniProgramLabel(context, '搜索商品、品牌或关键词'),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: TospinoColors.solidBrand(context),
                    size: 21,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
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
          ),
          Expanded(
            child: query.isEmpty
                ? _SearchLanding(
                    controller: widget.controller,
                    onQuery: (word) {
                      _textController
                        ..text = word
                        ..selection = TextSelection.collapsed(
                          offset: word.length,
                        );
                    },
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

class _SearchLanding extends StatelessWidget {
  const _SearchLanding({required this.controller, required this.onQuery});

  final TospinoAppController controller;
  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    final words = controller.homeRecommendWords
        .where((word) => word.trim().isNotEmpty)
        .take(10)
        .toList(growable: false);
    final products = controller.homeProducts.take(4).toList(growable: false);
    return ListView(
      key: const Key('tospino-search-landing'),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 26),
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: TospinoColors.resolve(context, TospinoColors.brandPale),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.travel_explore_rounded,
                color: TospinoColors.solidBrand(context),
                size: 23,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizeMiniProgramLabel(context, '发现你的下一件好物'),
                    style: TospinoText.section(context),
                  ),
                  Text(
                    localizeMiniProgramLabel(context, '搜索品牌、商品或分类'),
                    style: TospinoText.meta(context),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (words.isNotEmpty) ...[
          const SizedBox(height: 22),
          Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 17,
                color: TospinoColors.resolve(context, TospinoColors.saleStart),
              ),
              const SizedBox(width: 5),
              Text(
                localizeMiniProgramLabel(context, '热门搜索'),
                style: TospinoText.bodyStrong(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final word in words)
                ActionChip(
                  onPressed: () => onQuery(word),
                  avatar: Icon(
                    Icons.search_rounded,
                    size: 15,
                    color: TospinoColors.solidBrand(context),
                  ),
                  label: Text(
                    word,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TospinoText.meta(context).copyWith(
                      color: TospinoColors.resolve(context, TospinoColors.ink),
                    ),
                  ),
                  backgroundColor: TospinoColors.resolve(
                    context,
                    TospinoColors.surface,
                  ),
                  side: BorderSide(
                    color: TospinoColors.resolve(context, TospinoColors.line),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                ),
            ],
          ),
        ],
        if (products.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                localizeMiniProgramLabel(context, '大家都在看'),
                style: TospinoText.bodyStrong(context),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_rounded,
                size: 17,
                color: TospinoColors.solidBrand(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 9,
              crossAxisSpacing: 9,
              childAspectRatio: 0.66,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return TospinoProductTile(
                product: product,
                artworkHeight: 118,
                onTap: () => controller.openProduct(product),
              );
            },
          ),
        ],
      ],
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
