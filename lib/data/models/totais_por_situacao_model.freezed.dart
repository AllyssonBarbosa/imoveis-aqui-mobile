// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'totais_por_situacao_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TotaisPorSituacaoModel {

 Map<String, int> get totais; int get total;
/// Create a copy of TotaisPorSituacaoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TotaisPorSituacaoModelCopyWith<TotaisPorSituacaoModel> get copyWith => _$TotaisPorSituacaoModelCopyWithImpl<TotaisPorSituacaoModel>(this as TotaisPorSituacaoModel, _$identity);

  /// Serializes this TotaisPorSituacaoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TotaisPorSituacaoModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TotaisPorSituacaoModel&&const DeepCollectionEquality().equals(other.totais, _this.totais)&&(identical(other.total, _this.total) || other.total == _this.total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TotaisPorSituacaoModel;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.totais),_this.total);
}

@override
String toString() {
  final _this = this as TotaisPorSituacaoModel;
  return 'TotaisPorSituacaoModel(totais: ${_this.totais}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $TotaisPorSituacaoModelCopyWith<$Res>  {
  factory $TotaisPorSituacaoModelCopyWith(TotaisPorSituacaoModel value, $Res Function(TotaisPorSituacaoModel) _then) = _$TotaisPorSituacaoModelCopyWithImpl;
@useResult
$Res call({
 Map<String, int> totais, int total
});




}
/// @nodoc
class _$TotaisPorSituacaoModelCopyWithImpl<$Res>
    implements $TotaisPorSituacaoModelCopyWith<$Res> {
  _$TotaisPorSituacaoModelCopyWithImpl(this._self, this._then);

  final TotaisPorSituacaoModel _self;
  final $Res Function(TotaisPorSituacaoModel) _then;

/// Create a copy of TotaisPorSituacaoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totais = null,Object? total = null,}) {
  return _then(TotaisPorSituacaoModel(
totais: null == totais ? _self.totais : totais // ignore: cast_nullable_to_non_nullable
as Map<String, int>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TotaisPorSituacaoModel].
extension TotaisPorSituacaoModelPatterns on TotaisPorSituacaoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TotaisPorSituacaoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TotaisPorSituacaoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TotaisPorSituacaoModel value)  $default,){
final _that = this;
switch (_that) {
case _TotaisPorSituacaoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TotaisPorSituacaoModel value)?  $default,){
final _that = this;
switch (_that) {
case _TotaisPorSituacaoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, int> totais,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TotaisPorSituacaoModel() when $default != null:
return $default(_that.totais,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, int> totais,  int total)  $default,) {final _that = this;
switch (_that) {
case _TotaisPorSituacaoModel():
return $default(_that.totais,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, int> totais,  int total)?  $default,) {final _that = this;
switch (_that) {
case _TotaisPorSituacaoModel() when $default != null:
return $default(_that.totais,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TotaisPorSituacaoModel extends TotaisPorSituacaoModel {
  const _TotaisPorSituacaoModel({required  Map<String, int> totais, required this.total}): _totais = totais,super._();
  factory _TotaisPorSituacaoModel.fromJson(Map<String, dynamic> json) => _$TotaisPorSituacaoModelFromJson(json);

 final  Map<String, int> _totais;
@override Map<String, int> get totais {
  if (_totais is EqualUnmodifiableMapView) return _totais;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_totais);
}

@override final  int total;

/// Create a copy of TotaisPorSituacaoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TotaisPorSituacaoModelCopyWith<_TotaisPorSituacaoModel> get copyWith => __$TotaisPorSituacaoModelCopyWithImpl<_TotaisPorSituacaoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TotaisPorSituacaoModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TotaisPorSituacaoModel&&const DeepCollectionEquality().equals(other.totais, _totais)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_totais),total);
}

@override
String toString() {
    return 'TotaisPorSituacaoModel(totais: $totais, total: $total)';
}


}

/// @nodoc
abstract mixin class _$TotaisPorSituacaoModelCopyWith<$Res> implements $TotaisPorSituacaoModelCopyWith<$Res> {
  factory _$TotaisPorSituacaoModelCopyWith(_TotaisPorSituacaoModel value, $Res Function(_TotaisPorSituacaoModel) _then) = __$TotaisPorSituacaoModelCopyWithImpl;
@override @useResult
$Res call({
 Map<String, int> totais, int total
});




}
/// @nodoc
class __$TotaisPorSituacaoModelCopyWithImpl<$Res>
    implements _$TotaisPorSituacaoModelCopyWith<$Res> {
  __$TotaisPorSituacaoModelCopyWithImpl(this._self, this._then);

  final _TotaisPorSituacaoModel _self;
  final $Res Function(_TotaisPorSituacaoModel) _then;

/// Create a copy of TotaisPorSituacaoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totais = null,Object? total = null,}) {
  return _then(_TotaisPorSituacaoModel(
totais: null == totais ? _self._totais : totais // ignore: cast_nullable_to_non_nullable
as Map<String, int>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
