// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detalhe_imovel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DetalheImovel {

 int get id; String get titulo; FinalidadeImovel get finalidade; String? get precoVenda; String? get precoAluguel; String? get precoCondominio; String? get precoIptu; String get descricao; String get bairro; Cidade? get cidade; String? get latitude; String? get longitude;/// Na ordem recebida — o servidor já manda a capa primeiro; o app nunca
/// reordena.
 List<FotoImovel> get fotos; List<String> get caracteristicas; CorretorResponsavel? get corretor; NaturezaImovel? get natureza;/// Dados próprios da natureza; `null` quando o servidor não manda o bloco
/// ou a natureza é desconhecida (D-14).
 DadosNatureza? get dados;
/// Create a copy of DetalheImovel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DetalheImovelCopyWith<DetalheImovel> get copyWith => _$DetalheImovelCopyWithImpl<DetalheImovel>(this as DetalheImovel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DetalheImovel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DetalheImovel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.titulo, _this.titulo) || other.titulo == _this.titulo)&&(identical(other.finalidade, _this.finalidade) || other.finalidade == _this.finalidade)&&(identical(other.precoVenda, _this.precoVenda) || other.precoVenda == _this.precoVenda)&&(identical(other.precoAluguel, _this.precoAluguel) || other.precoAluguel == _this.precoAluguel)&&(identical(other.precoCondominio, _this.precoCondominio) || other.precoCondominio == _this.precoCondominio)&&(identical(other.precoIptu, _this.precoIptu) || other.precoIptu == _this.precoIptu)&&(identical(other.descricao, _this.descricao) || other.descricao == _this.descricao)&&(identical(other.bairro, _this.bairro) || other.bairro == _this.bairro)&&(identical(other.cidade, _this.cidade) || other.cidade == _this.cidade)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&const DeepCollectionEquality().equals(other.fotos, _this.fotos)&&const DeepCollectionEquality().equals(other.caracteristicas, _this.caracteristicas)&&(identical(other.corretor, _this.corretor) || other.corretor == _this.corretor)&&(identical(other.natureza, _this.natureza) || other.natureza == _this.natureza)&&(identical(other.dados, _this.dados) || other.dados == _this.dados));
}


@override
int get hashCode {
  final _this = this as DetalheImovel;
  return Object.hash(runtimeType,_this.id,_this.titulo,_this.finalidade,_this.precoVenda,_this.precoAluguel,_this.precoCondominio,_this.precoIptu,_this.descricao,_this.bairro,_this.cidade,_this.latitude,_this.longitude,const DeepCollectionEquality().hash(_this.fotos),const DeepCollectionEquality().hash(_this.caracteristicas),_this.corretor,_this.natureza,_this.dados);
}

@override
String toString() {
  final _this = this as DetalheImovel;
  return 'DetalheImovel(id: ${_this.id}, titulo: ${_this.titulo}, finalidade: ${_this.finalidade}, precoVenda: ${_this.precoVenda}, precoAluguel: ${_this.precoAluguel}, precoCondominio: ${_this.precoCondominio}, precoIptu: ${_this.precoIptu}, descricao: ${_this.descricao}, bairro: ${_this.bairro}, cidade: ${_this.cidade}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, fotos: ${_this.fotos}, caracteristicas: ${_this.caracteristicas}, corretor: ${_this.corretor}, natureza: ${_this.natureza}, dados: ${_this.dados})';
}


}

/// @nodoc
abstract mixin class $DetalheImovelCopyWith<$Res>  {
  factory $DetalheImovelCopyWith(DetalheImovel value, $Res Function(DetalheImovel) _then) = _$DetalheImovelCopyWithImpl;
@useResult
$Res call({
 int id, String titulo, FinalidadeImovel finalidade, String? precoVenda, String? precoAluguel, String? precoCondominio, String? precoIptu, String descricao, String bairro, Cidade? cidade, String? latitude, String? longitude, List<FotoImovel> fotos, List<String> caracteristicas, CorretorResponsavel? corretor, NaturezaImovel? natureza, DadosNatureza? dados
});


$CorretorResponsavelCopyWith<$Res>? get corretor;$DadosNaturezaCopyWith<$Res>? get dados;

}
/// @nodoc
class _$DetalheImovelCopyWithImpl<$Res>
    implements $DetalheImovelCopyWith<$Res> {
  _$DetalheImovelCopyWithImpl(this._self, this._then);

  final DetalheImovel _self;
  final $Res Function(DetalheImovel) _then;

/// Create a copy of DetalheImovel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? titulo = null,Object? finalidade = null,Object? precoVenda = freezed,Object? precoAluguel = freezed,Object? precoCondominio = freezed,Object? precoIptu = freezed,Object? descricao = null,Object? bairro = null,Object? cidade = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? fotos = null,Object? caracteristicas = null,Object? corretor = freezed,Object? natureza = freezed,Object? dados = freezed,}) {
  return _then(DetalheImovel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,finalidade: null == finalidade ? _self.finalidade : finalidade // ignore: cast_nullable_to_non_nullable
as FinalidadeImovel,precoVenda: freezed == precoVenda ? _self.precoVenda : precoVenda // ignore: cast_nullable_to_non_nullable
as String?,precoAluguel: freezed == precoAluguel ? _self.precoAluguel : precoAluguel // ignore: cast_nullable_to_non_nullable
as String?,precoCondominio: freezed == precoCondominio ? _self.precoCondominio : precoCondominio // ignore: cast_nullable_to_non_nullable
as String?,precoIptu: freezed == precoIptu ? _self.precoIptu : precoIptu // ignore: cast_nullable_to_non_nullable
as String?,descricao: null == descricao ? _self.descricao : descricao // ignore: cast_nullable_to_non_nullable
as String,bairro: null == bairro ? _self.bairro : bairro // ignore: cast_nullable_to_non_nullable
as String,cidade: freezed == cidade ? _self.cidade : cidade // ignore: cast_nullable_to_non_nullable
as Cidade?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,fotos: null == fotos ? _self.fotos : fotos // ignore: cast_nullable_to_non_nullable
as List<FotoImovel>,caracteristicas: null == caracteristicas ? _self.caracteristicas : caracteristicas // ignore: cast_nullable_to_non_nullable
as List<String>,corretor: freezed == corretor ? _self.corretor : corretor // ignore: cast_nullable_to_non_nullable
as CorretorResponsavel?,natureza: freezed == natureza ? _self.natureza : natureza // ignore: cast_nullable_to_non_nullable
as NaturezaImovel?,dados: freezed == dados ? _self.dados : dados // ignore: cast_nullable_to_non_nullable
as DadosNatureza?,
  ));
}
/// Create a copy of DetalheImovel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CorretorResponsavelCopyWith<$Res>? get corretor {
    if (_self.corretor == null) {
    return null;
  }

  return $CorretorResponsavelCopyWith<$Res>(_self.corretor!, (value) {
    return _then(_self.copyWith(corretor: value));
  });
}/// Create a copy of DetalheImovel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DadosNaturezaCopyWith<$Res>? get dados {
    if (_self.dados == null) {
    return null;
  }

  return $DadosNaturezaCopyWith<$Res>(_self.dados!, (value) {
    return _then(_self.copyWith(dados: value));
  });
}
}


/// Adds pattern-matching-related methods to [DetalheImovel].
extension DetalheImovelPatterns on DetalheImovel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DetalheImovel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DetalheImovel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DetalheImovel value)  $default,){
final _that = this;
switch (_that) {
case _DetalheImovel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DetalheImovel value)?  $default,){
final _that = this;
switch (_that) {
case _DetalheImovel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String titulo,  FinalidadeImovel finalidade,  String? precoVenda,  String? precoAluguel,  String? precoCondominio,  String? precoIptu,  String descricao,  String bairro,  Cidade? cidade,  String? latitude,  String? longitude,  List<FotoImovel> fotos,  List<String> caracteristicas,  CorretorResponsavel? corretor,  NaturezaImovel? natureza,  DadosNatureza? dados)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DetalheImovel() when $default != null:
return $default(_that.id,_that.titulo,_that.finalidade,_that.precoVenda,_that.precoAluguel,_that.precoCondominio,_that.precoIptu,_that.descricao,_that.bairro,_that.cidade,_that.latitude,_that.longitude,_that.fotos,_that.caracteristicas,_that.corretor,_that.natureza,_that.dados);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String titulo,  FinalidadeImovel finalidade,  String? precoVenda,  String? precoAluguel,  String? precoCondominio,  String? precoIptu,  String descricao,  String bairro,  Cidade? cidade,  String? latitude,  String? longitude,  List<FotoImovel> fotos,  List<String> caracteristicas,  CorretorResponsavel? corretor,  NaturezaImovel? natureza,  DadosNatureza? dados)  $default,) {final _that = this;
switch (_that) {
case _DetalheImovel():
return $default(_that.id,_that.titulo,_that.finalidade,_that.precoVenda,_that.precoAluguel,_that.precoCondominio,_that.precoIptu,_that.descricao,_that.bairro,_that.cidade,_that.latitude,_that.longitude,_that.fotos,_that.caracteristicas,_that.corretor,_that.natureza,_that.dados);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String titulo,  FinalidadeImovel finalidade,  String? precoVenda,  String? precoAluguel,  String? precoCondominio,  String? precoIptu,  String descricao,  String bairro,  Cidade? cidade,  String? latitude,  String? longitude,  List<FotoImovel> fotos,  List<String> caracteristicas,  CorretorResponsavel? corretor,  NaturezaImovel? natureza,  DadosNatureza? dados)?  $default,) {final _that = this;
switch (_that) {
case _DetalheImovel() when $default != null:
return $default(_that.id,_that.titulo,_that.finalidade,_that.precoVenda,_that.precoAluguel,_that.precoCondominio,_that.precoIptu,_that.descricao,_that.bairro,_that.cidade,_that.latitude,_that.longitude,_that.fotos,_that.caracteristicas,_that.corretor,_that.natureza,_that.dados);case _:
  return null;

}
}

}

/// @nodoc


class _DetalheImovel implements DetalheImovel {
  const _DetalheImovel({required this.id, required this.titulo, required this.finalidade, this.precoVenda, this.precoAluguel, this.precoCondominio, this.precoIptu, required this.descricao, required this.bairro, this.cidade, this.latitude, this.longitude,  List<FotoImovel> fotos = const <FotoImovel>[],  List<String> caracteristicas = const <String>[], this.corretor, this.natureza, this.dados}): _fotos = fotos,_caracteristicas = caracteristicas;
  

@override final  int id;
@override final  String titulo;
@override final  FinalidadeImovel finalidade;
@override final  String? precoVenda;
@override final  String? precoAluguel;
@override final  String? precoCondominio;
@override final  String? precoIptu;
@override final  String descricao;
@override final  String bairro;
@override final  Cidade? cidade;
@override final  String? latitude;
@override final  String? longitude;
/// Na ordem recebida — o servidor já manda a capa primeiro; o app nunca
/// reordena.
 final  List<FotoImovel> _fotos;
/// Na ordem recebida — o servidor já manda a capa primeiro; o app nunca
/// reordena.
@override@JsonKey() List<FotoImovel> get fotos {
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

@override final  CorretorResponsavel? corretor;
@override final  NaturezaImovel? natureza;
/// Dados próprios da natureza; `null` quando o servidor não manda o bloco
/// ou a natureza é desconhecida (D-14).
@override final  DadosNatureza? dados;

/// Create a copy of DetalheImovel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DetalheImovelCopyWith<_DetalheImovel> get copyWith => __$DetalheImovelCopyWithImpl<_DetalheImovel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DetalheImovel&&(identical(other.id, id) || other.id == id)&&(identical(other.titulo, titulo) || other.titulo == titulo)&&(identical(other.finalidade, finalidade) || other.finalidade == finalidade)&&(identical(other.precoVenda, precoVenda) || other.precoVenda == precoVenda)&&(identical(other.precoAluguel, precoAluguel) || other.precoAluguel == precoAluguel)&&(identical(other.precoCondominio, precoCondominio) || other.precoCondominio == precoCondominio)&&(identical(other.precoIptu, precoIptu) || other.precoIptu == precoIptu)&&(identical(other.descricao, descricao) || other.descricao == descricao)&&(identical(other.bairro, bairro) || other.bairro == bairro)&&(identical(other.cidade, cidade) || other.cidade == cidade)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other.fotos, _fotos)&&const DeepCollectionEquality().equals(other.caracteristicas, _caracteristicas)&&(identical(other.corretor, corretor) || other.corretor == corretor)&&(identical(other.natureza, natureza) || other.natureza == natureza)&&(identical(other.dados, dados) || other.dados == dados));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,titulo,finalidade,precoVenda,precoAluguel,precoCondominio,precoIptu,descricao,bairro,cidade,latitude,longitude,const DeepCollectionEquality().hash(_fotos),const DeepCollectionEquality().hash(_caracteristicas),corretor,natureza,dados);
}

@override
String toString() {
    return 'DetalheImovel(id: $id, titulo: $titulo, finalidade: $finalidade, precoVenda: $precoVenda, precoAluguel: $precoAluguel, precoCondominio: $precoCondominio, precoIptu: $precoIptu, descricao: $descricao, bairro: $bairro, cidade: $cidade, latitude: $latitude, longitude: $longitude, fotos: $fotos, caracteristicas: $caracteristicas, corretor: $corretor, natureza: $natureza, dados: $dados)';
}


}

/// @nodoc
abstract mixin class _$DetalheImovelCopyWith<$Res> implements $DetalheImovelCopyWith<$Res> {
  factory _$DetalheImovelCopyWith(_DetalheImovel value, $Res Function(_DetalheImovel) _then) = __$DetalheImovelCopyWithImpl;
@override @useResult
$Res call({
 int id, String titulo, FinalidadeImovel finalidade, String? precoVenda, String? precoAluguel, String? precoCondominio, String? precoIptu, String descricao, String bairro, Cidade? cidade, String? latitude, String? longitude, List<FotoImovel> fotos, List<String> caracteristicas, CorretorResponsavel? corretor, NaturezaImovel? natureza, DadosNatureza? dados
});


@override $CorretorResponsavelCopyWith<$Res>? get corretor;@override $DadosNaturezaCopyWith<$Res>? get dados;

}
/// @nodoc
class __$DetalheImovelCopyWithImpl<$Res>
    implements _$DetalheImovelCopyWith<$Res> {
  __$DetalheImovelCopyWithImpl(this._self, this._then);

  final _DetalheImovel _self;
  final $Res Function(_DetalheImovel) _then;

/// Create a copy of DetalheImovel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? titulo = null,Object? finalidade = null,Object? precoVenda = freezed,Object? precoAluguel = freezed,Object? precoCondominio = freezed,Object? precoIptu = freezed,Object? descricao = null,Object? bairro = null,Object? cidade = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? fotos = null,Object? caracteristicas = null,Object? corretor = freezed,Object? natureza = freezed,Object? dados = freezed,}) {
  return _then(_DetalheImovel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,finalidade: null == finalidade ? _self.finalidade : finalidade // ignore: cast_nullable_to_non_nullable
as FinalidadeImovel,precoVenda: freezed == precoVenda ? _self.precoVenda : precoVenda // ignore: cast_nullable_to_non_nullable
as String?,precoAluguel: freezed == precoAluguel ? _self.precoAluguel : precoAluguel // ignore: cast_nullable_to_non_nullable
as String?,precoCondominio: freezed == precoCondominio ? _self.precoCondominio : precoCondominio // ignore: cast_nullable_to_non_nullable
as String?,precoIptu: freezed == precoIptu ? _self.precoIptu : precoIptu // ignore: cast_nullable_to_non_nullable
as String?,descricao: null == descricao ? _self.descricao : descricao // ignore: cast_nullable_to_non_nullable
as String,bairro: null == bairro ? _self.bairro : bairro // ignore: cast_nullable_to_non_nullable
as String,cidade: freezed == cidade ? _self.cidade : cidade // ignore: cast_nullable_to_non_nullable
as Cidade?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,fotos: null == fotos ? _self._fotos : fotos // ignore: cast_nullable_to_non_nullable
as List<FotoImovel>,caracteristicas: null == caracteristicas ? _self._caracteristicas : caracteristicas // ignore: cast_nullable_to_non_nullable
as List<String>,corretor: freezed == corretor ? _self.corretor : corretor // ignore: cast_nullable_to_non_nullable
as CorretorResponsavel?,natureza: freezed == natureza ? _self.natureza : natureza // ignore: cast_nullable_to_non_nullable
as NaturezaImovel?,dados: freezed == dados ? _self.dados : dados // ignore: cast_nullable_to_non_nullable
as DadosNatureza?,
  ));
}

/// Create a copy of DetalheImovel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CorretorResponsavelCopyWith<$Res>? get corretor {
    if (_self.corretor == null) {
    return null;
  }

  return $CorretorResponsavelCopyWith<$Res>(_self.corretor!, (value) {
    return _then(_self.copyWith(corretor: value));
  });
}/// Create a copy of DetalheImovel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DadosNaturezaCopyWith<$Res>? get dados {
    if (_self.dados == null) {
    return null;
  }

  return $DadosNaturezaCopyWith<$Res>(_self.dados!, (value) {
    return _then(_self.copyWith(dados: value));
  });
}
}

/// @nodoc
mixin _$FotoImovel {

 String get url; bool get capa;
/// Create a copy of FotoImovel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FotoImovelCopyWith<FotoImovel> get copyWith => _$FotoImovelCopyWithImpl<FotoImovel>(this as FotoImovel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FotoImovel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FotoImovel&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.capa, _this.capa) || other.capa == _this.capa));
}


@override
int get hashCode {
  final _this = this as FotoImovel;
  return Object.hash(runtimeType,_this.url,_this.capa);
}

@override
String toString() {
  final _this = this as FotoImovel;
  return 'FotoImovel(url: ${_this.url}, capa: ${_this.capa})';
}


}

/// @nodoc
abstract mixin class $FotoImovelCopyWith<$Res>  {
  factory $FotoImovelCopyWith(FotoImovel value, $Res Function(FotoImovel) _then) = _$FotoImovelCopyWithImpl;
@useResult
$Res call({
 String url, bool capa
});




}
/// @nodoc
class _$FotoImovelCopyWithImpl<$Res>
    implements $FotoImovelCopyWith<$Res> {
  _$FotoImovelCopyWithImpl(this._self, this._then);

  final FotoImovel _self;
  final $Res Function(FotoImovel) _then;

/// Create a copy of FotoImovel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? capa = null,}) {
  return _then(FotoImovel(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,capa: null == capa ? _self.capa : capa // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FotoImovel].
extension FotoImovelPatterns on FotoImovel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FotoImovel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FotoImovel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FotoImovel value)  $default,){
final _that = this;
switch (_that) {
case _FotoImovel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FotoImovel value)?  $default,){
final _that = this;
switch (_that) {
case _FotoImovel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  bool capa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FotoImovel() when $default != null:
return $default(_that.url,_that.capa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  bool capa)  $default,) {final _that = this;
switch (_that) {
case _FotoImovel():
return $default(_that.url,_that.capa);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  bool capa)?  $default,) {final _that = this;
switch (_that) {
case _FotoImovel() when $default != null:
return $default(_that.url,_that.capa);case _:
  return null;

}
}

}

/// @nodoc


class _FotoImovel implements FotoImovel {
  const _FotoImovel({required this.url, required this.capa});
  

@override final  String url;
@override final  bool capa;

/// Create a copy of FotoImovel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FotoImovelCopyWith<_FotoImovel> get copyWith => __$FotoImovelCopyWithImpl<_FotoImovel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FotoImovel&&(identical(other.url, url) || other.url == url)&&(identical(other.capa, capa) || other.capa == capa));
}


@override
int get hashCode {
    return Object.hash(runtimeType,url,capa);
}

@override
String toString() {
    return 'FotoImovel(url: $url, capa: $capa)';
}


}

/// @nodoc
abstract mixin class _$FotoImovelCopyWith<$Res> implements $FotoImovelCopyWith<$Res> {
  factory _$FotoImovelCopyWith(_FotoImovel value, $Res Function(_FotoImovel) _then) = __$FotoImovelCopyWithImpl;
@override @useResult
$Res call({
 String url, bool capa
});




}
/// @nodoc
class __$FotoImovelCopyWithImpl<$Res>
    implements _$FotoImovelCopyWith<$Res> {
  __$FotoImovelCopyWithImpl(this._self, this._then);

  final _FotoImovel _self;
  final $Res Function(_FotoImovel) _then;

/// Create a copy of FotoImovel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? capa = null,}) {
  return _then(_FotoImovel(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,capa: null == capa ? _self.capa : capa // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$CorretorResponsavel {

 int get id; String get nome; String? get foto; String? get slug;
/// Create a copy of CorretorResponsavel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CorretorResponsavelCopyWith<CorretorResponsavel> get copyWith => _$CorretorResponsavelCopyWithImpl<CorretorResponsavel>(this as CorretorResponsavel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CorretorResponsavel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CorretorResponsavel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nome, _this.nome) || other.nome == _this.nome)&&(identical(other.foto, _this.foto) || other.foto == _this.foto)&&(identical(other.slug, _this.slug) || other.slug == _this.slug));
}


@override
int get hashCode {
  final _this = this as CorretorResponsavel;
  return Object.hash(runtimeType,_this.id,_this.nome,_this.foto,_this.slug);
}

@override
String toString() {
  final _this = this as CorretorResponsavel;
  return 'CorretorResponsavel(id: ${_this.id}, nome: ${_this.nome}, foto: ${_this.foto}, slug: ${_this.slug})';
}


}

/// @nodoc
abstract mixin class $CorretorResponsavelCopyWith<$Res>  {
  factory $CorretorResponsavelCopyWith(CorretorResponsavel value, $Res Function(CorretorResponsavel) _then) = _$CorretorResponsavelCopyWithImpl;
@useResult
$Res call({
 int id, String nome, String? foto, String? slug
});




}
/// @nodoc
class _$CorretorResponsavelCopyWithImpl<$Res>
    implements $CorretorResponsavelCopyWith<$Res> {
  _$CorretorResponsavelCopyWithImpl(this._self, this._then);

  final CorretorResponsavel _self;
  final $Res Function(CorretorResponsavel) _then;

/// Create a copy of CorretorResponsavel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nome = null,Object? foto = freezed,Object? slug = freezed,}) {
  return _then(CorretorResponsavel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,foto: freezed == foto ? _self.foto : foto // ignore: cast_nullable_to_non_nullable
as String?,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CorretorResponsavel].
extension CorretorResponsavelPatterns on CorretorResponsavel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CorretorResponsavel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CorretorResponsavel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CorretorResponsavel value)  $default,){
final _that = this;
switch (_that) {
case _CorretorResponsavel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CorretorResponsavel value)?  $default,){
final _that = this;
switch (_that) {
case _CorretorResponsavel() when $default != null:
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
case _CorretorResponsavel() when $default != null:
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
case _CorretorResponsavel():
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
case _CorretorResponsavel() when $default != null:
return $default(_that.id,_that.nome,_that.foto,_that.slug);case _:
  return null;

}
}

}

/// @nodoc


class _CorretorResponsavel implements CorretorResponsavel {
  const _CorretorResponsavel({required this.id, required this.nome, this.foto, this.slug});
  

@override final  int id;
@override final  String nome;
@override final  String? foto;
@override final  String? slug;

/// Create a copy of CorretorResponsavel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CorretorResponsavelCopyWith<_CorretorResponsavel> get copyWith => __$CorretorResponsavelCopyWithImpl<_CorretorResponsavel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CorretorResponsavel&&(identical(other.id, id) || other.id == id)&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.foto, foto) || other.foto == foto)&&(identical(other.slug, slug) || other.slug == slug));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,nome,foto,slug);
}

@override
String toString() {
    return 'CorretorResponsavel(id: $id, nome: $nome, foto: $foto, slug: $slug)';
}


}

/// @nodoc
abstract mixin class _$CorretorResponsavelCopyWith<$Res> implements $CorretorResponsavelCopyWith<$Res> {
  factory _$CorretorResponsavelCopyWith(_CorretorResponsavel value, $Res Function(_CorretorResponsavel) _then) = __$CorretorResponsavelCopyWithImpl;
@override @useResult
$Res call({
 int id, String nome, String? foto, String? slug
});




}
/// @nodoc
class __$CorretorResponsavelCopyWithImpl<$Res>
    implements _$CorretorResponsavelCopyWith<$Res> {
  __$CorretorResponsavelCopyWithImpl(this._self, this._then);

  final _CorretorResponsavel _self;
  final $Res Function(_CorretorResponsavel) _then;

/// Create a copy of CorretorResponsavel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nome = null,Object? foto = freezed,Object? slug = freezed,}) {
  return _then(_CorretorResponsavel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,foto: freezed == foto ? _self.foto : foto // ignore: cast_nullable_to_non_nullable
as String?,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
