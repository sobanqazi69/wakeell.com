import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../data/models/lawyer_model.dart';
import '../../data/repositories/lawyer_repository.dart';
import 'lawyer_list_state.dart';

class LawyerListCubit extends Cubit<LawyerListState> {
  static const _tag = 'LawyerListCubit';
  final LawyerRepository _repo;

  String _search = '';
  String _category = 'All';
  String _sort = 'all';
  String _nearMeCity = '';
  double _minRating = 0;
  double _maxFee = 0;
  List<LawyerModel> _fullResults = [];
  Timer? _debounce;

  LawyerListCubit(this._repo) : super(const LawyerListInitial());

  Future<void> load() async => _fetch();

  void onSearchChanged(String query) {
    _search = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _fetch);
  }

  void onCategoryChanged(String category) {
    _category = category;
    _fetch();
  }

  void onSortChanged(String sort) {
    final wasNearMe = _sort == 'near_me';
    _sort = sort;
    if (sort != 'near_me') _nearMeCity = '';
    if (wasNearMe) {
      _fetch(); // re-fetch without location filter
    } else {
      _applySort();
    }
  }

  void onNearMeFilter(String city) {
    _nearMeCity = city;
    _sort = 'near_me';
    _fetch(); // re-fetch with location filter sent to backend
  }

  void applyFilters({required double minRating, required double maxFee}) {
    _minRating = minRating;
    _maxFee = maxFee;
    _applySort();
  }

  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    try {
      if (isClosed) return;
      emit(const LawyerListLoading());

      _fullResults = await _repo.getLawyers(
        search:   _search.isEmpty ? null : _search,
        category: _category,
        location: _sort == 'near_me' && _nearMeCity.isNotEmpty ? _nearMeCity : null,
      );

      _applySort();
    } on LawyerException catch (e) {
      DebugLogger.error(_tag, e.message);
      if (!isClosed) emit(LawyerListError(e.message));
    } catch (e) {
      DebugLogger.error(_tag, 'unexpected: $e');
      if (!isClosed) emit(const LawyerListError('Failed to load lawyers'));
    }
  }

  void _applySort() {
    var result = List<LawyerModel>.from(_fullResults);

    switch (_sort) {
      case 'top_rated':
        result.sort((a, b) => b.rating.compareTo(a.rating));
      case 'low_fee':
        result.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
    }

    if (_minRating > 0) {
      result = result.where((l) => l.rating >= _minRating).toList();
    }
    if (_maxFee > 0) {
      result = result.where((l) => l.hourlyRate <= _maxFee).toList();
    }

    if (!isClosed) {
      emit(LawyerListLoaded(
        lawyers: result,
        search: _search,
        category: _category,
        sort: _sort,
        minRating: _minRating,
        maxFee: _maxFee,
      ));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
