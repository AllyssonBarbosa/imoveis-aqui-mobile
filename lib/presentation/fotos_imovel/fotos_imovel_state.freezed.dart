// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fotos_imovel_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FotosImovelState {

 ListaFotos get lista; List<EnvioDeFoto> get fila; OperacaoFotos get operacao; int get falhasDeOperacao;/// Mensagem do servidor da última falha de operação (400/403), para o
/// SnackBar; `null` usa o texto fixo.
 String? get mensagemDaUltimaFalha; int get fotosApagadas; int get falhasAoEscolher; bool get mudou;
/// Create a copy of FotosImovelState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FotosImovelStateCopyWith<FotosImovelState> get copyWith => _$FotosImovelStateCopyWithImpl<FotosImovelState>(this as FotosImovelState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FotosImovelState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FotosImovelState&&(identical(other.lista, _this.lista) || other.lista == _this.lista)&&const DeepCollectionEquality().equals(other.fila, _this.fila)&&(identical(other.operacao, _this.operacao) || other.operacao == _this.operacao)&&(identical(other.falhasDeOperacao, _this.falhasDeOperacao) || other.falhasDeOperacao == _this.falhasDeOperacao)&&(identical(other.mensagemDaUltimaFalha, _this.mensagemDaUltimaFalha) || other.mensagemDaUltimaFalha == _this.mensagemDaUltimaFalha)&&(identical(other.fotosApagadas, _this.fotosApagadas) || other.fotosApagadas == _this.fotosApagadas)&&(identical(other.falhasAoEscolher, _this.falhasAoEscolher) || other.falhasAoEscolher == _this.falhasAoEscolher)&&(identical(other.mudou, _this.mudou) || other.mudou == _this.mudou));
}


@override
int get hashCode {
  final _this = this as FotosImovelState;
  return Object.hash(runtimeType,_this.lista,const DeepCollectionEquality().hash(_this.fila),_this.operacao,_this.falhasDeOperacao,_this.mensagemDaUltimaFalha,_this.fotosApagadas,_this.falhasAoEscolher,_this.mudou);
}

@override
String toString() {
  final _this = this as FotosImovelState;
  return 'FotosImovelState(lista: ${_this.lista}, fila: ${_this.fila}, operacao: ${_this.operacao}, falhasDeOperacao: ${_this.falhasDeOperacao}, mensagemDaUltimaFalha: ${_this.mensagemDaUltimaFalha}, fotosApagadas: ${_this.fotosApagadas}, falhasAoEscolher: ${_this.falhasAoEscolher}, mudou: ${_this.mudou})';
}


}

/// @nodoc
abstract mixin class $FotosImovelStateCopyWith<$Res>  {
  factory $FotosImovelStateCopyWith(FotosImovelState value, $Res Function(FotosImovelState) _then) = _$FotosImovelStateCopyWithImpl;
@useResult
$Res call({
 ListaFotos lista, List<EnvioDeFoto> fila, OperacaoFotos operacao, int falhasDeOperacao, String? mensagemDaUltimaFalha, int fotosApagadas, int falhasAoEscolher, bool mudou
});


$ListaFotosCopyWith<$Res> get lista;$OperacaoFotosCopyWith<$Res> get operacao;

}
/// @nodoc
class _$FotosImovelStateCopyWithImpl<$Res>
    implements $FotosImovelStateCopyWith<$Res> {
  _$FotosImovelStateCopyWithImpl(this._self, this._then);

  final FotosImovelState _self;
  final $Res Function(FotosImovelState) _then;

/// Create a copy of FotosImovelState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lista = null,Object? fila = null,Object? operacao = null,Object? falhasDeOperacao = null,Object? mensagemDaUltimaFalha = freezed,Object? fotosApagadas = null,Object? falhasAoEscolher = null,Object? mudou = null,}) {
  return _then(FotosImovelState(
lista: null == lista ? _self.lista : lista // ignore: cast_nullable_to_non_nullable
as ListaFotos,fila: null == fila ? _self.fila : fila // ignore: cast_nullable_to_non_nullable
as List<EnvioDeFoto>,operacao: null == operacao ? _self.operacao : operacao // ignore: cast_nullable_to_non_nullable
as OperacaoFotos,falhasDeOperacao: null == falhasDeOperacao ? _self.falhasDeOperacao : falhasDeOperacao // ignore: cast_nullable_to_non_nullable
as int,mensagemDaUltimaFalha: freezed == mensagemDaUltimaFalha ? _self.mensagemDaUltimaFalha : mensagemDaUltimaFalha // ignore: cast_nullable_to_non_nullable
as String?,fotosApagadas: null == fotosApagadas ? _self.fotosApagadas : fotosApagadas // ignore: cast_nullable_to_non_nullable
as int,falhasAoEscolher: null == falhasAoEscolher ? _self.falhasAoEscolher : falhasAoEscolher // ignore: cast_nullable_to_non_nullable
as int,mudou: null == mudou ? _self.mudou : mudou // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of FotosImovelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListaFotosCopyWith<$Res> get lista {
  
  return $ListaFotosCopyWith<$Res>(_self.lista, (value) {
    return _then(_self.copyWith(lista: value));
  });
}/// Create a copy of FotosImovelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OperacaoFotosCopyWith<$Res> get operacao {
  
  return $OperacaoFotosCopyWith<$Res>(_self.operacao, (value) {
    return _then(_self.copyWith(operacao: value));
  });
}
}


/// Adds pattern-matching-related methods to [FotosImovelState].
extension FotosImovelStatePatterns on FotosImovelState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FotosImovelState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FotosImovelState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FotosImovelState value)  $default,){
final _that = this;
switch (_that) {
case _FotosImovelState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FotosImovelState value)?  $default,){
final _that = this;
switch (_that) {
case _FotosImovelState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ListaFotos lista,  List<EnvioDeFoto> fila,  OperacaoFotos operacao,  int falhasDeOperacao,  String? mensagemDaUltimaFalha,  int fotosApagadas,  int falhasAoEscolher,  bool mudou)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FotosImovelState() when $default != null:
return $default(_that.lista,_that.fila,_that.operacao,_that.falhasDeOperacao,_that.mensagemDaUltimaFalha,_that.fotosApagadas,_that.falhasAoEscolher,_that.mudou);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ListaFotos lista,  List<EnvioDeFoto> fila,  OperacaoFotos operacao,  int falhasDeOperacao,  String? mensagemDaUltimaFalha,  int fotosApagadas,  int falhasAoEscolher,  bool mudou)  $default,) {final _that = this;
switch (_that) {
case _FotosImovelState():
return $default(_that.lista,_that.fila,_that.operacao,_that.falhasDeOperacao,_that.mensagemDaUltimaFalha,_that.fotosApagadas,_that.falhasAoEscolher,_that.mudou);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ListaFotos lista,  List<EnvioDeFoto> fila,  OperacaoFotos operacao,  int falhasDeOperacao,  String? mensagemDaUltimaFalha,  int fotosApagadas,  int falhasAoEscolher,  bool mudou)?  $default,) {final _that = this;
switch (_that) {
case _FotosImovelState() when $default != null:
return $default(_that.lista,_that.fila,_that.operacao,_that.falhasDeOperacao,_that.mensagemDaUltimaFalha,_that.fotosApagadas,_that.falhasAoEscolher,_that.mudou);case _:
  return null;

}
}

}

/// @nodoc


class _FotosImovelState extends FotosImovelState {
  const _FotosImovelState({this.lista = const ListaFotos.carregando(),  List<EnvioDeFoto> fila = const <EnvioDeFoto>[], this.operacao = const OperacaoFotos.nenhuma(), this.falhasDeOperacao = 0, this.mensagemDaUltimaFalha, this.fotosApagadas = 0, this.falhasAoEscolher = 0, this.mudou = false}): _fila = fila,super._();
  

@override@JsonKey() final  ListaFotos lista;
 final  List<EnvioDeFoto> _fila;
@override@JsonKey() List<EnvioDeFoto> get fila {
  if (_fila is EqualUnmodifiableListView) return _fila;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fila);
}

@override@JsonKey() final  OperacaoFotos operacao;
@override@JsonKey() final  int falhasDeOperacao;
/// Mensagem do servidor da última falha de operação (400/403), para o
/// SnackBar; `null` usa o texto fixo.
@override final  String? mensagemDaUltimaFalha;
@override@JsonKey() final  int fotosApagadas;
@override@JsonKey() final  int falhasAoEscolher;
@override@JsonKey() final  bool mudou;

/// Create a copy of FotosImovelState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FotosImovelStateCopyWith<_FotosImovelState> get copyWith => __$FotosImovelStateCopyWithImpl<_FotosImovelState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FotosImovelState&&(identical(other.lista, lista) || other.lista == lista)&&const DeepCollectionEquality().equals(other.fila, _fila)&&(identical(other.operacao, operacao) || other.operacao == operacao)&&(identical(other.falhasDeOperacao, falhasDeOperacao) || other.falhasDeOperacao == falhasDeOperacao)&&(identical(other.mensagemDaUltimaFalha, mensagemDaUltimaFalha) || other.mensagemDaUltimaFalha == mensagemDaUltimaFalha)&&(identical(other.fotosApagadas, fotosApagadas) || other.fotosApagadas == fotosApagadas)&&(identical(other.falhasAoEscolher, falhasAoEscolher) || other.falhasAoEscolher == falhasAoEscolher)&&(identical(other.mudou, mudou) || other.mudou == mudou));
}


@override
int get hashCode {
    return Object.hash(runtimeType,lista,const DeepCollectionEquality().hash(_fila),operacao,falhasDeOperacao,mensagemDaUltimaFalha,fotosApagadas,falhasAoEscolher,mudou);
}

@override
String toString() {
    return 'FotosImovelState(lista: $lista, fila: $fila, operacao: $operacao, falhasDeOperacao: $falhasDeOperacao, mensagemDaUltimaFalha: $mensagemDaUltimaFalha, fotosApagadas: $fotosApagadas, falhasAoEscolher: $falhasAoEscolher, mudou: $mudou)';
}


}

/// @nodoc
abstract mixin class _$FotosImovelStateCopyWith<$Res> implements $FotosImovelStateCopyWith<$Res> {
  factory _$FotosImovelStateCopyWith(_FotosImovelState value, $Res Function(_FotosImovelState) _then) = __$FotosImovelStateCopyWithImpl;
@override @useResult
$Res call({
 ListaFotos lista, List<EnvioDeFoto> fila, OperacaoFotos operacao, int falhasDeOperacao, String? mensagemDaUltimaFalha, int fotosApagadas, int falhasAoEscolher, bool mudou
});


@override $ListaFotosCopyWith<$Res> get lista;@override $OperacaoFotosCopyWith<$Res> get operacao;

}
/// @nodoc
class __$FotosImovelStateCopyWithImpl<$Res>
    implements _$FotosImovelStateCopyWith<$Res> {
  __$FotosImovelStateCopyWithImpl(this._self, this._then);

  final _FotosImovelState _self;
  final $Res Function(_FotosImovelState) _then;

/// Create a copy of FotosImovelState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lista = null,Object? fila = null,Object? operacao = null,Object? falhasDeOperacao = null,Object? mensagemDaUltimaFalha = freezed,Object? fotosApagadas = null,Object? falhasAoEscolher = null,Object? mudou = null,}) {
  return _then(_FotosImovelState(
lista: null == lista ? _self.lista : lista // ignore: cast_nullable_to_non_nullable
as ListaFotos,fila: null == fila ? _self._fila : fila // ignore: cast_nullable_to_non_nullable
as List<EnvioDeFoto>,operacao: null == operacao ? _self.operacao : operacao // ignore: cast_nullable_to_non_nullable
as OperacaoFotos,falhasDeOperacao: null == falhasDeOperacao ? _self.falhasDeOperacao : falhasDeOperacao // ignore: cast_nullable_to_non_nullable
as int,mensagemDaUltimaFalha: freezed == mensagemDaUltimaFalha ? _self.mensagemDaUltimaFalha : mensagemDaUltimaFalha // ignore: cast_nullable_to_non_nullable
as String?,fotosApagadas: null == fotosApagadas ? _self.fotosApagadas : fotosApagadas // ignore: cast_nullable_to_non_nullable
as int,falhasAoEscolher: null == falhasAoEscolher ? _self.falhasAoEscolher : falhasAoEscolher // ignore: cast_nullable_to_non_nullable
as int,mudou: null == mudou ? _self.mudou : mudou // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of FotosImovelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListaFotosCopyWith<$Res> get lista {
  
  return $ListaFotosCopyWith<$Res>(_self.lista, (value) {
    return _then(_self.copyWith(lista: value));
  });
}/// Create a copy of FotosImovelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OperacaoFotosCopyWith<$Res> get operacao {
  
  return $OperacaoFotosCopyWith<$Res>(_self.operacao, (value) {
    return _then(_self.copyWith(operacao: value));
  });
}
}

/// @nodoc
mixin _$ListaFotos {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ListaFotos);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ListaFotos()';
}


}

/// @nodoc
class $ListaFotosCopyWith<$Res>  {
$ListaFotosCopyWith(ListaFotos _, $Res Function(ListaFotos) __);
}


/// Adds pattern-matching-related methods to [ListaFotos].
extension ListaFotosPatterns on ListaFotos {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ListaFotosCarregando value)?  carregando,TResult Function( ListaFotosCarregada value)?  carregada,TResult Function( ListaFotosErro value)?  erro,TResult Function( ListaFotosNaoEncontrado value)?  naoEncontrado,TResult Function( ListaFotosSessaoExpirada value)?  sessaoExpirada,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ListaFotosCarregando() when carregando != null:
return carregando(_that);case ListaFotosCarregada() when carregada != null:
return carregada(_that);case ListaFotosErro() when erro != null:
return erro(_that);case ListaFotosNaoEncontrado() when naoEncontrado != null:
return naoEncontrado(_that);case ListaFotosSessaoExpirada() when sessaoExpirada != null:
return sessaoExpirada(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ListaFotosCarregando value)  carregando,required TResult Function( ListaFotosCarregada value)  carregada,required TResult Function( ListaFotosErro value)  erro,required TResult Function( ListaFotosNaoEncontrado value)  naoEncontrado,required TResult Function( ListaFotosSessaoExpirada value)  sessaoExpirada,}){
final _that = this;
switch (_that) {
case ListaFotosCarregando():
return carregando(_that);case ListaFotosCarregada():
return carregada(_that);case ListaFotosErro():
return erro(_that);case ListaFotosNaoEncontrado():
return naoEncontrado(_that);case ListaFotosSessaoExpirada():
return sessaoExpirada(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ListaFotosCarregando value)?  carregando,TResult? Function( ListaFotosCarregada value)?  carregada,TResult? Function( ListaFotosErro value)?  erro,TResult? Function( ListaFotosNaoEncontrado value)?  naoEncontrado,TResult? Function( ListaFotosSessaoExpirada value)?  sessaoExpirada,}){
final _that = this;
switch (_that) {
case ListaFotosCarregando() when carregando != null:
return carregando(_that);case ListaFotosCarregada() when carregada != null:
return carregada(_that);case ListaFotosErro() when erro != null:
return erro(_that);case ListaFotosNaoEncontrado() when naoEncontrado != null:
return naoEncontrado(_that);case ListaFotosSessaoExpirada() when sessaoExpirada != null:
return sessaoExpirada(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  carregando,TResult Function( List<FotoImovel> fotos)?  carregada,TResult Function()?  erro,TResult Function()?  naoEncontrado,TResult Function()?  sessaoExpirada,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ListaFotosCarregando() when carregando != null:
return carregando();case ListaFotosCarregada() when carregada != null:
return carregada(_that.fotos);case ListaFotosErro() when erro != null:
return erro();case ListaFotosNaoEncontrado() when naoEncontrado != null:
return naoEncontrado();case ListaFotosSessaoExpirada() when sessaoExpirada != null:
return sessaoExpirada();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  carregando,required TResult Function( List<FotoImovel> fotos)  carregada,required TResult Function()  erro,required TResult Function()  naoEncontrado,required TResult Function()  sessaoExpirada,}) {final _that = this;
switch (_that) {
case ListaFotosCarregando():
return carregando();case ListaFotosCarregada():
return carregada(_that.fotos);case ListaFotosErro():
return erro();case ListaFotosNaoEncontrado():
return naoEncontrado();case ListaFotosSessaoExpirada():
return sessaoExpirada();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  carregando,TResult? Function( List<FotoImovel> fotos)?  carregada,TResult? Function()?  erro,TResult? Function()?  naoEncontrado,TResult? Function()?  sessaoExpirada,}) {final _that = this;
switch (_that) {
case ListaFotosCarregando() when carregando != null:
return carregando();case ListaFotosCarregada() when carregada != null:
return carregada(_that.fotos);case ListaFotosErro() when erro != null:
return erro();case ListaFotosNaoEncontrado() when naoEncontrado != null:
return naoEncontrado();case ListaFotosSessaoExpirada() when sessaoExpirada != null:
return sessaoExpirada();case _:
  return null;

}
}

}

/// @nodoc


class ListaFotosCarregando implements ListaFotos {
  const ListaFotosCarregando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ListaFotosCarregando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ListaFotos.carregando()';
}


}




/// @nodoc


class ListaFotosCarregada implements ListaFotos {
  const ListaFotosCarregada( List<FotoImovel> fotos): _fotos = fotos;
  

 final  List<FotoImovel> _fotos;
 List<FotoImovel> get fotos {
  if (_fotos is EqualUnmodifiableListView) return _fotos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fotos);
}


/// Create a copy of ListaFotos
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListaFotosCarregadaCopyWith<ListaFotosCarregada> get copyWith => _$ListaFotosCarregadaCopyWithImpl<ListaFotosCarregada>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ListaFotosCarregada&&const DeepCollectionEquality().equals(other.fotos, _fotos));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_fotos));
}

@override
String toString() {
    return 'ListaFotos.carregada(fotos: $fotos)';
}


}

/// @nodoc
abstract mixin class $ListaFotosCarregadaCopyWith<$Res> implements $ListaFotosCopyWith<$Res> {
  factory $ListaFotosCarregadaCopyWith(ListaFotosCarregada value, $Res Function(ListaFotosCarregada) _then) = _$ListaFotosCarregadaCopyWithImpl;
@useResult
$Res call({
 List<FotoImovel> fotos
});




}
/// @nodoc
class _$ListaFotosCarregadaCopyWithImpl<$Res>
    implements $ListaFotosCarregadaCopyWith<$Res> {
  _$ListaFotosCarregadaCopyWithImpl(this._self, this._then);

  final ListaFotosCarregada _self;
  final $Res Function(ListaFotosCarregada) _then;

/// Create a copy of ListaFotos
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fotos = null,}) {
  return _then(ListaFotosCarregada(
null == fotos ? _self._fotos : fotos // ignore: cast_nullable_to_non_nullable
as List<FotoImovel>,
  ));
}


}

/// @nodoc


class ListaFotosErro implements ListaFotos {
  const ListaFotosErro();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ListaFotosErro);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ListaFotos.erro()';
}


}




/// @nodoc


class ListaFotosNaoEncontrado implements ListaFotos {
  const ListaFotosNaoEncontrado();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ListaFotosNaoEncontrado);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ListaFotos.naoEncontrado()';
}


}




/// @nodoc


class ListaFotosSessaoExpirada implements ListaFotos {
  const ListaFotosSessaoExpirada();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ListaFotosSessaoExpirada);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ListaFotos.sessaoExpirada()';
}


}




/// @nodoc
mixin _$EnvioDeFoto {

/// Identificador local (não é o id do servidor).
 int get id;/// O arquivo como a câmera ou a galeria entregou (miniatura da fila).
 FotoEscolhida get original;/// O JPEG reduzido, depois de preparado; reaproveitado no "Tentar de novo".
 FotoEscolhida? get preparada; EstadoEnvio get estado;
/// Create a copy of EnvioDeFoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnvioDeFotoCopyWith<EnvioDeFoto> get copyWith => _$EnvioDeFotoCopyWithImpl<EnvioDeFoto>(this as EnvioDeFoto, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EnvioDeFoto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnvioDeFoto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.original, _this.original) || other.original == _this.original)&&(identical(other.preparada, _this.preparada) || other.preparada == _this.preparada)&&(identical(other.estado, _this.estado) || other.estado == _this.estado));
}


@override
int get hashCode {
  final _this = this as EnvioDeFoto;
  return Object.hash(runtimeType,_this.id,_this.original,_this.preparada,_this.estado);
}

@override
String toString() {
  final _this = this as EnvioDeFoto;
  return 'EnvioDeFoto(id: ${_this.id}, original: ${_this.original}, preparada: ${_this.preparada}, estado: ${_this.estado})';
}


}

/// @nodoc
abstract mixin class $EnvioDeFotoCopyWith<$Res>  {
  factory $EnvioDeFotoCopyWith(EnvioDeFoto value, $Res Function(EnvioDeFoto) _then) = _$EnvioDeFotoCopyWithImpl;
@useResult
$Res call({
 int id, FotoEscolhida original, FotoEscolhida? preparada, EstadoEnvio estado
});


$FotoEscolhidaCopyWith<$Res> get original;$FotoEscolhidaCopyWith<$Res>? get preparada;$EstadoEnvioCopyWith<$Res> get estado;

}
/// @nodoc
class _$EnvioDeFotoCopyWithImpl<$Res>
    implements $EnvioDeFotoCopyWith<$Res> {
  _$EnvioDeFotoCopyWithImpl(this._self, this._then);

  final EnvioDeFoto _self;
  final $Res Function(EnvioDeFoto) _then;

/// Create a copy of EnvioDeFoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? original = null,Object? preparada = freezed,Object? estado = null,}) {
  return _then(EnvioDeFoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,original: null == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as FotoEscolhida,preparada: freezed == preparada ? _self.preparada : preparada // ignore: cast_nullable_to_non_nullable
as FotoEscolhida?,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoEnvio,
  ));
}
/// Create a copy of EnvioDeFoto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FotoEscolhidaCopyWith<$Res> get original {
  
  return $FotoEscolhidaCopyWith<$Res>(_self.original, (value) {
    return _then(_self.copyWith(original: value));
  });
}/// Create a copy of EnvioDeFoto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FotoEscolhidaCopyWith<$Res>? get preparada {
    if (_self.preparada == null) {
    return null;
  }

  return $FotoEscolhidaCopyWith<$Res>(_self.preparada!, (value) {
    return _then(_self.copyWith(preparada: value));
  });
}/// Create a copy of EnvioDeFoto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EstadoEnvioCopyWith<$Res> get estado {
  
  return $EstadoEnvioCopyWith<$Res>(_self.estado, (value) {
    return _then(_self.copyWith(estado: value));
  });
}
}


/// Adds pattern-matching-related methods to [EnvioDeFoto].
extension EnvioDeFotoPatterns on EnvioDeFoto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnvioDeFoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnvioDeFoto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnvioDeFoto value)  $default,){
final _that = this;
switch (_that) {
case _EnvioDeFoto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnvioDeFoto value)?  $default,){
final _that = this;
switch (_that) {
case _EnvioDeFoto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  FotoEscolhida original,  FotoEscolhida? preparada,  EstadoEnvio estado)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnvioDeFoto() when $default != null:
return $default(_that.id,_that.original,_that.preparada,_that.estado);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  FotoEscolhida original,  FotoEscolhida? preparada,  EstadoEnvio estado)  $default,) {final _that = this;
switch (_that) {
case _EnvioDeFoto():
return $default(_that.id,_that.original,_that.preparada,_that.estado);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  FotoEscolhida original,  FotoEscolhida? preparada,  EstadoEnvio estado)?  $default,) {final _that = this;
switch (_that) {
case _EnvioDeFoto() when $default != null:
return $default(_that.id,_that.original,_that.preparada,_that.estado);case _:
  return null;

}
}

}

/// @nodoc


class _EnvioDeFoto implements EnvioDeFoto {
  const _EnvioDeFoto({required this.id, required this.original, this.preparada, this.estado = const EstadoEnvio.aguardando()});
  

/// Identificador local (não é o id do servidor).
@override final  int id;
/// O arquivo como a câmera ou a galeria entregou (miniatura da fila).
@override final  FotoEscolhida original;
/// O JPEG reduzido, depois de preparado; reaproveitado no "Tentar de novo".
@override final  FotoEscolhida? preparada;
@override@JsonKey() final  EstadoEnvio estado;

/// Create a copy of EnvioDeFoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnvioDeFotoCopyWith<_EnvioDeFoto> get copyWith => __$EnvioDeFotoCopyWithImpl<_EnvioDeFoto>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnvioDeFoto&&(identical(other.id, id) || other.id == id)&&(identical(other.original, original) || other.original == original)&&(identical(other.preparada, preparada) || other.preparada == preparada)&&(identical(other.estado, estado) || other.estado == estado));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,original,preparada,estado);
}

@override
String toString() {
    return 'EnvioDeFoto(id: $id, original: $original, preparada: $preparada, estado: $estado)';
}


}

/// @nodoc
abstract mixin class _$EnvioDeFotoCopyWith<$Res> implements $EnvioDeFotoCopyWith<$Res> {
  factory _$EnvioDeFotoCopyWith(_EnvioDeFoto value, $Res Function(_EnvioDeFoto) _then) = __$EnvioDeFotoCopyWithImpl;
@override @useResult
$Res call({
 int id, FotoEscolhida original, FotoEscolhida? preparada, EstadoEnvio estado
});


@override $FotoEscolhidaCopyWith<$Res> get original;@override $FotoEscolhidaCopyWith<$Res>? get preparada;@override $EstadoEnvioCopyWith<$Res> get estado;

}
/// @nodoc
class __$EnvioDeFotoCopyWithImpl<$Res>
    implements _$EnvioDeFotoCopyWith<$Res> {
  __$EnvioDeFotoCopyWithImpl(this._self, this._then);

  final _EnvioDeFoto _self;
  final $Res Function(_EnvioDeFoto) _then;

/// Create a copy of EnvioDeFoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? original = null,Object? preparada = freezed,Object? estado = null,}) {
  return _then(_EnvioDeFoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,original: null == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as FotoEscolhida,preparada: freezed == preparada ? _self.preparada : preparada // ignore: cast_nullable_to_non_nullable
as FotoEscolhida?,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoEnvio,
  ));
}

/// Create a copy of EnvioDeFoto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FotoEscolhidaCopyWith<$Res> get original {
  
  return $FotoEscolhidaCopyWith<$Res>(_self.original, (value) {
    return _then(_self.copyWith(original: value));
  });
}/// Create a copy of EnvioDeFoto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FotoEscolhidaCopyWith<$Res>? get preparada {
    if (_self.preparada == null) {
    return null;
  }

  return $FotoEscolhidaCopyWith<$Res>(_self.preparada!, (value) {
    return _then(_self.copyWith(preparada: value));
  });
}/// Create a copy of EnvioDeFoto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EstadoEnvioCopyWith<$Res> get estado {
  
  return $EstadoEnvioCopyWith<$Res>(_self.estado, (value) {
    return _then(_self.copyWith(estado: value));
  });
}
}

/// @nodoc
mixin _$EstadoEnvio {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EstadoEnvio);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EstadoEnvio()';
}


}

/// @nodoc
class $EstadoEnvioCopyWith<$Res>  {
$EstadoEnvioCopyWith(EstadoEnvio _, $Res Function(EstadoEnvio) __);
}


/// Adds pattern-matching-related methods to [EstadoEnvio].
extension EstadoEnvioPatterns on EstadoEnvio {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EnvioAguardando value)?  aguardando,TResult Function( EnvioPreparando value)?  preparando,TResult Function( EnvioEnviando value)?  enviando,TResult Function( EnvioFalhou value)?  falhou,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EnvioAguardando() when aguardando != null:
return aguardando(_that);case EnvioPreparando() when preparando != null:
return preparando(_that);case EnvioEnviando() when enviando != null:
return enviando(_that);case EnvioFalhou() when falhou != null:
return falhou(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EnvioAguardando value)  aguardando,required TResult Function( EnvioPreparando value)  preparando,required TResult Function( EnvioEnviando value)  enviando,required TResult Function( EnvioFalhou value)  falhou,}){
final _that = this;
switch (_that) {
case EnvioAguardando():
return aguardando(_that);case EnvioPreparando():
return preparando(_that);case EnvioEnviando():
return enviando(_that);case EnvioFalhou():
return falhou(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EnvioAguardando value)?  aguardando,TResult? Function( EnvioPreparando value)?  preparando,TResult? Function( EnvioEnviando value)?  enviando,TResult? Function( EnvioFalhou value)?  falhou,}){
final _that = this;
switch (_that) {
case EnvioAguardando() when aguardando != null:
return aguardando(_that);case EnvioPreparando() when preparando != null:
return preparando(_that);case EnvioEnviando() when enviando != null:
return enviando(_that);case EnvioFalhou() when falhou != null:
return falhou(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  aguardando,TResult Function()?  preparando,TResult Function( double? progresso)?  enviando,TResult Function( String? mensagemDoServidor,  bool noPreparo)?  falhou,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EnvioAguardando() when aguardando != null:
return aguardando();case EnvioPreparando() when preparando != null:
return preparando();case EnvioEnviando() when enviando != null:
return enviando(_that.progresso);case EnvioFalhou() when falhou != null:
return falhou(_that.mensagemDoServidor,_that.noPreparo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  aguardando,required TResult Function()  preparando,required TResult Function( double? progresso)  enviando,required TResult Function( String? mensagemDoServidor,  bool noPreparo)  falhou,}) {final _that = this;
switch (_that) {
case EnvioAguardando():
return aguardando();case EnvioPreparando():
return preparando();case EnvioEnviando():
return enviando(_that.progresso);case EnvioFalhou():
return falhou(_that.mensagemDoServidor,_that.noPreparo);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  aguardando,TResult? Function()?  preparando,TResult? Function( double? progresso)?  enviando,TResult? Function( String? mensagemDoServidor,  bool noPreparo)?  falhou,}) {final _that = this;
switch (_that) {
case EnvioAguardando() when aguardando != null:
return aguardando();case EnvioPreparando() when preparando != null:
return preparando();case EnvioEnviando() when enviando != null:
return enviando(_that.progresso);case EnvioFalhou() when falhou != null:
return falhou(_that.mensagemDoServidor,_that.noPreparo);case _:
  return null;

}
}

}

/// @nodoc


class EnvioAguardando implements EstadoEnvio {
  const EnvioAguardando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EnvioAguardando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EstadoEnvio.aguardando()';
}


}




/// @nodoc


class EnvioPreparando implements EstadoEnvio {
  const EnvioPreparando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EnvioPreparando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EstadoEnvio.preparando()';
}


}




/// @nodoc


class EnvioEnviando implements EstadoEnvio {
  const EnvioEnviando({this.progresso});
  

 final  double? progresso;

/// Create a copy of EstadoEnvio
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnvioEnviandoCopyWith<EnvioEnviando> get copyWith => _$EnvioEnviandoCopyWithImpl<EnvioEnviando>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EnvioEnviando&&(identical(other.progresso, progresso) || other.progresso == progresso));
}


@override
int get hashCode {
    return Object.hash(runtimeType,progresso);
}

@override
String toString() {
    return 'EstadoEnvio.enviando(progresso: $progresso)';
}


}

/// @nodoc
abstract mixin class $EnvioEnviandoCopyWith<$Res> implements $EstadoEnvioCopyWith<$Res> {
  factory $EnvioEnviandoCopyWith(EnvioEnviando value, $Res Function(EnvioEnviando) _then) = _$EnvioEnviandoCopyWithImpl;
@useResult
$Res call({
 double? progresso
});




}
/// @nodoc
class _$EnvioEnviandoCopyWithImpl<$Res>
    implements $EnvioEnviandoCopyWith<$Res> {
  _$EnvioEnviandoCopyWithImpl(this._self, this._then);

  final EnvioEnviando _self;
  final $Res Function(EnvioEnviando) _then;

/// Create a copy of EstadoEnvio
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? progresso = freezed,}) {
  return _then(EnvioEnviando(
progresso: freezed == progresso ? _self.progresso : progresso // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc


class EnvioFalhou implements EstadoEnvio {
  const EnvioFalhou({this.mensagemDoServidor, this.noPreparo = false});
  

 final  String? mensagemDoServidor;
@JsonKey() final  bool noPreparo;

/// Create a copy of EstadoEnvio
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnvioFalhouCopyWith<EnvioFalhou> get copyWith => _$EnvioFalhouCopyWithImpl<EnvioFalhou>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EnvioFalhou&&(identical(other.mensagemDoServidor, mensagemDoServidor) || other.mensagemDoServidor == mensagemDoServidor)&&(identical(other.noPreparo, noPreparo) || other.noPreparo == noPreparo));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mensagemDoServidor,noPreparo);
}

@override
String toString() {
    return 'EstadoEnvio.falhou(mensagemDoServidor: $mensagemDoServidor, noPreparo: $noPreparo)';
}


}

/// @nodoc
abstract mixin class $EnvioFalhouCopyWith<$Res> implements $EstadoEnvioCopyWith<$Res> {
  factory $EnvioFalhouCopyWith(EnvioFalhou value, $Res Function(EnvioFalhou) _then) = _$EnvioFalhouCopyWithImpl;
@useResult
$Res call({
 String? mensagemDoServidor, bool noPreparo
});




}
/// @nodoc
class _$EnvioFalhouCopyWithImpl<$Res>
    implements $EnvioFalhouCopyWith<$Res> {
  _$EnvioFalhouCopyWithImpl(this._self, this._then);

  final EnvioFalhou _self;
  final $Res Function(EnvioFalhou) _then;

/// Create a copy of EstadoEnvio
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? mensagemDoServidor = freezed,Object? noPreparo = null,}) {
  return _then(EnvioFalhou(
mensagemDoServidor: freezed == mensagemDoServidor ? _self.mensagemDoServidor : mensagemDoServidor // ignore: cast_nullable_to_non_nullable
as String?,noPreparo: null == noPreparo ? _self.noPreparo : noPreparo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$OperacaoFotos {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OperacaoFotos);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OperacaoFotos()';
}


}

/// @nodoc
class $OperacaoFotosCopyWith<$Res>  {
$OperacaoFotosCopyWith(OperacaoFotos _, $Res Function(OperacaoFotos) __);
}


/// Adds pattern-matching-related methods to [OperacaoFotos].
extension OperacaoFotosPatterns on OperacaoFotos {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OperacaoNenhuma value)?  nenhuma,TResult Function( OperacaoReordenando value)?  reordenando,TResult Function( OperacaoDefinindoCapa value)?  definindoCapa,TResult Function( OperacaoApagando value)?  apagando,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OperacaoNenhuma() when nenhuma != null:
return nenhuma(_that);case OperacaoReordenando() when reordenando != null:
return reordenando(_that);case OperacaoDefinindoCapa() when definindoCapa != null:
return definindoCapa(_that);case OperacaoApagando() when apagando != null:
return apagando(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OperacaoNenhuma value)  nenhuma,required TResult Function( OperacaoReordenando value)  reordenando,required TResult Function( OperacaoDefinindoCapa value)  definindoCapa,required TResult Function( OperacaoApagando value)  apagando,}){
final _that = this;
switch (_that) {
case OperacaoNenhuma():
return nenhuma(_that);case OperacaoReordenando():
return reordenando(_that);case OperacaoDefinindoCapa():
return definindoCapa(_that);case OperacaoApagando():
return apagando(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OperacaoNenhuma value)?  nenhuma,TResult? Function( OperacaoReordenando value)?  reordenando,TResult? Function( OperacaoDefinindoCapa value)?  definindoCapa,TResult? Function( OperacaoApagando value)?  apagando,}){
final _that = this;
switch (_that) {
case OperacaoNenhuma() when nenhuma != null:
return nenhuma(_that);case OperacaoReordenando() when reordenando != null:
return reordenando(_that);case OperacaoDefinindoCapa() when definindoCapa != null:
return definindoCapa(_that);case OperacaoApagando() when apagando != null:
return apagando(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  nenhuma,TResult Function()?  reordenando,TResult Function( int fotoId)?  definindoCapa,TResult Function( int fotoId)?  apagando,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OperacaoNenhuma() when nenhuma != null:
return nenhuma();case OperacaoReordenando() when reordenando != null:
return reordenando();case OperacaoDefinindoCapa() when definindoCapa != null:
return definindoCapa(_that.fotoId);case OperacaoApagando() when apagando != null:
return apagando(_that.fotoId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  nenhuma,required TResult Function()  reordenando,required TResult Function( int fotoId)  definindoCapa,required TResult Function( int fotoId)  apagando,}) {final _that = this;
switch (_that) {
case OperacaoNenhuma():
return nenhuma();case OperacaoReordenando():
return reordenando();case OperacaoDefinindoCapa():
return definindoCapa(_that.fotoId);case OperacaoApagando():
return apagando(_that.fotoId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  nenhuma,TResult? Function()?  reordenando,TResult? Function( int fotoId)?  definindoCapa,TResult? Function( int fotoId)?  apagando,}) {final _that = this;
switch (_that) {
case OperacaoNenhuma() when nenhuma != null:
return nenhuma();case OperacaoReordenando() when reordenando != null:
return reordenando();case OperacaoDefinindoCapa() when definindoCapa != null:
return definindoCapa(_that.fotoId);case OperacaoApagando() when apagando != null:
return apagando(_that.fotoId);case _:
  return null;

}
}

}

/// @nodoc


class OperacaoNenhuma implements OperacaoFotos {
  const OperacaoNenhuma();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OperacaoNenhuma);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OperacaoFotos.nenhuma()';
}


}




/// @nodoc


class OperacaoReordenando implements OperacaoFotos {
  const OperacaoReordenando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OperacaoReordenando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OperacaoFotos.reordenando()';
}


}




/// @nodoc


class OperacaoDefinindoCapa implements OperacaoFotos {
  const OperacaoDefinindoCapa(this.fotoId);
  

 final  int fotoId;

/// Create a copy of OperacaoFotos
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperacaoDefinindoCapaCopyWith<OperacaoDefinindoCapa> get copyWith => _$OperacaoDefinindoCapaCopyWithImpl<OperacaoDefinindoCapa>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OperacaoDefinindoCapa&&(identical(other.fotoId, fotoId) || other.fotoId == fotoId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,fotoId);
}

@override
String toString() {
    return 'OperacaoFotos.definindoCapa(fotoId: $fotoId)';
}


}

/// @nodoc
abstract mixin class $OperacaoDefinindoCapaCopyWith<$Res> implements $OperacaoFotosCopyWith<$Res> {
  factory $OperacaoDefinindoCapaCopyWith(OperacaoDefinindoCapa value, $Res Function(OperacaoDefinindoCapa) _then) = _$OperacaoDefinindoCapaCopyWithImpl;
@useResult
$Res call({
 int fotoId
});




}
/// @nodoc
class _$OperacaoDefinindoCapaCopyWithImpl<$Res>
    implements $OperacaoDefinindoCapaCopyWith<$Res> {
  _$OperacaoDefinindoCapaCopyWithImpl(this._self, this._then);

  final OperacaoDefinindoCapa _self;
  final $Res Function(OperacaoDefinindoCapa) _then;

/// Create a copy of OperacaoFotos
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fotoId = null,}) {
  return _then(OperacaoDefinindoCapa(
null == fotoId ? _self.fotoId : fotoId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class OperacaoApagando implements OperacaoFotos {
  const OperacaoApagando(this.fotoId);
  

 final  int fotoId;

/// Create a copy of OperacaoFotos
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperacaoApagandoCopyWith<OperacaoApagando> get copyWith => _$OperacaoApagandoCopyWithImpl<OperacaoApagando>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OperacaoApagando&&(identical(other.fotoId, fotoId) || other.fotoId == fotoId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,fotoId);
}

@override
String toString() {
    return 'OperacaoFotos.apagando(fotoId: $fotoId)';
}


}

/// @nodoc
abstract mixin class $OperacaoApagandoCopyWith<$Res> implements $OperacaoFotosCopyWith<$Res> {
  factory $OperacaoApagandoCopyWith(OperacaoApagando value, $Res Function(OperacaoApagando) _then) = _$OperacaoApagandoCopyWithImpl;
@useResult
$Res call({
 int fotoId
});




}
/// @nodoc
class _$OperacaoApagandoCopyWithImpl<$Res>
    implements $OperacaoApagandoCopyWith<$Res> {
  _$OperacaoApagandoCopyWithImpl(this._self, this._then);

  final OperacaoApagando _self;
  final $Res Function(OperacaoApagando) _then;

/// Create a copy of OperacaoFotos
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fotoId = null,}) {
  return _then(OperacaoApagando(
null == fotoId ? _self.fotoId : fotoId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
