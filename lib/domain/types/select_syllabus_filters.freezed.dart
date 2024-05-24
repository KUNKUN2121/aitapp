// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'select_syllabus_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SelectSyllabusFilters {
// 年度
  String get year => throw _privateConstructorUsedError; // 学部フォルダ
  String? get folder => throw _privateConstructorUsedError; // キャンパス
  Campus? get campus => throw _privateConstructorUsedError; // 時限
  int? get hour => throw _privateConstructorUsedError; // 曜日
  DayOfWeek? get week => throw _privateConstructorUsedError; // 開講学期
  Semester? get semester => throw _privateConstructorUsedError; // 検索ワード
  String get word => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SelectSyllabusFiltersCopyWith<SelectSyllabusFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SelectSyllabusFiltersCopyWith<$Res> {
  factory $SelectSyllabusFiltersCopyWith(SelectSyllabusFilters value,
          $Res Function(SelectSyllabusFilters) then) =
      _$SelectSyllabusFiltersCopyWithImpl<$Res, SelectSyllabusFilters>;
  @useResult
  $Res call(
      {String year,
      String? folder,
      Campus? campus,
      int? hour,
      DayOfWeek? week,
      Semester? semester,
      String word});
}

/// @nodoc
class _$SelectSyllabusFiltersCopyWithImpl<$Res,
        $Val extends SelectSyllabusFilters>
    implements $SelectSyllabusFiltersCopyWith<$Res> {
  _$SelectSyllabusFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? folder = freezed,
    Object? campus = freezed,
    Object? hour = freezed,
    Object? week = freezed,
    Object? semester = freezed,
    Object? word = null,
  }) {
    return _then(_value.copyWith(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as String,
      folder: freezed == folder
          ? _value.folder
          : folder // ignore: cast_nullable_to_non_nullable
              as String?,
      campus: freezed == campus
          ? _value.campus
          : campus // ignore: cast_nullable_to_non_nullable
              as Campus?,
      hour: freezed == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int?,
      week: freezed == week
          ? _value.week
          : week // ignore: cast_nullable_to_non_nullable
              as DayOfWeek?,
      semester: freezed == semester
          ? _value.semester
          : semester // ignore: cast_nullable_to_non_nullable
              as Semester?,
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SelectSyllabusFiltersImplCopyWith<$Res>
    implements $SelectSyllabusFiltersCopyWith<$Res> {
  factory _$$SelectSyllabusFiltersImplCopyWith(
          _$SelectSyllabusFiltersImpl value,
          $Res Function(_$SelectSyllabusFiltersImpl) then) =
      __$$SelectSyllabusFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String year,
      String? folder,
      Campus? campus,
      int? hour,
      DayOfWeek? week,
      Semester? semester,
      String word});
}

/// @nodoc
class __$$SelectSyllabusFiltersImplCopyWithImpl<$Res>
    extends _$SelectSyllabusFiltersCopyWithImpl<$Res,
        _$SelectSyllabusFiltersImpl>
    implements _$$SelectSyllabusFiltersImplCopyWith<$Res> {
  __$$SelectSyllabusFiltersImplCopyWithImpl(_$SelectSyllabusFiltersImpl _value,
      $Res Function(_$SelectSyllabusFiltersImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? folder = freezed,
    Object? campus = freezed,
    Object? hour = freezed,
    Object? week = freezed,
    Object? semester = freezed,
    Object? word = null,
  }) {
    return _then(_$SelectSyllabusFiltersImpl(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as String,
      folder: freezed == folder
          ? _value.folder
          : folder // ignore: cast_nullable_to_non_nullable
              as String?,
      campus: freezed == campus
          ? _value.campus
          : campus // ignore: cast_nullable_to_non_nullable
              as Campus?,
      hour: freezed == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int?,
      week: freezed == week
          ? _value.week
          : week // ignore: cast_nullable_to_non_nullable
              as DayOfWeek?,
      semester: freezed == semester
          ? _value.semester
          : semester // ignore: cast_nullable_to_non_nullable
              as Semester?,
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SelectSyllabusFiltersImpl extends _SelectSyllabusFilters {
  const _$SelectSyllabusFiltersImpl(
      {required this.year,
      this.folder,
      this.campus,
      this.hour,
      this.week,
      this.semester,
      this.word = ''})
      : super._();

// 年度
  @override
  final String year;
// 学部フォルダ
  @override
  final String? folder;
// キャンパス
  @override
  final Campus? campus;
// 時限
  @override
  final int? hour;
// 曜日
  @override
  final DayOfWeek? week;
// 開講学期
  @override
  final Semester? semester;
// 検索ワード
  @override
  @JsonKey()
  final String word;

  @override
  String toString() {
    return 'SelectSyllabusFilters(year: $year, folder: $folder, campus: $campus, hour: $hour, week: $week, semester: $semester, word: $word)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SelectSyllabusFiltersImpl &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.folder, folder) || other.folder == folder) &&
            (identical(other.campus, campus) || other.campus == campus) &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.week, week) || other.week == week) &&
            (identical(other.semester, semester) ||
                other.semester == semester) &&
            (identical(other.word, word) || other.word == word));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, year, folder, campus, hour, week, semester, word);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SelectSyllabusFiltersImplCopyWith<_$SelectSyllabusFiltersImpl>
      get copyWith => __$$SelectSyllabusFiltersImplCopyWithImpl<
          _$SelectSyllabusFiltersImpl>(this, _$identity);
}

abstract class _SelectSyllabusFilters extends SelectSyllabusFilters {
  const factory _SelectSyllabusFilters(
      {required final String year,
      final String? folder,
      final Campus? campus,
      final int? hour,
      final DayOfWeek? week,
      final Semester? semester,
      final String word}) = _$SelectSyllabusFiltersImpl;
  const _SelectSyllabusFilters._() : super._();

  @override // 年度
  String get year;
  @override // 学部フォルダ
  String? get folder;
  @override // キャンパス
  Campus? get campus;
  @override // 時限
  int? get hour;
  @override // 曜日
  DayOfWeek? get week;
  @override // 開講学期
  Semester? get semester;
  @override // 検索ワード
  String get word;
  @override
  @JsonKey(ignore: true)
  _$$SelectSyllabusFiltersImplCopyWith<_$SelectSyllabusFiltersImpl>
      get copyWith => throw _privateConstructorUsedError;
}
