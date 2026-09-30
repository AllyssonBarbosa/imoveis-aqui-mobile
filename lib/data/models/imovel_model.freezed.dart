// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'imovel_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImovelModel {

 int get id; String get titulo; String get finalidade;@JsonKey(name: 'preco_venda') String? get precoVenda;@JsonKey(name: 'preco_aluguel') String? get precoAluguel; String get descricao; String get bairro; CidadeModel get cidade;@JsonKey(name: 'foto_capa') String? get fotoCapa; List<String> get caracteristicas;@JsonKey(name: 'criado_em') String get criadoEm; String? get natureza; int? get quartos; int? get suites; int? get vagas; String? get area;
/// Create a copy of ImovelModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImovelModelCopyWith<ImovelModel> get copyWith => _$ImovelModelCopyWithImpl<ImovelModel>(this as ImovelModel, _$identity);

  /// Serializes this ImovelModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ImovelModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImovelModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.titulo, _this.titulo) || other.titulo == _this.titulo)&&(identical(other.finalidade, _this.finalidade) || other.finalidade == _this.finalidade)&&(identical(other.precoVenda, _this.precoVenda) || other.precoVenda == _this.precoVenda)&&(identical(other.precoAluguel, _this.precoAluguel) || other.precoAluguel == _this.precoAluguel)&&(identical(other.descricao, _this.descricao) || other.descricao == _this.descricao)&&(identical(other.bairro, _this.bairro) || other.bairro == _this.bairro)&&(identical(other.cidade, _this.cidade) || other.cidade == _this.cidade)&&(identical(other.fotoCapa, _this.fotoCapa) || other.fotoCapa == _this.fotoCapa)&&const DeepCollectionEquality().equals(other.caracteristicas, _this.caracteristicas)&&(identical(other.criadoEm, _this.criadoEm) || other.criadoEm == _this.criadoEm)&&(identical(other.natureza, _this.natureza) || other.natureza == _this.natureza)&&(identical(other.quartos, _this.quartos) || other.quartos == _this.quartos)&&(identical(other.suites, _this.suites) || other.suites == _this.suites)&&(identical(other.vagas, _this.vagas) || other.vagas == _this.vagas)&&(identical(other.area, _this.area) || other.area == _this.area));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ImovelModel;
  return Object.hash(runtimeType,_this.id,_this.titulo,_this.finalidade,_this.precoVenda,_this.precoAluguel,_this.descricao,_this.bairro,_this.cidade,_this.fotoCapa,const DeepCollectionEquality().hash(_this.caracteristicas),_this.criadoEm,_this.natureza,_this.quartos,_this.suites,_this.vagas,_this.area);
}

@override
String toString() {
  final _this = this as ImovelModel;
  return 'ImovelModel(id: ${_this.id}, titulo: ${_this.titulo}, finalidade: ${_this.finalidade}, precoVenda: ${_this.precoVenda}, precoAluguel: ${_this.precoAluguel}, descricao: ${_this.descricao}, bairro: ${_this.bairro}, cidade: ${_this.cidade}, fotoCapa: ${_this.fotoCapa}, caracteristicas: ${_this.caracteristicas}, criadoEm: ${_this.criadoEm}, natureza: ${_this.natureza}, quartos: ${_this.quartos}, suites: ${_this.suites}, vagas: ${_this.vagas}, area: ${_this.area})';
}


}

/// @nodoc
abstract mixin class $ImovelModelCopyWith<$Res>  {
  factory $ImovelModelCopyWith(ImovelModel value, $Res Function(ImovelModel) _then) = _$ImovelModelCopyWithImpl;
@useResult
$Res call({
 int id, String titulo, String finalidade,@JsonKey(name: 'preco_venda') String? precoVenda,@JsonKey(name: 'preco_aluguel') String? precoAluguel, String descricao, String bairro, CidadeModel cidade,@JsonKey(name: 'foto_capa') String? fotoCapa, List<String> caracteristicas,@JsonKey(name: 'criado_em') String criadoEm, String? natureza, int? quartos, int? suites, int? vagas, String? area
});


$CidadeModelCopyWith<$Res> get cidade;

}
/// @nodoc
class _$ImovelModelCopyWithImpl<$Res>
    implements $ImovelModelCopyWith<$Res> {
  _$ImovelModelCopyWithImpl(this._self, this._then);

  final ImovelModel _self;
  final $Res Function(ImovelModel) _then;

/// Create a copy of ImovelModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? titulo = null,Object? finalidade = null,Object? precoVenda = freezed,Object? precoAluguel = freezed,Object? descricao = null,Object? bairro = null,Object? cidade = null,Object? fotoCapa = freezed,Object? caracteristicas = null,Object? criadoEm = null,Object? natureza = freezed,Object? quartos = freezed,Object? suites = freezed,Object? vagas = freezed,Object? area = freezed,}) {
  return _then(ImovelModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,finalidade: null == finalidade ? _self.finalidade : finalidade // ignore: cast_nullable_to_non_nullable
as String,precoVenda: freezed == precoVenda ? _self.precoVenda : precoVenda // ignore: cast_nullable_to_non_nullable
as String?,precoAluguel: freezed == precoAluguel ? _self.precoAluguel : precoAluguel // ignore: cast_nullable_to_non_nullable
as String?,descricao: null == descricao ? _self.descricao : descricao // ignore: cast_nullable_to_non_nullable
as String,bairro: null == bairro ? _self.bairro : bairro // ignore: cast_nullable_to_non_nullable
as String,cidade: null == cidade ? _self.cidade : cidade // ignore: cast_nullable_to_non_nullable
as CidadeModel,fotoCapa: freezed == fotoCapa ? _self.fotoCapa : fotoCapa // ignore: cast_nullable_to_non_nullable
as String?,caracteristicas: null == caracteristicas ? _self.caracteristicas : caracteristicas // ignore: cast_nullable_to_non_nullable
as List<String>,criadoEm: null == criadoEm ? _self.criadoEm : criadoEm // ignore: cast_nullable_to_non_nullable
as String,natureza: freezed == natureza ? _self.natureza : natureza // ignore: cast_nullable_to_non_nullable
as String?,quartos: freezed == quartos ? _self.quartos : quartos // ignore: cast_nullable_to_non_nullable
as int?,suites: freezed == suites ? _self.suites : suites // ignore: cast_nullable_to_non_nullable
as int?,vagas: freezed == vagas ? _self.vagas : vagas // ignore: cast_nullable_to_non_nullable
as int?,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ImovelModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CidadeModelCopyWith<$Res> get cidade {
  
  return $CidadeModelCopyWith<$Res>(_self.cidade, (value) {
    return _then(_self.copyWith(cidade: value));
  });
}
}


/// Adds pattern-matching-related methods to [ImovelModel].
extension ImovelModelPatterns on ImovelModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImovelModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImovelModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImovelModel value)  $default,){
final _that = this;
switch (_that) {
case _ImovelModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImovelModel value)?  $default,){
final _that = this;
switch (_that) {
case _ImovelModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String titulo,  String finalidade, @JsonKey(name: 'preco_venda')  String? precoVenda, @JsonKey(name: 'preco_aluguel')  String? precoAluguel,  String descricao,  String bairro,  CidadeModel cidade, @JsonKey(name: 'foto_capa')  String? fotoCapa,  List<String> caracteristicas, @JsonKey(name: 'criado_em')  String criadoEm,  String? natureza,  int? quartos,  int? suites,  int? vagas,  String? area)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImovelModel() when $default != null:
return $default(_that.id,_that.titulo,_that.finalidade,_that.precoVenda,_that.precoAluguel,_that.descricao,_that.bairro,_that.cidade,_that.fotoCapa,_that.caracteristicas,_that.criadoEm,_that.natureza,_that.quartos,_that.suites,_that.vagas,_that.area);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String titulo,  String finalidade, @JsonKey(name: 'preco_venda')  String? precoVenda, @JsonKey(name: 'preco_aluguel')  String? precoAluguel,  String descricao,  String bairro,  CidadeModel cidade, @JsonKey(name: 'foto_capa')  String? fotoCapa,  List<String> caracteristicas, @JsonKey(name: 'criado_em')  String criadoEm,  String? natureza,  int? quartos,  int? suites,  int? vagas,  String? area)  $default,) {final _that = this;
switch (_that) {
case _ImovelModel():
return $default(_that.id,_that.titulo,_that.finalidade,_that.precoVenda,_that.precoAluguel,_that.descricao,_that.bairro,_that.cidade,_that.fotoCapa,_that.caracteristicas,_that.criadoEm,_that.natureza,_that.quartos,_that.suites,_that.vagas,_that.area);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String titulo,  String finalidade, @JsonKey(name: 'preco_venda')  String? precoVenda, @JsonKey(name: 'preco_aluguel')  String? precoAluguel,  String descricao,  String bairro,  CidadeModel cidade, @JsonKey(name: 'foto_capa')  String? fotoCapa,  List<String> caracteristicas, @JsonKey(name: 'criado_em')  String criadoEm,  String? natureza,  int? quartos,  int? suites,  int? vagas,  String? area)?  $default,) {final _that = this;
switch (_that) {
case _ImovelModel() when $default != null:
return $default(_that.id,_that.titulo,_that.finalidade,_that.precoVenda,_that.precoAluguel,_that.descricao,_that.bairro,_that.cidade,_that.fotoCapa,_that.caracteristicas,_that.criadoEm,_that.natureza,_that.quartos,_that.suites,_that.vagas,_that.area);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImovelModel extends ImovelModel {
  const _ImovelModel({required this.id, required this.titulo, required this.finalidade, @JsonKey(name: 'preco_venda') this.precoVenda, @JsonKey(name: 'preco_aluguel') this.precoAluguel, required this.descricao, required this.bairro, required this.cidade, @JsonKey(name: 'foto_capa') this.fotoCapa, required  List<String> caracteristicas, @JsonKey(name: 'criado_em') required this.criadoEm, this.natureza, this.quartos, this.suites, this.vagas, this.area}): _caracteristicas = caracteristicas,super._();
  factory _ImovelModel.fromJson(Map<String, dynamic> json) => _$ImovelModelFromJson(json);

@override final  int id;
@override final  String titulo;
@override final  String finalidade;
@override@JsonKey(name: 'preco_venda') final  String? precoVenda;
@override@JsonKey(name: 'preco_aluguel') final  String? precoAluguel;
@override final  String descricao;
@override final  String bairro;
@override final  CidadeModel cidade;
@override@JsonKey(name: 'foto_capa') final  String? fotoCapa;
 final  List<String> _caracteristicas;
@override List<String> get caracteristicas {
  if (_caracteristicas is EqualUnmodifiableListView) return _caracteristicas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_caracteristicas);
}

@override@JsonKey(name: 'criado_em') final  String criadoEm;
@override final  String? natureza;
@override final  int? quartos;
@override final  int? suites;
@override final  int? vagas;
@override final  String? area;

/// Create a copy of ImovelModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImovelModelCopyWith<_ImovelModel> get copyWith => __$ImovelModelCopyWithImpl<_ImovelModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImovelModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImovelModel&&(identical(other.id, id) || other.id == id)&&(identical(other.titulo, titulo) || other.titulo == titulo)&&(identical(other.finalidade, finalidade) || other.finalidade == finalidade)&&(identical(other.precoVenda, precoVenda) || other.precoVenda == precoVenda)&&(identical(other.precoAluguel, precoAluguel) || other.precoAluguel == precoAluguel)&&(identical(other.descricao, descricao) || other.descricao == descricao)&&(identical(other.bairro, bairro) || other.bairro == bairro)&&(identical(other.cidade, cidade) || other.cidade == cidade)&&(identical(other.fotoCapa, fotoCapa) || other.fotoCapa == fotoCapa)&&const DeepCollectionEquality().equals(other.caracteristicas, _caracteristicas)&&(identical(other.criadoEm, criadoEm) || other.criadoEm == criadoEm)&&(identical(other.natureza, natureza) || other.natureza == natureza)&&(identical(other.quartos, quartos) || other.quartos == quartos)&&(identical(other.suites, suites) || other.suites == suites)&&(identical(other.vagas, vagas) || other.vagas == vagas)&&(identical(other.area, area) || other.area == area));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,titulo,finalidade,precoVenda,precoAluguel,descricao,bairro,cidade,fotoCapa,const DeepCollectionEquality().hash(_caracteristicas),criadoEm,natureza,quartos,suites,vagas,area);
}

@override
String toString() {
    return 'ImovelModel(id: $id, titulo: $titulo, finalidade: $finalidade, precoVenda: $precoVenda, precoAluguel: $precoAluguel, descricao: $descricao, bairro: $bairro, cidade: $cidade, fotoCapa: $fotoCapa, caracteristicas: $caracteristicas, criadoEm: $criadoEm, natureza: $natureza, quartos: $quartos, suites: $suites, vagas: $vagas, area: $area)';
}


}

/// @nodoc
abstract mixin class _$ImovelModelCopyWith<$Res> implements $ImovelModelCopyWith<$Res> {
  factory _$ImovelModelCopyWith(_ImovelModel value, $Res Function(_ImovelModel) _then) = __$ImovelModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String titulo, String finalidade,@JsonKey(name: 'preco_venda') String? precoVenda,@JsonKey(name: 'preco_aluguel') String? precoAluguel, String descricao, String bairro, CidadeModel cidade,@JsonKey(name: 'foto_capa') String? fotoCapa, List<String> caracteristicas,@JsonKey(name: 'criado_em') String criadoEm, String? natureza, int? quartos, int? suites, int? vagas, String? area
});


@override $CidadeModelCopyWith<$Res> get cidade;

}
/// @nodoc
class __$ImovelModelCopyWithImpl<$Res>
    implements _$ImovelModelCopyWith<$Res> {
  __$ImovelModelCopyWithImpl(this._self, this._then);

  final _ImovelModel _self;
  final $Res Function(_ImovelModel) _then;

/// Create a copy of ImovelModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? titulo = null,Object? finalidade = null,Object? precoVenda = freezed,Object? precoAluguel = freezed,Object? descricao = null,Object? bairro = null,Object? cidade = null,Object? fotoCapa = freezed,Object? caracteristicas = null,Object? criadoEm = null,Object? natureza = freezed,Object? quartos = freezed,Object? suites = freezed,Object? vagas = freezed,Object? area = freezed,}) {
  return _then(_ImovelModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,finalidade: null == finalidade ? _self.finalidade : finalidade // ignore: cast_nullable_to_non_nullable
as String,precoVenda: freezed == precoVenda ? _self.precoVenda : precoVenda // ignore: cast_nullable_to_non_nullable
as String?,precoAluguel: freezed == precoAluguel ? _self.precoAluguel : precoAluguel // ignore: cast_nullable_to_non_nullable
as String?,descricao: null == descricao ? _self.descricao : descricao // ignore: cast_nullable_to_non_nullable
as String,bairro: null == bairro ? _self.bairro : bairro // ignore: cast_nullable_to_non_nullable
as String,cidade: null == cidade ? _self.cidade : cidade // ignore: cast_nullable_to_non_nullable
as CidadeModel,fotoCapa: freezed == fotoCapa ? _self.fotoCapa : fotoCapa // ignore: cast_nullable_to_non_nullable
as String?,caracteristicas: null == caracteristicas ? _self._caracteristicas : caracteristicas // ignore: cast_nullable_to_non_nullable
as List<String>,criadoEm: null == criadoEm ? _self.criadoEm : criadoEm // ignore: cast_nullable_to_non_nullable
as String,natureza: freezed == natureza ? _self.natureza : natureza // ignore: cast_nullable_to_non_nullable
as String?,quartos: freezed == quartos ? _self.quartos : quartos // ignore: cast_nullable_to_non_nullable
as int?,suites: freezed == suites ? _self.suites : suites // ignore: cast_nullable_to_non_nullable
as int?,vagas: freezed == vagas ? _self.vagas : vagas // ignore: cast_nullable_to_non_nullable
as int?,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ImovelModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CidadeModelCopyWith<$Res> get cidade {
  
  return $CidadeModelCopyWith<$Res>(_self.cidade, (value) {
    return _then(_self.copyWith(cidade: value));
  });
}
}

// dart format on
