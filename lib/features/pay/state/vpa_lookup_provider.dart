import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/vpa.dart';
import '../data/vpa_repository.dart';

final vpaRepositoryProvider = Provider<VpaRepository>((ref) {
  return FakeVpaRepository();
});

final vpaLookupProvider = FutureProvider.family<Vpa, String>((ref, address) async {
  if (address.trim().isEmpty) {
    throw ArgumentError('Address cannot be empty');
  }
  final repo = ref.read(vpaRepositoryProvider);
  return await repo.verify(address);
});
