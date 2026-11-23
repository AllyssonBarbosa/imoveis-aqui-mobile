// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contato_recebido_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContatoRecebidoModel {

 int get id;@JsonKey(name: 'imovel_codigo') String get imovelCodigo;@JsonKey(name: 'imovel_titulo') String get imovelTitulo; String get canal;@JsonKey(name: 'criado_em') String get criadoEm; String get retorno;@JsonKey(name: 'retorno_em') String? get retornoEm;
/// Create a copy of ContatoRecebidoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContatoRecebidoModelCopyWith<ContatoRecebidoModel> get copyWith => _$ContatoRecebidoModelCopyWithImpl<ContatoRecebidoModel>(this as ContatoRecebidoModel, _$identity);

  /// Serializes this ContatoRecebidoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ContatoRecebidoModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContatoRecebidoModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.imovelCodigo, _this.imovelCodigo) || other.imovelCodigo == _this.imovelCodigo)&&(identical(other.imovelTitulo, _this.imovelTitulo) || other.imovelTitulo == _this.imovelTitulo)&&(identical(other.canal, _this.canal) || other.canal == _this.canal)&&(identical(other.criadoEm, _this.criadoEm) || other.criadoEm == _this.criadoEm)&&(identical(other.retorno, _this.retorno) || other.retorno == _this.retorno)&&(identical(other.retornoEm, _this.retornoEm) || other.retornoEm == _this.retornoEm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ContatoRecebidoModel;
  return Object.hash(runtimeType,_this.id,_this.imovelCodigo,_this.imovelTitulo,_this.canal,_this.criadoEm,_this.retorno,_this.retornoEm);
}

@override
String toString() {
  final _this = this as ContatoRecebidoModel;
  return 'ContatoRecebidoModel(id: ${_this.id}, imovelCodigo: ${_this.imovelCodigo}, imovelTitulo: ${_this.imovelTitulo}, canal: ${_this.canal}, criadoEm: ${_this.criadoEm}, retorno: ${_this.retorno}, retornoEm: ${_this.retornoEm})';
}


}

/// @nodoc
abstract mixin class $ContatoRecebidoModelCopyWith<$Res>  {
  factory $ContatoRecebidoModelCopyWith(ContatoRecebidoModel value, $Res Function(ContatoRecebidoModel) _then) = _$ContatoRecebidoModelCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'imovel_codigo') String imovelCodigo,@JsonKey(name: 'imovel_titulo') String imovelTitulo, String canal,@JsonKey(name: 'criado_em') String criadoEm, String retorno,@JsonKey(name: 'retorno_em') String? retornoEm
});




}
/// @nodoc
class _$ContatoRecebidoModelCopyWithImpl<$Res>
    implements $ContatoRecebidoModelCopyWith<$Res> {
  _$ContatoRecebidoModelCopyWithImpl(this._self, this._then);

  final ContatoRecebidoModel _self;
  final $Res Function(ContatoRecebidoModel) _then;

/// Create a copy of ContatoRecebidoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? imovelCodigo = null,Object? imovelTitulo = null,Object? canal = null,Object? criadoEm = null,Object? retorno = null,Object? retornoEm = freezed,}) {
  return _then(ContatoRecebidoModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,imovelCodigo: null == imovelCodigo ? _self.imovelCodigo : imovelCodigo // ignore: cast_nullable_to_non_nullable
as String,imovelTitulo: null == imovelTitulo ? _self.imovelTitulo : imovelTitulo // ignore: cast_nullable_to_non_nullable
as String,canal: null == canal ? _self.canal : canal // ignore: cast_nullable_to_non_nullable
as String,criadoEm: null == criadoEm ? _self.criadoEm : criadoEm // ignore: cast_nullable_to_non_nullable
as String,retorno: null == retorno ? _self.retorno : retorno // ignore: cast_nullable_to_non_nullable
as String,retornoEm: freezed == retornoEm ? _self.retornoEm : retornoEm // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContatoRecebidoModel].
extension ContatoRecebidoModelPatterns on ContatoRecebidoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContatoRecebidoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContatoRecebidoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContatoRecebidoModel value)  $default,){
final _that = this;
switch (_that) {
case _ContatoRecebidoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContatoRecebidoModel value)?  $default,){
final _that = this;
switch (_that) {
case _ContatoRecebidoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'imovel_codigo')  String imovelCodigo, @JsonKey(name: 'imovel_titulo')  String imovelTitulo,  String canal, @JsonKey(name: 'criado_em')  String criadoEm,  String retorno, @JsonKey(name: 'retorno_em')  String? retornoEm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContatoRecebidoModel() when $default != null:
return $default(_that.id,_that.imovelCodigo,_that.imovelTitulo,_that.canal,_that.criadoEm,_that.retorno,_that.retornoEm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'imovel_codigo')  String imovelCodigo, @JsonKey(name: 'imovel_titulo')  String imovelTitulo,  String canal, @JsonKey(name: 'criado_em')  String criadoEm,  String retorno, @JsonKey(name: 'retorno_em')  String? retornoEm)  $default,) {final _that = this;
switch (_that) {
case _ContatoRecebidoModel():
return $default(_that.id,_that.imovelCodigo,_that.imovelTitulo,_that.canal,_that.criadoEm,_that.retorno,_that.retornoEm);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'imovel_codigo')  String imovelCodigo, @JsonKey(name: 'imovel_titulo')  String imovelTitulo,  String canal, @JsonKey(name: 'criado_em')  String criadoEm,  String retorno, @JsonKey(name: 'retorno_em')  String? retornoEm)?  $default,) {final _that = this;
switch (_that) {
case _ContatoRecebidoModel() when $default != null:
return $default(_that.id,_that.imovelCodigo,_that.imovelTitulo,_that.canal,_that.criadoEm,_that.retorno,_that.retornoEm);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContatoRecebidoModel extends ContatoRecebidoModel {
  const _ContatoRecebidoModel({required this.id, @JsonKey(name: 'imovel_codigo') required this.imovelCodigo, @JsonKey(name: 'imovel_titulo') required this.imovelTitulo, required this.canal, @JsonKey(name: 'criado_em') required this.criadoEm, required this.retorno, @JsonKey(name: 'retorno_em') this.retornoEm}): super._();
  factory _ContatoRecebidoModel.fromJson(Map<String, dynamic> json) => _$ContatoRecebidoModelFromJson(json);

@override final  int id;
@override@JsonKey(name: 'imovel_codigo') final  String imovelCodigo;
@override@JsonKey(name: 'imovel_titulo') final  String imovelTitulo;
@override final  String canal;
@override@JsonKey(name: 'criado_em') final  String criadoEm;
@override final  String retorno;
@override@JsonKey(name: 'retorno_em') final  String? retornoEm;

/// Create a copy of ContatoRecebidoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContatoRecebidoModelCopyWith<_ContatoRecebidoModel> get copyWith => __$ContatoRecebidoModelCopyWithImpl<_ContatoRecebidoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContatoRecebidoModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContatoRecebidoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.imovelCodigo, imovelCodigo) || other.imovelCodigo == imovelCodigo)&&(identical(other.imovelTitulo, imovelTitulo) || other.imovelTitulo == imovelTitulo)&&(identical(other.canal, canal) || other.canal == canal)&&(identical(other.criadoEm, criadoEm) || other.criadoEm == criadoEm)&&(identical(other.retorno, retorno) || other.retorno == retorno)&&(identical(other.retornoEm, retornoEm) || other.retornoEm == retornoEm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,imovelCodigo,imovelTitulo,canal,criadoEm,retorno,retornoEm);
}

@override
String toString() {
    return 'ContatoRecebidoModel(id: $id, imovelCodigo: $imovelCodigo, imovelTitulo: $imovelTitulo, canal: $canal, criadoEm: $criadoEm, retorno: $retorno, retornoEm: $retornoEm)';
}


}

/// @nodoc
abstract mixin class _$ContatoRecebidoModelCopyWith<$Res> implements $ContatoRecebidoModelCopyWith<$Res> {
  factory _$ContatoRecebidoModelCopyWith(_ContatoRecebidoModel value, $Res Function(_ContatoRecebidoModel) _then) = __$ContatoRecebidoModelCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'imovel_codigo') String imovelCodigo,@JsonKey(name: 'imovel_titulo') String imovelTitulo, String canal,@JsonKey(name: 'criado_em') String criadoEm, String retorno,@JsonKey(name: 'retorno_em') String? retornoEm
});




}
/// @nodoc
class __$ContatoRecebidoModelCopyWithImpl<$Res>
    implements _$ContatoRecebidoModelCopyWith<$Res> {
  __$ContatoRecebidoModelCopyWithImpl(this._self, this._then);

  final _ContatoRecebidoModel _self;
  final $Res Function(_ContatoRecebidoModel) _then;

/// Create a copy of ContatoRecebidoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? imovelCodigo = null,Object? imovelTitulo = null,Object? canal = null,Object? criadoEm = null,Object? retorno = null,Object? retornoEm = freezed,}) {
  return _then(_ContatoRecebidoModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,imovelCodigo: null == imovelCodigo ? _self.imovelCodigo : imovelCodigo // ignore: cast_nullable_to_non_nullable
as String,imovelTitulo: null == imovelTitulo ? _self.imovelTitulo : imovelTitulo // ignore: cast_nullable_to_non_nullable
as String,canal: null == canal ? _self.canal : canal // ignore: cast_nullable_to_non_nullable
as String,criadoEm: null == criadoEm ? _self.criadoEm : criadoEm // ignore: cast_nullable_to_non_nullable
as String,retorno: null == retorno ? _self.retorno : retorno // ignore: cast_nullable_to_non_nullable
as String,retornoEm: freezed == retornoEm ? _self.retornoEm : retornoEm // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
