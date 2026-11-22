// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gestao_imovel_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GestaoImovelState {

 ConteudoImovelGestao get imovel; ConteudoHistorico get historico; int get falhasAoAtualizar;
/// Create a copy of GestaoImovelState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GestaoImovelStateCopyWith<GestaoImovelState> get copyWith => _$GestaoImovelStateCopyWithImpl<GestaoImovelState>(this as GestaoImovelState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GestaoImovelState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GestaoImovelState&&(identical(other.imovel, _this.imovel) || other.imovel == _this.imovel)&&(identical(other.historico, _this.historico) || other.historico == _this.historico)&&(identical(other.falhasAoAtualizar, _this.falhasAoAtualizar) || other.falhasAoAtualizar == _this.falhasAoAtualizar));
}


@override
int get hashCode {
  final _this = this as GestaoImovelState;
  return Object.hash(runtimeType,_this.imovel,_this.historico,_this.falhasAoAtualizar);
}

@override
String toString() {
  final _this = this as GestaoImovelState;
  return 'GestaoImovelState(imovel: ${_this.imovel}, historico: ${_this.historico}, falhasAoAtualizar: ${_this.falhasAoAtualizar})';
}


}

/// @nodoc
abstract mixin class $GestaoImovelStateCopyWith<$Res>  {
  factory $GestaoImovelStateCopyWith(GestaoImovelState value, $Res Function(GestaoImovelState) _then) = _$GestaoImovelStateCopyWithImpl;
@useResult
$Res call({
 ConteudoImovelGestao imovel, ConteudoHistorico historico, int falhasAoAtualizar
});


$ConteudoImovelGestaoCopyWith<$Res> get imovel;$ConteudoHistoricoCopyWith<$Res> get historico;

}
/// @nodoc
class _$GestaoImovelStateCopyWithImpl<$Res>
    implements $GestaoImovelStateCopyWith<$Res> {
  _$GestaoImovelStateCopyWithImpl(this._self, this._then);

  final GestaoImovelState _self;
  final $Res Function(GestaoImovelState) _then;

/// Create a copy of GestaoImovelState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imovel = null,Object? historico = null,Object? falhasAoAtualizar = null,}) {
  return _then(GestaoImovelState(
imovel: null == imovel ? _self.imovel : imovel // ignore: cast_nullable_to_non_nullable
as ConteudoImovelGestao,historico: null == historico ? _self.historico : historico // ignore: cast_nullable_to_non_nullable
as ConteudoHistorico,falhasAoAtualizar: null == falhasAoAtualizar ? _self.falhasAoAtualizar : falhasAoAtualizar // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of GestaoImovelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConteudoImovelGestaoCopyWith<$Res> get imovel {
  
  return $ConteudoImovelGestaoCopyWith<$Res>(_self.imovel, (value) {
    return _then(_self.copyWith(imovel: value));
  });
}/// Create a copy of GestaoImovelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConteudoHistoricoCopyWith<$Res> get historico {
  
  return $ConteudoHistoricoCopyWith<$Res>(_self.historico, (value) {
    return _then(_self.copyWith(historico: value));
  });
}
}


/// Adds pattern-matching-related methods to [GestaoImovelState].
extension GestaoImovelStatePatterns on GestaoImovelState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GestaoImovelState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GestaoImovelState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GestaoImovelState value)  $default,){
final _that = this;
switch (_that) {
case _GestaoImovelState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GestaoImovelState value)?  $default,){
final _that = this;
switch (_that) {
case _GestaoImovelState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ConteudoImovelGestao imovel,  ConteudoHistorico historico,  int falhasAoAtualizar)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GestaoImovelState() when $default != null:
return $default(_that.imovel,_that.historico,_that.falhasAoAtualizar);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ConteudoImovelGestao imovel,  ConteudoHistorico historico,  int falhasAoAtualizar)  $default,) {final _that = this;
switch (_that) {
case _GestaoImovelState():
return $default(_that.imovel,_that.historico,_that.falhasAoAtualizar);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ConteudoImovelGestao imovel,  ConteudoHistorico historico,  int falhasAoAtualizar)?  $default,) {final _that = this;
switch (_that) {
case _GestaoImovelState() when $default != null:
return $default(_that.imovel,_that.historico,_that.falhasAoAtualizar);case _:
  return null;

}
}

}

/// @nodoc


class _GestaoImovelState implements GestaoImovelState {
  const _GestaoImovelState({this.imovel = const ConteudoImovelGestao.carregando(), this.historico = const ConteudoHistorico.carregando(), this.falhasAoAtualizar = 0});
  

@override@JsonKey() final  ConteudoImovelGestao imovel;
@override@JsonKey() final  ConteudoHistorico historico;
@override@JsonKey() final  int falhasAoAtualizar;

/// Create a copy of GestaoImovelState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GestaoImovelStateCopyWith<_GestaoImovelState> get copyWith => __$GestaoImovelStateCopyWithImpl<_GestaoImovelState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GestaoImovelState&&(identical(other.imovel, imovel) || other.imovel == imovel)&&(identical(other.historico, historico) || other.historico == historico)&&(identical(other.falhasAoAtualizar, falhasAoAtualizar) || other.falhasAoAtualizar == falhasAoAtualizar));
}


@override
int get hashCode {
    return Object.hash(runtimeType,imovel,historico,falhasAoAtualizar);
}

@override
String toString() {
    return 'GestaoImovelState(imovel: $imovel, historico: $historico, falhasAoAtualizar: $falhasAoAtualizar)';
}


}

/// @nodoc
abstract mixin class _$GestaoImovelStateCopyWith<$Res> implements $GestaoImovelStateCopyWith<$Res> {
  factory _$GestaoImovelStateCopyWith(_GestaoImovelState value, $Res Function(_GestaoImovelState) _then) = __$GestaoImovelStateCopyWithImpl;
@override @useResult
$Res call({
 ConteudoImovelGestao imovel, ConteudoHistorico historico, int falhasAoAtualizar
});


@override $ConteudoImovelGestaoCopyWith<$Res> get imovel;@override $ConteudoHistoricoCopyWith<$Res> get historico;

}
/// @nodoc
class __$GestaoImovelStateCopyWithImpl<$Res>
    implements _$GestaoImovelStateCopyWith<$Res> {
  __$GestaoImovelStateCopyWithImpl(this._self, this._then);

  final _GestaoImovelState _self;
  final $Res Function(_GestaoImovelState) _then;

/// Create a copy of GestaoImovelState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imovel = null,Object? historico = null,Object? falhasAoAtualizar = null,}) {
  return _then(_GestaoImovelState(
imovel: null == imovel ? _self.imovel : imovel // ignore: cast_nullable_to_non_nullable
as ConteudoImovelGestao,historico: null == historico ? _self.historico : historico // ignore: cast_nullable_to_non_nullable
as ConteudoHistorico,falhasAoAtualizar: null == falhasAoAtualizar ? _self.falhasAoAtualizar : falhasAoAtualizar // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of GestaoImovelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConteudoImovelGestaoCopyWith<$Res> get imovel {
  
  return $ConteudoImovelGestaoCopyWith<$Res>(_self.imovel, (value) {
    return _then(_self.copyWith(imovel: value));
  });
}/// Create a copy of GestaoImovelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConteudoHistoricoCopyWith<$Res> get historico {
  
  return $ConteudoHistoricoCopyWith<$Res>(_self.historico, (value) {
    return _then(_self.copyWith(historico: value));
  });
}
}

/// @nodoc
mixin _$ConteudoImovelGestao {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConteudoImovelGestao);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoImovelGestao()';
}


}

/// @nodoc
class $ConteudoImovelGestaoCopyWith<$Res>  {
$ConteudoImovelGestaoCopyWith(ConteudoImovelGestao _, $Res Function(ConteudoImovelGestao) __);
}


/// Adds pattern-matching-related methods to [ConteudoImovelGestao].
extension ConteudoImovelGestaoPatterns on ConteudoImovelGestao {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ImovelGestaoCarregando value)?  carregando,TResult Function( ImovelGestaoCarregado value)?  carregado,TResult Function( ImovelGestaoErro value)?  erro,TResult Function( ImovelGestaoNaoEncontrado value)?  naoEncontrado,TResult Function( ImovelGestaoSessaoExpirada value)?  sessaoExpirada,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ImovelGestaoCarregando() when carregando != null:
return carregando(_that);case ImovelGestaoCarregado() when carregado != null:
return carregado(_that);case ImovelGestaoErro() when erro != null:
return erro(_that);case ImovelGestaoNaoEncontrado() when naoEncontrado != null:
return naoEncontrado(_that);case ImovelGestaoSessaoExpirada() when sessaoExpirada != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ImovelGestaoCarregando value)  carregando,required TResult Function( ImovelGestaoCarregado value)  carregado,required TResult Function( ImovelGestaoErro value)  erro,required TResult Function( ImovelGestaoNaoEncontrado value)  naoEncontrado,required TResult Function( ImovelGestaoSessaoExpirada value)  sessaoExpirada,}){
final _that = this;
switch (_that) {
case ImovelGestaoCarregando():
return carregando(_that);case ImovelGestaoCarregado():
return carregado(_that);case ImovelGestaoErro():
return erro(_that);case ImovelGestaoNaoEncontrado():
return naoEncontrado(_that);case ImovelGestaoSessaoExpirada():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ImovelGestaoCarregando value)?  carregando,TResult? Function( ImovelGestaoCarregado value)?  carregado,TResult? Function( ImovelGestaoErro value)?  erro,TResult? Function( ImovelGestaoNaoEncontrado value)?  naoEncontrado,TResult? Function( ImovelGestaoSessaoExpirada value)?  sessaoExpirada,}){
final _that = this;
switch (_that) {
case ImovelGestaoCarregando() when carregando != null:
return carregando(_that);case ImovelGestaoCarregado() when carregado != null:
return carregado(_that);case ImovelGestaoErro() when erro != null:
return erro(_that);case ImovelGestaoNaoEncontrado() when naoEncontrado != null:
return naoEncontrado(_that);case ImovelGestaoSessaoExpirada() when sessaoExpirada != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  carregando,TResult Function( ImovelGestao imovel)?  carregado,TResult Function()?  erro,TResult Function()?  naoEncontrado,TResult Function()?  sessaoExpirada,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ImovelGestaoCarregando() when carregando != null:
return carregando();case ImovelGestaoCarregado() when carregado != null:
return carregado(_that.imovel);case ImovelGestaoErro() when erro != null:
return erro();case ImovelGestaoNaoEncontrado() when naoEncontrado != null:
return naoEncontrado();case ImovelGestaoSessaoExpirada() when sessaoExpirada != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  carregando,required TResult Function( ImovelGestao imovel)  carregado,required TResult Function()  erro,required TResult Function()  naoEncontrado,required TResult Function()  sessaoExpirada,}) {final _that = this;
switch (_that) {
case ImovelGestaoCarregando():
return carregando();case ImovelGestaoCarregado():
return carregado(_that.imovel);case ImovelGestaoErro():
return erro();case ImovelGestaoNaoEncontrado():
return naoEncontrado();case ImovelGestaoSessaoExpirada():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  carregando,TResult? Function( ImovelGestao imovel)?  carregado,TResult? Function()?  erro,TResult? Function()?  naoEncontrado,TResult? Function()?  sessaoExpirada,}) {final _that = this;
switch (_that) {
case ImovelGestaoCarregando() when carregando != null:
return carregando();case ImovelGestaoCarregado() when carregado != null:
return carregado(_that.imovel);case ImovelGestaoErro() when erro != null:
return erro();case ImovelGestaoNaoEncontrado() when naoEncontrado != null:
return naoEncontrado();case ImovelGestaoSessaoExpirada() when sessaoExpirada != null:
return sessaoExpirada();case _:
  return null;

}
}

}

/// @nodoc


class ImovelGestaoCarregando implements ConteudoImovelGestao {
  const ImovelGestaoCarregando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImovelGestaoCarregando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoImovelGestao.carregando()';
}


}




/// @nodoc


class ImovelGestaoCarregado implements ConteudoImovelGestao {
  const ImovelGestaoCarregado(this.imovel);
  

 final  ImovelGestao imovel;

/// Create a copy of ConteudoImovelGestao
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImovelGestaoCarregadoCopyWith<ImovelGestaoCarregado> get copyWith => _$ImovelGestaoCarregadoCopyWithImpl<ImovelGestaoCarregado>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImovelGestaoCarregado&&(identical(other.imovel, imovel) || other.imovel == imovel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,imovel);
}

@override
String toString() {
    return 'ConteudoImovelGestao.carregado(imovel: $imovel)';
}


}

/// @nodoc
abstract mixin class $ImovelGestaoCarregadoCopyWith<$Res> implements $ConteudoImovelGestaoCopyWith<$Res> {
  factory $ImovelGestaoCarregadoCopyWith(ImovelGestaoCarregado value, $Res Function(ImovelGestaoCarregado) _then) = _$ImovelGestaoCarregadoCopyWithImpl;
@useResult
$Res call({
 ImovelGestao imovel
});




}
/// @nodoc
class _$ImovelGestaoCarregadoCopyWithImpl<$Res>
    implements $ImovelGestaoCarregadoCopyWith<$Res> {
  _$ImovelGestaoCarregadoCopyWithImpl(this._self, this._then);

  final ImovelGestaoCarregado _self;
  final $Res Function(ImovelGestaoCarregado) _then;

/// Create a copy of ConteudoImovelGestao
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? imovel = null,}) {
  return _then(ImovelGestaoCarregado(
null == imovel ? _self.imovel : imovel // ignore: cast_nullable_to_non_nullable
as ImovelGestao,
  ));
}


}

/// @nodoc


class ImovelGestaoErro implements ConteudoImovelGestao {
  const ImovelGestaoErro();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImovelGestaoErro);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoImovelGestao.erro()';
}


}




/// @nodoc


class ImovelGestaoNaoEncontrado implements ConteudoImovelGestao {
  const ImovelGestaoNaoEncontrado();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImovelGestaoNaoEncontrado);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoImovelGestao.naoEncontrado()';
}


}




/// @nodoc


class ImovelGestaoSessaoExpirada implements ConteudoImovelGestao {
  const ImovelGestaoSessaoExpirada();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImovelGestaoSessaoExpirada);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoImovelGestao.sessaoExpirada()';
}


}




/// @nodoc
mixin _$ConteudoHistorico {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConteudoHistorico);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoHistorico()';
}


}

/// @nodoc
class $ConteudoHistoricoCopyWith<$Res>  {
$ConteudoHistoricoCopyWith(ConteudoHistorico _, $Res Function(ConteudoHistorico) __);
}


/// Adds pattern-matching-related methods to [ConteudoHistorico].
extension ConteudoHistoricoPatterns on ConteudoHistorico {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( HistoricoCarregando value)?  carregando,TResult Function( HistoricoCarregado value)?  carregado,TResult Function( HistoricoErro value)?  erro,required TResult orElse(),}){
final _that = this;
switch (_that) {
case HistoricoCarregando() when carregando != null:
return carregando(_that);case HistoricoCarregado() when carregado != null:
return carregado(_that);case HistoricoErro() when erro != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( HistoricoCarregando value)  carregando,required TResult Function( HistoricoCarregado value)  carregado,required TResult Function( HistoricoErro value)  erro,}){
final _that = this;
switch (_that) {
case HistoricoCarregando():
return carregando(_that);case HistoricoCarregado():
return carregado(_that);case HistoricoErro():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( HistoricoCarregando value)?  carregando,TResult? Function( HistoricoCarregado value)?  carregado,TResult? Function( HistoricoErro value)?  erro,}){
final _that = this;
switch (_that) {
case HistoricoCarregando() when carregando != null:
return carregando(_that);case HistoricoCarregado() when carregado != null:
return carregado(_that);case HistoricoErro() when erro != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  carregando,TResult Function( List<MudancaSituacao> itens)?  carregado,TResult Function()?  erro,required TResult orElse(),}) {final _that = this;
switch (_that) {
case HistoricoCarregando() when carregando != null:
return carregando();case HistoricoCarregado() when carregado != null:
return carregado(_that.itens);case HistoricoErro() when erro != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  carregando,required TResult Function( List<MudancaSituacao> itens)  carregado,required TResult Function()  erro,}) {final _that = this;
switch (_that) {
case HistoricoCarregando():
return carregando();case HistoricoCarregado():
return carregado(_that.itens);case HistoricoErro():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  carregando,TResult? Function( List<MudancaSituacao> itens)?  carregado,TResult? Function()?  erro,}) {final _that = this;
switch (_that) {
case HistoricoCarregando() when carregando != null:
return carregando();case HistoricoCarregado() when carregado != null:
return carregado(_that.itens);case HistoricoErro() when erro != null:
return erro();case _:
  return null;

}
}

}

/// @nodoc


class HistoricoCarregando implements ConteudoHistorico {
  const HistoricoCarregando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoricoCarregando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoHistorico.carregando()';
}


}




/// @nodoc


class HistoricoCarregado implements ConteudoHistorico {
  const HistoricoCarregado( List<MudancaSituacao> itens): _itens = itens;
  

 final  List<MudancaSituacao> _itens;
 List<MudancaSituacao> get itens {
  if (_itens is EqualUnmodifiableListView) return _itens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_itens);
}


/// Create a copy of ConteudoHistorico
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoricoCarregadoCopyWith<HistoricoCarregado> get copyWith => _$HistoricoCarregadoCopyWithImpl<HistoricoCarregado>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoricoCarregado&&const DeepCollectionEquality().equals(other.itens, _itens));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_itens));
}

@override
String toString() {
    return 'ConteudoHistorico.carregado(itens: $itens)';
}


}

/// @nodoc
abstract mixin class $HistoricoCarregadoCopyWith<$Res> implements $ConteudoHistoricoCopyWith<$Res> {
  factory $HistoricoCarregadoCopyWith(HistoricoCarregado value, $Res Function(HistoricoCarregado) _then) = _$HistoricoCarregadoCopyWithImpl;
@useResult
$Res call({
 List<MudancaSituacao> itens
});




}
/// @nodoc
class _$HistoricoCarregadoCopyWithImpl<$Res>
    implements $HistoricoCarregadoCopyWith<$Res> {
  _$HistoricoCarregadoCopyWithImpl(this._self, this._then);

  final HistoricoCarregado _self;
  final $Res Function(HistoricoCarregado) _then;

/// Create a copy of ConteudoHistorico
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? itens = null,}) {
  return _then(HistoricoCarregado(
null == itens ? _self._itens : itens // ignore: cast_nullable_to_non_nullable
as List<MudancaSituacao>,
  ));
}


}

/// @nodoc


class HistoricoErro implements ConteudoHistorico {
  const HistoricoErro();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoricoErro);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoHistorico.erro()';
}


}




// dart format on
