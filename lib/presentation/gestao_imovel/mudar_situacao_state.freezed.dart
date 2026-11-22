// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mudar_situacao_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MudarSituacaoState {

 int? get imovelId; SituacaoImovel? get atual; SituacaoImovel? get escolhida; EnvioSituacao get envio;
/// Create a copy of MudarSituacaoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MudarSituacaoStateCopyWith<MudarSituacaoState> get copyWith => _$MudarSituacaoStateCopyWithImpl<MudarSituacaoState>(this as MudarSituacaoState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MudarSituacaoState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MudarSituacaoState&&(identical(other.imovelId, _this.imovelId) || other.imovelId == _this.imovelId)&&(identical(other.atual, _this.atual) || other.atual == _this.atual)&&(identical(other.escolhida, _this.escolhida) || other.escolhida == _this.escolhida)&&(identical(other.envio, _this.envio) || other.envio == _this.envio));
}


@override
int get hashCode {
  final _this = this as MudarSituacaoState;
  return Object.hash(runtimeType,_this.imovelId,_this.atual,_this.escolhida,_this.envio);
}

@override
String toString() {
  final _this = this as MudarSituacaoState;
  return 'MudarSituacaoState(imovelId: ${_this.imovelId}, atual: ${_this.atual}, escolhida: ${_this.escolhida}, envio: ${_this.envio})';
}


}

/// @nodoc
abstract mixin class $MudarSituacaoStateCopyWith<$Res>  {
  factory $MudarSituacaoStateCopyWith(MudarSituacaoState value, $Res Function(MudarSituacaoState) _then) = _$MudarSituacaoStateCopyWithImpl;
@useResult
$Res call({
 int? imovelId, SituacaoImovel? atual, SituacaoImovel? escolhida, EnvioSituacao envio
});


$EnvioSituacaoCopyWith<$Res> get envio;

}
/// @nodoc
class _$MudarSituacaoStateCopyWithImpl<$Res>
    implements $MudarSituacaoStateCopyWith<$Res> {
  _$MudarSituacaoStateCopyWithImpl(this._self, this._then);

  final MudarSituacaoState _self;
  final $Res Function(MudarSituacaoState) _then;

/// Create a copy of MudarSituacaoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imovelId = freezed,Object? atual = freezed,Object? escolhida = freezed,Object? envio = null,}) {
  return _then(MudarSituacaoState(
imovelId: freezed == imovelId ? _self.imovelId : imovelId // ignore: cast_nullable_to_non_nullable
as int?,atual: freezed == atual ? _self.atual : atual // ignore: cast_nullable_to_non_nullable
as SituacaoImovel?,escolhida: freezed == escolhida ? _self.escolhida : escolhida // ignore: cast_nullable_to_non_nullable
as SituacaoImovel?,envio: null == envio ? _self.envio : envio // ignore: cast_nullable_to_non_nullable
as EnvioSituacao,
  ));
}
/// Create a copy of MudarSituacaoState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnvioSituacaoCopyWith<$Res> get envio {
  
  return $EnvioSituacaoCopyWith<$Res>(_self.envio, (value) {
    return _then(_self.copyWith(envio: value));
  });
}
}


/// Adds pattern-matching-related methods to [MudarSituacaoState].
extension MudarSituacaoStatePatterns on MudarSituacaoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MudarSituacaoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MudarSituacaoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MudarSituacaoState value)  $default,){
final _that = this;
switch (_that) {
case _MudarSituacaoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MudarSituacaoState value)?  $default,){
final _that = this;
switch (_that) {
case _MudarSituacaoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? imovelId,  SituacaoImovel? atual,  SituacaoImovel? escolhida,  EnvioSituacao envio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MudarSituacaoState() when $default != null:
return $default(_that.imovelId,_that.atual,_that.escolhida,_that.envio);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? imovelId,  SituacaoImovel? atual,  SituacaoImovel? escolhida,  EnvioSituacao envio)  $default,) {final _that = this;
switch (_that) {
case _MudarSituacaoState():
return $default(_that.imovelId,_that.atual,_that.escolhida,_that.envio);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? imovelId,  SituacaoImovel? atual,  SituacaoImovel? escolhida,  EnvioSituacao envio)?  $default,) {final _that = this;
switch (_that) {
case _MudarSituacaoState() when $default != null:
return $default(_that.imovelId,_that.atual,_that.escolhida,_that.envio);case _:
  return null;

}
}

}

/// @nodoc


class _MudarSituacaoState extends MudarSituacaoState {
  const _MudarSituacaoState({this.imovelId, this.atual, this.escolhida, this.envio = const EnvioSituacao.ocioso()}): super._();
  

@override final  int? imovelId;
@override final  SituacaoImovel? atual;
@override final  SituacaoImovel? escolhida;
@override@JsonKey() final  EnvioSituacao envio;

/// Create a copy of MudarSituacaoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MudarSituacaoStateCopyWith<_MudarSituacaoState> get copyWith => __$MudarSituacaoStateCopyWithImpl<_MudarSituacaoState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MudarSituacaoState&&(identical(other.imovelId, imovelId) || other.imovelId == imovelId)&&(identical(other.atual, atual) || other.atual == atual)&&(identical(other.escolhida, escolhida) || other.escolhida == escolhida)&&(identical(other.envio, envio) || other.envio == envio));
}


@override
int get hashCode {
    return Object.hash(runtimeType,imovelId,atual,escolhida,envio);
}

@override
String toString() {
    return 'MudarSituacaoState(imovelId: $imovelId, atual: $atual, escolhida: $escolhida, envio: $envio)';
}


}

/// @nodoc
abstract mixin class _$MudarSituacaoStateCopyWith<$Res> implements $MudarSituacaoStateCopyWith<$Res> {
  factory _$MudarSituacaoStateCopyWith(_MudarSituacaoState value, $Res Function(_MudarSituacaoState) _then) = __$MudarSituacaoStateCopyWithImpl;
@override @useResult
$Res call({
 int? imovelId, SituacaoImovel? atual, SituacaoImovel? escolhida, EnvioSituacao envio
});


@override $EnvioSituacaoCopyWith<$Res> get envio;

}
/// @nodoc
class __$MudarSituacaoStateCopyWithImpl<$Res>
    implements _$MudarSituacaoStateCopyWith<$Res> {
  __$MudarSituacaoStateCopyWithImpl(this._self, this._then);

  final _MudarSituacaoState _self;
  final $Res Function(_MudarSituacaoState) _then;

/// Create a copy of MudarSituacaoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imovelId = freezed,Object? atual = freezed,Object? escolhida = freezed,Object? envio = null,}) {
  return _then(_MudarSituacaoState(
imovelId: freezed == imovelId ? _self.imovelId : imovelId // ignore: cast_nullable_to_non_nullable
as int?,atual: freezed == atual ? _self.atual : atual // ignore: cast_nullable_to_non_nullable
as SituacaoImovel?,escolhida: freezed == escolhida ? _self.escolhida : escolhida // ignore: cast_nullable_to_non_nullable
as SituacaoImovel?,envio: null == envio ? _self.envio : envio // ignore: cast_nullable_to_non_nullable
as EnvioSituacao,
  ));
}

/// Create a copy of MudarSituacaoState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnvioSituacaoCopyWith<$Res> get envio {
  
  return $EnvioSituacaoCopyWith<$Res>(_self.envio, (value) {
    return _then(_self.copyWith(envio: value));
  });
}
}

/// @nodoc
mixin _$EnvioSituacao {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EnvioSituacao);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EnvioSituacao()';
}


}

/// @nodoc
class $EnvioSituacaoCopyWith<$Res>  {
$EnvioSituacaoCopyWith(EnvioSituacao _, $Res Function(EnvioSituacao) __);
}


/// Adds pattern-matching-related methods to [EnvioSituacao].
extension EnvioSituacaoPatterns on EnvioSituacao {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EnvioOcioso value)?  ocioso,TResult Function( EnvioEnviando value)?  enviando,TResult Function( EnvioConcluido value)?  concluido,TResult Function( EnvioFalhou value)?  falhou,TResult Function( EnvioRecusado value)?  recusado,TResult Function( EnvioNaoEncontrado value)?  naoEncontrado,TResult Function( EnvioSessaoExpirada value)?  sessaoExpirada,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EnvioOcioso() when ocioso != null:
return ocioso(_that);case EnvioEnviando() when enviando != null:
return enviando(_that);case EnvioConcluido() when concluido != null:
return concluido(_that);case EnvioFalhou() when falhou != null:
return falhou(_that);case EnvioRecusado() when recusado != null:
return recusado(_that);case EnvioNaoEncontrado() when naoEncontrado != null:
return naoEncontrado(_that);case EnvioSessaoExpirada() when sessaoExpirada != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EnvioOcioso value)  ocioso,required TResult Function( EnvioEnviando value)  enviando,required TResult Function( EnvioConcluido value)  concluido,required TResult Function( EnvioFalhou value)  falhou,required TResult Function( EnvioRecusado value)  recusado,required TResult Function( EnvioNaoEncontrado value)  naoEncontrado,required TResult Function( EnvioSessaoExpirada value)  sessaoExpirada,}){
final _that = this;
switch (_that) {
case EnvioOcioso():
return ocioso(_that);case EnvioEnviando():
return enviando(_that);case EnvioConcluido():
return concluido(_that);case EnvioFalhou():
return falhou(_that);case EnvioRecusado():
return recusado(_that);case EnvioNaoEncontrado():
return naoEncontrado(_that);case EnvioSessaoExpirada():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EnvioOcioso value)?  ocioso,TResult? Function( EnvioEnviando value)?  enviando,TResult? Function( EnvioConcluido value)?  concluido,TResult? Function( EnvioFalhou value)?  falhou,TResult? Function( EnvioRecusado value)?  recusado,TResult? Function( EnvioNaoEncontrado value)?  naoEncontrado,TResult? Function( EnvioSessaoExpirada value)?  sessaoExpirada,}){
final _that = this;
switch (_that) {
case EnvioOcioso() when ocioso != null:
return ocioso(_that);case EnvioEnviando() when enviando != null:
return enviando(_that);case EnvioConcluido() when concluido != null:
return concluido(_that);case EnvioFalhou() when falhou != null:
return falhou(_that);case EnvioRecusado() when recusado != null:
return recusado(_that);case EnvioNaoEncontrado() when naoEncontrado != null:
return naoEncontrado(_that);case EnvioSessaoExpirada() when sessaoExpirada != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  ocioso,TResult Function()?  enviando,TResult Function( SituacaoImovel situacao)?  concluido,TResult Function()?  falhou,TResult Function( String mensagem)?  recusado,TResult Function()?  naoEncontrado,TResult Function()?  sessaoExpirada,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EnvioOcioso() when ocioso != null:
return ocioso();case EnvioEnviando() when enviando != null:
return enviando();case EnvioConcluido() when concluido != null:
return concluido(_that.situacao);case EnvioFalhou() when falhou != null:
return falhou();case EnvioRecusado() when recusado != null:
return recusado(_that.mensagem);case EnvioNaoEncontrado() when naoEncontrado != null:
return naoEncontrado();case EnvioSessaoExpirada() when sessaoExpirada != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  ocioso,required TResult Function()  enviando,required TResult Function( SituacaoImovel situacao)  concluido,required TResult Function()  falhou,required TResult Function( String mensagem)  recusado,required TResult Function()  naoEncontrado,required TResult Function()  sessaoExpirada,}) {final _that = this;
switch (_that) {
case EnvioOcioso():
return ocioso();case EnvioEnviando():
return enviando();case EnvioConcluido():
return concluido(_that.situacao);case EnvioFalhou():
return falhou();case EnvioRecusado():
return recusado(_that.mensagem);case EnvioNaoEncontrado():
return naoEncontrado();case EnvioSessaoExpirada():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  ocioso,TResult? Function()?  enviando,TResult? Function( SituacaoImovel situacao)?  concluido,TResult? Function()?  falhou,TResult? Function( String mensagem)?  recusado,TResult? Function()?  naoEncontrado,TResult? Function()?  sessaoExpirada,}) {final _that = this;
switch (_that) {
case EnvioOcioso() when ocioso != null:
return ocioso();case EnvioEnviando() when enviando != null:
return enviando();case EnvioConcluido() when concluido != null:
return concluido(_that.situacao);case EnvioFalhou() when falhou != null:
return falhou();case EnvioRecusado() when recusado != null:
return recusado(_that.mensagem);case EnvioNaoEncontrado() when naoEncontrado != null:
return naoEncontrado();case EnvioSessaoExpirada() when sessaoExpirada != null:
return sessaoExpirada();case _:
  return null;

}
}

}

/// @nodoc


class EnvioOcioso implements EnvioSituacao {
  const EnvioOcioso();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EnvioOcioso);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EnvioSituacao.ocioso()';
}


}




/// @nodoc


class EnvioEnviando implements EnvioSituacao {
  const EnvioEnviando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EnvioEnviando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EnvioSituacao.enviando()';
}


}




/// @nodoc


class EnvioConcluido implements EnvioSituacao {
  const EnvioConcluido(this.situacao);
  

 final  SituacaoImovel situacao;

/// Create a copy of EnvioSituacao
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnvioConcluidoCopyWith<EnvioConcluido> get copyWith => _$EnvioConcluidoCopyWithImpl<EnvioConcluido>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EnvioConcluido&&(identical(other.situacao, situacao) || other.situacao == situacao));
}


@override
int get hashCode {
    return Object.hash(runtimeType,situacao);
}

@override
String toString() {
    return 'EnvioSituacao.concluido(situacao: $situacao)';
}


}

/// @nodoc
abstract mixin class $EnvioConcluidoCopyWith<$Res> implements $EnvioSituacaoCopyWith<$Res> {
  factory $EnvioConcluidoCopyWith(EnvioConcluido value, $Res Function(EnvioConcluido) _then) = _$EnvioConcluidoCopyWithImpl;
@useResult
$Res call({
 SituacaoImovel situacao
});




}
/// @nodoc
class _$EnvioConcluidoCopyWithImpl<$Res>
    implements $EnvioConcluidoCopyWith<$Res> {
  _$EnvioConcluidoCopyWithImpl(this._self, this._then);

  final EnvioConcluido _self;
  final $Res Function(EnvioConcluido) _then;

/// Create a copy of EnvioSituacao
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? situacao = null,}) {
  return _then(EnvioConcluido(
null == situacao ? _self.situacao : situacao // ignore: cast_nullable_to_non_nullable
as SituacaoImovel,
  ));
}


}

/// @nodoc


class EnvioFalhou implements EnvioSituacao {
  const EnvioFalhou();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EnvioFalhou);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EnvioSituacao.falhou()';
}


}




/// @nodoc


class EnvioRecusado implements EnvioSituacao {
  const EnvioRecusado(this.mensagem);
  

 final  String mensagem;

/// Create a copy of EnvioSituacao
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnvioRecusadoCopyWith<EnvioRecusado> get copyWith => _$EnvioRecusadoCopyWithImpl<EnvioRecusado>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EnvioRecusado&&(identical(other.mensagem, mensagem) || other.mensagem == mensagem));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mensagem);
}

@override
String toString() {
    return 'EnvioSituacao.recusado(mensagem: $mensagem)';
}


}

/// @nodoc
abstract mixin class $EnvioRecusadoCopyWith<$Res> implements $EnvioSituacaoCopyWith<$Res> {
  factory $EnvioRecusadoCopyWith(EnvioRecusado value, $Res Function(EnvioRecusado) _then) = _$EnvioRecusadoCopyWithImpl;
@useResult
$Res call({
 String mensagem
});




}
/// @nodoc
class _$EnvioRecusadoCopyWithImpl<$Res>
    implements $EnvioRecusadoCopyWith<$Res> {
  _$EnvioRecusadoCopyWithImpl(this._self, this._then);

  final EnvioRecusado _self;
  final $Res Function(EnvioRecusado) _then;

/// Create a copy of EnvioSituacao
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? mensagem = null,}) {
  return _then(EnvioRecusado(
null == mensagem ? _self.mensagem : mensagem // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class EnvioNaoEncontrado implements EnvioSituacao {
  const EnvioNaoEncontrado();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EnvioNaoEncontrado);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EnvioSituacao.naoEncontrado()';
}


}




/// @nodoc


class EnvioSessaoExpirada implements EnvioSituacao {
  const EnvioSessaoExpirada();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EnvioSessaoExpirada);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EnvioSituacao.sessaoExpirada()';
}


}




// dart format on
