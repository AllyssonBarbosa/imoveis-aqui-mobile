// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resumo_contatos_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ResumoContatosModel {

@JsonKey(name: 'sem_retorno') int get semRetorno;
/// Create a copy of ResumoContatosModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResumoContatosModelCopyWith<ResumoContatosModel> get copyWith => _$ResumoContatosModelCopyWithImpl<ResumoContatosModel>(this as ResumoContatosModel, _$identity);

  /// Serializes this ResumoContatosModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ResumoContatosModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResumoContatosModel&&(identical(other.semRetorno, _this.semRetorno) || other.semRetorno == _this.semRetorno));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ResumoContatosModel;
  return Object.hash(runtimeType,_this.semRetorno);
}

@override
String toString() {
  final _this = this as ResumoContatosModel;
  return 'ResumoContatosModel(semRetorno: ${_this.semRetorno})';
}


}

/// @nodoc
abstract mixin class $ResumoContatosModelCopyWith<$Res>  {
  factory $ResumoContatosModelCopyWith(ResumoContatosModel value, $Res Function(ResumoContatosModel) _then) = _$ResumoContatosModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'sem_retorno') int semRetorno
});




}
/// @nodoc
class _$ResumoContatosModelCopyWithImpl<$Res>
    implements $ResumoContatosModelCopyWith<$Res> {
  _$ResumoContatosModelCopyWithImpl(this._self, this._then);

  final ResumoContatosModel _self;
  final $Res Function(ResumoContatosModel) _then;

/// Create a copy of ResumoContatosModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? semRetorno = null,}) {
  return _then(ResumoContatosModel(
semRetorno: null == semRetorno ? _self.semRetorno : semRetorno // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ResumoContatosModel].
extension ResumoContatosModelPatterns on ResumoContatosModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResumoContatosModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResumoContatosModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResumoContatosModel value)  $default,){
final _that = this;
switch (_that) {
case _ResumoContatosModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResumoContatosModel value)?  $default,){
final _that = this;
switch (_that) {
case _ResumoContatosModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'sem_retorno')  int semRetorno)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResumoContatosModel() when $default != null:
return $default(_that.semRetorno);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'sem_retorno')  int semRetorno)  $default,) {final _that = this;
switch (_that) {
case _ResumoContatosModel():
return $default(_that.semRetorno);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'sem_retorno')  int semRetorno)?  $default,) {final _that = this;
switch (_that) {
case _ResumoContatosModel() when $default != null:
return $default(_that.semRetorno);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResumoContatosModel implements ResumoContatosModel {
  const _ResumoContatosModel({@JsonKey(name: 'sem_retorno') required this.semRetorno});
  factory _ResumoContatosModel.fromJson(Map<String, dynamic> json) => _$ResumoContatosModelFromJson(json);

@override@JsonKey(name: 'sem_retorno') final  int semRetorno;

/// Create a copy of ResumoContatosModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResumoContatosModelCopyWith<_ResumoContatosModel> get copyWith => __$ResumoContatosModelCopyWithImpl<_ResumoContatosModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResumoContatosModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResumoContatosModel&&(identical(other.semRetorno, semRetorno) || other.semRetorno == semRetorno));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,semRetorno);
}

@override
String toString() {
    return 'ResumoContatosModel(semRetorno: $semRetorno)';
}


}

/// @nodoc
abstract mixin class _$ResumoContatosModelCopyWith<$Res> implements $ResumoContatosModelCopyWith<$Res> {
  factory _$ResumoContatosModelCopyWith(_ResumoContatosModel value, $Res Function(_ResumoContatosModel) _then) = __$ResumoContatosModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'sem_retorno') int semRetorno
});




}
/// @nodoc
class __$ResumoContatosModelCopyWithImpl<$Res>
    implements _$ResumoContatosModelCopyWith<$Res> {
  __$ResumoContatosModelCopyWithImpl(this._self, this._then);

  final _ResumoContatosModel _self;
  final $Res Function(_ResumoContatosModel) _then;

/// Create a copy of ResumoContatosModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? semRetorno = null,}) {
  return _then(_ResumoContatosModel(
semRetorno: null == semRetorno ? _self.semRetorno : semRetorno // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
