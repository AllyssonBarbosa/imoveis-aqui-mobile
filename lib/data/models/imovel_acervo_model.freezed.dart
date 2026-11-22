// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'imovel_acervo_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImovelAcervoModel {

 int get id; String get codigo; String get titulo; String get finalidade;@JsonKey(name: 'preco_venda') String? get precoVenda;@JsonKey(name: 'preco_aluguel') String? get precoAluguel;@JsonKey(name: 'foto_capa') String? get fotoCapa; String? get situacao;@JsonKey(name: 'meu_imovel') bool get meuImovel;@JsonKey(name: 'na_vitrine') bool get naVitrine;
/// Create a copy of ImovelAcervoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImovelAcervoModelCopyWith<ImovelAcervoModel> get copyWith => _$ImovelAcervoModelCopyWithImpl<ImovelAcervoModel>(this as ImovelAcervoModel, _$identity);

  /// Serializes this ImovelAcervoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ImovelAcervoModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImovelAcervoModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.codigo, _this.codigo) || other.codigo == _this.codigo)&&(identical(other.titulo, _this.titulo) || other.titulo == _this.titulo)&&(identical(other.finalidade, _this.finalidade) || other.finalidade == _this.finalidade)&&(identical(other.precoVenda, _this.precoVenda) || other.precoVenda == _this.precoVenda)&&(identical(other.precoAluguel, _this.precoAluguel) || other.precoAluguel == _this.precoAluguel)&&(identical(other.fotoCapa, _this.fotoCapa) || other.fotoCapa == _this.fotoCapa)&&(identical(other.situacao, _this.situacao) || other.situacao == _this.situacao)&&(identical(other.meuImovel, _this.meuImovel) || other.meuImovel == _this.meuImovel)&&(identical(other.naVitrine, _this.naVitrine) || other.naVitrine == _this.naVitrine));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ImovelAcervoModel;
  return Object.hash(runtimeType,_this.id,_this.codigo,_this.titulo,_this.finalidade,_this.precoVenda,_this.precoAluguel,_this.fotoCapa,_this.situacao,_this.meuImovel,_this.naVitrine);
}

@override
String toString() {
  final _this = this as ImovelAcervoModel;
  return 'ImovelAcervoModel(id: ${_this.id}, codigo: ${_this.codigo}, titulo: ${_this.titulo}, finalidade: ${_this.finalidade}, precoVenda: ${_this.precoVenda}, precoAluguel: ${_this.precoAluguel}, fotoCapa: ${_this.fotoCapa}, situacao: ${_this.situacao}, meuImovel: ${_this.meuImovel}, naVitrine: ${_this.naVitrine})';
}


}

/// @nodoc
abstract mixin class $ImovelAcervoModelCopyWith<$Res>  {
  factory $ImovelAcervoModelCopyWith(ImovelAcervoModel value, $Res Function(ImovelAcervoModel) _then) = _$ImovelAcervoModelCopyWithImpl;
@useResult
$Res call({
 int id, String codigo, String titulo, String finalidade,@JsonKey(name: 'preco_venda') String? precoVenda,@JsonKey(name: 'preco_aluguel') String? precoAluguel,@JsonKey(name: 'foto_capa') String? fotoCapa, String? situacao,@JsonKey(name: 'meu_imovel') bool meuImovel,@JsonKey(name: 'na_vitrine') bool naVitrine
});




}
/// @nodoc
class _$ImovelAcervoModelCopyWithImpl<$Res>
    implements $ImovelAcervoModelCopyWith<$Res> {
  _$ImovelAcervoModelCopyWithImpl(this._self, this._then);

  final ImovelAcervoModel _self;
  final $Res Function(ImovelAcervoModel) _then;

/// Create a copy of ImovelAcervoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? codigo = null,Object? titulo = null,Object? finalidade = null,Object? precoVenda = freezed,Object? precoAluguel = freezed,Object? fotoCapa = freezed,Object? situacao = freezed,Object? meuImovel = null,Object? naVitrine = null,}) {
  return _then(ImovelAcervoModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,codigo: null == codigo ? _self.codigo : codigo // ignore: cast_nullable_to_non_nullable
as String,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,finalidade: null == finalidade ? _self.finalidade : finalidade // ignore: cast_nullable_to_non_nullable
as String,precoVenda: freezed == precoVenda ? _self.precoVenda : precoVenda // ignore: cast_nullable_to_non_nullable
as String?,precoAluguel: freezed == precoAluguel ? _self.precoAluguel : precoAluguel // ignore: cast_nullable_to_non_nullable
as String?,fotoCapa: freezed == fotoCapa ? _self.fotoCapa : fotoCapa // ignore: cast_nullable_to_non_nullable
as String?,situacao: freezed == situacao ? _self.situacao : situacao // ignore: cast_nullable_to_non_nullable
as String?,meuImovel: null == meuImovel ? _self.meuImovel : meuImovel // ignore: cast_nullable_to_non_nullable
as bool,naVitrine: null == naVitrine ? _self.naVitrine : naVitrine // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ImovelAcervoModel].
extension ImovelAcervoModelPatterns on ImovelAcervoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImovelAcervoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImovelAcervoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImovelAcervoModel value)  $default,){
final _that = this;
switch (_that) {
case _ImovelAcervoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImovelAcervoModel value)?  $default,){
final _that = this;
switch (_that) {
case _ImovelAcervoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String codigo,  String titulo,  String finalidade, @JsonKey(name: 'preco_venda')  String? precoVenda, @JsonKey(name: 'preco_aluguel')  String? precoAluguel, @JsonKey(name: 'foto_capa')  String? fotoCapa,  String? situacao, @JsonKey(name: 'meu_imovel')  bool meuImovel, @JsonKey(name: 'na_vitrine')  bool naVitrine)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImovelAcervoModel() when $default != null:
return $default(_that.id,_that.codigo,_that.titulo,_that.finalidade,_that.precoVenda,_that.precoAluguel,_that.fotoCapa,_that.situacao,_that.meuImovel,_that.naVitrine);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String codigo,  String titulo,  String finalidade, @JsonKey(name: 'preco_venda')  String? precoVenda, @JsonKey(name: 'preco_aluguel')  String? precoAluguel, @JsonKey(name: 'foto_capa')  String? fotoCapa,  String? situacao, @JsonKey(name: 'meu_imovel')  bool meuImovel, @JsonKey(name: 'na_vitrine')  bool naVitrine)  $default,) {final _that = this;
switch (_that) {
case _ImovelAcervoModel():
return $default(_that.id,_that.codigo,_that.titulo,_that.finalidade,_that.precoVenda,_that.precoAluguel,_that.fotoCapa,_that.situacao,_that.meuImovel,_that.naVitrine);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String codigo,  String titulo,  String finalidade, @JsonKey(name: 'preco_venda')  String? precoVenda, @JsonKey(name: 'preco_aluguel')  String? precoAluguel, @JsonKey(name: 'foto_capa')  String? fotoCapa,  String? situacao, @JsonKey(name: 'meu_imovel')  bool meuImovel, @JsonKey(name: 'na_vitrine')  bool naVitrine)?  $default,) {final _that = this;
switch (_that) {
case _ImovelAcervoModel() when $default != null:
return $default(_that.id,_that.codigo,_that.titulo,_that.finalidade,_that.precoVenda,_that.precoAluguel,_that.fotoCapa,_that.situacao,_that.meuImovel,_that.naVitrine);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImovelAcervoModel extends ImovelAcervoModel {
  const _ImovelAcervoModel({required this.id, required this.codigo, required this.titulo, required this.finalidade, @JsonKey(name: 'preco_venda') this.precoVenda, @JsonKey(name: 'preco_aluguel') this.precoAluguel, @JsonKey(name: 'foto_capa') this.fotoCapa, this.situacao, @JsonKey(name: 'meu_imovel') required this.meuImovel, @JsonKey(name: 'na_vitrine') required this.naVitrine}): super._();
  factory _ImovelAcervoModel.fromJson(Map<String, dynamic> json) => _$ImovelAcervoModelFromJson(json);

@override final  int id;
@override final  String codigo;
@override final  String titulo;
@override final  String finalidade;
@override@JsonKey(name: 'preco_venda') final  String? precoVenda;
@override@JsonKey(name: 'preco_aluguel') final  String? precoAluguel;
@override@JsonKey(name: 'foto_capa') final  String? fotoCapa;
@override final  String? situacao;
@override@JsonKey(name: 'meu_imovel') final  bool meuImovel;
@override@JsonKey(name: 'na_vitrine') final  bool naVitrine;

/// Create a copy of ImovelAcervoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImovelAcervoModelCopyWith<_ImovelAcervoModel> get copyWith => __$ImovelAcervoModelCopyWithImpl<_ImovelAcervoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImovelAcervoModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImovelAcervoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.codigo, codigo) || other.codigo == codigo)&&(identical(other.titulo, titulo) || other.titulo == titulo)&&(identical(other.finalidade, finalidade) || other.finalidade == finalidade)&&(identical(other.precoVenda, precoVenda) || other.precoVenda == precoVenda)&&(identical(other.precoAluguel, precoAluguel) || other.precoAluguel == precoAluguel)&&(identical(other.fotoCapa, fotoCapa) || other.fotoCapa == fotoCapa)&&(identical(other.situacao, situacao) || other.situacao == situacao)&&(identical(other.meuImovel, meuImovel) || other.meuImovel == meuImovel)&&(identical(other.naVitrine, naVitrine) || other.naVitrine == naVitrine));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,codigo,titulo,finalidade,precoVenda,precoAluguel,fotoCapa,situacao,meuImovel,naVitrine);
}

@override
String toString() {
    return 'ImovelAcervoModel(id: $id, codigo: $codigo, titulo: $titulo, finalidade: $finalidade, precoVenda: $precoVenda, precoAluguel: $precoAluguel, fotoCapa: $fotoCapa, situacao: $situacao, meuImovel: $meuImovel, naVitrine: $naVitrine)';
}


}

/// @nodoc
abstract mixin class _$ImovelAcervoModelCopyWith<$Res> implements $ImovelAcervoModelCopyWith<$Res> {
  factory _$ImovelAcervoModelCopyWith(_ImovelAcervoModel value, $Res Function(_ImovelAcervoModel) _then) = __$ImovelAcervoModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String codigo, String titulo, String finalidade,@JsonKey(name: 'preco_venda') String? precoVenda,@JsonKey(name: 'preco_aluguel') String? precoAluguel,@JsonKey(name: 'foto_capa') String? fotoCapa, String? situacao,@JsonKey(name: 'meu_imovel') bool meuImovel,@JsonKey(name: 'na_vitrine') bool naVitrine
});




}
/// @nodoc
class __$ImovelAcervoModelCopyWithImpl<$Res>
    implements _$ImovelAcervoModelCopyWith<$Res> {
  __$ImovelAcervoModelCopyWithImpl(this._self, this._then);

  final _ImovelAcervoModel _self;
  final $Res Function(_ImovelAcervoModel) _then;

/// Create a copy of ImovelAcervoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? codigo = null,Object? titulo = null,Object? finalidade = null,Object? precoVenda = freezed,Object? precoAluguel = freezed,Object? fotoCapa = freezed,Object? situacao = freezed,Object? meuImovel = null,Object? naVitrine = null,}) {
  return _then(_ImovelAcervoModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,codigo: null == codigo ? _self.codigo : codigo // ignore: cast_nullable_to_non_nullable
as String,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,finalidade: null == finalidade ? _self.finalidade : finalidade // ignore: cast_nullable_to_non_nullable
as String,precoVenda: freezed == precoVenda ? _self.precoVenda : precoVenda // ignore: cast_nullable_to_non_nullable
as String?,precoAluguel: freezed == precoAluguel ? _self.precoAluguel : precoAluguel // ignore: cast_nullable_to_non_nullable
as String?,fotoCapa: freezed == fotoCapa ? _self.fotoCapa : fotoCapa // ignore: cast_nullable_to_non_nullable
as String?,situacao: freezed == situacao ? _self.situacao : situacao // ignore: cast_nullable_to_non_nullable
as String?,meuImovel: null == meuImovel ? _self.meuImovel : meuImovel // ignore: cast_nullable_to_non_nullable
as bool,naVitrine: null == naVitrine ? _self.naVitrine : naVitrine // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
