// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'acervo_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AcervoState {

/// Termo de busca já aplicado (sem espaços nas pontas); vazio = sem busca.
 String get termoBusca;/// Situação escolhida nos chips; `null` é "Todas" (D-09).
 SituacaoImovel? get situacao; ConteudoAcervo get conteudo;
/// Create a copy of AcervoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcervoStateCopyWith<AcervoState> get copyWith => _$AcervoStateCopyWithImpl<AcervoState>(this as AcervoState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AcervoState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AcervoState&&(identical(other.termoBusca, _this.termoBusca) || other.termoBusca == _this.termoBusca)&&(identical(other.situacao, _this.situacao) || other.situacao == _this.situacao)&&(identical(other.conteudo, _this.conteudo) || other.conteudo == _this.conteudo));
}


@override
int get hashCode {
  final _this = this as AcervoState;
  return Object.hash(runtimeType,_this.termoBusca,_this.situacao,_this.conteudo);
}

@override
String toString() {
  final _this = this as AcervoState;
  return 'AcervoState(termoBusca: ${_this.termoBusca}, situacao: ${_this.situacao}, conteudo: ${_this.conteudo})';
}


}

/// @nodoc
abstract mixin class $AcervoStateCopyWith<$Res>  {
  factory $AcervoStateCopyWith(AcervoState value, $Res Function(AcervoState) _then) = _$AcervoStateCopyWithImpl;
@useResult
$Res call({
 String termoBusca, SituacaoImovel? situacao, ConteudoAcervo conteudo
});


$ConteudoAcervoCopyWith<$Res> get conteudo;

}
/// @nodoc
class _$AcervoStateCopyWithImpl<$Res>
    implements $AcervoStateCopyWith<$Res> {
  _$AcervoStateCopyWithImpl(this._self, this._then);

  final AcervoState _self;
  final $Res Function(AcervoState) _then;

/// Create a copy of AcervoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? termoBusca = null,Object? situacao = freezed,Object? conteudo = null,}) {
  return _then(AcervoState(
termoBusca: null == termoBusca ? _self.termoBusca : termoBusca // ignore: cast_nullable_to_non_nullable
as String,situacao: freezed == situacao ? _self.situacao : situacao // ignore: cast_nullable_to_non_nullable
as SituacaoImovel?,conteudo: null == conteudo ? _self.conteudo : conteudo // ignore: cast_nullable_to_non_nullable
as ConteudoAcervo,
  ));
}
/// Create a copy of AcervoState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConteudoAcervoCopyWith<$Res> get conteudo {
  
  return $ConteudoAcervoCopyWith<$Res>(_self.conteudo, (value) {
    return _then(_self.copyWith(conteudo: value));
  });
}
}


/// Adds pattern-matching-related methods to [AcervoState].
extension AcervoStatePatterns on AcervoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AcervoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AcervoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AcervoState value)  $default,){
final _that = this;
switch (_that) {
case _AcervoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AcervoState value)?  $default,){
final _that = this;
switch (_that) {
case _AcervoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String termoBusca,  SituacaoImovel? situacao,  ConteudoAcervo conteudo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AcervoState() when $default != null:
return $default(_that.termoBusca,_that.situacao,_that.conteudo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String termoBusca,  SituacaoImovel? situacao,  ConteudoAcervo conteudo)  $default,) {final _that = this;
switch (_that) {
case _AcervoState():
return $default(_that.termoBusca,_that.situacao,_that.conteudo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String termoBusca,  SituacaoImovel? situacao,  ConteudoAcervo conteudo)?  $default,) {final _that = this;
switch (_that) {
case _AcervoState() when $default != null:
return $default(_that.termoBusca,_that.situacao,_that.conteudo);case _:
  return null;

}
}

}

/// @nodoc


class _AcervoState implements AcervoState {
  const _AcervoState({this.termoBusca = '', this.situacao, this.conteudo = const ConteudoAcervo.carregando()});
  

/// Termo de busca já aplicado (sem espaços nas pontas); vazio = sem busca.
@override@JsonKey() final  String termoBusca;
/// Situação escolhida nos chips; `null` é "Todas" (D-09).
@override final  SituacaoImovel? situacao;
@override@JsonKey() final  ConteudoAcervo conteudo;

/// Create a copy of AcervoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcervoStateCopyWith<_AcervoState> get copyWith => __$AcervoStateCopyWithImpl<_AcervoState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AcervoState&&(identical(other.termoBusca, termoBusca) || other.termoBusca == termoBusca)&&(identical(other.situacao, situacao) || other.situacao == situacao)&&(identical(other.conteudo, conteudo) || other.conteudo == conteudo));
}


@override
int get hashCode {
    return Object.hash(runtimeType,termoBusca,situacao,conteudo);
}

@override
String toString() {
    return 'AcervoState(termoBusca: $termoBusca, situacao: $situacao, conteudo: $conteudo)';
}


}

/// @nodoc
abstract mixin class _$AcervoStateCopyWith<$Res> implements $AcervoStateCopyWith<$Res> {
  factory _$AcervoStateCopyWith(_AcervoState value, $Res Function(_AcervoState) _then) = __$AcervoStateCopyWithImpl;
@override @useResult
$Res call({
 String termoBusca, SituacaoImovel? situacao, ConteudoAcervo conteudo
});


@override $ConteudoAcervoCopyWith<$Res> get conteudo;

}
/// @nodoc
class __$AcervoStateCopyWithImpl<$Res>
    implements _$AcervoStateCopyWith<$Res> {
  __$AcervoStateCopyWithImpl(this._self, this._then);

  final _AcervoState _self;
  final $Res Function(_AcervoState) _then;

/// Create a copy of AcervoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? termoBusca = null,Object? situacao = freezed,Object? conteudo = null,}) {
  return _then(_AcervoState(
termoBusca: null == termoBusca ? _self.termoBusca : termoBusca // ignore: cast_nullable_to_non_nullable
as String,situacao: freezed == situacao ? _self.situacao : situacao // ignore: cast_nullable_to_non_nullable
as SituacaoImovel?,conteudo: null == conteudo ? _self.conteudo : conteudo // ignore: cast_nullable_to_non_nullable
as ConteudoAcervo,
  ));
}

/// Create a copy of AcervoState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConteudoAcervoCopyWith<$Res> get conteudo {
  
  return $ConteudoAcervoCopyWith<$Res>(_self.conteudo, (value) {
    return _then(_self.copyWith(conteudo: value));
  });
}
}

/// @nodoc
mixin _$ConteudoAcervo {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConteudoAcervo);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoAcervo()';
}


}

/// @nodoc
class $ConteudoAcervoCopyWith<$Res>  {
$ConteudoAcervoCopyWith(ConteudoAcervo _, $Res Function(ConteudoAcervo) __);
}


/// Adds pattern-matching-related methods to [ConteudoAcervo].
extension ConteudoAcervoPatterns on ConteudoAcervo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AcervoCarregando value)?  carregando,TResult Function( AcervoVazio value)?  vazio,TResult Function( AcervoSemResultado value)?  semResultado,TResult Function( AcervoErro value)?  erro,TResult Function( AcervoSessaoExpirada value)?  sessaoExpirada,TResult Function( AcervoCarregada value)?  carregada,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AcervoCarregando() when carregando != null:
return carregando(_that);case AcervoVazio() when vazio != null:
return vazio(_that);case AcervoSemResultado() when semResultado != null:
return semResultado(_that);case AcervoErro() when erro != null:
return erro(_that);case AcervoSessaoExpirada() when sessaoExpirada != null:
return sessaoExpirada(_that);case AcervoCarregada() when carregada != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AcervoCarregando value)  carregando,required TResult Function( AcervoVazio value)  vazio,required TResult Function( AcervoSemResultado value)  semResultado,required TResult Function( AcervoErro value)  erro,required TResult Function( AcervoSessaoExpirada value)  sessaoExpirada,required TResult Function( AcervoCarregada value)  carregada,}){
final _that = this;
switch (_that) {
case AcervoCarregando():
return carregando(_that);case AcervoVazio():
return vazio(_that);case AcervoSemResultado():
return semResultado(_that);case AcervoErro():
return erro(_that);case AcervoSessaoExpirada():
return sessaoExpirada(_that);case AcervoCarregada():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AcervoCarregando value)?  carregando,TResult? Function( AcervoVazio value)?  vazio,TResult? Function( AcervoSemResultado value)?  semResultado,TResult? Function( AcervoErro value)?  erro,TResult? Function( AcervoSessaoExpirada value)?  sessaoExpirada,TResult? Function( AcervoCarregada value)?  carregada,}){
final _that = this;
switch (_that) {
case AcervoCarregando() when carregando != null:
return carregando(_that);case AcervoVazio() when vazio != null:
return vazio(_that);case AcervoSemResultado() when semResultado != null:
return semResultado(_that);case AcervoErro() when erro != null:
return erro(_that);case AcervoSessaoExpirada() when sessaoExpirada != null:
return sessaoExpirada(_that);case AcervoCarregada() when carregada != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  carregando,TResult Function()?  vazio,TResult Function()?  semResultado,TResult Function()?  erro,TResult Function()?  sessaoExpirada,TResult Function( List<ImovelAcervo> itens,  String? proximaPagina,  bool carregandoMais,  bool erroAoCarregarMais)?  carregada,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AcervoCarregando() when carregando != null:
return carregando();case AcervoVazio() when vazio != null:
return vazio();case AcervoSemResultado() when semResultado != null:
return semResultado();case AcervoErro() when erro != null:
return erro();case AcervoSessaoExpirada() when sessaoExpirada != null:
return sessaoExpirada();case AcervoCarregada() when carregada != null:
return carregada(_that.itens,_that.proximaPagina,_that.carregandoMais,_that.erroAoCarregarMais);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  carregando,required TResult Function()  vazio,required TResult Function()  semResultado,required TResult Function()  erro,required TResult Function()  sessaoExpirada,required TResult Function( List<ImovelAcervo> itens,  String? proximaPagina,  bool carregandoMais,  bool erroAoCarregarMais)  carregada,}) {final _that = this;
switch (_that) {
case AcervoCarregando():
return carregando();case AcervoVazio():
return vazio();case AcervoSemResultado():
return semResultado();case AcervoErro():
return erro();case AcervoSessaoExpirada():
return sessaoExpirada();case AcervoCarregada():
return carregada(_that.itens,_that.proximaPagina,_that.carregandoMais,_that.erroAoCarregarMais);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  carregando,TResult? Function()?  vazio,TResult? Function()?  semResultado,TResult? Function()?  erro,TResult? Function()?  sessaoExpirada,TResult? Function( List<ImovelAcervo> itens,  String? proximaPagina,  bool carregandoMais,  bool erroAoCarregarMais)?  carregada,}) {final _that = this;
switch (_that) {
case AcervoCarregando() when carregando != null:
return carregando();case AcervoVazio() when vazio != null:
return vazio();case AcervoSemResultado() when semResultado != null:
return semResultado();case AcervoErro() when erro != null:
return erro();case AcervoSessaoExpirada() when sessaoExpirada != null:
return sessaoExpirada();case AcervoCarregada() when carregada != null:
return carregada(_that.itens,_that.proximaPagina,_that.carregandoMais,_that.erroAoCarregarMais);case _:
  return null;

}
}

}

/// @nodoc


class AcervoCarregando implements ConteudoAcervo {
  const AcervoCarregando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AcervoCarregando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoAcervo.carregando()';
}


}




/// @nodoc


class AcervoVazio implements ConteudoAcervo {
  const AcervoVazio();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AcervoVazio);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoAcervo.vazio()';
}


}




/// @nodoc


class AcervoSemResultado implements ConteudoAcervo {
  const AcervoSemResultado();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AcervoSemResultado);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoAcervo.semResultado()';
}


}




/// @nodoc


class AcervoErro implements ConteudoAcervo {
  const AcervoErro();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AcervoErro);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoAcervo.erro()';
}


}




/// @nodoc


class AcervoSessaoExpirada implements ConteudoAcervo {
  const AcervoSessaoExpirada();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AcervoSessaoExpirada);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoAcervo.sessaoExpirada()';
}


}




/// @nodoc


class AcervoCarregada implements ConteudoAcervo {
  const AcervoCarregada({required  List<ImovelAcervo> itens, this.proximaPagina, this.carregandoMais = false, this.erroAoCarregarMais = false}): _itens = itens;
  

 final  List<ImovelAcervo> _itens;
 List<ImovelAcervo> get itens {
  if (_itens is EqualUnmodifiableListView) return _itens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_itens);
}

 final  String? proximaPagina;
@JsonKey() final  bool carregandoMais;
@JsonKey() final  bool erroAoCarregarMais;

/// Create a copy of ConteudoAcervo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcervoCarregadaCopyWith<AcervoCarregada> get copyWith => _$AcervoCarregadaCopyWithImpl<AcervoCarregada>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AcervoCarregada&&const DeepCollectionEquality().equals(other.itens, _itens)&&(identical(other.proximaPagina, proximaPagina) || other.proximaPagina == proximaPagina)&&(identical(other.carregandoMais, carregandoMais) || other.carregandoMais == carregandoMais)&&(identical(other.erroAoCarregarMais, erroAoCarregarMais) || other.erroAoCarregarMais == erroAoCarregarMais));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_itens),proximaPagina,carregandoMais,erroAoCarregarMais);
}

@override
String toString() {
    return 'ConteudoAcervo.carregada(itens: $itens, proximaPagina: $proximaPagina, carregandoMais: $carregandoMais, erroAoCarregarMais: $erroAoCarregarMais)';
}


}

/// @nodoc
abstract mixin class $AcervoCarregadaCopyWith<$Res> implements $ConteudoAcervoCopyWith<$Res> {
  factory $AcervoCarregadaCopyWith(AcervoCarregada value, $Res Function(AcervoCarregada) _then) = _$AcervoCarregadaCopyWithImpl;
@useResult
$Res call({
 List<ImovelAcervo> itens, String? proximaPagina, bool carregandoMais, bool erroAoCarregarMais
});




}
/// @nodoc
class _$AcervoCarregadaCopyWithImpl<$Res>
    implements $AcervoCarregadaCopyWith<$Res> {
  _$AcervoCarregadaCopyWithImpl(this._self, this._then);

  final AcervoCarregada _self;
  final $Res Function(AcervoCarregada) _then;

/// Create a copy of ConteudoAcervo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? itens = null,Object? proximaPagina = freezed,Object? carregandoMais = null,Object? erroAoCarregarMais = null,}) {
  return _then(AcervoCarregada(
itens: null == itens ? _self._itens : itens // ignore: cast_nullable_to_non_nullable
as List<ImovelAcervo>,proximaPagina: freezed == proximaPagina ? _self.proximaPagina : proximaPagina // ignore: cast_nullable_to_non_nullable
as String?,carregandoMais: null == carregandoMais ? _self.carregandoMais : carregandoMais // ignore: cast_nullable_to_non_nullable
as bool,erroAoCarregarMais: null == erroAoCarregarMais ? _self.erroAoCarregarMais : erroAoCarregarMais // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
