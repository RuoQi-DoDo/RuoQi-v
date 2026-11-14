import 'package:flutter/material.dart';

import '../../localization.dart';
import 'phone_country.dart';

class PhoneCountryPickerPage extends StatefulWidget {
  const PhoneCountryPickerPage({super.key, required this.selectedCountry});

  final PhoneCountry selectedCountry;

  static Route<PhoneCountry> route(PhoneCountry selectedCountry) {
    return MaterialPageRoute<PhoneCountry>(
      builder: (_) => PhoneCountryPickerPage(selectedCountry: selectedCountry),
    );
  }

  @override
  State<PhoneCountryPickerPage> createState() => _PhoneCountryPickerPageState();
}

class _PhoneCountryPickerPageState extends State<PhoneCountryPickerPage> {
  static const _accent = Color(0xFF1DAA61);

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final english = l10n.locale.languageCode == 'en';
    final query = _query.trim().toLowerCase();
    final countries = phoneCountries
        .where((country) {
          if (query.isEmpty) {
            return true;
          }
          return country.nameZh.contains(query) ||
              country.nameEn.toLowerCase().contains(query) ||
              country.dialCode.contains(query);
        })
        .toList(growable: false);
    return Scaffold(
      key: const Key('phone-country-picker-page'),
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: const Color(0xFFF7F7F7),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leadingWidth: 58,
        leading: IconButton(
          key: const Key('phone-country-close'),
          tooltip: l10n.text('关闭', 'Close'),
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close_rounded),
        ),
        titleSpacing: 2,
        title: Text(
          l10n.text('选择国家/地区', 'Select a country'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE1E5E3)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: TextField(
              key: const Key('phone-country-search'),
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: l10n.text('搜索国家/地区', 'Search countries'),
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];
                final selected = country.code == widget.selectedCountry.code;
                return _CountryRow(
                  key: Key('phone-country-${country.code}'),
                  country: country,
                  english: english,
                  selected: selected,
                  onTap: () => Navigator.of(context).pop(country),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryRow extends StatelessWidget {
  const _CountryRow({
    super.key,
    required this.country,
    required this.english,
    required this.selected,
    required this.onTap,
  });

  final PhoneCountry country;
  final bool english;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = english ? country.nameEn : country.nameZh;
    final secondary = english ? country.nameZh : country.nameEn;
    return Material(
      color: selected
          ? _PhoneCountryPickerPageState._accent.withValues(alpha: 0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _flagEmoji(country.code),
                  style: const TextStyle(fontSize: 23),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onSurface,
                        fontSize: 17,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      secondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                country.dialCode,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 22,
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: _PhoneCountryPickerPageState._accent,
                        size: 21,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _flagEmoji(String countryCode) {
    return countryCode
        .toUpperCase()
        .codeUnits
        .map((unit) => String.fromCharCode(0x1F1E6 + unit - 65))
        .join();
  }
}
