// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detalhe_imovel_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DetalheImovelModel {

 int get id; String get titulo; String get finalidade;@JsonKey(name: 'preco_venda') String? get precoVenda;@JsonKey(name: 'preco_aluguel') String? get precoAluguel;@JsonKey(name: 'preco_condominio') String? get precoCondominio;@JsonKey(name: 'preco_iptu') String? get precoIptu; String get descricao; String get bairro; CidadeModel get cidade; String? get latitude; String? get longitude; List<FotoImovelModel> get fotos; List<String> get caracteristicas; CorretorModel? get corretor; String? get natureza;/// Um bloco por natureza; só o que bate com `natureza` é usado
/// (RESEARCH Pattern 2: o discriminador é irmão do bloco).
 CasaModel? get casa; ApartamentoModel? get apartamento; TerrenoModel? get terreno; LoteModel? get lote;
/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DetalheImovelModelCopyWith<DetalheImovelModel> get copyWith => _$DetalheImovelModelCopyWithImpl<DetalheImovelModel>(this as DetalheImovelModel, _$identity);

  /// Serializes this DetalheImovelModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DetalheImovelModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DetalheImovelModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.titulo, _this.titulo) || other.titulo == _this.titulo)&&(identical(other.finalidade, _this.finalidade) || other.finalidade == _this.finalidade)&&(identical(other.precoVenda, _this.precoVenda) || other.precoVenda == _this.precoVenda)&&(identical(other.precoAluguel, _this.precoAluguel) || other.precoAluguel == _this.precoAluguel)&&(identical(other.precoCondominio, _this.precoCondominio) || other.precoCondominio == _this.precoCondominio)&&(identical(other.precoIptu, _this.precoIptu) || other.precoIptu == _this.precoIptu)&&(identical(other.descricao, _this.descricao) || other.descricao == _this.descricao)&&(identical(other.bairro, _this.bairro) || other.bairro == _this.bairro)&&(identical(other.cidade, _this.cidade) || other.cidade == _this.cidade)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&const DeepCollectionEquality().equals(other.fotos, _this.fotos)&&const DeepCollectionEquality().equals(other.caracteristicas, _this.caracteristicas)&&(identical(other.corretor, _this.corretor) || other.corretor == _this.corretor)&&(identical(other.natureza, _this.natureza) || other.natureza == _this.natureza)&&(identical(other.casa, _this.casa) || other.casa == _this.casa)&&(identical(other.apartamento, _this.apartamento) || other.apartamento == _this.apartamento)&&(identical(other.terreno, _this.terreno) || other.terreno == _this.terreno)&&(identical(other.lote, _this.lote) || other.lote == _this.lote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DetalheImovelModel;
  return Object.hashAll([runtimeType,_this.id,_this.titulo,_this.finalidade,_this.precoVenda,_this.precoAluguel,_this.precoCondominio,_this.precoIptu,_this.descricao,_this.bairro,_this.cidade,_this.latitude,_this.longitude,const DeepCollectionEquality().hash(_this.fotos),const DeepCollectionEquality().hash(_this.caracteristicas),_this.corretor,_this.natureza,_this.casa,_this.apartamento,_this.terreno,_this.lote]);
}

@override
String toString() {
  final _this = this as DetalheImovelModel;
  return 'DetalheImovelModel(id: ${_this.id}, titulo: ${_this.titulo}, finalidade: ${_this.finalidade}, precoVenda: ${_this.precoVenda}, precoAluguel: ${_this.precoAluguel}, precoCondominio: ${_this.precoCondominio}, precoIptu: ${_this.precoIptu}, descricao: ${_this.descricao}, bairro: ${_this.bairro}, cidade: ${_this.cidade}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, fotos: ${_this.fotos}, caracteristicas: ${_this.caracteristicas}, corretor: ${_this.corretor}, natureza: ${_this.natureza}, casa: ${_this.casa}, apartamento: ${_this.apartamento}, terreno: ${_this.terreno}, lote: ${_this.lote})';
}


}

/// @nodoc
abstract mixin class $DetalheImovelModelCopyWith<$Res>  {
  factory $DetalheImovelModelCopyWith(DetalheImovelModel value, $Res Function(DetalheImovelModel) _then) = _$DetalheImovelModelCopyWithImpl;
@useResult
$Res call({
 int id, String titulo, String finalidade,@JsonKey(name: 'preco_venda') String? precoVenda,@JsonKey(name: 'preco_aluguel') String? precoAluguel,@JsonKey(name: 'preco_condominio') String? precoCondominio,@JsonKey(name: 'preco_iptu') String? precoIptu, String descricao, String bairro, CidadeModel cidade, String? latitude, String? longitude, List<FotoImovelModel> fotos, List<String> caracteristicas, CorretorModel? corretor, String? natureza, CasaModel? casa, ApartamentoModel? apartamento, TerrenoModel? terreno, LoteModel? lote
});


$CidadeModelCopyWith<$Res> get cidade;$CorretorModelCopyWith<$Res>? get corretor;$CasaModelCopyWith<$Res>? get casa;$ApartamentoModelCopyWith<$Res>? get apartamento;$TerrenoModelCopyWith<$Res>? get terreno;$LoteModelCopyWith<$Res>? get lote;

}
/// @nodoc
class _$DetalheImovelModelCopyWithImpl<$Res>
    implements $DetalheImovelModelCopyWith<$Res> {
  _$DetalheImovelModelCopyWithImpl(this._self, this._then);

  final DetalheImovelModel _self;
  final $Res Function(DetalheImovelModel) _then;

/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? titulo = null,Object? finalidade = null,Object? precoVenda = freezed,Object? precoAluguel = freezed,Object? precoCondominio = freezed,Object? precoIptu = freezed,Object? descricao = null,Object? bairro = null,Object? cidade = null,Object? latitude = freezed,Object? longitude = freezed,Object? fotos = null,Object? caracteristicas = null,Object? corretor = freezed,Object? natureza = freezed,Object? casa = freezed,Object? apartamento = freezed,Object? terreno = freezed,Object? lote = freezed,}) {
  return _then(DetalheImovelModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,finalidade: null == finalidade ? _self.finalidade : finalidade // ignore: cast_nullable_to_non_nullable
as String,precoVenda: freezed == precoVenda ? _self.precoVenda : precoVenda // ignore: cast_nullable_to_non_nullable
as String?,precoAluguel: freezed == precoAluguel ? _self.precoAluguel : precoAluguel // ignore: cast_nullable_to_non_nullable
as String?,precoCondominio: freezed == precoCondominio ? _self.precoCondominio : precoCondominio // ignore: cast_nullable_to_non_nullable
as String?,precoIptu: freezed == precoIptu ? _self.precoIptu : precoIptu // ignore: cast_nullable_to_non_nullable
as String?,descricao: null == descricao ? _self.descricao : descricao // ignore: cast_nullable_to_non_nullable
as String,bairro: null == bairro ? _self.bairro : bairro // ignore: cast_nullable_to_non_nullable
as String,cidade: null == cidade ? _self.cidade : cidade // ignore: cast_nullable_to_non_nullable
as CidadeModel,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,fotos: null == fotos ? _self.fotos : fotos // ignore: cast_nullable_to_non_nullable
as List<FotoImovelModel>,caracteristicas: null == caracteristicas ? _self.caracteristicas : caracteristicas // ignore: cast_nullable_to_non_nullable
as List<String>,corretor: freezed == corretor ? _self.corretor : corretor // ignore: cast_nullable_to_non_nullable
as CorretorModel?,natureza: freezed == natureza ? _self.natureza : natureza // ignore: cast_nullable_to_non_nullable
as String?,casa: freezed == casa ? _self.casa : casa // ignore: cast_nullable_to_non_nullable
as CasaModel?,apartamento: freezed == apartamento ? _self.apartamento : apartamento // ignore: cast_nullable_to_non_nullable
as ApartamentoModel?,terreno: freezed == terreno ? _self.terreno : terreno // ignore: cast_nullable_to_non_nullable
as TerrenoModel?,lote: freezed == lote ? _self.lote : lote // ignore: cast_nullable_to_non_nullable
as LoteModel?,
  ));
}
/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CidadeModelCopyWith<$Res> get cidade {
  
  return $CidadeModelCopyWith<$Res>(_self.cidade, (value) {
    return _then(_self.copyWith(cidade: value));
  });
}/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CorretorModelCopyWith<$Res>? get corretor {
    if (_self.corretor == null) {
    return null;
  }

  return $CorretorModelCopyWith<$Res>(_self.corretor!, (value) {
    return _then(_self.copyWith(corretor: value));
  });
}/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CasaModelCopyWith<$Res>? get casa {
    if (_self.casa == null) {
    return null;
  }

  return $CasaModelCopyWith<$Res>(_self.casa!, (value) {
    return _then(_self.copyWith(casa: value));
  });
}/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApartamentoModelCopyWith<$Res>? get apartamento {
    if (_self.apartamento == null) {
    return null;
  }

  return $ApartamentoModelCopyWith<$Res>(_self.apartamento!, (value) {
    return _then(_self.copyWith(apartamento: value));
  });
}/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TerrenoModelCopyWith<$Res>? get terreno {
    if (_self.terreno == null) {
    return null;
  }

  return $TerrenoModelCopyWith<$Res>(_self.terreno!, (value) {
    return _then(_self.copyWith(terreno: value));
  });
}/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoteModelCopyWith<$Res>? get lote {
    if (_self.lote == null) {
    return null;
  }

  return $LoteModelCopyWith<$Res>(_self.lote!, (value) {
    return _then(_self.copyWith(lote: value));
  });
}
}


/// Adds pattern-matching-related methods to [DetalheImovelModel].
extension DetalheImovelModelPatterns on DetalheImovelModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DetalheImovelModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DetalheImovelModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DetalheImovelModel value)  $default,){
final _that = this;
switch (_that) {
case _DetalheImovelModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DetalheImovelModel value)?  $default,){
final _that = this;
switch (_that) {
case _DetalheImovelModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String titulo,  String finalidade, @JsonKey(name: 'preco_venda')  String? precoVenda, @JsonKey(name: 'preco_aluguel')  String? precoAluguel, @JsonKey(name: 'preco_condominio')  String? precoCondominio, @JsonKey(name: 'preco_iptu')  String? precoIptu,  String descricao,  String bairro,  CidadeModel cidade,  String? latitude,  String? longitude,  List<FotoImovelModel> fotos,  List<String> caracteristicas,  CorretorModel? corretor,  String? natureza,  CasaModel? casa,  ApartamentoModel? apartamento,  TerrenoModel? terreno,  LoteModel? lote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DetalheImovelModel() when $default != null:
return $default(_that.id,_that.titulo,_that.finalidade,_that.precoVenda,_that.precoAluguel,_that.precoCondominio,_that.precoIptu,_that.descricao,_that.bairro,_that.cidade,_that.latitude,_that.longitude,_that.fotos,_that.caracteristicas,_that.corretor,_that.natureza,_that.casa,_that.apartamento,_that.terreno,_that.lote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String titulo,  String finalidade, @JsonKey(name: 'preco_venda')  String? precoVenda, @JsonKey(name: 'preco_aluguel')  String? precoAluguel, @JsonKey(name: 'preco_condominio')  String? precoCondominio, @JsonKey(name: 'preco_iptu')  String? precoIptu,  String descricao,  String bairro,  CidadeModel cidade,  String? latitude,  String? longitude,  List<FotoImovelModel> fotos,  List<String> caracteristicas,  CorretorModel? corretor,  String? natureza,  CasaModel? casa,  ApartamentoModel? apartamento,  TerrenoModel? terreno,  LoteModel? lote)  $default,) {final _that = this;
switch (_that) {
case _DetalheImovelModel():
return $default(_that.id,_that.titulo,_that.finalidade,_that.precoVenda,_that.precoAluguel,_that.precoCondominio,_that.precoIptu,_that.descricao,_that.bairro,_that.cidade,_that.latitude,_that.longitude,_that.fotos,_that.caracteristicas,_that.corretor,_that.natureza,_that.casa,_that.apartamento,_that.terreno,_that.lote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String titulo,  String finalidade, @JsonKey(name: 'preco_venda')  String? precoVenda, @JsonKey(name: 'preco_aluguel')  String? precoAluguel, @JsonKey(name: 'preco_condominio')  String? precoCondominio, @JsonKey(name: 'preco_iptu')  String? precoIptu,  String descricao,  String bairro,  CidadeModel cidade,  String? latitude,  String? longitude,  List<FotoImovelModel> fotos,  List<String> caracteristicas,  CorretorModel? corretor,  String? natureza,  CasaModel? casa,  ApartamentoModel? apartamento,  TerrenoModel? terreno,  LoteModel? lote)?  $default,) {final _that = this;
switch (_that) {
case _DetalheImovelModel() when $default != null:
return $default(_that.id,_that.titulo,_that.finalidade,_that.precoVenda,_that.precoAluguel,_that.precoCondominio,_that.precoIptu,_that.descricao,_that.bairro,_that.cidade,_that.latitude,_that.longitude,_that.fotos,_that.caracteristicas,_that.corretor,_that.natureza,_that.casa,_that.apartamento,_that.terreno,_that.lote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DetalheImovelModel extends DetalheImovelModel {
  const _DetalheImovelModel({required this.id, required this.titulo, required this.finalidade, @JsonKey(name: 'preco_venda') this.precoVenda, @JsonKey(name: 'preco_aluguel') this.precoAluguel, @JsonKey(name: 'preco_condominio') this.precoCondominio, @JsonKey(name: 'preco_iptu') this.precoIptu, required this.descricao, required this.bairro, required this.cidade, this.latitude, this.longitude,  List<FotoImovelModel> fotos = const <FotoImovelModel>[],  List<String> caracteristicas = const <String>[], this.corretor, this.natureza, this.casa, this.apartamento, this.terreno, this.lote}): _fotos = fotos,_caracteristicas = caracteristicas,super._();
  factory _DetalheImovelModel.fromJson(Map<String, dynamic> json) => _$DetalheImovelModelFromJson(json);

@override final  int id;
@override final  String titulo;
@override final  String finalidade;
@override@JsonKey(name: 'preco_venda') final  String? precoVenda;
@override@JsonKey(name: 'preco_aluguel') final  String? precoAluguel;
@override@JsonKey(name: 'preco_condominio') final  String? precoCondominio;
@override@JsonKey(name: 'preco_iptu') final  String? precoIptu;
@override final  String descricao;
@override final  String bairro;
@override final  CidadeModel cidade;
@override final  String? latitude;
@override final  String? longitude;
 final  List<FotoImovelModel> _fotos;
@override@JsonKey() List<FotoImovelModel> get fotos {
  if (_fotos is EqualUnmodifiableListView) return _fotos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fotos);
}

 final  List<String> _caracteristicas;
@override@JsonKey() List<String> get caracteristicas {
  if (_caracteristicas is EqualUnmodifiableListView) return _caracteristicas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_caracteristicas);
}

@override final  CorretorModel? corretor;
@override final  String? natureza;
/// Um bloco por natureza; só o que bate com `natureza` é usado
/// (RESEARCH Pattern 2: o discriminador é irmão do bloco).
@override final  CasaModel? casa;
@override final  ApartamentoModel? apartamento;
@override final  TerrenoModel? terreno;
@override final  LoteModel? lote;

/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DetalheImovelModelCopyWith<_DetalheImovelModel> get copyWith => __$DetalheImovelModelCopyWithImpl<_DetalheImovelModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DetalheImovelModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DetalheImovelModel&&(identical(other.id, id) || other.id == id)&&(identical(other.titulo, titulo) || other.titulo == titulo)&&(identical(other.finalidade, finalidade) || other.finalidade == finalidade)&&(identical(other.precoVenda, precoVenda) || other.precoVenda == precoVenda)&&(identical(other.precoAluguel, precoAluguel) || other.precoAluguel == precoAluguel)&&(identical(other.precoCondominio, precoCondominio) || other.precoCondominio == precoCondominio)&&(identical(other.precoIptu, precoIptu) || other.precoIptu == precoIptu)&&(identical(other.descricao, descricao) || other.descricao == descricao)&&(identical(other.bairro, bairro) || other.bairro == bairro)&&(identical(other.cidade, cidade) || other.cidade == cidade)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other.fotos, _fotos)&&const DeepCollectionEquality().equals(other.caracteristicas, _caracteristicas)&&(identical(other.corretor, corretor) || other.corretor == corretor)&&(identical(other.natureza, natureza) || other.natureza == natureza)&&(identical(other.casa, casa) || other.casa == casa)&&(identical(other.apartamento, apartamento) || other.apartamento == apartamento)&&(identical(other.terreno, terreno) || other.terreno == terreno)&&(identical(other.lote, lote) || other.lote == lote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,titulo,finalidade,precoVenda,precoAluguel,precoCondominio,precoIptu,descricao,bairro,cidade,latitude,longitude,const DeepCollectionEquality().hash(_fotos),const DeepCollectionEquality().hash(_caracteristicas),corretor,natureza,casa,apartamento,terreno,lote]);
}

@override
String toString() {
    return 'DetalheImovelModel(id: $id, titulo: $titulo, finalidade: $finalidade, precoVenda: $precoVenda, precoAluguel: $precoAluguel, precoCondominio: $precoCondominio, precoIptu: $precoIptu, descricao: $descricao, bairro: $bairro, cidade: $cidade, latitude: $latitude, longitude: $longitude, fotos: $fotos, caracteristicas: $caracteristicas, corretor: $corretor, natureza: $natureza, casa: $casa, apartamento: $apartamento, terreno: $terreno, lote: $lote)';
}


}

/// @nodoc
abstract mixin class _$DetalheImovelModelCopyWith<$Res> implements $DetalheImovelModelCopyWith<$Res> {
  factory _$DetalheImovelModelCopyWith(_DetalheImovelModel value, $Res Function(_DetalheImovelModel) _then) = __$DetalheImovelModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String titulo, String finalidade,@JsonKey(name: 'preco_venda') String? precoVenda,@JsonKey(name: 'preco_aluguel') String? precoAluguel,@JsonKey(name: 'preco_condominio') String? precoCondominio,@JsonKey(name: 'preco_iptu') String? precoIptu, String descricao, String bairro, CidadeModel cidade, String? latitude, String? longitude, List<FotoImovelModel> fotos, List<String> caracteristicas, CorretorModel? corretor, String? natureza, CasaModel? casa, ApartamentoModel? apartamento, TerrenoModel? terreno, LoteModel? lote
});


@override $CidadeModelCopyWith<$Res> get cidade;@override $CorretorModelCopyWith<$Res>? get corretor;@override $CasaModelCopyWith<$Res>? get casa;@override $ApartamentoModelCopyWith<$Res>? get apartamento;@override $TerrenoModelCopyWith<$Res>? get terreno;@override $LoteModelCopyWith<$Res>? get lote;

}
/// @nodoc
class __$DetalheImovelModelCopyWithImpl<$Res>
    implements _$DetalheImovelModelCopyWith<$Res> {
  __$DetalheImovelModelCopyWithImpl(this._self, this._then);

  final _DetalheImovelModel _self;
  final $Res Function(_DetalheImovelModel) _then;

/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? titulo = null,Object? finalidade = null,Object? precoVenda = freezed,Object? precoAluguel = freezed,Object? precoCondominio = freezed,Object? precoIptu = freezed,Object? descricao = null,Object? bairro = null,Object? cidade = null,Object? latitude = freezed,Object? longitude = freezed,Object? fotos = null,Object? caracteristicas = null,Object? corretor = freezed,Object? natureza = freezed,Object? casa = freezed,Object? apartamento = freezed,Object? terreno = freezed,Object? lote = freezed,}) {
  return _then(_DetalheImovelModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,finalidade: null == finalidade ? _self.finalidade : finalidade // ignore: cast_nullable_to_non_nullable
as String,precoVenda: freezed == precoVenda ? _self.precoVenda : precoVenda // ignore: cast_nullable_to_non_nullable
as String?,precoAluguel: freezed == precoAluguel ? _self.precoAluguel : precoAluguel // ignore: cast_nullable_to_non_nullable
as String?,precoCondominio: freezed == precoCondominio ? _self.precoCondominio : precoCondominio // ignore: cast_nullable_to_non_nullable
as String?,precoIptu: freezed == precoIptu ? _self.precoIptu : precoIptu // ignore: cast_nullable_to_non_nullable
as String?,descricao: null == descricao ? _self.descricao : descricao // ignore: cast_nullable_to_non_nullable
as String,bairro: null == bairro ? _self.bairro : bairro // ignore: cast_nullable_to_non_nullable
as String,cidade: null == cidade ? _self.cidade : cidade // ignore: cast_nullable_to_non_nullable
as CidadeModel,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,fotos: null == fotos ? _self._fotos : fotos // ignore: cast_nullable_to_non_nullable
as List<FotoImovelModel>,caracteristicas: null == caracteristicas ? _self._caracteristicas : caracteristicas // ignore: cast_nullable_to_non_nullable
as List<String>,corretor: freezed == corretor ? _self.corretor : corretor // ignore: cast_nullable_to_non_nullable
as CorretorModel?,natureza: freezed == natureza ? _self.natureza : natureza // ignore: cast_nullable_to_non_nullable
as String?,casa: freezed == casa ? _self.casa : casa // ignore: cast_nullable_to_non_nullable
as CasaModel?,apartamento: freezed == apartamento ? _self.apartamento : apartamento // ignore: cast_nullable_to_non_nullable
as ApartamentoModel?,terreno: freezed == terreno ? _self.terreno : terreno // ignore: cast_nullable_to_non_nullable
as TerrenoModel?,lote: freezed == lote ? _self.lote : lote // ignore: cast_nullable_to_non_nullable
as LoteModel?,
  ));
}

/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CidadeModelCopyWith<$Res> get cidade {
  
  return $CidadeModelCopyWith<$Res>(_self.cidade, (value) {
    return _then(_self.copyWith(cidade: value));
  });
}/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CorretorModelCopyWith<$Res>? get corretor {
    if (_self.corretor == null) {
    return null;
  }

  return $CorretorModelCopyWith<$Res>(_self.corretor!, (value) {
    return _then(_self.copyWith(corretor: value));
  });
}/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CasaModelCopyWith<$Res>? get casa {
    if (_self.casa == null) {
    return null;
  }

  return $CasaModelCopyWith<$Res>(_self.casa!, (value) {
    return _then(_self.copyWith(casa: value));
  });
}/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApartamentoModelCopyWith<$Res>? get apartamento {
    if (_self.apartamento == null) {
    return null;
  }

  return $ApartamentoModelCopyWith<$Res>(_self.apartamento!, (value) {
    return _then(_self.copyWith(apartamento: value));
  });
}/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TerrenoModelCopyWith<$Res>? get terreno {
    if (_self.terreno == null) {
    return null;
  }

  return $TerrenoModelCopyWith<$Res>(_self.terreno!, (value) {
    return _then(_self.copyWith(terreno: value));
  });
}/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoteModelCopyWith<$Res>? get lote {
    if (_self.lote == null) {
    return null;
  }

  return $LoteModelCopyWith<$Res>(_self.lote!, (value) {
    return _then(_self.copyWith(lote: value));
  });
}
}


/// @nodoc
mixin _$FotoImovelModel {

 String get url; bool get capa; int get ordem;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FotoImovelModel&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.capa, _this.capa) || other.capa == _this.capa)&&(identical(other.ordem, _this.ordem) || other.ordem == _this.ordem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FotoImovelModel;
  return Object.hash(runtimeType,_this.url,_this.capa,_this.ordem);
}

@override
String toString() {
  final _this = this as FotoImovelModel;
  return 'FotoImovelModel(url: ${_this.url}, capa: ${_this.capa}, ordem: ${_this.ordem})';
}


}

/// @nodoc
abstract mixin class $FotoImovelModelCopyWith<$Res>  {
  factory $FotoImovelModelCopyWith(FotoImovelModel value, $Res Function(FotoImovelModel) _then) = _$FotoImovelModelCopyWithImpl;
@useResult
$Res call({
 String url, bool capa, int ordem
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
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? capa = null,Object? ordem = null,}) {
  return _then(FotoImovelModel(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,capa: null == capa ? _self.capa : capa // ignore: cast_nullable_to_non_nullable
as bool,ordem: null == ordem ? _self.ordem : ordem // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  bool capa,  int ordem)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FotoImovelModel() when $default != null:
return $default(_that.url,_that.capa,_that.ordem);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  bool capa,  int ordem)  $default,) {final _that = this;
switch (_that) {
case _FotoImovelModel():
return $default(_that.url,_that.capa,_that.ordem);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  bool capa,  int ordem)?  $default,) {final _that = this;
switch (_that) {
case _FotoImovelModel() when $default != null:
return $default(_that.url,_that.capa,_that.ordem);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FotoImovelModel extends FotoImovelModel {
  const _FotoImovelModel({required this.url, required this.capa, required this.ordem}): super._();
  factory _FotoImovelModel.fromJson(Map<String, dynamic> json) => _$FotoImovelModelFromJson(json);

@override final  String url;
@override final  bool capa;
@override final  int ordem;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FotoImovelModel&&(identical(other.url, url) || other.url == url)&&(identical(other.capa, capa) || other.capa == capa)&&(identical(other.ordem, ordem) || other.ordem == ordem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,capa,ordem);
}

@override
String toString() {
    return 'FotoImovelModel(url: $url, capa: $capa, ordem: $ordem)';
}


}

/// @nodoc
abstract mixin class _$FotoImovelModelCopyWith<$Res> implements $FotoImovelModelCopyWith<$Res> {
  factory _$FotoImovelModelCopyWith(_FotoImovelModel value, $Res Function(_FotoImovelModel) _then) = __$FotoImovelModelCopyWithImpl;
@override @useResult
$Res call({
 String url, bool capa, int ordem
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
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? capa = null,Object? ordem = null,}) {
  return _then(_FotoImovelModel(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,capa: null == capa ? _self.capa : capa // ignore: cast_nullable_to_non_nullable
as bool,ordem: null == ordem ? _self.ordem : ordem // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CorretorModel {

 int get id; String get nome; String? get foto; String? get slug;
/// Create a copy of CorretorModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CorretorModelCopyWith<CorretorModel> get copyWith => _$CorretorModelCopyWithImpl<CorretorModel>(this as CorretorModel, _$identity);

  /// Serializes this CorretorModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CorretorModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CorretorModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nome, _this.nome) || other.nome == _this.nome)&&(identical(other.foto, _this.foto) || other.foto == _this.foto)&&(identical(other.slug, _this.slug) || other.slug == _this.slug));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CorretorModel;
  return Object.hash(runtimeType,_this.id,_this.nome,_this.foto,_this.slug);
}

@override
String toString() {
  final _this = this as CorretorModel;
  return 'CorretorModel(id: ${_this.id}, nome: ${_this.nome}, foto: ${_this.foto}, slug: ${_this.slug})';
}


}

/// @nodoc
abstract mixin class $CorretorModelCopyWith<$Res>  {
  factory $CorretorModelCopyWith(CorretorModel value, $Res Function(CorretorModel) _then) = _$CorretorModelCopyWithImpl;
@useResult
$Res call({
 int id, String nome, String? foto, String? slug
});




}
/// @nodoc
class _$CorretorModelCopyWithImpl<$Res>
    implements $CorretorModelCopyWith<$Res> {
  _$CorretorModelCopyWithImpl(this._self, this._then);

  final CorretorModel _self;
  final $Res Function(CorretorModel) _then;

/// Create a copy of CorretorModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nome = null,Object? foto = freezed,Object? slug = freezed,}) {
  return _then(CorretorModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,foto: freezed == foto ? _self.foto : foto // ignore: cast_nullable_to_non_nullable
as String?,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CorretorModel].
extension CorretorModelPatterns on CorretorModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CorretorModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CorretorModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CorretorModel value)  $default,){
final _that = this;
switch (_that) {
case _CorretorModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CorretorModel value)?  $default,){
final _that = this;
switch (_that) {
case _CorretorModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String nome,  String? foto,  String? slug)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CorretorModel() when $default != null:
return $default(_that.id,_that.nome,_that.foto,_that.slug);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String nome,  String? foto,  String? slug)  $default,) {final _that = this;
switch (_that) {
case _CorretorModel():
return $default(_that.id,_that.nome,_that.foto,_that.slug);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String nome,  String? foto,  String? slug)?  $default,) {final _that = this;
switch (_that) {
case _CorretorModel() when $default != null:
return $default(_that.id,_that.nome,_that.foto,_that.slug);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CorretorModel extends CorretorModel {
  const _CorretorModel({required this.id, required this.nome, this.foto, this.slug}): super._();
  factory _CorretorModel.fromJson(Map<String, dynamic> json) => _$CorretorModelFromJson(json);

@override final  int id;
@override final  String nome;
@override final  String? foto;
@override final  String? slug;

/// Create a copy of CorretorModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CorretorModelCopyWith<_CorretorModel> get copyWith => __$CorretorModelCopyWithImpl<_CorretorModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CorretorModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CorretorModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.foto, foto) || other.foto == foto)&&(identical(other.slug, slug) || other.slug == slug));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,nome,foto,slug);
}

@override
String toString() {
    return 'CorretorModel(id: $id, nome: $nome, foto: $foto, slug: $slug)';
}


}

/// @nodoc
abstract mixin class _$CorretorModelCopyWith<$Res> implements $CorretorModelCopyWith<$Res> {
  factory _$CorretorModelCopyWith(_CorretorModel value, $Res Function(_CorretorModel) _then) = __$CorretorModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String nome, String? foto, String? slug
});




}
/// @nodoc
class __$CorretorModelCopyWithImpl<$Res>
    implements _$CorretorModelCopyWith<$Res> {
  __$CorretorModelCopyWithImpl(this._self, this._then);

  final _CorretorModel _self;
  final $Res Function(_CorretorModel) _then;

/// Create a copy of CorretorModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nome = null,Object? foto = freezed,Object? slug = freezed,}) {
  return _then(_CorretorModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,foto: freezed == foto ? _self.foto : foto // ignore: cast_nullable_to_non_nullable
as String?,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
