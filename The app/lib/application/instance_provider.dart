import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../routes/app_router.dart';

part 'instance_provider.g.dart';

@riverpod
class RouterInstance extends _$RouterInstance {
  @override
  AppRouter build() {
    return AppRouter(ref);
  }
}
