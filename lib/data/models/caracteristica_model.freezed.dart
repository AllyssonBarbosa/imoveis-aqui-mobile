// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'caracteristica_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CaracteristicaModel {

 int get id; String get nome;
/// Create a copy of CaracteristicaModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaracteristicaModelCopyWith<CaracteristicaModel> get copyWith => _$CaracteristicaModelCopyWithImpl<CaracteristicaModel>(this as CaracteristicaModel, _$identity);

  /// Serializes this CaracteristicaModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CaracteristicaModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaracteristicaModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nome, _this.nome) || other.nome == _this.nome));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CaracteristicaModel;
  return Object.hash(runtimeType,_this.id,_this.nome);
}

@override
String toString() {
  final _this = this as CaracteristicaModel;
  return 'CaracteristicaModel(id: ${_this.id}, nome: ${_this.nome})';
}


}

/// @nodoc
abstract mixin class $CaracteristicaModelCopyWith<$Res>  {
  factory $CaracteristicaModelCopyWith(CaracteristicaModel value, $Res Function(CaracteristicaModel) _then) = _$CaracteristicaModelCopyWithImpl;
@useResult
$Res call({
 int id, String nome
});




}
/// @nodoc
class _$CaracteristicaModelCopyWithImpl<$Res>
    implements $CaracteristicaModelCopyWith<$Res> {
  _$CaracteristicaModelCopyWithImpl(this._self, this._then);

  final CaracteristicaModel _self;
  final $Res Function(CaracteristicaModel) _then;

/// Create a copy of CaracteristicaModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nome = null,}) {
  return _then(CaracteristicaModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CaracteristicaModel].
extension CaracteristicaModelPatterns on CaracteristicaModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaracteristicaModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaracteristicaModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaracteristicaModel value)  $default,){
final _that = this;
switch (_that) {
case _CaracteristicaModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaracteristicaModel value)?  $default,){
final _that = this;
switch (_that) {
case _CaracteristicaModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String nome)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaracteristicaModel() when $default != null:
return $default(_that.id,_that.nome);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String nome)  $default,) {final _that = this;
switch (_that) {
case _CaracteristicaModel():
return $default(_that.id,_that.nome);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String nome)?  $default,) {final _that = this;
switch (_that) {
case _CaracteristicaModel() when $default != null:
return $default(_that.id,_that.nome);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaracteristicaModel implements CaracteristicaModel {
  const _CaracteristicaModel({required this.id, required this.nome});
  factory _CaracteristicaModel.fromJson(Map<String, dynamic> json) => _$CaracteristicaModelFromJson(json);

@override final  int id;
@override final  String nome;

/// Create a copy of CaracteristicaModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaracteristicaModelCopyWith<_CaracteristicaModel> get copyWith => __$CaracteristicaModelCopyWithImpl<_CaracteristicaModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaracteristicaModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaracteristicaModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nome, nome) || other.nome == nome));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,nome);
}

@override
String toString() {
    return 'CaracteristicaModel(id: $id, nome: $nome)';
}


}

/// @nodoc
abstract mixin class _$CaracteristicaModelCopyWith<$Res> implements $CaracteristicaModelCopyWith<$Res> {
  factory _$CaracteristicaModelCopyWith(_CaracteristicaModel value, $Res Function(_CaracteristicaModel) _then) = __$CaracteristicaModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String nome
});




}
/// @nodoc
class __$CaracteristicaModelCopyWithImpl<$Res>
    implements _$CaracteristicaModelCopyWith<$Res> {
  __$CaracteristicaModelCopyWithImpl(this._self, this._then);

  final _CaracteristicaModel _self;
  final $Res Function(_CaracteristicaModel) _then;

/// Create a copy of CaracteristicaModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nome = null,}) {
  return _then(_CaracteristicaModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
