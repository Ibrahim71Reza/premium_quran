import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/surah.dart';

final surahListProvider = FutureProvider<List<Surah>>((ref) async {
  final response = await rootBundle.loadString('assets/data/surahs.json');
  final List<dynamic> data = json.decode(response);
  return data.map((json) => Surah.fromJson(json)).toList();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final debouncedSearchQueryProvider = FutureProvider<String>((ref) async {
  final query = ref.watch(searchQueryProvider);

  await Future<void>.delayed(const Duration(milliseconds: 180));

  return query.trim().toLowerCase();
});

final filteredSurahListProvider = FutureProvider<List<Surah>>((ref) async {
  final allSurahs = await ref.watch(surahListProvider.future);
  final query = await ref.watch(debouncedSearchQueryProvider.future);

  if (query.isEmpty) return allSurahs;

  return allSurahs.where((surah) {
    return surah.nameEn.toLowerCase().contains(query) ||
        surah.nameBn.toLowerCase().contains(query) ||
        surah.nameAr.contains(query) ||
        surah.id.toString() == query;
  }).toList();
});