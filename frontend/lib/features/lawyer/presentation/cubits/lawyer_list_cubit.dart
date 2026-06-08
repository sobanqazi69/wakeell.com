import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../data/repositories/lawyer_repository.dart';
import 'lawyer_list_state.dart';

class LawyerListCubit extends Cubit<LawyerListState> {
  static const _tag = 'LawyerListCubit';
  final LawyerRepository _repo;

  String _search = '';
  String _category = 'All';
  Timer? _debounce;

  LawyerListCubit(this._repo) : super(const LawyerListInitial());

  Future<void> load() async {
    await _fetch();
  }

  void onSearchChanged(String query) {
    _search = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _fetch);
  }

  void onCategoryChanged(String category) {
    _category = category;
    _fetch();
  }

  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    try {
      if (isClosed) return;
      emit(const LawyerListLoading());

      final lawyers = await _repo.getLawyers(
        search:   _search.isEmpty ? null : _search,
        category: _category,
      );

      if (!isClosed) {
        emit(LawyerListLoaded(lawyers: lawyers, search: _search, category: _category));
      }
    } on LawyerException catch (e) {
      DebugLogger.error(_tag, e.message);
      if (!isClosed) emit(LawyerListError(e.message));
    } catch (e) {
      DebugLogger.error(_tag, 'unexpected: $e');
      if (!isClosed) emit(const LawyerListError('Failed to load lawyers'));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
