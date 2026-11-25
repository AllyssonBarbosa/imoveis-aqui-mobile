// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'area_gestor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EstadoSecao<T> {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EstadoSecao<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EstadoSecao<$T>()';
}


}

/// @nodoc
class $EstadoSecaoCopyWith<T,$Res>  {
$EstadoSecaoCopyWith(EstadoSecao<T> _, $Res Function(EstadoSecao<T>) __);
}


/// Adds pattern-matching-related methods to [EstadoSecao].
extension EstadoSecaoPatterns<T> on EstadoSecao<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SecaoCarregando<T> value)?  carregando,TResult Function( SecaoComFalha<T> value)?  comFalha,TResult Function( SecaoCarregada<T> value)?  carregada,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SecaoCarregando() when carregando != null:
return carregando(_that);case SecaoComFalha() when comFalha != null:
return comFalha(_that);case SecaoCarregada() when carregada != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SecaoCarregando<T> value)  carregando,required TResult Function( SecaoComFalha<T> value)  comFalha,required TResult Function( SecaoCarregada<T> value)  carregada,}){
final _that = this;
switch (_that) {
case SecaoCarregando():
return carregando(_that);case SecaoComFalha():
return comFalha(_that);case SecaoCarregada():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SecaoCarregando<T> value)?  carregando,TResult? Function( SecaoComFalha<T> value)?  comFalha,TResult? Function( SecaoCarregada<T> value)?  carregada,}){
final _that = this;
switch (_that) {
case SecaoCarregando() when carregando != null:
return carregando(_that);case SecaoComFalha() when comFalha != null:
return comFalha(_that);case SecaoCarregada() when carregada != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  carregando,TResult Function( FalhaDaSecao falha)?  comFalha,TResult Function( T dados)?  carregada,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SecaoCarregando() when carregando != null:
return carregando();case SecaoComFalha() when comFalha != null:
return comFalha(_that.falha);case SecaoCarregada() when carregada != null:
return carregada(_that.dados);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  carregando,required TResult Function( FalhaDaSecao falha)  comFalha,required TResult Function( T dados)  carregada,}) {final _that = this;
switch (_that) {
case SecaoCarregando():
return carregando();case SecaoComFalha():
return comFalha(_that.falha);case SecaoCarregada():
return carregada(_that.dados);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  carregando,TResult? Function( FalhaDaSecao falha)?  comFalha,TResult? Function( T dados)?  carregada,}) {final _that = this;
switch (_that) {
case SecaoCarregando() when carregando != null:
return carregando();case SecaoComFalha() when comFalha != null:
return comFalha(_that.falha);case SecaoCarregada() when carregada != null:
return carregada(_that.dados);case _:
  return null;

}
}

}

/// @nodoc


class SecaoCarregando<T> implements EstadoSecao<T> {
  const SecaoCarregando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SecaoCarregando<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EstadoSecao<$T>.carregando()';
}


}




/// @nodoc


class SecaoComFalha<T> implements EstadoSecao<T> {
  const SecaoComFalha(this.falha);
  

 final  FalhaDaSecao falha;

/// Create a copy of EstadoSecao
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SecaoComFalhaCopyWith<T, SecaoComFalha<T>> get copyWith => _$SecaoComFalhaCopyWithImpl<T, SecaoComFalha<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SecaoComFalha<T>&&(identical(other.falha, falha) || other.falha == falha));
}


@override
int get hashCode {
    return Object.hash(runtimeType,falha);
}

@override
String toString() {
    return 'EstadoSecao<$T>.comFalha(falha: $falha)';
}


}

/// @nodoc
abstract mixin class $SecaoComFalhaCopyWith<T,$Res> implements $EstadoSecaoCopyWith<T, $Res> {
  factory $SecaoComFalhaCopyWith(SecaoComFalha<T> value, $Res Function(SecaoComFalha<T>) _then) = _$SecaoComFalhaCopyWithImpl;
@useResult
$Res call({
 FalhaDaSecao falha
});




}
/// @nodoc
class _$SecaoComFalhaCopyWithImpl<T,$Res>
    implements $SecaoComFalhaCopyWith<T, $Res> {
  _$SecaoComFalhaCopyWithImpl(this._self, this._then);

  final SecaoComFalha<T> _self;
  final $Res Function(SecaoComFalha<T>) _then;

/// Create a copy of EstadoSecao
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? falha = null,}) {
  return _then(SecaoComFalha<T>(
null == falha ? _self.falha : falha // ignore: cast_nullable_to_non_nullable
as FalhaDaSecao,
  ));
}


}

/// @nodoc


class SecaoCarregada<T> implements EstadoSecao<T> {
  const SecaoCarregada(this.dados);
  

 final  T dados;

/// Create a copy of EstadoSecao
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SecaoCarregadaCopyWith<T, SecaoCarregada<T>> get copyWith => _$SecaoCarregadaCopyWithImpl<T, SecaoCarregada<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SecaoCarregada<T>&&const DeepCollectionEquality().equals(other.dados, dados));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(dados));
}

@override
String toString() {
    return 'EstadoSecao<$T>.carregada(dados: $dados)';
}


}

/// @nodoc
abstract mixin class $SecaoCarregadaCopyWith<T,$Res> implements $EstadoSecaoCopyWith<T, $Res> {
  factory $SecaoCarregadaCopyWith(SecaoCarregada<T> value, $Res Function(SecaoCarregada<T>) _then) = _$SecaoCarregadaCopyWithImpl;
@useResult
$Res call({
 T dados
});




}
/// @nodoc
class _$SecaoCarregadaCopyWithImpl<T,$Res>
    implements $SecaoCarregadaCopyWith<T, $Res> {
  _$SecaoCarregadaCopyWithImpl(this._self, this._then);

  final SecaoCarregada<T> _self;
  final $Res Function(SecaoCarregada<T>) _then;

/// Create a copy of EstadoSecao
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? dados = freezed,}) {
  return _then(SecaoCarregada<T>(
freezed == dados ? _self.dados : dados // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc
mixin _$AreaGestorState {

/// Totais da empresa por situação (GES-01).
 EstadoSecao<TotaisPorSituacao> get totais;/// Acervo por corretor (GES-02).
 EstadoSecao<AcervoPorCorretor> get acervo;/// Contatos por corretor, no [periodo] aplicado (GES-03, GES-04).
 EstadoSecao<ContatosPorCorretor> get contatos;/// Mudanças de situação dos últimos dias que o servidor definiu (GES-05).
 EstadoSecao<MudancasRecentes> get mudancas;/// Período aplicado à seção de contatos; `null` = todo o período (D-16).
 PeriodoContatos? get periodo;/// O servidor recusou o token (401) em qualquer seção: a sessão terminou
/// (D-22). Estado terminal — depois dele nada mais é emitido.
 bool get sessaoExpirada;
/// Create a copy of AreaGestorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AreaGestorStateCopyWith<AreaGestorState> get copyWith => _$AreaGestorStateCopyWithImpl<AreaGestorState>(this as AreaGestorState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AreaGestorState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AreaGestorState&&(identical(other.totais, _this.totais) || other.totais == _this.totais)&&(identical(other.acervo, _this.acervo) || other.acervo == _this.acervo)&&(identical(other.contatos, _this.contatos) || other.contatos == _this.contatos)&&(identical(other.mudancas, _this.mudancas) || other.mudancas == _this.mudancas)&&(identical(other.periodo, _this.periodo) || other.periodo == _this.periodo)&&(identical(other.sessaoExpirada, _this.sessaoExpirada) || other.sessaoExpirada == _this.sessaoExpirada));
}


@override
int get hashCode {
  final _this = this as AreaGestorState;
  return Object.hash(runtimeType,_this.totais,_this.acervo,_this.contatos,_this.mudancas,_this.periodo,_this.sessaoExpirada);
}

@override
String toString() {
  final _this = this as AreaGestorState;
  return 'AreaGestorState(totais: ${_this.totais}, acervo: ${_this.acervo}, contatos: ${_this.contatos}, mudancas: ${_this.mudancas}, periodo: ${_this.periodo}, sessaoExpirada: ${_this.sessaoExpirada})';
}


}

/// @nodoc
abstract mixin class $AreaGestorStateCopyWith<$Res>  {
  factory $AreaGestorStateCopyWith(AreaGestorState value, $Res Function(AreaGestorState) _then) = _$AreaGestorStateCopyWithImpl;
@useResult
$Res call({
 EstadoSecao<TotaisPorSituacao> totais, EstadoSecao<AcervoPorCorretor> acervo, EstadoSecao<ContatosPorCorretor> contatos, EstadoSecao<MudancasRecentes> mudancas, PeriodoContatos? periodo, bool sessaoExpirada
});


$EstadoSecaoCopyWith<TotaisPorSituacao, $Res> get totais;$EstadoSecaoCopyWith<AcervoPorCorretor, $Res> get acervo;$EstadoSecaoCopyWith<ContatosPorCorretor, $Res> get contatos;$EstadoSecaoCopyWith<MudancasRecentes, $Res> get mudancas;

}
/// @nodoc
class _$AreaGestorStateCopyWithImpl<$Res>
    implements $AreaGestorStateCopyWith<$Res> {
  _$AreaGestorStateCopyWithImpl(this._self, this._then);

  final AreaGestorState _self;
  final $Res Function(AreaGestorState) _then;

/// Create a copy of AreaGestorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totais = null,Object? acervo = null,Object? contatos = null,Object? mudancas = null,Object? periodo = freezed,Object? sessaoExpirada = null,}) {
  return _then(AreaGestorState(
totais: null == totais ? _self.totais : totais // ignore: cast_nullable_to_non_nullable
as EstadoSecao<TotaisPorSituacao>,acervo: null == acervo ? _self.acervo : acervo // ignore: cast_nullable_to_non_nullable
as EstadoSecao<AcervoPorCorretor>,contatos: null == contatos ? _self.contatos : contatos // ignore: cast_nullable_to_non_nullable
as EstadoSecao<ContatosPorCorretor>,mudancas: null == mudancas ? _self.mudancas : mudancas // ignore: cast_nullable_to_non_nullable
as EstadoSecao<MudancasRecentes>,periodo: freezed == periodo ? _self.periodo : periodo // ignore: cast_nullable_to_non_nullable
as PeriodoContatos?,sessaoExpirada: null == sessaoExpirada ? _self.sessaoExpirada : sessaoExpirada // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AreaGestorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EstadoSecaoCopyWith<TotaisPorSituacao, $Res> get totais {
  
  return $EstadoSecaoCopyWith<TotaisPorSituacao, $Res>(_self.totais, (value) {
    return _then(_self.copyWith(totais: value));
  });
}/// Create a copy of AreaGestorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EstadoSecaoCopyWith<AcervoPorCorretor, $Res> get acervo {
  
  return $EstadoSecaoCopyWith<AcervoPorCorretor, $Res>(_self.acervo, (value) {
    return _then(_self.copyWith(acervo: value));
  });
}/// Create a copy of AreaGestorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EstadoSecaoCopyWith<ContatosPorCorretor, $Res> get contatos {
  
  return $EstadoSecaoCopyWith<ContatosPorCorretor, $Res>(_self.contatos, (value) {
    return _then(_self.copyWith(contatos: value));
  });
}/// Create a copy of AreaGestorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EstadoSecaoCopyWith<MudancasRecentes, $Res> get mudancas {
  
  return $EstadoSecaoCopyWith<MudancasRecentes, $Res>(_self.mudancas, (value) {
    return _then(_self.copyWith(mudancas: value));
  });
}
}


/// Adds pattern-matching-related methods to [AreaGestorState].
extension AreaGestorStatePatterns on AreaGestorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AreaGestorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AreaGestorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AreaGestorState value)  $default,){
final _that = this;
switch (_that) {
case _AreaGestorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AreaGestorState value)?  $default,){
final _that = this;
switch (_that) {
case _AreaGestorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EstadoSecao<TotaisPorSituacao> totais,  EstadoSecao<AcervoPorCorretor> acervo,  EstadoSecao<ContatosPorCorretor> contatos,  EstadoSecao<MudancasRecentes> mudancas,  PeriodoContatos? periodo,  bool sessaoExpirada)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AreaGestorState() when $default != null:
return $default(_that.totais,_that.acervo,_that.contatos,_that.mudancas,_that.periodo,_that.sessaoExpirada);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EstadoSecao<TotaisPorSituacao> totais,  EstadoSecao<AcervoPorCorretor> acervo,  EstadoSecao<ContatosPorCorretor> contatos,  EstadoSecao<MudancasRecentes> mudancas,  PeriodoContatos? periodo,  bool sessaoExpirada)  $default,) {final _that = this;
switch (_that) {
case _AreaGestorState():
return $default(_that.totais,_that.acervo,_that.contatos,_that.mudancas,_that.periodo,_that.sessaoExpirada);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EstadoSecao<TotaisPorSituacao> totais,  EstadoSecao<AcervoPorCorretor> acervo,  EstadoSecao<ContatosPorCorretor> contatos,  EstadoSecao<MudancasRecentes> mudancas,  PeriodoContatos? periodo,  bool sessaoExpirada)?  $default,) {final _that = this;
switch (_that) {
case _AreaGestorState() when $default != null:
return $default(_that.totais,_that.acervo,_that.contatos,_that.mudancas,_that.periodo,_that.sessaoExpirada);case _:
  return null;

}
}

}

/// @nodoc


class _AreaGestorState implements AreaGestorState {
  const _AreaGestorState({this.totais = const EstadoSecao<TotaisPorSituacao>.carregando(), this.acervo = const EstadoSecao<AcervoPorCorretor>.carregando(), this.contatos = const EstadoSecao<ContatosPorCorretor>.carregando(), this.mudancas = const EstadoSecao<MudancasRecentes>.carregando(), this.periodo, this.sessaoExpirada = false});
  

/// Totais da empresa por situação (GES-01).
@override@JsonKey() final  EstadoSecao<TotaisPorSituacao> totais;
/// Acervo por corretor (GES-02).
@override@JsonKey() final  EstadoSecao<AcervoPorCorretor> acervo;
/// Contatos por corretor, no [periodo] aplicado (GES-03, GES-04).
@override@JsonKey() final  EstadoSecao<ContatosPorCorretor> contatos;
/// Mudanças de situação dos últimos dias que o servidor definiu (GES-05).
@override@JsonKey() final  EstadoSecao<MudancasRecentes> mudancas;
/// Período aplicado à seção de contatos; `null` = todo o período (D-16).
@override final  PeriodoContatos? periodo;
/// O servidor recusou o token (401) em qualquer seção: a sessão terminou
/// (D-22). Estado terminal — depois dele nada mais é emitido.
@override@JsonKey() final  bool sessaoExpirada;

/// Create a copy of AreaGestorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AreaGestorStateCopyWith<_AreaGestorState> get copyWith => __$AreaGestorStateCopyWithImpl<_AreaGestorState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AreaGestorState&&(identical(other.totais, totais) || other.totais == totais)&&(identical(other.acervo, acervo) || other.acervo == acervo)&&(identical(other.contatos, contatos) || other.contatos == contatos)&&(identical(other.mudancas, mudancas) || other.mudancas == mudancas)&&(identical(other.periodo, periodo) || other.periodo == periodo)&&(identical(other.sessaoExpirada, sessaoExpirada) || other.sessaoExpirada == sessaoExpirada));
}


@override
int get hashCode {
    return Object.hash(runtimeType,totais,acervo,contatos,mudancas,periodo,sessaoExpirada);
}

@override
String toString() {
    return 'AreaGestorState(totais: $totais, acervo: $acervo, contatos: $contatos, mudancas: $mudancas, periodo: $periodo, sessaoExpirada: $sessaoExpirada)';
}


}

/// @nodoc
abstract mixin class _$AreaGestorStateCopyWith<$Res> implements $AreaGestorStateCopyWith<$Res> {
  factory _$AreaGestorStateCopyWith(_AreaGestorState value, $Res Function(_AreaGestorState) _then) = __$AreaGestorStateCopyWithImpl;
@override @useResult
$Res call({
 EstadoSecao<TotaisPorSituacao> totais, EstadoSecao<AcervoPorCorretor> acervo, EstadoSecao<ContatosPorCorretor> contatos, EstadoSecao<MudancasRecentes> mudancas, PeriodoContatos? periodo, bool sessaoExpirada
});


@override $EstadoSecaoCopyWith<TotaisPorSituacao, $Res> get totais;@override $EstadoSecaoCopyWith<AcervoPorCorretor, $Res> get acervo;@override $EstadoSecaoCopyWith<ContatosPorCorretor, $Res> get contatos;@override $EstadoSecaoCopyWith<MudancasRecentes, $Res> get mudancas;

}
/// @nodoc
class __$AreaGestorStateCopyWithImpl<$Res>
    implements _$AreaGestorStateCopyWith<$Res> {
  __$AreaGestorStateCopyWithImpl(this._self, this._then);

  final _AreaGestorState _self;
  final $Res Function(_AreaGestorState) _then;

/// Create a copy of AreaGestorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totais = null,Object? acervo = null,Object? contatos = null,Object? mudancas = null,Object? periodo = freezed,Object? sessaoExpirada = null,}) {
  return _then(_AreaGestorState(
totais: null == totais ? _self.totais : totais // ignore: cast_nullable_to_non_nullable
as EstadoSecao<TotaisPorSituacao>,acervo: null == acervo ? _self.acervo : acervo // ignore: cast_nullable_to_non_nullable
as EstadoSecao<AcervoPorCorretor>,contatos: null == contatos ? _self.contatos : contatos // ignore: cast_nullable_to_non_nullable
as EstadoSecao<ContatosPorCorretor>,mudancas: null == mudancas ? _self.mudancas : mudancas // ignore: cast_nullable_to_non_nullable
as EstadoSecao<MudancasRecentes>,periodo: freezed == periodo ? _self.periodo : periodo // ignore: cast_nullable_to_non_nullable
as PeriodoContatos?,sessaoExpirada: null == sessaoExpirada ? _self.sessaoExpirada : sessaoExpirada // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AreaGestorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EstadoSecaoCopyWith<TotaisPorSituacao, $Res> get totais {
  
  return $EstadoSecaoCopyWith<TotaisPorSituacao, $Res>(_self.totais, (value) {
    return _then(_self.copyWith(totais: value));
  });
}/// Create a copy of AreaGestorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EstadoSecaoCopyWith<AcervoPorCorretor, $Res> get acervo {
  
  return $EstadoSecaoCopyWith<AcervoPorCorretor, $Res>(_self.acervo, (value) {
    return _then(_self.copyWith(acervo: value));
  });
}/// Create a copy of AreaGestorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EstadoSecaoCopyWith<ContatosPorCorretor, $Res> get contatos {
  
  return $EstadoSecaoCopyWith<ContatosPorCorretor, $Res>(_self.contatos, (value) {
    return _then(_self.copyWith(contatos: value));
  });
}/// Create a copy of AreaGestorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EstadoSecaoCopyWith<MudancasRecentes, $Res> get mudancas {
  
  return $EstadoSecaoCopyWith<MudancasRecentes, $Res>(_self.mudancas, (value) {
    return _then(_self.copyWith(mudancas: value));
  });
}
}

// dart format on
