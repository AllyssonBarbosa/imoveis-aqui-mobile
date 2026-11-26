// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'foto_imovel_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FotoImovelModel {

 int get id; String get imagem; int get ordem; bool get capa;
/// Create a copy of FotoImovelModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FotoImovelModelCopyWith<FotoImovelModel> get copyWith => _$FotoImovelModelCopyWithImpl<FotoImovelModel>(this as FotoImovelModel, _$identity);

  /// Serializes this FotoImovelModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FotoImovelModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FotoImovelModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.imagem, _this.imagem) || other.imagem == _this.imagem)&&(identical(other.ordem, _this.ordem) || other.ordem == _this.ordem)&&(identical(other.capa, _this.capa) || other.capa == _this.capa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FotoImovelModel;
  return Object.hash(runtimeType,_this.id,_this.imagem,_this.ordem,_this.capa);
}

@override
String toString() {
  final _this = this as FotoImovelModel;
  return 'FotoImovelModel(id: ${_this.id}, imagem: ${_this.imagem}, ordem: ${_this.ordem}, capa: ${_this.capa})';
}


}

/// @nodoc
abstract mixin class $FotoImovelModelCopyWith<$Res>  {
  factory $FotoImovelModelCopyWith(FotoImovelModel value, $Res Function(FotoImovelModel) _then) = _$FotoImovelModelCopyWithImpl;
@useResult
$Res call({
 int id, String imagem, int ordem, bool capa
});




}
/// @nodoc
class _$FotoImovelModelCopyWithImpl<$Res>
    implements $FotoImovelModelCopyWith<$Res> {
  _$FotoImovelModelCopyWithImpl(this._self, this._then);

  final FotoImovelModel _self;
  final $Res Function(FotoImovelModel) _then;

/// Create a copy of FotoImovelModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? imagem = null,Object? ordem = null,Object? capa = null,}) {
  return _then(FotoImovelModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,imagem: null == imagem ? _self.imagem : imagem // ignore: cast_nullable_to_non_nullable
as String,ordem: null == ordem ? _self.ordem : ordem // ignore: cast_nullable_to_non_nullable
as int,capa: null == capa ? _self.capa : capa // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FotoImovelModel].
extension FotoImovelModelPatterns on FotoImovelModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FotoImovelModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FotoImovelModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FotoImovelModel value)  $default,){
final _that = this;
switch (_that) {
case _FotoImovelModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FotoImovelModel value)?  $default,){
final _that = this;
switch (_that) {
case _FotoImovelModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String imagem,  int ordem,  bool capa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FotoImovelModel() when $default != null:
return $default(_that.id,_that.imagem,_that.ordem,_that.capa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String imagem,  int ordem,  bool capa)  $default,) {final _that = this;
switch (_that) {
case _FotoImovelModel():
return $default(_that.id,_that.imagem,_that.ordem,_that.capa);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String imagem,  int ordem,  bool capa)?  $default,) {final _that = this;
switch (_that) {
case _FotoImovelModel() when $default != null:
return $default(_that.id,_that.imagem,_that.ordem,_that.capa);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FotoImovelModel extends FotoImovelModel {
  const _FotoImovelModel({required this.id, required this.imagem, required this.ordem, required this.capa}): super._();
  factory _FotoImovelModel.fromJson(Map<String, dynamic> json) => _$FotoImovelModelFromJson(json);

@override final  int id;
@override final  String imagem;
@override final  int ordem;
@override final  bool capa;

/// Create a copy of FotoImovelModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FotoImovelModelCopyWith<_FotoImovelModel> get copyWith => __$FotoImovelModelCopyWithImpl<_FotoImovelModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FotoImovelModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FotoImovelModel&&(identical(other.id, id) || other.id == id)&&(identical(other.imagem, imagem) || other.imagem == imagem)&&(identical(other.ordem, ordem) || other.ordem == ordem)&&(identical(other.capa, capa) || other.capa == capa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,imagem,ordem,capa);
}

@override
String toString() {
    return 'FotoImovelModel(id: $id, imagem: $imagem, ordem: $ordem, capa: $capa)';
}


}

/// @nodoc
abstract mixin class _$FotoImovelModelCopyWith<$Res> implements $FotoImovelModelCopyWith<$Res> {
  factory _$FotoImovelModelCopyWith(_FotoImovelModel value, $Res Function(_FotoImovelModel) _then) = __$FotoImovelModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String imagem, int ordem, bool capa
});




}
/// @nodoc
class __$FotoImovelModelCopyWithImpl<$Res>
    implements _$FotoImovelModelCopyWith<$Res> {
  __$FotoImovelModelCopyWithImpl(this._self, this._then);

  final _FotoImovelModel _self;
  final $Res Function(_FotoImovelModel) _then;

/// Create a copy of FotoImovelModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? imagem = null,Object? ordem = null,Object? capa = null,}) {
  return _then(_FotoImovelModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,imagem: null == imagem ? _self.imagem : imagem // ignore: cast_nullable_to_non_nullable
as String,ordem: null == ordem ? _self.ordem : ordem // ignore: cast_nullable_to_non_nullable
as int,capa: null == capa ? _self.capa : capa // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
