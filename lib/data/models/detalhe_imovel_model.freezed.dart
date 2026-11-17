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

 int get id; String get titulo; String get finalidade;@JsonKey(name: 'preco_venda') String? get precoVenda;@JsonKey(name: 'preco_aluguel') String? get precoAluguel;@JsonKey(name: 'preco_condominio') String? get precoCondominio;@JsonKey(name: 'preco_iptu') String? get precoIptu; String get descricao;/// Pode vir `null` (imóvel sem endereço cadastrado): tolerado.
 EnderecoPublicoModel? get endereco; List<FotoImovelModel> get fotos; List<CaracteristicaModel> get caracteristicas;@JsonKey(name: 'corretor_responsavel') CorretorModel? get corretor; String? get natureza;/// Um bloco por natureza; só o que bate com `natureza` é usado
/// (RESEARCH Pattern 2: o discriminador é irmão do bloco).
 CasaModel? get casa; ApartamentoModel? get apartamento; TerrenoModel? get terreno; LoteModel? get lote;/// Só os nomes dos canais, na ordem do servidor; nomes desconhecidos são
/// descartados na `paraEntidade()` (D-01, D-03).
@JsonKey(name: 'canais_contato') List<String> get canaisContato;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DetalheImovelModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.titulo, _this.titulo) || other.titulo == _this.titulo)&&(identical(other.finalidade, _this.finalidade) || other.finalidade == _this.finalidade)&&(identical(other.precoVenda, _this.precoVenda) || other.precoVenda == _this.precoVenda)&&(identical(other.precoAluguel, _this.precoAluguel) || other.precoAluguel == _this.precoAluguel)&&(identical(other.precoCondominio, _this.precoCondominio) || other.precoCondominio == _this.precoCondominio)&&(identical(other.precoIptu, _this.precoIptu) || other.precoIptu == _this.precoIptu)&&(identical(other.descricao, _this.descricao) || other.descricao == _this.descricao)&&(identical(other.endereco, _this.endereco) || other.endereco == _this.endereco)&&const DeepCollectionEquality().equals(other.fotos, _this.fotos)&&const DeepCollectionEquality().equals(other.caracteristicas, _this.caracteristicas)&&(identical(other.corretor, _this.corretor) || other.corretor == _this.corretor)&&(identical(other.natureza, _this.natureza) || other.natureza == _this.natureza)&&(identical(other.casa, _this.casa) || other.casa == _this.casa)&&(identical(other.apartamento, _this.apartamento) || other.apartamento == _this.apartamento)&&(identical(other.terreno, _this.terreno) || other.terreno == _this.terreno)&&(identical(other.lote, _this.lote) || other.lote == _this.lote)&&const DeepCollectionEquality().equals(other.canaisContato, _this.canaisContato));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DetalheImovelModel;
  return Object.hash(runtimeType,_this.id,_this.titulo,_this.finalidade,_this.precoVenda,_this.precoAluguel,_this.precoCondominio,_this.precoIptu,_this.descricao,_this.endereco,const DeepCollectionEquality().hash(_this.fotos),const DeepCollectionEquality().hash(_this.caracteristicas),_this.corretor,_this.natureza,_this.casa,_this.apartamento,_this.terreno,_this.lote,const DeepCollectionEquality().hash(_this.canaisContato));
}

@override
String toString() {
  final _this = this as DetalheImovelModel;
  return 'DetalheImovelModel(id: ${_this.id}, titulo: ${_this.titulo}, finalidade: ${_this.finalidade}, precoVenda: ${_this.precoVenda}, precoAluguel: ${_this.precoAluguel}, precoCondominio: ${_this.precoCondominio}, precoIptu: ${_this.precoIptu}, descricao: ${_this.descricao}, endereco: ${_this.endereco}, fotos: ${_this.fotos}, caracteristicas: ${_this.caracteristicas}, corretor: ${_this.corretor}, natureza: ${_this.natureza}, casa: ${_this.casa}, apartamento: ${_this.apartamento}, terreno: ${_this.terreno}, lote: ${_this.lote}, canaisContato: ${_this.canaisContato})';
}


}

/// @nodoc
abstract mixin class $DetalheImovelModelCopyWith<$Res>  {
  factory $DetalheImovelModelCopyWith(DetalheImovelModel value, $Res Function(DetalheImovelModel) _then) = _$DetalheImovelModelCopyWithImpl;
@useResult
$Res call({
 int id, String titulo, String finalidade,@JsonKey(name: 'preco_venda') String? precoVenda,@JsonKey(name: 'preco_aluguel') String? precoAluguel,@JsonKey(name: 'preco_condominio') String? precoCondominio,@JsonKey(name: 'preco_iptu') String? precoIptu, String descricao, EnderecoPublicoModel? endereco, List<FotoImovelModel> fotos, List<CaracteristicaModel> caracteristicas,@JsonKey(name: 'corretor_responsavel') CorretorModel? corretor, String? natureza, CasaModel? casa, ApartamentoModel? apartamento, TerrenoModel? terreno, LoteModel? lote,@JsonKey(name: 'canais_contato') List<String> canaisContato
});


$EnderecoPublicoModelCopyWith<$Res>? get endereco;$CorretorModelCopyWith<$Res>? get corretor;$CasaModelCopyWith<$Res>? get casa;$ApartamentoModelCopyWith<$Res>? get apartamento;$TerrenoModelCopyWith<$Res>? get terreno;$LoteModelCopyWith<$Res>? get lote;

}
/// @nodoc
class _$DetalheImovelModelCopyWithImpl<$Res>
    implements $DetalheImovelModelCopyWith<$Res> {
  _$DetalheImovelModelCopyWithImpl(this._self, this._then);

  final DetalheImovelModel _self;
  final $Res Function(DetalheImovelModel) _then;

/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? titulo = null,Object? finalidade = null,Object? precoVenda = freezed,Object? precoAluguel = freezed,Object? precoCondominio = freezed,Object? precoIptu = freezed,Object? descricao = null,Object? endereco = freezed,Object? fotos = null,Object? caracteristicas = null,Object? corretor = freezed,Object? natureza = freezed,Object? casa = freezed,Object? apartamento = freezed,Object? terreno = freezed,Object? lote = freezed,Object? canaisContato = null,}) {
  return _then(DetalheImovelModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,finalidade: null == finalidade ? _self.finalidade : finalidade // ignore: cast_nullable_to_non_nullable
as String,precoVenda: freezed == precoVenda ? _self.precoVenda : precoVenda // ignore: cast_nullable_to_non_nullable
as String?,precoAluguel: freezed == precoAluguel ? _self.precoAluguel : precoAluguel // ignore: cast_nullable_to_non_nullable
as String?,precoCondominio: freezed == precoCondominio ? _self.precoCondominio : precoCondominio // ignore: cast_nullable_to_non_nullable
as String?,precoIptu: freezed == precoIptu ? _self.precoIptu : precoIptu // ignore: cast_nullable_to_non_nullable
as String?,descricao: null == descricao ? _self.descricao : descricao // ignore: cast_nullable_to_non_nullable
as String,endereco: freezed == endereco ? _self.endereco : endereco // ignore: cast_nullable_to_non_nullable
as EnderecoPublicoModel?,fotos: null == fotos ? _self.fotos : fotos // ignore: cast_nullable_to_non_nullable
as List<FotoImovelModel>,caracteristicas: null == caracteristicas ? _self.caracteristicas : caracteristicas // ignore: cast_nullable_to_non_nullable
as List<CaracteristicaModel>,corretor: freezed == corretor ? _self.corretor : corretor // ignore: cast_nullable_to_non_nullable
as CorretorModel?,natureza: freezed == natureza ? _self.natureza : natureza // ignore: cast_nullable_to_non_nullable
as String?,casa: freezed == casa ? _self.casa : casa // ignore: cast_nullable_to_non_nullable
as CasaModel?,apartamento: freezed == apartamento ? _self.apartamento : apartamento // ignore: cast_nullable_to_non_nullable
as ApartamentoModel?,terreno: freezed == terreno ? _self.terreno : terreno // ignore: cast_nullable_to_non_nullable
as TerrenoModel?,lote: freezed == lote ? _self.lote : lote // ignore: cast_nullable_to_non_nullable
as LoteModel?,canaisContato: null == canaisContato ? _self.canaisContato : canaisContato // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnderecoPublicoModelCopyWith<$Res>? get endereco {
    if (_self.endereco == null) {
    return null;
  }

  return $EnderecoPublicoModelCopyWith<$Res>(_self.endereco!, (value) {
    return _then(_self.copyWith(endereco: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String titulo,  String finalidade, @JsonKey(name: 'preco_venda')  String? precoVenda, @JsonKey(name: 'preco_aluguel')  String? precoAluguel, @JsonKey(name: 'preco_condominio')  String? precoCondominio, @JsonKey(name: 'preco_iptu')  String? precoIptu,  String descricao,  EnderecoPublicoModel? endereco,  List<FotoImovelModel> fotos,  List<CaracteristicaModel> caracteristicas, @JsonKey(name: 'corretor_responsavel')  CorretorModel? corretor,  String? natureza,  CasaModel? casa,  ApartamentoModel? apartamento,  TerrenoModel? terreno,  LoteModel? lote, @JsonKey(name: 'canais_contato')  List<String> canaisContato)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DetalheImovelModel() when $default != null:
return $default(_that.id,_that.titulo,_that.finalidade,_that.precoVenda,_that.precoAluguel,_that.precoCondominio,_that.precoIptu,_that.descricao,_that.endereco,_that.fotos,_that.caracteristicas,_that.corretor,_that.natureza,_that.casa,_that.apartamento,_that.terreno,_that.lote,_that.canaisContato);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String titulo,  String finalidade, @JsonKey(name: 'preco_venda')  String? precoVenda, @JsonKey(name: 'preco_aluguel')  String? precoAluguel, @JsonKey(name: 'preco_condominio')  String? precoCondominio, @JsonKey(name: 'preco_iptu')  String? precoIptu,  String descricao,  EnderecoPublicoModel? endereco,  List<FotoImovelModel> fotos,  List<CaracteristicaModel> caracteristicas, @JsonKey(name: 'corretor_responsavel')  CorretorModel? corretor,  String? natureza,  CasaModel? casa,  ApartamentoModel? apartamento,  TerrenoModel? terreno,  LoteModel? lote, @JsonKey(name: 'canais_contato')  List<String> canaisContato)  $default,) {final _that = this;
switch (_that) {
case _DetalheImovelModel():
return $default(_that.id,_that.titulo,_that.finalidade,_that.precoVenda,_that.precoAluguel,_that.precoCondominio,_that.precoIptu,_that.descricao,_that.endereco,_that.fotos,_that.caracteristicas,_that.corretor,_that.natureza,_that.casa,_that.apartamento,_that.terreno,_that.lote,_that.canaisContato);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String titulo,  String finalidade, @JsonKey(name: 'preco_venda')  String? precoVenda, @JsonKey(name: 'preco_aluguel')  String? precoAluguel, @JsonKey(name: 'preco_condominio')  String? precoCondominio, @JsonKey(name: 'preco_iptu')  String? precoIptu,  String descricao,  EnderecoPublicoModel? endereco,  List<FotoImovelModel> fotos,  List<CaracteristicaModel> caracteristicas, @JsonKey(name: 'corretor_responsavel')  CorretorModel? corretor,  String? natureza,  CasaModel? casa,  ApartamentoModel? apartamento,  TerrenoModel? terreno,  LoteModel? lote, @JsonKey(name: 'canais_contato')  List<String> canaisContato)?  $default,) {final _that = this;
switch (_that) {
case _DetalheImovelModel() when $default != null:
return $default(_that.id,_that.titulo,_that.finalidade,_that.precoVenda,_that.precoAluguel,_that.precoCondominio,_that.precoIptu,_that.descricao,_that.endereco,_that.fotos,_that.caracteristicas,_that.corretor,_that.natureza,_that.casa,_that.apartamento,_that.terreno,_that.lote,_that.canaisContato);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DetalheImovelModel extends DetalheImovelModel {
  const _DetalheImovelModel({required this.id, required this.titulo, required this.finalidade, @JsonKey(name: 'preco_venda') this.precoVenda, @JsonKey(name: 'preco_aluguel') this.precoAluguel, @JsonKey(name: 'preco_condominio') this.precoCondominio, @JsonKey(name: 'preco_iptu') this.precoIptu, required this.descricao, this.endereco,  List<FotoImovelModel> fotos = const <FotoImovelModel>[],  List<CaracteristicaModel> caracteristicas = const <CaracteristicaModel>[], @JsonKey(name: 'corretor_responsavel') this.corretor, this.natureza, this.casa, this.apartamento, this.terreno, this.lote, @JsonKey(name: 'canais_contato')  List<String> canaisContato = const <String>[]}): _fotos = fotos,_caracteristicas = caracteristicas,_canaisContato = canaisContato,super._();
  factory _DetalheImovelModel.fromJson(Map<String, dynamic> json) => _$DetalheImovelModelFromJson(json);

@override final  int id;
@override final  String titulo;
@override final  String finalidade;
@override@JsonKey(name: 'preco_venda') final  String? precoVenda;
@override@JsonKey(name: 'preco_aluguel') final  String? precoAluguel;
@override@JsonKey(name: 'preco_condominio') final  String? precoCondominio;
@override@JsonKey(name: 'preco_iptu') final  String? precoIptu;
@override final  String descricao;
/// Pode vir `null` (imóvel sem endereço cadastrado): tolerado.
@override final  EnderecoPublicoModel? endereco;
 final  List<FotoImovelModel> _fotos;
@override@JsonKey() List<FotoImovelModel> get fotos {
  if (_fotos is EqualUnmodifiableListView) return _fotos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fotos);
}

 final  List<CaracteristicaModel> _caracteristicas;
@override@JsonKey() List<CaracteristicaModel> get caracteristicas {
  if (_caracteristicas is EqualUnmodifiableListView) return _caracteristicas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_caracteristicas);
}

@override@JsonKey(name: 'corretor_responsavel') final  CorretorModel? corretor;
@override final  String? natureza;
/// Um bloco por natureza; só o que bate com `natureza` é usado
/// (RESEARCH Pattern 2: o discriminador é irmão do bloco).
@override final  CasaModel? casa;
@override final  ApartamentoModel? apartamento;
@override final  TerrenoModel? terreno;
@override final  LoteModel? lote;
/// Só os nomes dos canais, na ordem do servidor; nomes desconhecidos são
/// descartados na `paraEntidade()` (D-01, D-03).
 final  List<String> _canaisContato;
/// Só os nomes dos canais, na ordem do servidor; nomes desconhecidos são
/// descartados na `paraEntidade()` (D-01, D-03).
@override@JsonKey(name: 'canais_contato') List<String> get canaisContato {
  if (_canaisContato is EqualUnmodifiableListView) return _canaisContato;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_canaisContato);
}


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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DetalheImovelModel&&(identical(other.id, id) || other.id == id)&&(identical(other.titulo, titulo) || other.titulo == titulo)&&(identical(other.finalidade, finalidade) || other.finalidade == finalidade)&&(identical(other.precoVenda, precoVenda) || other.precoVenda == precoVenda)&&(identical(other.precoAluguel, precoAluguel) || other.precoAluguel == precoAluguel)&&(identical(other.precoCondominio, precoCondominio) || other.precoCondominio == precoCondominio)&&(identical(other.precoIptu, precoIptu) || other.precoIptu == precoIptu)&&(identical(other.descricao, descricao) || other.descricao == descricao)&&(identical(other.endereco, endereco) || other.endereco == endereco)&&const DeepCollectionEquality().equals(other.fotos, _fotos)&&const DeepCollectionEquality().equals(other.caracteristicas, _caracteristicas)&&(identical(other.corretor, corretor) || other.corretor == corretor)&&(identical(other.natureza, natureza) || other.natureza == natureza)&&(identical(other.casa, casa) || other.casa == casa)&&(identical(other.apartamento, apartamento) || other.apartamento == apartamento)&&(identical(other.terreno, terreno) || other.terreno == terreno)&&(identical(other.lote, lote) || other.lote == lote)&&const DeepCollectionEquality().equals(other.canaisContato, _canaisContato));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,titulo,finalidade,precoVenda,precoAluguel,precoCondominio,precoIptu,descricao,endereco,const DeepCollectionEquality().hash(_fotos),const DeepCollectionEquality().hash(_caracteristicas),corretor,natureza,casa,apartamento,terreno,lote,const DeepCollectionEquality().hash(_canaisContato));
}

@override
String toString() {
    return 'DetalheImovelModel(id: $id, titulo: $titulo, finalidade: $finalidade, precoVenda: $precoVenda, precoAluguel: $precoAluguel, precoCondominio: $precoCondominio, precoIptu: $precoIptu, descricao: $descricao, endereco: $endereco, fotos: $fotos, caracteristicas: $caracteristicas, corretor: $corretor, natureza: $natureza, casa: $casa, apartamento: $apartamento, terreno: $terreno, lote: $lote, canaisContato: $canaisContato)';
}


}

/// @nodoc
abstract mixin class _$DetalheImovelModelCopyWith<$Res> implements $DetalheImovelModelCopyWith<$Res> {
  factory _$DetalheImovelModelCopyWith(_DetalheImovelModel value, $Res Function(_DetalheImovelModel) _then) = __$DetalheImovelModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String titulo, String finalidade,@JsonKey(name: 'preco_venda') String? precoVenda,@JsonKey(name: 'preco_aluguel') String? precoAluguel,@JsonKey(name: 'preco_condominio') String? precoCondominio,@JsonKey(name: 'preco_iptu') String? precoIptu, String descricao, EnderecoPublicoModel? endereco, List<FotoImovelModel> fotos, List<CaracteristicaModel> caracteristicas,@JsonKey(name: 'corretor_responsavel') CorretorModel? corretor, String? natureza, CasaModel? casa, ApartamentoModel? apartamento, TerrenoModel? terreno, LoteModel? lote,@JsonKey(name: 'canais_contato') List<String> canaisContato
});


@override $EnderecoPublicoModelCopyWith<$Res>? get endereco;@override $CorretorModelCopyWith<$Res>? get corretor;@override $CasaModelCopyWith<$Res>? get casa;@override $ApartamentoModelCopyWith<$Res>? get apartamento;@override $TerrenoModelCopyWith<$Res>? get terreno;@override $LoteModelCopyWith<$Res>? get lote;

}
/// @nodoc
class __$DetalheImovelModelCopyWithImpl<$Res>
    implements _$DetalheImovelModelCopyWith<$Res> {
  __$DetalheImovelModelCopyWithImpl(this._self, this._then);

  final _DetalheImovelModel _self;
  final $Res Function(_DetalheImovelModel) _then;

/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? titulo = null,Object? finalidade = null,Object? precoVenda = freezed,Object? precoAluguel = freezed,Object? precoCondominio = freezed,Object? precoIptu = freezed,Object? descricao = null,Object? endereco = freezed,Object? fotos = null,Object? caracteristicas = null,Object? corretor = freezed,Object? natureza = freezed,Object? casa = freezed,Object? apartamento = freezed,Object? terreno = freezed,Object? lote = freezed,Object? canaisContato = null,}) {
  return _then(_DetalheImovelModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,finalidade: null == finalidade ? _self.finalidade : finalidade // ignore: cast_nullable_to_non_nullable
as String,precoVenda: freezed == precoVenda ? _self.precoVenda : precoVenda // ignore: cast_nullable_to_non_nullable
as String?,precoAluguel: freezed == precoAluguel ? _self.precoAluguel : precoAluguel // ignore: cast_nullable_to_non_nullable
as String?,precoCondominio: freezed == precoCondominio ? _self.precoCondominio : precoCondominio // ignore: cast_nullable_to_non_nullable
as String?,precoIptu: freezed == precoIptu ? _self.precoIptu : precoIptu // ignore: cast_nullable_to_non_nullable
as String?,descricao: null == descricao ? _self.descricao : descricao // ignore: cast_nullable_to_non_nullable
as String,endereco: freezed == endereco ? _self.endereco : endereco // ignore: cast_nullable_to_non_nullable
as EnderecoPublicoModel?,fotos: null == fotos ? _self._fotos : fotos // ignore: cast_nullable_to_non_nullable
as List<FotoImovelModel>,caracteristicas: null == caracteristicas ? _self._caracteristicas : caracteristicas // ignore: cast_nullable_to_non_nullable
as List<CaracteristicaModel>,corretor: freezed == corretor ? _self.corretor : corretor // ignore: cast_nullable_to_non_nullable
as CorretorModel?,natureza: freezed == natureza ? _self.natureza : natureza // ignore: cast_nullable_to_non_nullable
as String?,casa: freezed == casa ? _self.casa : casa // ignore: cast_nullable_to_non_nullable
as CasaModel?,apartamento: freezed == apartamento ? _self.apartamento : apartamento // ignore: cast_nullable_to_non_nullable
as ApartamentoModel?,terreno: freezed == terreno ? _self.terreno : terreno // ignore: cast_nullable_to_non_nullable
as TerrenoModel?,lote: freezed == lote ? _self.lote : lote // ignore: cast_nullable_to_non_nullable
as LoteModel?,canaisContato: null == canaisContato ? _self._canaisContato : canaisContato // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of DetalheImovelModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnderecoPublicoModelCopyWith<$Res>? get endereco {
    if (_self.endereco == null) {
    return null;
  }

  return $EnderecoPublicoModelCopyWith<$Res>(_self.endereco!, (value) {
    return _then(_self.copyWith(endereco: value));
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
mixin _$EnderecoPublicoModel {

 String? get logradouro; String? get numero; String? get bairro; String? get cep; CidadeModel? get cidade; String? get latitude; String? get longitude;
/// Create a copy of EnderecoPublicoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnderecoPublicoModelCopyWith<EnderecoPublicoModel> get copyWith => _$EnderecoPublicoModelCopyWithImpl<EnderecoPublicoModel>(this as EnderecoPublicoModel, _$identity);

  /// Serializes this EnderecoPublicoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EnderecoPublicoModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnderecoPublicoModel&&(identical(other.logradouro, _this.logradouro) || other.logradouro == _this.logradouro)&&(identical(other.numero, _this.numero) || other.numero == _this.numero)&&(identical(other.bairro, _this.bairro) || other.bairro == _this.bairro)&&(identical(other.cep, _this.cep) || other.cep == _this.cep)&&(identical(other.cidade, _this.cidade) || other.cidade == _this.cidade)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EnderecoPublicoModel;
  return Object.hash(runtimeType,_this.logradouro,_this.numero,_this.bairro,_this.cep,_this.cidade,_this.latitude,_this.longitude);
}

@override
String toString() {
  final _this = this as EnderecoPublicoModel;
  return 'EnderecoPublicoModel(logradouro: ${_this.logradouro}, numero: ${_this.numero}, bairro: ${_this.bairro}, cep: ${_this.cep}, cidade: ${_this.cidade}, latitude: ${_this.latitude}, longitude: ${_this.longitude})';
}


}

/// @nodoc
abstract mixin class $EnderecoPublicoModelCopyWith<$Res>  {
  factory $EnderecoPublicoModelCopyWith(EnderecoPublicoModel value, $Res Function(EnderecoPublicoModel) _then) = _$EnderecoPublicoModelCopyWithImpl;
@useResult
$Res call({
 String? logradouro, String? numero, String? bairro, String? cep, CidadeModel? cidade, String? latitude, String? longitude
});


$CidadeModelCopyWith<$Res>? get cidade;

}
/// @nodoc
class _$EnderecoPublicoModelCopyWithImpl<$Res>
    implements $EnderecoPublicoModelCopyWith<$Res> {
  _$EnderecoPublicoModelCopyWithImpl(this._self, this._then);

  final EnderecoPublicoModel _self;
  final $Res Function(EnderecoPublicoModel) _then;

/// Create a copy of EnderecoPublicoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? logradouro = freezed,Object? numero = freezed,Object? bairro = freezed,Object? cep = freezed,Object? cidade = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(EnderecoPublicoModel(
logradouro: freezed == logradouro ? _self.logradouro : logradouro // ignore: cast_nullable_to_non_nullable
as String?,numero: freezed == numero ? _self.numero : numero // ignore: cast_nullable_to_non_nullable
as String?,bairro: freezed == bairro ? _self.bairro : bairro // ignore: cast_nullable_to_non_nullable
as String?,cep: freezed == cep ? _self.cep : cep // ignore: cast_nullable_to_non_nullable
as String?,cidade: freezed == cidade ? _self.cidade : cidade // ignore: cast_nullable_to_non_nullable
as CidadeModel?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of EnderecoPublicoModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CidadeModelCopyWith<$Res>? get cidade {
    if (_self.cidade == null) {
    return null;
  }

  return $CidadeModelCopyWith<$Res>(_self.cidade!, (value) {
    return _then(_self.copyWith(cidade: value));
  });
}
}


/// Adds pattern-matching-related methods to [EnderecoPublicoModel].
extension EnderecoPublicoModelPatterns on EnderecoPublicoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnderecoPublicoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnderecoPublicoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnderecoPublicoModel value)  $default,){
final _that = this;
switch (_that) {
case _EnderecoPublicoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnderecoPublicoModel value)?  $default,){
final _that = this;
switch (_that) {
case _EnderecoPublicoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? logradouro,  String? numero,  String? bairro,  String? cep,  CidadeModel? cidade,  String? latitude,  String? longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnderecoPublicoModel() when $default != null:
return $default(_that.logradouro,_that.numero,_that.bairro,_that.cep,_that.cidade,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? logradouro,  String? numero,  String? bairro,  String? cep,  CidadeModel? cidade,  String? latitude,  String? longitude)  $default,) {final _that = this;
switch (_that) {
case _EnderecoPublicoModel():
return $default(_that.logradouro,_that.numero,_that.bairro,_that.cep,_that.cidade,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? logradouro,  String? numero,  String? bairro,  String? cep,  CidadeModel? cidade,  String? latitude,  String? longitude)?  $default,) {final _that = this;
switch (_that) {
case _EnderecoPublicoModel() when $default != null:
return $default(_that.logradouro,_that.numero,_that.bairro,_that.cep,_that.cidade,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnderecoPublicoModel implements EnderecoPublicoModel {
  const _EnderecoPublicoModel({this.logradouro, this.numero, this.bairro, this.cep, this.cidade, this.latitude, this.longitude});
  factory _EnderecoPublicoModel.fromJson(Map<String, dynamic> json) => _$EnderecoPublicoModelFromJson(json);

@override final  String? logradouro;
@override final  String? numero;
@override final  String? bairro;
@override final  String? cep;
@override final  CidadeModel? cidade;
@override final  String? latitude;
@override final  String? longitude;

/// Create a copy of EnderecoPublicoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnderecoPublicoModelCopyWith<_EnderecoPublicoModel> get copyWith => __$EnderecoPublicoModelCopyWithImpl<_EnderecoPublicoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EnderecoPublicoModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnderecoPublicoModel&&(identical(other.logradouro, logradouro) || other.logradouro == logradouro)&&(identical(other.numero, numero) || other.numero == numero)&&(identical(other.bairro, bairro) || other.bairro == bairro)&&(identical(other.cep, cep) || other.cep == cep)&&(identical(other.cidade, cidade) || other.cidade == cidade)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,logradouro,numero,bairro,cep,cidade,latitude,longitude);
}

@override
String toString() {
    return 'EnderecoPublicoModel(logradouro: $logradouro, numero: $numero, bairro: $bairro, cep: $cep, cidade: $cidade, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$EnderecoPublicoModelCopyWith<$Res> implements $EnderecoPublicoModelCopyWith<$Res> {
  factory _$EnderecoPublicoModelCopyWith(_EnderecoPublicoModel value, $Res Function(_EnderecoPublicoModel) _then) = __$EnderecoPublicoModelCopyWithImpl;
@override @useResult
$Res call({
 String? logradouro, String? numero, String? bairro, String? cep, CidadeModel? cidade, String? latitude, String? longitude
});


@override $CidadeModelCopyWith<$Res>? get cidade;

}
/// @nodoc
class __$EnderecoPublicoModelCopyWithImpl<$Res>
    implements _$EnderecoPublicoModelCopyWith<$Res> {
  __$EnderecoPublicoModelCopyWithImpl(this._self, this._then);

  final _EnderecoPublicoModel _self;
  final $Res Function(_EnderecoPublicoModel) _then;

/// Create a copy of EnderecoPublicoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? logradouro = freezed,Object? numero = freezed,Object? bairro = freezed,Object? cep = freezed,Object? cidade = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_EnderecoPublicoModel(
logradouro: freezed == logradouro ? _self.logradouro : logradouro // ignore: cast_nullable_to_non_nullable
as String?,numero: freezed == numero ? _self.numero : numero // ignore: cast_nullable_to_non_nullable
as String?,bairro: freezed == bairro ? _self.bairro : bairro // ignore: cast_nullable_to_non_nullable
as String?,cep: freezed == cep ? _self.cep : cep // ignore: cast_nullable_to_non_nullable
as String?,cidade: freezed == cidade ? _self.cidade : cidade // ignore: cast_nullable_to_non_nullable
as CidadeModel?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of EnderecoPublicoModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CidadeModelCopyWith<$Res>? get cidade {
    if (_self.cidade == null) {
    return null;
  }

  return $CidadeModelCopyWith<$Res>(_self.cidade!, (value) {
    return _then(_self.copyWith(cidade: value));
  });
}
}


/// @nodoc
mixin _$FotoImovelModel {

@JsonKey(name: 'imagem') String get url; int get ordem; bool get capa;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FotoImovelModel&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.ordem, _this.ordem) || other.ordem == _this.ordem)&&(identical(other.capa, _this.capa) || other.capa == _this.capa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FotoImovelModel;
  return Object.hash(runtimeType,_this.url,_this.ordem,_this.capa);
}

@override
String toString() {
  final _this = this as FotoImovelModel;
  return 'FotoImovelModel(url: ${_this.url}, ordem: ${_this.ordem}, capa: ${_this.capa})';
}


}

/// @nodoc
abstract mixin class $FotoImovelModelCopyWith<$Res>  {
  factory $FotoImovelModelCopyWith(FotoImovelModel value, $Res Function(FotoImovelModel) _then) = _$FotoImovelModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'imagem') String url, int ordem, bool capa
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
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? ordem = null,Object? capa = null,}) {
  return _then(FotoImovelModel(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'imagem')  String url,  int ordem,  bool capa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FotoImovelModel() when $default != null:
return $default(_that.url,_that.ordem,_that.capa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'imagem')  String url,  int ordem,  bool capa)  $default,) {final _that = this;
switch (_that) {
case _FotoImovelModel():
return $default(_that.url,_that.ordem,_that.capa);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'imagem')  String url,  int ordem,  bool capa)?  $default,) {final _that = this;
switch (_that) {
case _FotoImovelModel() when $default != null:
return $default(_that.url,_that.ordem,_that.capa);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FotoImovelModel extends FotoImovelModel {
  const _FotoImovelModel({@JsonKey(name: 'imagem') required this.url, required this.ordem, required this.capa}): super._();
  factory _FotoImovelModel.fromJson(Map<String, dynamic> json) => _$FotoImovelModelFromJson(json);

@override@JsonKey(name: 'imagem') final  String url;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FotoImovelModel&&(identical(other.url, url) || other.url == url)&&(identical(other.ordem, ordem) || other.ordem == ordem)&&(identical(other.capa, capa) || other.capa == capa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,ordem,capa);
}

@override
String toString() {
    return 'FotoImovelModel(url: $url, ordem: $ordem, capa: $capa)';
}


}

/// @nodoc
abstract mixin class _$FotoImovelModelCopyWith<$Res> implements $FotoImovelModelCopyWith<$Res> {
  factory _$FotoImovelModelCopyWith(_FotoImovelModel value, $Res Function(_FotoImovelModel) _then) = __$FotoImovelModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'imagem') String url, int ordem, bool capa
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
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? ordem = null,Object? capa = null,}) {
  return _then(_FotoImovelModel(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,ordem: null == ordem ? _self.ordem : ordem // ignore: cast_nullable_to_non_nullable
as int,capa: null == capa ? _self.capa : capa // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CorretorModel {

 int get id; String get nome; String? get foto;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CorretorModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nome, _this.nome) || other.nome == _this.nome)&&(identical(other.foto, _this.foto) || other.foto == _this.foto));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CorretorModel;
  return Object.hash(runtimeType,_this.id,_this.nome,_this.foto);
}

@override
String toString() {
  final _this = this as CorretorModel;
  return 'CorretorModel(id: ${_this.id}, nome: ${_this.nome}, foto: ${_this.foto})';
}


}

/// @nodoc
abstract mixin class $CorretorModelCopyWith<$Res>  {
  factory $CorretorModelCopyWith(CorretorModel value, $Res Function(CorretorModel) _then) = _$CorretorModelCopyWithImpl;
@useResult
$Res call({
 int id, String nome, String? foto
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nome = null,Object? foto = freezed,}) {
  return _then(CorretorModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,foto: freezed == foto ? _self.foto : foto // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String nome,  String? foto)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CorretorModel() when $default != null:
return $default(_that.id,_that.nome,_that.foto);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String nome,  String? foto)  $default,) {final _that = this;
switch (_that) {
case _CorretorModel():
return $default(_that.id,_that.nome,_that.foto);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String nome,  String? foto)?  $default,) {final _that = this;
switch (_that) {
case _CorretorModel() when $default != null:
return $default(_that.id,_that.nome,_that.foto);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CorretorModel extends CorretorModel {
  const _CorretorModel({required this.id, required this.nome, this.foto}): super._();
  factory _CorretorModel.fromJson(Map<String, dynamic> json) => _$CorretorModelFromJson(json);

@override final  int id;
@override final  String nome;
@override final  String? foto;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CorretorModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.foto, foto) || other.foto == foto));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,nome,foto);
}

@override
String toString() {
    return 'CorretorModel(id: $id, nome: $nome, foto: $foto)';
}


}

/// @nodoc
abstract mixin class _$CorretorModelCopyWith<$Res> implements $CorretorModelCopyWith<$Res> {
  factory _$CorretorModelCopyWith(_CorretorModel value, $Res Function(_CorretorModel) _then) = __$CorretorModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String nome, String? foto
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nome = null,Object? foto = freezed,}) {
  return _then(_CorretorModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,foto: freezed == foto ? _self.foto : foto // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
