// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'caixa_contatos_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CaixaContatosState {

/// Consulta aplicada à lista (imóvel e período); sem filtro por padrão.
 ConsultaContatos get consulta;/// Contatos sem retorno, como o servidor contou (D-04, D-06). `null` =
/// ainda não veio ou falhou: a tela some com a linha e a lista segue
/// (D-22). O app nunca soma nem subtrai este número.
 int? get semRetorno; ConteudoCaixa get conteudo;/// Opções do filtro por imóvel, como o servidor devolveu (D-19). Pedidas a
/// cada abertura da folha — não fazem parte da lista nem da consulta.
 OpcoesDeImovel get opcoesDeImovel;/// Aviso de uma anotação que não deu certo — one-shot da `SnackBar` (D-17).
/// Toda anotação começa limpando-o, então duas falhas seguidas passam por
/// um estado sem aviso e a tela mostra as duas.
 AvisoCaixa? get aviso;
/// Create a copy of CaixaContatosState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaixaContatosStateCopyWith<CaixaContatosState> get copyWith => _$CaixaContatosStateCopyWithImpl<CaixaContatosState>(this as CaixaContatosState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CaixaContatosState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaixaContatosState&&(identical(other.consulta, _this.consulta) || other.consulta == _this.consulta)&&(identical(other.semRetorno, _this.semRetorno) || other.semRetorno == _this.semRetorno)&&(identical(other.conteudo, _this.conteudo) || other.conteudo == _this.conteudo)&&(identical(other.opcoesDeImovel, _this.opcoesDeImovel) || other.opcoesDeImovel == _this.opcoesDeImovel)&&(identical(other.aviso, _this.aviso) || other.aviso == _this.aviso));
}


@override
int get hashCode {
  final _this = this as CaixaContatosState;
  return Object.hash(runtimeType,_this.consulta,_this.semRetorno,_this.conteudo,_this.opcoesDeImovel,_this.aviso);
}

@override
String toString() {
  final _this = this as CaixaContatosState;
  return 'CaixaContatosState(consulta: ${_this.consulta}, semRetorno: ${_this.semRetorno}, conteudo: ${_this.conteudo}, opcoesDeImovel: ${_this.opcoesDeImovel}, aviso: ${_this.aviso})';
}


}

/// @nodoc
abstract mixin class $CaixaContatosStateCopyWith<$Res>  {
  factory $CaixaContatosStateCopyWith(CaixaContatosState value, $Res Function(CaixaContatosState) _then) = _$CaixaContatosStateCopyWithImpl;
@useResult
$Res call({
 ConsultaContatos consulta, int? semRetorno, ConteudoCaixa conteudo, OpcoesDeImovel opcoesDeImovel, AvisoCaixa? aviso
});


$ConteudoCaixaCopyWith<$Res> get conteudo;$OpcoesDeImovelCopyWith<$Res> get opcoesDeImovel;

}
/// @nodoc
class _$CaixaContatosStateCopyWithImpl<$Res>
    implements $CaixaContatosStateCopyWith<$Res> {
  _$CaixaContatosStateCopyWithImpl(this._self, this._then);

  final CaixaContatosState _self;
  final $Res Function(CaixaContatosState) _then;

/// Create a copy of CaixaContatosState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? consulta = null,Object? semRetorno = freezed,Object? conteudo = null,Object? opcoesDeImovel = null,Object? aviso = freezed,}) {
  return _then(CaixaContatosState(
consulta: null == consulta ? _self.consulta : consulta // ignore: cast_nullable_to_non_nullable
as ConsultaContatos,semRetorno: freezed == semRetorno ? _self.semRetorno : semRetorno // ignore: cast_nullable_to_non_nullable
as int?,conteudo: null == conteudo ? _self.conteudo : conteudo // ignore: cast_nullable_to_non_nullable
as ConteudoCaixa,opcoesDeImovel: null == opcoesDeImovel ? _self.opcoesDeImovel : opcoesDeImovel // ignore: cast_nullable_to_non_nullable
as OpcoesDeImovel,aviso: freezed == aviso ? _self.aviso : aviso // ignore: cast_nullable_to_non_nullable
as AvisoCaixa?,
  ));
}
/// Create a copy of CaixaContatosState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConteudoCaixaCopyWith<$Res> get conteudo {
  
  return $ConteudoCaixaCopyWith<$Res>(_self.conteudo, (value) {
    return _then(_self.copyWith(conteudo: value));
  });
}/// Create a copy of CaixaContatosState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpcoesDeImovelCopyWith<$Res> get opcoesDeImovel {
  
  return $OpcoesDeImovelCopyWith<$Res>(_self.opcoesDeImovel, (value) {
    return _then(_self.copyWith(opcoesDeImovel: value));
  });
}
}


/// Adds pattern-matching-related methods to [CaixaContatosState].
extension CaixaContatosStatePatterns on CaixaContatosState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaixaContatosState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaixaContatosState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaixaContatosState value)  $default,){
final _that = this;
switch (_that) {
case _CaixaContatosState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaixaContatosState value)?  $default,){
final _that = this;
switch (_that) {
case _CaixaContatosState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ConsultaContatos consulta,  int? semRetorno,  ConteudoCaixa conteudo,  OpcoesDeImovel opcoesDeImovel,  AvisoCaixa? aviso)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaixaContatosState() when $default != null:
return $default(_that.consulta,_that.semRetorno,_that.conteudo,_that.opcoesDeImovel,_that.aviso);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ConsultaContatos consulta,  int? semRetorno,  ConteudoCaixa conteudo,  OpcoesDeImovel opcoesDeImovel,  AvisoCaixa? aviso)  $default,) {final _that = this;
switch (_that) {
case _CaixaContatosState():
return $default(_that.consulta,_that.semRetorno,_that.conteudo,_that.opcoesDeImovel,_that.aviso);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ConsultaContatos consulta,  int? semRetorno,  ConteudoCaixa conteudo,  OpcoesDeImovel opcoesDeImovel,  AvisoCaixa? aviso)?  $default,) {final _that = this;
switch (_that) {
case _CaixaContatosState() when $default != null:
return $default(_that.consulta,_that.semRetorno,_that.conteudo,_that.opcoesDeImovel,_that.aviso);case _:
  return null;

}
}

}

/// @nodoc


class _CaixaContatosState implements CaixaContatosState {
  const _CaixaContatosState({this.consulta = const ConsultaContatos(), this.semRetorno, this.conteudo = const ConteudoCaixa.carregando(), this.opcoesDeImovel = const OpcoesDeImovel.naoCarregadas(), this.aviso});
  

/// Consulta aplicada à lista (imóvel e período); sem filtro por padrão.
@override@JsonKey() final  ConsultaContatos consulta;
/// Contatos sem retorno, como o servidor contou (D-04, D-06). `null` =
/// ainda não veio ou falhou: a tela some com a linha e a lista segue
/// (D-22). O app nunca soma nem subtrai este número.
@override final  int? semRetorno;
@override@JsonKey() final  ConteudoCaixa conteudo;
/// Opções do filtro por imóvel, como o servidor devolveu (D-19). Pedidas a
/// cada abertura da folha — não fazem parte da lista nem da consulta.
@override@JsonKey() final  OpcoesDeImovel opcoesDeImovel;
/// Aviso de uma anotação que não deu certo — one-shot da `SnackBar` (D-17).
/// Toda anotação começa limpando-o, então duas falhas seguidas passam por
/// um estado sem aviso e a tela mostra as duas.
@override final  AvisoCaixa? aviso;

/// Create a copy of CaixaContatosState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaixaContatosStateCopyWith<_CaixaContatosState> get copyWith => __$CaixaContatosStateCopyWithImpl<_CaixaContatosState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaixaContatosState&&(identical(other.consulta, consulta) || other.consulta == consulta)&&(identical(other.semRetorno, semRetorno) || other.semRetorno == semRetorno)&&(identical(other.conteudo, conteudo) || other.conteudo == conteudo)&&(identical(other.opcoesDeImovel, opcoesDeImovel) || other.opcoesDeImovel == opcoesDeImovel)&&(identical(other.aviso, aviso) || other.aviso == aviso));
}


@override
int get hashCode {
    return Object.hash(runtimeType,consulta,semRetorno,conteudo,opcoesDeImovel,aviso);
}

@override
String toString() {
    return 'CaixaContatosState(consulta: $consulta, semRetorno: $semRetorno, conteudo: $conteudo, opcoesDeImovel: $opcoesDeImovel, aviso: $aviso)';
}


}

/// @nodoc
abstract mixin class _$CaixaContatosStateCopyWith<$Res> implements $CaixaContatosStateCopyWith<$Res> {
  factory _$CaixaContatosStateCopyWith(_CaixaContatosState value, $Res Function(_CaixaContatosState) _then) = __$CaixaContatosStateCopyWithImpl;
@override @useResult
$Res call({
 ConsultaContatos consulta, int? semRetorno, ConteudoCaixa conteudo, OpcoesDeImovel opcoesDeImovel, AvisoCaixa? aviso
});


@override $ConteudoCaixaCopyWith<$Res> get conteudo;@override $OpcoesDeImovelCopyWith<$Res> get opcoesDeImovel;

}
/// @nodoc
class __$CaixaContatosStateCopyWithImpl<$Res>
    implements _$CaixaContatosStateCopyWith<$Res> {
  __$CaixaContatosStateCopyWithImpl(this._self, this._then);

  final _CaixaContatosState _self;
  final $Res Function(_CaixaContatosState) _then;

/// Create a copy of CaixaContatosState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? consulta = null,Object? semRetorno = freezed,Object? conteudo = null,Object? opcoesDeImovel = null,Object? aviso = freezed,}) {
  return _then(_CaixaContatosState(
consulta: null == consulta ? _self.consulta : consulta // ignore: cast_nullable_to_non_nullable
as ConsultaContatos,semRetorno: freezed == semRetorno ? _self.semRetorno : semRetorno // ignore: cast_nullable_to_non_nullable
as int?,conteudo: null == conteudo ? _self.conteudo : conteudo // ignore: cast_nullable_to_non_nullable
as ConteudoCaixa,opcoesDeImovel: null == opcoesDeImovel ? _self.opcoesDeImovel : opcoesDeImovel // ignore: cast_nullable_to_non_nullable
as OpcoesDeImovel,aviso: freezed == aviso ? _self.aviso : aviso // ignore: cast_nullable_to_non_nullable
as AvisoCaixa?,
  ));
}

/// Create a copy of CaixaContatosState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConteudoCaixaCopyWith<$Res> get conteudo {
  
  return $ConteudoCaixaCopyWith<$Res>(_self.conteudo, (value) {
    return _then(_self.copyWith(conteudo: value));
  });
}/// Create a copy of CaixaContatosState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpcoesDeImovelCopyWith<$Res> get opcoesDeImovel {
  
  return $OpcoesDeImovelCopyWith<$Res>(_self.opcoesDeImovel, (value) {
    return _then(_self.copyWith(opcoesDeImovel: value));
  });
}
}

/// @nodoc
mixin _$ConteudoCaixa {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConteudoCaixa);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoCaixa()';
}


}

/// @nodoc
class $ConteudoCaixaCopyWith<$Res>  {
$ConteudoCaixaCopyWith(ConteudoCaixa _, $Res Function(ConteudoCaixa) __);
}


/// Adds pattern-matching-related methods to [ConteudoCaixa].
extension ConteudoCaixaPatterns on ConteudoCaixa {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CaixaCarregando value)?  carregando,TResult Function( CaixaVazia value)?  vazio,TResult Function( CaixaSemResultado value)?  semResultado,TResult Function( CaixaErro value)?  erro,TResult Function( CaixaSessaoExpirada value)?  sessaoExpirada,TResult Function( CaixaCarregada value)?  carregada,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CaixaCarregando() when carregando != null:
return carregando(_that);case CaixaVazia() when vazio != null:
return vazio(_that);case CaixaSemResultado() when semResultado != null:
return semResultado(_that);case CaixaErro() when erro != null:
return erro(_that);case CaixaSessaoExpirada() when sessaoExpirada != null:
return sessaoExpirada(_that);case CaixaCarregada() when carregada != null:
return carregada(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CaixaCarregando value)  carregando,required TResult Function( CaixaVazia value)  vazio,required TResult Function( CaixaSemResultado value)  semResultado,required TResult Function( CaixaErro value)  erro,required TResult Function( CaixaSessaoExpirada value)  sessaoExpirada,required TResult Function( CaixaCarregada value)  carregada,}){
final _that = this;
switch (_that) {
case CaixaCarregando():
return carregando(_that);case CaixaVazia():
return vazio(_that);case CaixaSemResultado():
return semResultado(_that);case CaixaErro():
return erro(_that);case CaixaSessaoExpirada():
return sessaoExpirada(_that);case CaixaCarregada():
return carregada(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CaixaCarregando value)?  carregando,TResult? Function( CaixaVazia value)?  vazio,TResult? Function( CaixaSemResultado value)?  semResultado,TResult? Function( CaixaErro value)?  erro,TResult? Function( CaixaSessaoExpirada value)?  sessaoExpirada,TResult? Function( CaixaCarregada value)?  carregada,}){
final _that = this;
switch (_that) {
case CaixaCarregando() when carregando != null:
return carregando(_that);case CaixaVazia() when vazio != null:
return vazio(_that);case CaixaSemResultado() when semResultado != null:
return semResultado(_that);case CaixaErro() when erro != null:
return erro(_that);case CaixaSessaoExpirada() when sessaoExpirada != null:
return sessaoExpirada(_that);case CaixaCarregada() when carregada != null:
return carregada(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  carregando,TResult Function()?  vazio,TResult Function()?  semResultado,TResult Function()?  erro,TResult Function()?  sessaoExpirada,TResult Function( List<ContatoRecebido> itens,  String? proximaPagina,  bool carregandoMais,  bool erroAoCarregarMais,  Set<int> anotando)?  carregada,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CaixaCarregando() when carregando != null:
return carregando();case CaixaVazia() when vazio != null:
return vazio();case CaixaSemResultado() when semResultado != null:
return semResultado();case CaixaErro() when erro != null:
return erro();case CaixaSessaoExpirada() when sessaoExpirada != null:
return sessaoExpirada();case CaixaCarregada() when carregada != null:
return carregada(_that.itens,_that.proximaPagina,_that.carregandoMais,_that.erroAoCarregarMais,_that.anotando);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  carregando,required TResult Function()  vazio,required TResult Function()  semResultado,required TResult Function()  erro,required TResult Function()  sessaoExpirada,required TResult Function( List<ContatoRecebido> itens,  String? proximaPagina,  bool carregandoMais,  bool erroAoCarregarMais,  Set<int> anotando)  carregada,}) {final _that = this;
switch (_that) {
case CaixaCarregando():
return carregando();case CaixaVazia():
return vazio();case CaixaSemResultado():
return semResultado();case CaixaErro():
return erro();case CaixaSessaoExpirada():
return sessaoExpirada();case CaixaCarregada():
return carregada(_that.itens,_that.proximaPagina,_that.carregandoMais,_that.erroAoCarregarMais,_that.anotando);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  carregando,TResult? Function()?  vazio,TResult? Function()?  semResultado,TResult? Function()?  erro,TResult? Function()?  sessaoExpirada,TResult? Function( List<ContatoRecebido> itens,  String? proximaPagina,  bool carregandoMais,  bool erroAoCarregarMais,  Set<int> anotando)?  carregada,}) {final _that = this;
switch (_that) {
case CaixaCarregando() when carregando != null:
return carregando();case CaixaVazia() when vazio != null:
return vazio();case CaixaSemResultado() when semResultado != null:
return semResultado();case CaixaErro() when erro != null:
return erro();case CaixaSessaoExpirada() when sessaoExpirada != null:
return sessaoExpirada();case CaixaCarregada() when carregada != null:
return carregada(_that.itens,_that.proximaPagina,_that.carregandoMais,_that.erroAoCarregarMais,_that.anotando);case _:
  return null;

}
}

}

/// @nodoc


class CaixaCarregando implements ConteudoCaixa {
  const CaixaCarregando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CaixaCarregando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoCaixa.carregando()';
}


}




/// @nodoc


class CaixaVazia implements ConteudoCaixa {
  const CaixaVazia();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CaixaVazia);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoCaixa.vazio()';
}


}




/// @nodoc


class CaixaSemResultado implements ConteudoCaixa {
  const CaixaSemResultado();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CaixaSemResultado);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoCaixa.semResultado()';
}


}




/// @nodoc


class CaixaErro implements ConteudoCaixa {
  const CaixaErro();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CaixaErro);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoCaixa.erro()';
}


}




/// @nodoc


class CaixaSessaoExpirada implements ConteudoCaixa {
  const CaixaSessaoExpirada();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CaixaSessaoExpirada);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoCaixa.sessaoExpirada()';
}


}




/// @nodoc


class CaixaCarregada implements ConteudoCaixa {
  const CaixaCarregada({required  List<ContatoRecebido> itens, this.proximaPagina, this.carregandoMais = false, this.erroAoCarregarMais = false,  Set<int> anotando = const <int>{}}): _itens = itens,_anotando = anotando;
  

 final  List<ContatoRecebido> _itens;
 List<ContatoRecebido> get itens {
  if (_itens is EqualUnmodifiableListView) return _itens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_itens);
}

 final  String? proximaPagina;
@JsonKey() final  bool carregandoMais;
@JsonKey() final  bool erroAoCarregarMais;
/// Ids com `PATCH` em voo (D-16): o item mostra carregamento e ignora
/// toques até o servidor responder.
 final  Set<int> _anotando;
/// Ids com `PATCH` em voo (D-16): o item mostra carregamento e ignora
/// toques até o servidor responder.
@JsonKey() Set<int> get anotando {
  if (_anotando is EqualUnmodifiableSetView) return _anotando;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_anotando);
}


/// Create a copy of ConteudoCaixa
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaixaCarregadaCopyWith<CaixaCarregada> get copyWith => _$CaixaCarregadaCopyWithImpl<CaixaCarregada>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CaixaCarregada&&const DeepCollectionEquality().equals(other.itens, _itens)&&(identical(other.proximaPagina, proximaPagina) || other.proximaPagina == proximaPagina)&&(identical(other.carregandoMais, carregandoMais) || other.carregandoMais == carregandoMais)&&(identical(other.erroAoCarregarMais, erroAoCarregarMais) || other.erroAoCarregarMais == erroAoCarregarMais)&&const DeepCollectionEquality().equals(other.anotando, _anotando));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_itens),proximaPagina,carregandoMais,erroAoCarregarMais,const DeepCollectionEquality().hash(_anotando));
}

@override
String toString() {
    return 'ConteudoCaixa.carregada(itens: $itens, proximaPagina: $proximaPagina, carregandoMais: $carregandoMais, erroAoCarregarMais: $erroAoCarregarMais, anotando: $anotando)';
}


}

/// @nodoc
abstract mixin class $CaixaCarregadaCopyWith<$Res> implements $ConteudoCaixaCopyWith<$Res> {
  factory $CaixaCarregadaCopyWith(CaixaCarregada value, $Res Function(CaixaCarregada) _then) = _$CaixaCarregadaCopyWithImpl;
@useResult
$Res call({
 List<ContatoRecebido> itens, String? proximaPagina, bool carregandoMais, bool erroAoCarregarMais, Set<int> anotando
});




}
/// @nodoc
class _$CaixaCarregadaCopyWithImpl<$Res>
    implements $CaixaCarregadaCopyWith<$Res> {
  _$CaixaCarregadaCopyWithImpl(this._self, this._then);

  final CaixaCarregada _self;
  final $Res Function(CaixaCarregada) _then;

/// Create a copy of ConteudoCaixa
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? itens = null,Object? proximaPagina = freezed,Object? carregandoMais = null,Object? erroAoCarregarMais = null,Object? anotando = null,}) {
  return _then(CaixaCarregada(
itens: null == itens ? _self._itens : itens // ignore: cast_nullable_to_non_nullable
as List<ContatoRecebido>,proximaPagina: freezed == proximaPagina ? _self.proximaPagina : proximaPagina // ignore: cast_nullable_to_non_nullable
as String?,carregandoMais: null == carregandoMais ? _self.carregandoMais : carregandoMais // ignore: cast_nullable_to_non_nullable
as bool,erroAoCarregarMais: null == erroAoCarregarMais ? _self.erroAoCarregarMais : erroAoCarregarMais // ignore: cast_nullable_to_non_nullable
as bool,anotando: null == anotando ? _self._anotando : anotando // ignore: cast_nullable_to_non_nullable
as Set<int>,
  ));
}


}

/// @nodoc
mixin _$OpcoesDeImovel {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OpcoesDeImovel);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OpcoesDeImovel()';
}


}

/// @nodoc
class $OpcoesDeImovelCopyWith<$Res>  {
$OpcoesDeImovelCopyWith(OpcoesDeImovel _, $Res Function(OpcoesDeImovel) __);
}


/// Adds pattern-matching-related methods to [OpcoesDeImovel].
extension OpcoesDeImovelPatterns on OpcoesDeImovel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OpcoesNaoCarregadas value)?  naoCarregadas,TResult Function( OpcoesCarregando value)?  carregando,TResult Function( OpcoesCarregadas value)?  carregadas,TResult Function( OpcoesComErro value)?  erro,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OpcoesNaoCarregadas() when naoCarregadas != null:
return naoCarregadas(_that);case OpcoesCarregando() when carregando != null:
return carregando(_that);case OpcoesCarregadas() when carregadas != null:
return carregadas(_that);case OpcoesComErro() when erro != null:
return erro(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OpcoesNaoCarregadas value)  naoCarregadas,required TResult Function( OpcoesCarregando value)  carregando,required TResult Function( OpcoesCarregadas value)  carregadas,required TResult Function( OpcoesComErro value)  erro,}){
final _that = this;
switch (_that) {
case OpcoesNaoCarregadas():
return naoCarregadas(_that);case OpcoesCarregando():
return carregando(_that);case OpcoesCarregadas():
return carregadas(_that);case OpcoesComErro():
return erro(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OpcoesNaoCarregadas value)?  naoCarregadas,TResult? Function( OpcoesCarregando value)?  carregando,TResult? Function( OpcoesCarregadas value)?  carregadas,TResult? Function( OpcoesComErro value)?  erro,}){
final _that = this;
switch (_that) {
case OpcoesNaoCarregadas() when naoCarregadas != null:
return naoCarregadas(_that);case OpcoesCarregando() when carregando != null:
return carregando(_that);case OpcoesCarregadas() when carregadas != null:
return carregadas(_that);case OpcoesComErro() when erro != null:
return erro(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  naoCarregadas,TResult Function()?  carregando,TResult Function( List<ImovelComContato> imoveis)?  carregadas,TResult Function()?  erro,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OpcoesNaoCarregadas() when naoCarregadas != null:
return naoCarregadas();case OpcoesCarregando() when carregando != null:
return carregando();case OpcoesCarregadas() when carregadas != null:
return carregadas(_that.imoveis);case OpcoesComErro() when erro != null:
return erro();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  naoCarregadas,required TResult Function()  carregando,required TResult Function( List<ImovelComContato> imoveis)  carregadas,required TResult Function()  erro,}) {final _that = this;
switch (_that) {
case OpcoesNaoCarregadas():
return naoCarregadas();case OpcoesCarregando():
return carregando();case OpcoesCarregadas():
return carregadas(_that.imoveis);case OpcoesComErro():
return erro();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  naoCarregadas,TResult? Function()?  carregando,TResult? Function( List<ImovelComContato> imoveis)?  carregadas,TResult? Function()?  erro,}) {final _that = this;
switch (_that) {
case OpcoesNaoCarregadas() when naoCarregadas != null:
return naoCarregadas();case OpcoesCarregando() when carregando != null:
return carregando();case OpcoesCarregadas() when carregadas != null:
return carregadas(_that.imoveis);case OpcoesComErro() when erro != null:
return erro();case _:
  return null;

}
}

}

/// @nodoc


class OpcoesNaoCarregadas implements OpcoesDeImovel {
  const OpcoesNaoCarregadas();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OpcoesNaoCarregadas);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OpcoesDeImovel.naoCarregadas()';
}


}




/// @nodoc


class OpcoesCarregando implements OpcoesDeImovel {
  const OpcoesCarregando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OpcoesCarregando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OpcoesDeImovel.carregando()';
}


}




/// @nodoc


class OpcoesCarregadas implements OpcoesDeImovel {
  const OpcoesCarregadas( List<ImovelComContato> imoveis): _imoveis = imoveis;
  

 final  List<ImovelComContato> _imoveis;
 List<ImovelComContato> get imoveis {
  if (_imoveis is EqualUnmodifiableListView) return _imoveis;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imoveis);
}


/// Create a copy of OpcoesDeImovel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpcoesCarregadasCopyWith<OpcoesCarregadas> get copyWith => _$OpcoesCarregadasCopyWithImpl<OpcoesCarregadas>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OpcoesCarregadas&&const DeepCollectionEquality().equals(other.imoveis, _imoveis));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_imoveis));
}

@override
String toString() {
    return 'OpcoesDeImovel.carregadas(imoveis: $imoveis)';
}


}

/// @nodoc
abstract mixin class $OpcoesCarregadasCopyWith<$Res> implements $OpcoesDeImovelCopyWith<$Res> {
  factory $OpcoesCarregadasCopyWith(OpcoesCarregadas value, $Res Function(OpcoesCarregadas) _then) = _$OpcoesCarregadasCopyWithImpl;
@useResult
$Res call({
 List<ImovelComContato> imoveis
});




}
/// @nodoc
class _$OpcoesCarregadasCopyWithImpl<$Res>
    implements $OpcoesCarregadasCopyWith<$Res> {
  _$OpcoesCarregadasCopyWithImpl(this._self, this._then);

  final OpcoesCarregadas _self;
  final $Res Function(OpcoesCarregadas) _then;

/// Create a copy of OpcoesDeImovel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? imoveis = null,}) {
  return _then(OpcoesCarregadas(
null == imoveis ? _self._imoveis : imoveis // ignore: cast_nullable_to_non_nullable
as List<ImovelComContato>,
  ));
}


}

/// @nodoc


class OpcoesComErro implements OpcoesDeImovel {
  const OpcoesComErro();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OpcoesComErro);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OpcoesDeImovel.erro()';
}


}




// dart format on
