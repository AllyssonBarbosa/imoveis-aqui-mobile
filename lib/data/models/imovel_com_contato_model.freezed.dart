// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'imovel_com_contato_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImovelComContatoModel {

 int get id; String get codigo; String get titulo;
/// Create a copy of ImovelComContatoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImovelComContatoModelCopyWith<ImovelComContatoModel> get copyWith => _$ImovelComContatoModelCopyWithImpl<ImovelComContatoModel>(this as ImovelComContatoModel, _$identity);

  /// Serializes this ImovelComContatoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ImovelComContatoModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImovelComContatoModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.codigo, _this.codigo) || other.codigo == _this.codigo)&&(identical(other.titulo, _this.titulo) || other.titulo == _this.titulo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ImovelComContatoModel;
  return Object.hash(runtimeType,_this.id,_this.codigo,_this.titulo);
}

@override
String toString() {
  final _this = this as ImovelComContatoModel;
  return 'ImovelComContatoModel(id: ${_this.id}, codigo: ${_this.codigo}, titulo: ${_this.titulo})';
}


}

/// @nodoc
abstract mixin class $ImovelComContatoModelCopyWith<$Res>  {
  factory $ImovelComContatoModelCopyWith(ImovelComContatoModel value, $Res Function(ImovelComContatoModel) _then) = _$ImovelComContatoModelCopyWithImpl;
@useResult
$Res call({
 int id, String codigo, String titulo
});




}
/// @nodoc
class _$ImovelComContatoModelCopyWithImpl<$Res>
    implements $ImovelComContatoModelCopyWith<$Res> {
  _$ImovelComContatoModelCopyWithImpl(this._self, this._then);

  final ImovelComContatoModel _self;
  final $Res Function(ImovelComContatoModel) _then;

/// Create a copy of ImovelComContatoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? codigo = null,Object? titulo = null,}) {
  return _then(ImovelComContatoModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,codigo: null == codigo ? _self.codigo : codigo // ignore: cast_nullable_to_non_nullable
as String,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ImovelComContatoModel].
extension ImovelComContatoModelPatterns on ImovelComContatoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImovelComContatoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImovelComContatoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImovelComContatoModel value)  $default,){
final _that = this;
switch (_that) {
case _ImovelComContatoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImovelComContatoModel value)?  $default,){
final _that = this;
switch (_that) {
case _ImovelComContatoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String codigo,  String titulo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImovelComContatoModel() when $default != null:
return $default(_that.id,_that.codigo,_that.titulo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String codigo,  String titulo)  $default,) {final _that = this;
switch (_that) {
case _ImovelComContatoModel():
return $default(_that.id,_that.codigo,_that.titulo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String codigo,  String titulo)?  $default,) {final _that = this;
switch (_that) {
case _ImovelComContatoModel() when $default != null:
return $default(_that.id,_that.codigo,_that.titulo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImovelComContatoModel extends ImovelComContatoModel {
  const _ImovelComContatoModel({required this.id, required this.codigo, required this.titulo}): super._();
  factory _ImovelComContatoModel.fromJson(Map<String, dynamic> json) => _$ImovelComContatoModelFromJson(json);

@override final  int id;
@override final  String codigo;
@override final  String titulo;

/// Create a copy of ImovelComContatoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImovelComContatoModelCopyWith<_ImovelComContatoModel> get copyWith => __$ImovelComContatoModelCopyWithImpl<_ImovelComContatoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImovelComContatoModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImovelComContatoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.codigo, codigo) || other.codigo == codigo)&&(identical(other.titulo, titulo) || other.titulo == titulo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,codigo,titulo);
}

@override
String toString() {
    return 'ImovelComContatoModel(id: $id, codigo: $codigo, titulo: $titulo)';
}


}

/// @nodoc
abstract mixin class _$ImovelComContatoModelCopyWith<$Res> implements $ImovelComContatoModelCopyWith<$Res> {
  factory _$ImovelComContatoModelCopyWith(_ImovelComContatoModel value, $Res Function(_ImovelComContatoModel) _then) = __$ImovelComContatoModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String codigo, String titulo
});




}
/// @nodoc
class __$ImovelComContatoModelCopyWithImpl<$Res>
    implements _$ImovelComContatoModelCopyWith<$Res> {
  __$ImovelComContatoModelCopyWithImpl(this._self, this._then);

  final _ImovelComContatoModel _self;
  final $Res Function(_ImovelComContatoModel) _then;

/// Create a copy of ImovelComContatoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? codigo = null,Object? titulo = null,}) {
  return _then(_ImovelComContatoModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,codigo: null == codigo ? _self.codigo : codigo // ignore: cast_nullable_to_non_nullable
as String,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
