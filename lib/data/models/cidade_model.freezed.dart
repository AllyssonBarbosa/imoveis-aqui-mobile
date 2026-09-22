// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cidade_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CidadeModel {

 int get id; String get nome; String get uf;
/// Create a copy of CidadeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CidadeModelCopyWith<CidadeModel> get copyWith => _$CidadeModelCopyWithImpl<CidadeModel>(this as CidadeModel, _$identity);

  /// Serializes this CidadeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CidadeModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CidadeModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nome, _this.nome) || other.nome == _this.nome)&&(identical(other.uf, _this.uf) || other.uf == _this.uf));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CidadeModel;
  return Object.hash(runtimeType,_this.id,_this.nome,_this.uf);
}

@override
String toString() {
  final _this = this as CidadeModel;
  return 'CidadeModel(id: ${_this.id}, nome: ${_this.nome}, uf: ${_this.uf})';
}


}

/// @nodoc
abstract mixin class $CidadeModelCopyWith<$Res>  {
  factory $CidadeModelCopyWith(CidadeModel value, $Res Function(CidadeModel) _then) = _$CidadeModelCopyWithImpl;
@useResult
$Res call({
 int id, String nome, String uf
});




}
/// @nodoc
class _$CidadeModelCopyWithImpl<$Res>
    implements $CidadeModelCopyWith<$Res> {
  _$CidadeModelCopyWithImpl(this._self, this._then);

  final CidadeModel _self;
  final $Res Function(CidadeModel) _then;

/// Create a copy of CidadeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nome = null,Object? uf = null,}) {
  return _then(CidadeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,uf: null == uf ? _self.uf : uf // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CidadeModel].
extension CidadeModelPatterns on CidadeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CidadeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CidadeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CidadeModel value)  $default,){
final _that = this;
switch (_that) {
case _CidadeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CidadeModel value)?  $default,){
final _that = this;
switch (_that) {
case _CidadeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String nome,  String uf)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CidadeModel() when $default != null:
return $default(_that.id,_that.nome,_that.uf);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String nome,  String uf)  $default,) {final _that = this;
switch (_that) {
case _CidadeModel():
return $default(_that.id,_that.nome,_that.uf);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String nome,  String uf)?  $default,) {final _that = this;
switch (_that) {
case _CidadeModel() when $default != null:
return $default(_that.id,_that.nome,_that.uf);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CidadeModel extends CidadeModel {
  const _CidadeModel({required this.id, required this.nome, required this.uf}): super._();
  factory _CidadeModel.fromJson(Map<String, dynamic> json) => _$CidadeModelFromJson(json);

@override final  int id;
@override final  String nome;
@override final  String uf;

/// Create a copy of CidadeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CidadeModelCopyWith<_CidadeModel> get copyWith => __$CidadeModelCopyWithImpl<_CidadeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CidadeModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CidadeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.uf, uf) || other.uf == uf));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,nome,uf);
}

@override
String toString() {
    return 'CidadeModel(id: $id, nome: $nome, uf: $uf)';
}


}

/// @nodoc
abstract mixin class _$CidadeModelCopyWith<$Res> implements $CidadeModelCopyWith<$Res> {
  factory _$CidadeModelCopyWith(_CidadeModel value, $Res Function(_CidadeModel) _then) = __$CidadeModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String nome, String uf
});




}
/// @nodoc
class __$CidadeModelCopyWithImpl<$Res>
    implements _$CidadeModelCopyWith<$Res> {
  __$CidadeModelCopyWithImpl(this._self, this._then);

  final _CidadeModel _self;
  final $Res Function(_CidadeModel) _then;

/// Create a copy of CidadeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nome = null,Object? uf = null,}) {
  return _then(_CidadeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,uf: null == uf ? _self.uf : uf // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
