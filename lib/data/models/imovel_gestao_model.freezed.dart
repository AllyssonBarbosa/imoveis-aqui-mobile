// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'imovel_gestao_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImovelGestaoModel {

 int get id; String get codigo; String get titulo; String get finalidade;@JsonKey(name: 'preco_venda') String? get precoVenda;@JsonKey(name: 'preco_aluguel') String? get precoAluguel; String? get situacao;@JsonKey(name: 'situacao_desde') String get situacaoDesde;@JsonKey(name: 'pode_mudar_situacao') bool get podeMudarSituacao;
/// Create a copy of ImovelGestaoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImovelGestaoModelCopyWith<ImovelGestaoModel> get copyWith => _$ImovelGestaoModelCopyWithImpl<ImovelGestaoModel>(this as ImovelGestaoModel, _$identity);

  /// Serializes this ImovelGestaoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ImovelGestaoModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImovelGestaoModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.codigo, _this.codigo) || other.codigo == _this.codigo)&&(identical(other.titulo, _this.titulo) || other.titulo == _this.titulo)&&(identical(other.finalidade, _this.finalidade) || other.finalidade == _this.finalidade)&&(identical(other.precoVenda, _this.precoVenda) || other.precoVenda == _this.precoVenda)&&(identical(other.precoAluguel, _this.precoAluguel) || other.precoAluguel == _this.precoAluguel)&&(identical(other.situacao, _this.situacao) || other.situacao == _this.situacao)&&(identical(other.situacaoDesde, _this.situacaoDesde) || other.situacaoDesde == _this.situacaoDesde)&&(identical(other.podeMudarSituacao, _this.podeMudarSituacao) || other.podeMudarSituacao == _this.podeMudarSituacao));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ImovelGestaoModel;
  return Object.hash(runtimeType,_this.id,_this.codigo,_this.titulo,_this.finalidade,_this.precoVenda,_this.precoAluguel,_this.situacao,_this.situacaoDesde,_this.podeMudarSituacao);
}

@override
String toString() {
  final _this = this as ImovelGestaoModel;
  return 'ImovelGestaoModel(id: ${_this.id}, codigo: ${_this.codigo}, titulo: ${_this.titulo}, finalidade: ${_this.finalidade}, precoVenda: ${_this.precoVenda}, precoAluguel: ${_this.precoAluguel}, situacao: ${_this.situacao}, situacaoDesde: ${_this.situacaoDesde}, podeMudarSituacao: ${_this.podeMudarSituacao})';
}


}

/// @nodoc
abstract mixin class $ImovelGestaoModelCopyWith<$Res>  {
  factory $ImovelGestaoModelCopyWith(ImovelGestaoModel value, $Res Function(ImovelGestaoModel) _then) = _$ImovelGestaoModelCopyWithImpl;
@useResult
$Res call({
 int id, String codigo, String titulo, String finalidade,@JsonKey(name: 'preco_venda') String? precoVenda,@JsonKey(name: 'preco_aluguel') String? precoAluguel, String? situacao,@JsonKey(name: 'situacao_desde') String situacaoDesde,@JsonKey(name: 'pode_mudar_situacao') bool podeMudarSituacao
});




}
/// @nodoc
class _$ImovelGestaoModelCopyWithImpl<$Res>
    implements $ImovelGestaoModelCopyWith<$Res> {
  _$ImovelGestaoModelCopyWithImpl(this._self, this._then);

  final ImovelGestaoModel _self;
  final $Res Function(ImovelGestaoModel) _then;

/// Create a copy of ImovelGestaoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? codigo = null,Object? titulo = null,Object? finalidade = null,Object? precoVenda = freezed,Object? precoAluguel = freezed,Object? situacao = freezed,Object? situacaoDesde = null,Object? podeMudarSituacao = null,}) {
  return _then(ImovelGestaoModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,codigo: null == codigo ? _self.codigo : codigo // ignore: cast_nullable_to_non_nullable
as String,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,finalidade: null == finalidade ? _self.finalidade : finalidade // ignore: cast_nullable_to_non_nullable
as String,precoVenda: freezed == precoVenda ? _self.precoVenda : precoVenda // ignore: cast_nullable_to_non_nullable
as String?,precoAluguel: freezed == precoAluguel ? _self.precoAluguel : precoAluguel // ignore: cast_nullable_to_non_nullable
as String?,situacao: freezed == situacao ? _self.situacao : situacao // ignore: cast_nullable_to_non_nullable
as String?,situacaoDesde: null == situacaoDesde ? _self.situacaoDesde : situacaoDesde // ignore: cast_nullable_to_non_nullable
as String,podeMudarSituacao: null == podeMudarSituacao ? _self.podeMudarSituacao : podeMudarSituacao // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ImovelGestaoModel].
extension ImovelGestaoModelPatterns on ImovelGestaoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImovelGestaoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImovelGestaoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImovelGestaoModel value)  $default,){
final _that = this;
switch (_that) {
case _ImovelGestaoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImovelGestaoModel value)?  $default,){
final _that = this;
switch (_that) {
case _ImovelGestaoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String codigo,  String titulo,  String finalidade, @JsonKey(name: 'preco_venda')  String? precoVenda, @JsonKey(name: 'preco_aluguel')  String? precoAluguel,  String? situacao, @JsonKey(name: 'situacao_desde')  String situacaoDesde, @JsonKey(name: 'pode_mudar_situacao')  bool podeMudarSituacao)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImovelGestaoModel() when $default != null:
return $default(_that.id,_that.codigo,_that.titulo,_that.finalidade,_that.precoVenda,_that.precoAluguel,_that.situacao,_that.situacaoDesde,_that.podeMudarSituacao);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String codigo,  String titulo,  String finalidade, @JsonKey(name: 'preco_venda')  String? precoVenda, @JsonKey(name: 'preco_aluguel')  String? precoAluguel,  String? situacao, @JsonKey(name: 'situacao_desde')  String situacaoDesde, @JsonKey(name: 'pode_mudar_situacao')  bool podeMudarSituacao)  $default,) {final _that = this;
switch (_that) {
case _ImovelGestaoModel():
return $default(_that.id,_that.codigo,_that.titulo,_that.finalidade,_that.precoVenda,_that.precoAluguel,_that.situacao,_that.situacaoDesde,_that.podeMudarSituacao);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String codigo,  String titulo,  String finalidade, @JsonKey(name: 'preco_venda')  String? precoVenda, @JsonKey(name: 'preco_aluguel')  String? precoAluguel,  String? situacao, @JsonKey(name: 'situacao_desde')  String situacaoDesde, @JsonKey(name: 'pode_mudar_situacao')  bool podeMudarSituacao)?  $default,) {final _that = this;
switch (_that) {
case _ImovelGestaoModel() when $default != null:
return $default(_that.id,_that.codigo,_that.titulo,_that.finalidade,_that.precoVenda,_that.precoAluguel,_that.situacao,_that.situacaoDesde,_that.podeMudarSituacao);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImovelGestaoModel extends ImovelGestaoModel {
  const _ImovelGestaoModel({required this.id, required this.codigo, required this.titulo, required this.finalidade, @JsonKey(name: 'preco_venda') this.precoVenda, @JsonKey(name: 'preco_aluguel') this.precoAluguel, this.situacao, @JsonKey(name: 'situacao_desde') required this.situacaoDesde, @JsonKey(name: 'pode_mudar_situacao') required this.podeMudarSituacao}): super._();
  factory _ImovelGestaoModel.fromJson(Map<String, dynamic> json) => _$ImovelGestaoModelFromJson(json);

@override final  int id;
@override final  String codigo;
@override final  String titulo;
@override final  String finalidade;
@override@JsonKey(name: 'preco_venda') final  String? precoVenda;
@override@JsonKey(name: 'preco_aluguel') final  String? precoAluguel;
@override final  String? situacao;
@override@JsonKey(name: 'situacao_desde') final  String situacaoDesde;
@override@JsonKey(name: 'pode_mudar_situacao') final  bool podeMudarSituacao;

/// Create a copy of ImovelGestaoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImovelGestaoModelCopyWith<_ImovelGestaoModel> get copyWith => __$ImovelGestaoModelCopyWithImpl<_ImovelGestaoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImovelGestaoModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImovelGestaoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.codigo, codigo) || other.codigo == codigo)&&(identical(other.titulo, titulo) || other.titulo == titulo)&&(identical(other.finalidade, finalidade) || other.finalidade == finalidade)&&(identical(other.precoVenda, precoVenda) || other.precoVenda == precoVenda)&&(identical(other.precoAluguel, precoAluguel) || other.precoAluguel == precoAluguel)&&(identical(other.situacao, situacao) || other.situacao == situacao)&&(identical(other.situacaoDesde, situacaoDesde) || other.situacaoDesde == situacaoDesde)&&(identical(other.podeMudarSituacao, podeMudarSituacao) || other.podeMudarSituacao == podeMudarSituacao));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,codigo,titulo,finalidade,precoVenda,precoAluguel,situacao,situacaoDesde,podeMudarSituacao);
}

@override
String toString() {
    return 'ImovelGestaoModel(id: $id, codigo: $codigo, titulo: $titulo, finalidade: $finalidade, precoVenda: $precoVenda, precoAluguel: $precoAluguel, situacao: $situacao, situacaoDesde: $situacaoDesde, podeMudarSituacao: $podeMudarSituacao)';
}


}

/// @nodoc
abstract mixin class _$ImovelGestaoModelCopyWith<$Res> implements $ImovelGestaoModelCopyWith<$Res> {
  factory _$ImovelGestaoModelCopyWith(_ImovelGestaoModel value, $Res Function(_ImovelGestaoModel) _then) = __$ImovelGestaoModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String codigo, String titulo, String finalidade,@JsonKey(name: 'preco_venda') String? precoVenda,@JsonKey(name: 'preco_aluguel') String? precoAluguel, String? situacao,@JsonKey(name: 'situacao_desde') String situacaoDesde,@JsonKey(name: 'pode_mudar_situacao') bool podeMudarSituacao
});




}
/// @nodoc
class __$ImovelGestaoModelCopyWithImpl<$Res>
    implements _$ImovelGestaoModelCopyWith<$Res> {
  __$ImovelGestaoModelCopyWithImpl(this._self, this._then);

  final _ImovelGestaoModel _self;
  final $Res Function(_ImovelGestaoModel) _then;

/// Create a copy of ImovelGestaoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? codigo = null,Object? titulo = null,Object? finalidade = null,Object? precoVenda = freezed,Object? precoAluguel = freezed,Object? situacao = freezed,Object? situacaoDesde = null,Object? podeMudarSituacao = null,}) {
  return _then(_ImovelGestaoModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,codigo: null == codigo ? _self.codigo : codigo // ignore: cast_nullable_to_non_nullable
as String,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,finalidade: null == finalidade ? _self.finalidade : finalidade // ignore: cast_nullable_to_non_nullable
as String,precoVenda: freezed == precoVenda ? _self.precoVenda : precoVenda // ignore: cast_nullable_to_non_nullable
as String?,precoAluguel: freezed == precoAluguel ? _self.precoAluguel : precoAluguel // ignore: cast_nullable_to_non_nullable
as String?,situacao: freezed == situacao ? _self.situacao : situacao // ignore: cast_nullable_to_non_nullable
as String?,situacaoDesde: null == situacaoDesde ? _self.situacaoDesde : situacaoDesde // ignore: cast_nullable_to_non_nullable
as String,podeMudarSituacao: null == podeMudarSituacao ? _self.podeMudarSituacao : podeMudarSituacao // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
