// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'imoveis_envelope_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImoveisEnvelopeModel {

 String? get next; String? get previous; List<ImovelModel> get results;
/// Create a copy of ImoveisEnvelopeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImoveisEnvelopeModelCopyWith<ImoveisEnvelopeModel> get copyWith => _$ImoveisEnvelopeModelCopyWithImpl<ImoveisEnvelopeModel>(this as ImoveisEnvelopeModel, _$identity);

  /// Serializes this ImoveisEnvelopeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ImoveisEnvelopeModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImoveisEnvelopeModel&&(identical(other.next, _this.next) || other.next == _this.next)&&(identical(other.previous, _this.previous) || other.previous == _this.previous)&&const DeepCollectionEquality().equals(other.results, _this.results));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ImoveisEnvelopeModel;
  return Object.hash(runtimeType,_this.next,_this.previous,const DeepCollectionEquality().hash(_this.results));
}

@override
String toString() {
  final _this = this as ImoveisEnvelopeModel;
  return 'ImoveisEnvelopeModel(next: ${_this.next}, previous: ${_this.previous}, results: ${_this.results})';
}


}

/// @nodoc
abstract mixin class $ImoveisEnvelopeModelCopyWith<$Res>  {
  factory $ImoveisEnvelopeModelCopyWith(ImoveisEnvelopeModel value, $Res Function(ImoveisEnvelopeModel) _then) = _$ImoveisEnvelopeModelCopyWithImpl;
@useResult
$Res call({
 String? next, String? previous, List<ImovelModel> results
});




}
/// @nodoc
class _$ImoveisEnvelopeModelCopyWithImpl<$Res>
    implements $ImoveisEnvelopeModelCopyWith<$Res> {
  _$ImoveisEnvelopeModelCopyWithImpl(this._self, this._then);

  final ImoveisEnvelopeModel _self;
  final $Res Function(ImoveisEnvelopeModel) _then;

/// Create a copy of ImoveisEnvelopeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? next = freezed,Object? previous = freezed,Object? results = null,}) {
  return _then(ImoveisEnvelopeModel(
next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String?,previous: freezed == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as String?,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<ImovelModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [ImoveisEnvelopeModel].
extension ImoveisEnvelopeModelPatterns on ImoveisEnvelopeModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImoveisEnvelopeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImoveisEnvelopeModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImoveisEnvelopeModel value)  $default,){
final _that = this;
switch (_that) {
case _ImoveisEnvelopeModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImoveisEnvelopeModel value)?  $default,){
final _that = this;
switch (_that) {
case _ImoveisEnvelopeModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? next,  String? previous,  List<ImovelModel> results)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImoveisEnvelopeModel() when $default != null:
return $default(_that.next,_that.previous,_that.results);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? next,  String? previous,  List<ImovelModel> results)  $default,) {final _that = this;
switch (_that) {
case _ImoveisEnvelopeModel():
return $default(_that.next,_that.previous,_that.results);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? next,  String? previous,  List<ImovelModel> results)?  $default,) {final _that = this;
switch (_that) {
case _ImoveisEnvelopeModel() when $default != null:
return $default(_that.next,_that.previous,_that.results);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImoveisEnvelopeModel extends ImoveisEnvelopeModel {
  const _ImoveisEnvelopeModel({this.next, this.previous, required  List<ImovelModel> results}): _results = results,super._();
  factory _ImoveisEnvelopeModel.fromJson(Map<String, dynamic> json) => _$ImoveisEnvelopeModelFromJson(json);

@override final  String? next;
@override final  String? previous;
 final  List<ImovelModel> _results;
@override List<ImovelModel> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}


/// Create a copy of ImoveisEnvelopeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImoveisEnvelopeModelCopyWith<_ImoveisEnvelopeModel> get copyWith => __$ImoveisEnvelopeModelCopyWithImpl<_ImoveisEnvelopeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImoveisEnvelopeModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImoveisEnvelopeModel&&(identical(other.next, next) || other.next == next)&&(identical(other.previous, previous) || other.previous == previous)&&const DeepCollectionEquality().equals(other.results, _results));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,next,previous,const DeepCollectionEquality().hash(_results));
}

@override
String toString() {
    return 'ImoveisEnvelopeModel(next: $next, previous: $previous, results: $results)';
}


}

/// @nodoc
abstract mixin class _$ImoveisEnvelopeModelCopyWith<$Res> implements $ImoveisEnvelopeModelCopyWith<$Res> {
  factory _$ImoveisEnvelopeModelCopyWith(_ImoveisEnvelopeModel value, $Res Function(_ImoveisEnvelopeModel) _then) = __$ImoveisEnvelopeModelCopyWithImpl;
@override @useResult
$Res call({
 String? next, String? previous, List<ImovelModel> results
});




}
/// @nodoc
class __$ImoveisEnvelopeModelCopyWithImpl<$Res>
    implements _$ImoveisEnvelopeModelCopyWith<$Res> {
  __$ImoveisEnvelopeModelCopyWithImpl(this._self, this._then);

  final _ImoveisEnvelopeModel _self;
  final $Res Function(_ImoveisEnvelopeModel) _then;

/// Create a copy of ImoveisEnvelopeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? next = freezed,Object? previous = freezed,Object? results = null,}) {
  return _then(_ImoveisEnvelopeModel(
next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String?,previous: freezed == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as String?,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<ImovelModel>,
  ));
}


}

// dart format on
