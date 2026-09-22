// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cidade_selecao_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CidadeSelecaoState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CidadeSelecaoState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CidadeSelecaoState()';
}


}

/// @nodoc
class $CidadeSelecaoStateCopyWith<$Res>  {
$CidadeSelecaoStateCopyWith(CidadeSelecaoState _, $Res Function(CidadeSelecaoState) __);
}


/// Adds pattern-matching-related methods to [CidadeSelecaoState].
extension CidadeSelecaoStatePatterns on CidadeSelecaoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Localizando value)?  localizando,TResult Function( AutorizadaEAtendida value)?  autorizadaEAtendida,TResult Function( AutorizadaNaoAtendida value)?  autorizadaNaoAtendida,TResult Function( Recusada value)?  recusada,TResult Function( BloqueadaParaSempre value)?  bloqueadaParaSempre,TResult Function( ServicoDesligado value)?  servicoDesligado,TResult Function( FalhaGeocodificacao value)?  falhaGeocodificacao,TResult Function( ErroCarregarCidades value)?  erroCarregarCidades,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Localizando() when localizando != null:
return localizando(_that);case AutorizadaEAtendida() when autorizadaEAtendida != null:
return autorizadaEAtendida(_that);case AutorizadaNaoAtendida() when autorizadaNaoAtendida != null:
return autorizadaNaoAtendida(_that);case Recusada() when recusada != null:
return recusada(_that);case BloqueadaParaSempre() when bloqueadaParaSempre != null:
return bloqueadaParaSempre(_that);case ServicoDesligado() when servicoDesligado != null:
return servicoDesligado(_that);case FalhaGeocodificacao() when falhaGeocodificacao != null:
return falhaGeocodificacao(_that);case ErroCarregarCidades() when erroCarregarCidades != null:
return erroCarregarCidades(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Localizando value)  localizando,required TResult Function( AutorizadaEAtendida value)  autorizadaEAtendida,required TResult Function( AutorizadaNaoAtendida value)  autorizadaNaoAtendida,required TResult Function( Recusada value)  recusada,required TResult Function( BloqueadaParaSempre value)  bloqueadaParaSempre,required TResult Function( ServicoDesligado value)  servicoDesligado,required TResult Function( FalhaGeocodificacao value)  falhaGeocodificacao,required TResult Function( ErroCarregarCidades value)  erroCarregarCidades,}){
final _that = this;
switch (_that) {
case Localizando():
return localizando(_that);case AutorizadaEAtendida():
return autorizadaEAtendida(_that);case AutorizadaNaoAtendida():
return autorizadaNaoAtendida(_that);case Recusada():
return recusada(_that);case BloqueadaParaSempre():
return bloqueadaParaSempre(_that);case ServicoDesligado():
return servicoDesligado(_that);case FalhaGeocodificacao():
return falhaGeocodificacao(_that);case ErroCarregarCidades():
return erroCarregarCidades(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Localizando value)?  localizando,TResult? Function( AutorizadaEAtendida value)?  autorizadaEAtendida,TResult? Function( AutorizadaNaoAtendida value)?  autorizadaNaoAtendida,TResult? Function( Recusada value)?  recusada,TResult? Function( BloqueadaParaSempre value)?  bloqueadaParaSempre,TResult? Function( ServicoDesligado value)?  servicoDesligado,TResult? Function( FalhaGeocodificacao value)?  falhaGeocodificacao,TResult? Function( ErroCarregarCidades value)?  erroCarregarCidades,}){
final _that = this;
switch (_that) {
case Localizando() when localizando != null:
return localizando(_that);case AutorizadaEAtendida() when autorizadaEAtendida != null:
return autorizadaEAtendida(_that);case AutorizadaNaoAtendida() when autorizadaNaoAtendida != null:
return autorizadaNaoAtendida(_that);case Recusada() when recusada != null:
return recusada(_that);case BloqueadaParaSempre() when bloqueadaParaSempre != null:
return bloqueadaParaSempre(_that);case ServicoDesligado() when servicoDesligado != null:
return servicoDesligado(_that);case FalhaGeocodificacao() when falhaGeocodificacao != null:
return falhaGeocodificacao(_that);case ErroCarregarCidades() when erroCarregarCidades != null:
return erroCarregarCidades(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  localizando,TResult Function( Cidade cidade)?  autorizadaEAtendida,TResult Function( String cidadeDetectada,  List<Cidade> cidadesAtendidas)?  autorizadaNaoAtendida,TResult Function( List<Cidade> cidadesAtendidas)?  recusada,TResult Function( List<Cidade> cidadesAtendidas)?  bloqueadaParaSempre,TResult Function( List<Cidade> cidadesAtendidas)?  servicoDesligado,TResult Function( List<Cidade> cidadesAtendidas)?  falhaGeocodificacao,TResult Function()?  erroCarregarCidades,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Localizando() when localizando != null:
return localizando();case AutorizadaEAtendida() when autorizadaEAtendida != null:
return autorizadaEAtendida(_that.cidade);case AutorizadaNaoAtendida() when autorizadaNaoAtendida != null:
return autorizadaNaoAtendida(_that.cidadeDetectada,_that.cidadesAtendidas);case Recusada() when recusada != null:
return recusada(_that.cidadesAtendidas);case BloqueadaParaSempre() when bloqueadaParaSempre != null:
return bloqueadaParaSempre(_that.cidadesAtendidas);case ServicoDesligado() when servicoDesligado != null:
return servicoDesligado(_that.cidadesAtendidas);case FalhaGeocodificacao() when falhaGeocodificacao != null:
return falhaGeocodificacao(_that.cidadesAtendidas);case ErroCarregarCidades() when erroCarregarCidades != null:
return erroCarregarCidades();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  localizando,required TResult Function( Cidade cidade)  autorizadaEAtendida,required TResult Function( String cidadeDetectada,  List<Cidade> cidadesAtendidas)  autorizadaNaoAtendida,required TResult Function( List<Cidade> cidadesAtendidas)  recusada,required TResult Function( List<Cidade> cidadesAtendidas)  bloqueadaParaSempre,required TResult Function( List<Cidade> cidadesAtendidas)  servicoDesligado,required TResult Function( List<Cidade> cidadesAtendidas)  falhaGeocodificacao,required TResult Function()  erroCarregarCidades,}) {final _that = this;
switch (_that) {
case Localizando():
return localizando();case AutorizadaEAtendida():
return autorizadaEAtendida(_that.cidade);case AutorizadaNaoAtendida():
return autorizadaNaoAtendida(_that.cidadeDetectada,_that.cidadesAtendidas);case Recusada():
return recusada(_that.cidadesAtendidas);case BloqueadaParaSempre():
return bloqueadaParaSempre(_that.cidadesAtendidas);case ServicoDesligado():
return servicoDesligado(_that.cidadesAtendidas);case FalhaGeocodificacao():
return falhaGeocodificacao(_that.cidadesAtendidas);case ErroCarregarCidades():
return erroCarregarCidades();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  localizando,TResult? Function( Cidade cidade)?  autorizadaEAtendida,TResult? Function( String cidadeDetectada,  List<Cidade> cidadesAtendidas)?  autorizadaNaoAtendida,TResult? Function( List<Cidade> cidadesAtendidas)?  recusada,TResult? Function( List<Cidade> cidadesAtendidas)?  bloqueadaParaSempre,TResult? Function( List<Cidade> cidadesAtendidas)?  servicoDesligado,TResult? Function( List<Cidade> cidadesAtendidas)?  falhaGeocodificacao,TResult? Function()?  erroCarregarCidades,}) {final _that = this;
switch (_that) {
case Localizando() when localizando != null:
return localizando();case AutorizadaEAtendida() when autorizadaEAtendida != null:
return autorizadaEAtendida(_that.cidade);case AutorizadaNaoAtendida() when autorizadaNaoAtendida != null:
return autorizadaNaoAtendida(_that.cidadeDetectada,_that.cidadesAtendidas);case Recusada() when recusada != null:
return recusada(_that.cidadesAtendidas);case BloqueadaParaSempre() when bloqueadaParaSempre != null:
return bloqueadaParaSempre(_that.cidadesAtendidas);case ServicoDesligado() when servicoDesligado != null:
return servicoDesligado(_that.cidadesAtendidas);case FalhaGeocodificacao() when falhaGeocodificacao != null:
return falhaGeocodificacao(_that.cidadesAtendidas);case ErroCarregarCidades() when erroCarregarCidades != null:
return erroCarregarCidades();case _:
  return null;

}
}

}

/// @nodoc


class Localizando implements CidadeSelecaoState {
  const Localizando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Localizando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CidadeSelecaoState.localizando()';
}


}




/// @nodoc


class AutorizadaEAtendida implements CidadeSelecaoState {
  const AutorizadaEAtendida(this.cidade);
  

 final  Cidade cidade;

/// Create a copy of CidadeSelecaoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutorizadaEAtendidaCopyWith<AutorizadaEAtendida> get copyWith => _$AutorizadaEAtendidaCopyWithImpl<AutorizadaEAtendida>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AutorizadaEAtendida&&(identical(other.cidade, cidade) || other.cidade == cidade));
}


@override
int get hashCode {
    return Object.hash(runtimeType,cidade);
}

@override
String toString() {
    return 'CidadeSelecaoState.autorizadaEAtendida(cidade: $cidade)';
}


}

/// @nodoc
abstract mixin class $AutorizadaEAtendidaCopyWith<$Res> implements $CidadeSelecaoStateCopyWith<$Res> {
  factory $AutorizadaEAtendidaCopyWith(AutorizadaEAtendida value, $Res Function(AutorizadaEAtendida) _then) = _$AutorizadaEAtendidaCopyWithImpl;
@useResult
$Res call({
 Cidade cidade
});




}
/// @nodoc
class _$AutorizadaEAtendidaCopyWithImpl<$Res>
    implements $AutorizadaEAtendidaCopyWith<$Res> {
  _$AutorizadaEAtendidaCopyWithImpl(this._self, this._then);

  final AutorizadaEAtendida _self;
  final $Res Function(AutorizadaEAtendida) _then;

/// Create a copy of CidadeSelecaoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cidade = null,}) {
  return _then(AutorizadaEAtendida(
null == cidade ? _self.cidade : cidade // ignore: cast_nullable_to_non_nullable
as Cidade,
  ));
}


}

/// @nodoc


class AutorizadaNaoAtendida implements CidadeSelecaoState {
  const AutorizadaNaoAtendida(this.cidadeDetectada,  List<Cidade> cidadesAtendidas): _cidadesAtendidas = cidadesAtendidas;
  

 final  String cidadeDetectada;
 final  List<Cidade> _cidadesAtendidas;
 List<Cidade> get cidadesAtendidas {
  if (_cidadesAtendidas is EqualUnmodifiableListView) return _cidadesAtendidas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cidadesAtendidas);
}


/// Create a copy of CidadeSelecaoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutorizadaNaoAtendidaCopyWith<AutorizadaNaoAtendida> get copyWith => _$AutorizadaNaoAtendidaCopyWithImpl<AutorizadaNaoAtendida>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AutorizadaNaoAtendida&&(identical(other.cidadeDetectada, cidadeDetectada) || other.cidadeDetectada == cidadeDetectada)&&const DeepCollectionEquality().equals(other.cidadesAtendidas, _cidadesAtendidas));
}


@override
int get hashCode {
    return Object.hash(runtimeType,cidadeDetectada,const DeepCollectionEquality().hash(_cidadesAtendidas));
}

@override
String toString() {
    return 'CidadeSelecaoState.autorizadaNaoAtendida(cidadeDetectada: $cidadeDetectada, cidadesAtendidas: $cidadesAtendidas)';
}


}

/// @nodoc
abstract mixin class $AutorizadaNaoAtendidaCopyWith<$Res> implements $CidadeSelecaoStateCopyWith<$Res> {
  factory $AutorizadaNaoAtendidaCopyWith(AutorizadaNaoAtendida value, $Res Function(AutorizadaNaoAtendida) _then) = _$AutorizadaNaoAtendidaCopyWithImpl;
@useResult
$Res call({
 String cidadeDetectada, List<Cidade> cidadesAtendidas
});




}
/// @nodoc
class _$AutorizadaNaoAtendidaCopyWithImpl<$Res>
    implements $AutorizadaNaoAtendidaCopyWith<$Res> {
  _$AutorizadaNaoAtendidaCopyWithImpl(this._self, this._then);

  final AutorizadaNaoAtendida _self;
  final $Res Function(AutorizadaNaoAtendida) _then;

/// Create a copy of CidadeSelecaoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cidadeDetectada = null,Object? cidadesAtendidas = null,}) {
  return _then(AutorizadaNaoAtendida(
null == cidadeDetectada ? _self.cidadeDetectada : cidadeDetectada // ignore: cast_nullable_to_non_nullable
as String,null == cidadesAtendidas ? _self._cidadesAtendidas : cidadesAtendidas // ignore: cast_nullable_to_non_nullable
as List<Cidade>,
  ));
}


}

/// @nodoc


class Recusada implements CidadeSelecaoState {
  const Recusada( List<Cidade> cidadesAtendidas): _cidadesAtendidas = cidadesAtendidas;
  

 final  List<Cidade> _cidadesAtendidas;
 List<Cidade> get cidadesAtendidas {
  if (_cidadesAtendidas is EqualUnmodifiableListView) return _cidadesAtendidas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cidadesAtendidas);
}


/// Create a copy of CidadeSelecaoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecusadaCopyWith<Recusada> get copyWith => _$RecusadaCopyWithImpl<Recusada>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Recusada&&const DeepCollectionEquality().equals(other.cidadesAtendidas, _cidadesAtendidas));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_cidadesAtendidas));
}

@override
String toString() {
    return 'CidadeSelecaoState.recusada(cidadesAtendidas: $cidadesAtendidas)';
}


}

/// @nodoc
abstract mixin class $RecusadaCopyWith<$Res> implements $CidadeSelecaoStateCopyWith<$Res> {
  factory $RecusadaCopyWith(Recusada value, $Res Function(Recusada) _then) = _$RecusadaCopyWithImpl;
@useResult
$Res call({
 List<Cidade> cidadesAtendidas
});




}
/// @nodoc
class _$RecusadaCopyWithImpl<$Res>
    implements $RecusadaCopyWith<$Res> {
  _$RecusadaCopyWithImpl(this._self, this._then);

  final Recusada _self;
  final $Res Function(Recusada) _then;

/// Create a copy of CidadeSelecaoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cidadesAtendidas = null,}) {
  return _then(Recusada(
null == cidadesAtendidas ? _self._cidadesAtendidas : cidadesAtendidas // ignore: cast_nullable_to_non_nullable
as List<Cidade>,
  ));
}


}

/// @nodoc


class BloqueadaParaSempre implements CidadeSelecaoState {
  const BloqueadaParaSempre( List<Cidade> cidadesAtendidas): _cidadesAtendidas = cidadesAtendidas;
  

 final  List<Cidade> _cidadesAtendidas;
 List<Cidade> get cidadesAtendidas {
  if (_cidadesAtendidas is EqualUnmodifiableListView) return _cidadesAtendidas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cidadesAtendidas);
}


/// Create a copy of CidadeSelecaoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BloqueadaParaSempreCopyWith<BloqueadaParaSempre> get copyWith => _$BloqueadaParaSempreCopyWithImpl<BloqueadaParaSempre>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BloqueadaParaSempre&&const DeepCollectionEquality().equals(other.cidadesAtendidas, _cidadesAtendidas));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_cidadesAtendidas));
}

@override
String toString() {
    return 'CidadeSelecaoState.bloqueadaParaSempre(cidadesAtendidas: $cidadesAtendidas)';
}


}

/// @nodoc
abstract mixin class $BloqueadaParaSempreCopyWith<$Res> implements $CidadeSelecaoStateCopyWith<$Res> {
  factory $BloqueadaParaSempreCopyWith(BloqueadaParaSempre value, $Res Function(BloqueadaParaSempre) _then) = _$BloqueadaParaSempreCopyWithImpl;
@useResult
$Res call({
 List<Cidade> cidadesAtendidas
});




}
/// @nodoc
class _$BloqueadaParaSempreCopyWithImpl<$Res>
    implements $BloqueadaParaSempreCopyWith<$Res> {
  _$BloqueadaParaSempreCopyWithImpl(this._self, this._then);

  final BloqueadaParaSempre _self;
  final $Res Function(BloqueadaParaSempre) _then;

/// Create a copy of CidadeSelecaoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cidadesAtendidas = null,}) {
  return _then(BloqueadaParaSempre(
null == cidadesAtendidas ? _self._cidadesAtendidas : cidadesAtendidas // ignore: cast_nullable_to_non_nullable
as List<Cidade>,
  ));
}


}

/// @nodoc


class ServicoDesligado implements CidadeSelecaoState {
  const ServicoDesligado( List<Cidade> cidadesAtendidas): _cidadesAtendidas = cidadesAtendidas;
  

 final  List<Cidade> _cidadesAtendidas;
 List<Cidade> get cidadesAtendidas {
  if (_cidadesAtendidas is EqualUnmodifiableListView) return _cidadesAtendidas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cidadesAtendidas);
}


/// Create a copy of CidadeSelecaoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServicoDesligadoCopyWith<ServicoDesligado> get copyWith => _$ServicoDesligadoCopyWithImpl<ServicoDesligado>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ServicoDesligado&&const DeepCollectionEquality().equals(other.cidadesAtendidas, _cidadesAtendidas));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_cidadesAtendidas));
}

@override
String toString() {
    return 'CidadeSelecaoState.servicoDesligado(cidadesAtendidas: $cidadesAtendidas)';
}


}

/// @nodoc
abstract mixin class $ServicoDesligadoCopyWith<$Res> implements $CidadeSelecaoStateCopyWith<$Res> {
  factory $ServicoDesligadoCopyWith(ServicoDesligado value, $Res Function(ServicoDesligado) _then) = _$ServicoDesligadoCopyWithImpl;
@useResult
$Res call({
 List<Cidade> cidadesAtendidas
});




}
/// @nodoc
class _$ServicoDesligadoCopyWithImpl<$Res>
    implements $ServicoDesligadoCopyWith<$Res> {
  _$ServicoDesligadoCopyWithImpl(this._self, this._then);

  final ServicoDesligado _self;
  final $Res Function(ServicoDesligado) _then;

/// Create a copy of CidadeSelecaoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cidadesAtendidas = null,}) {
  return _then(ServicoDesligado(
null == cidadesAtendidas ? _self._cidadesAtendidas : cidadesAtendidas // ignore: cast_nullable_to_non_nullable
as List<Cidade>,
  ));
}


}

/// @nodoc


class FalhaGeocodificacao implements CidadeSelecaoState {
  const FalhaGeocodificacao( List<Cidade> cidadesAtendidas): _cidadesAtendidas = cidadesAtendidas;
  

 final  List<Cidade> _cidadesAtendidas;
 List<Cidade> get cidadesAtendidas {
  if (_cidadesAtendidas is EqualUnmodifiableListView) return _cidadesAtendidas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cidadesAtendidas);
}


/// Create a copy of CidadeSelecaoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FalhaGeocodificacaoCopyWith<FalhaGeocodificacao> get copyWith => _$FalhaGeocodificacaoCopyWithImpl<FalhaGeocodificacao>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FalhaGeocodificacao&&const DeepCollectionEquality().equals(other.cidadesAtendidas, _cidadesAtendidas));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_cidadesAtendidas));
}

@override
String toString() {
    return 'CidadeSelecaoState.falhaGeocodificacao(cidadesAtendidas: $cidadesAtendidas)';
}


}

/// @nodoc
abstract mixin class $FalhaGeocodificacaoCopyWith<$Res> implements $CidadeSelecaoStateCopyWith<$Res> {
  factory $FalhaGeocodificacaoCopyWith(FalhaGeocodificacao value, $Res Function(FalhaGeocodificacao) _then) = _$FalhaGeocodificacaoCopyWithImpl;
@useResult
$Res call({
 List<Cidade> cidadesAtendidas
});




}
/// @nodoc
class _$FalhaGeocodificacaoCopyWithImpl<$Res>
    implements $FalhaGeocodificacaoCopyWith<$Res> {
  _$FalhaGeocodificacaoCopyWithImpl(this._self, this._then);

  final FalhaGeocodificacao _self;
  final $Res Function(FalhaGeocodificacao) _then;

/// Create a copy of CidadeSelecaoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cidadesAtendidas = null,}) {
  return _then(FalhaGeocodificacao(
null == cidadesAtendidas ? _self._cidadesAtendidas : cidadesAtendidas // ignore: cast_nullable_to_non_nullable
as List<Cidade>,
  ));
}


}

/// @nodoc


class ErroCarregarCidades implements CidadeSelecaoState {
  const ErroCarregarCidades();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ErroCarregarCidades);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CidadeSelecaoState.erroCarregarCidades()';
}


}




// dart format on
