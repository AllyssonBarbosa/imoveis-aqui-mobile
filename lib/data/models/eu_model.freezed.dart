// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'eu_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EuModel {

 String get perfil;
/// Create a copy of EuModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EuModelCopyWith<EuModel> get copyWith => _$EuModelCopyWithImpl<EuModel>(this as EuModel, _$identity);

  /// Serializes this EuModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EuModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EuModel&&(identical(other.perfil, _this.perfil) || other.perfil == _this.perfil));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EuModel;
  return Object.hash(runtimeType,_this.perfil);
}

@override
String toString() {
  final _this = this as EuModel;
  return 'EuModel(perfil: ${_this.perfil})';
}


}

/// @nodoc
abstract mixin class $EuModelCopyWith<$Res>  {
  factory $EuModelCopyWith(EuModel value, $Res Function(EuModel) _then) = _$EuModelCopyWithImpl;
@useResult
$Res call({
 String perfil
});




}
/// @nodoc
class _$EuModelCopyWithImpl<$Res>
    implements $EuModelCopyWith<$Res> {
  _$EuModelCopyWithImpl(this._self, this._then);

  final EuModel _self;
  final $Res Function(EuModel) _then;

/// Create a copy of EuModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? perfil = null,}) {
  return _then(EuModel(
perfil: null == perfil ? _self.perfil : perfil // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EuModel].
extension EuModelPatterns on EuModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EuModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EuModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EuModel value)  $default,){
final _that = this;
switch (_that) {
case _EuModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EuModel value)?  $default,){
final _that = this;
switch (_that) {
case _EuModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String perfil)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EuModel() when $default != null:
return $default(_that.perfil);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String perfil)  $default,) {final _that = this;
switch (_that) {
case _EuModel():
return $default(_that.perfil);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String perfil)?  $default,) {final _that = this;
switch (_that) {
case _EuModel() when $default != null:
return $default(_that.perfil);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EuModel extends EuModel {
  const _EuModel({required this.perfil}): super._();
  factory _EuModel.fromJson(Map<String, dynamic> json) => _$EuModelFromJson(json);

@override final  String perfil;

/// Create a copy of EuModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EuModelCopyWith<_EuModel> get copyWith => __$EuModelCopyWithImpl<_EuModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EuModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EuModel&&(identical(other.perfil, perfil) || other.perfil == perfil));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,perfil);
}

@override
String toString() {
    return 'EuModel(perfil: $perfil)';
}


}

/// @nodoc
abstract mixin class _$EuModelCopyWith<$Res> implements $EuModelCopyWith<$Res> {
  factory _$EuModelCopyWith(_EuModel value, $Res Function(_EuModel) _then) = __$EuModelCopyWithImpl;
@override @useResult
$Res call({
 String perfil
});




}
/// @nodoc
class __$EuModelCopyWithImpl<$Res>
    implements _$EuModelCopyWith<$Res> {
  __$EuModelCopyWithImpl(this._self, this._then);

  final _EuModel _self;
  final $Res Function(_EuModel) _then;

/// Create a copy of EuModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? perfil = null,}) {
  return _then(_EuModel(
perfil: null == perfil ? _self.perfil : perfil // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
