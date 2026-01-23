import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pocketbase_service.dart';

part 'providers.g.dart';

@riverpod
PocketBaseService pocketBaseService(Ref ref) {
  return PocketBaseService();
}
