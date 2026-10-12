// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detalhe_imovel_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DetalheImovelState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DetalheImovelState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DetalheImovelState()';
}


}

/// @nodoc
class $DetalheImovelStateCopyWith<$Res>  {
$DetalheImovelStateCopyWith(DetalheImovelState _, $Res Function(DetalheImovelState) __);
}


/// Adds pattern-matching-related methods to [DetalheImovelState].
extension DetalheImovelStatePatterns on DetalheImovelState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DetalheCarregando value)?  carregando,TResult Function( DetalheCarregado value)?  carregado,TResult Function( DetalheErro value)?  erro,TResult Function( DetalheNaoEncontrado value)?  naoEncontrado,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DetalheCarregando() when carregando != null:
return carregando(_that);case DetalheCarregado() when carregado != null:
return carregado(_that);case DetalheErro() when erro != null:
return erro(_that);case DetalheNaoEncontrado() when naoEncontrado != null:
return naoEncontrado(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DetalheCarregando value)  carregando,required TResult Function( DetalheCarregado value)  carregado,required TResult Function( DetalheErro value)  erro,required TResult Function( DetalheNaoEncontrado value)  naoEncontrado,}){
final _that = this;
switch (_that) {
case DetalheCarregando():
return carregando(_that);case DetalheCarregado():
return carregado(_that);case DetalheErro():
return erro(_that);case DetalheNaoEncontrado():
return naoEncontrado(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DetalheCarregando value)?  carregando,TResult? Function( DetalheCarregado value)?  carregado,TResult? Function( DetalheErro value)?  erro,TResult? Function( DetalheNaoEncontrado value)?  naoEncontrado,}){
final _that = this;
switch (_that) {
case DetalheCarregando() when carregando != null:
return carregando(_that);case DetalheCarregado() when carregado != null:
return carregado(_that);case DetalheErro() when erro != null:
return erro(_that);case DetalheNaoEncontrado() when naoEncontrado != null:
return naoEncontrado(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  carregando,TResult Function( DetalheImovel detalhe)?  carregado,TResult Function()?  erro,TResult Function()?  naoEncontrado,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DetalheCarregando() when carregando != null:
return carregando();case DetalheCarregado() when carregado != null:
return carregado(_that.detalhe);case DetalheErro() when erro != null:
return erro();case DetalheNaoEncontrado() when naoEncontrado != null:
return naoEncontrado();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  carregando,required TResult Function( DetalheImovel detalhe)  carregado,required TResult Function()  erro,required TResult Function()  naoEncontrado,}) {final _that = this;
switch (_that) {
case DetalheCarregando():
return carregando();case DetalheCarregado():
return carregado(_that.detalhe);case DetalheErro():
return erro();case DetalheNaoEncontrado():
return naoEncontrado();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  carregando,TResult? Function( DetalheImovel detalhe)?  carregado,TResult? Function()?  erro,TResult? Function()?  naoEncontrado,}) {final _that = this;
switch (_that) {
case DetalheCarregando() when carregando != null:
return carregando();case DetalheCarregado() when carregado != null:
return carregado(_that.detalhe);case DetalheErro() when erro != null:
return erro();case DetalheNaoEncontrado() when naoEncontrado != null:
return naoEncontrado();case _:
  return null;

}
}

}

/// @nodoc


class DetalheCarregando implements DetalheImovelState {
  const DetalheCarregando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DetalheCarregando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DetalheImovelState.carregando()';
}


}




/// @nodoc


class DetalheCarregado implements DetalheImovelState {
  const DetalheCarregado(this.detalhe);
  

 final  DetalheImovel detalhe;

/// Create a copy of DetalheImovelState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DetalheCarregadoCopyWith<DetalheCarregado> get copyWith => _$DetalheCarregadoCopyWithImpl<DetalheCarregado>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DetalheCarregado&&(identical(other.detalhe, detalhe) || other.detalhe == detalhe));
}


@override
int get hashCode {
    return Object.hash(runtimeType,detalhe);
}

@override
String toString() {
    return 'DetalheImovelState.carregado(detalhe: $detalhe)';
}


}

/// @nodoc
abstract mixin class $DetalheCarregadoCopyWith<$Res> implements $DetalheImovelStateCopyWith<$Res> {
  factory $DetalheCarregadoCopyWith(DetalheCarregado value, $Res Function(DetalheCarregado) _then) = _$DetalheCarregadoCopyWithImpl;
@useResult
$Res call({
 DetalheImovel detalhe
});


$DetalheImovelCopyWith<$Res> get detalhe;

}
/// @nodoc
class _$DetalheCarregadoCopyWithImpl<$Res>
    implements $DetalheCarregadoCopyWith<$Res> {
  _$DetalheCarregadoCopyWithImpl(this._self, this._then);

  final DetalheCarregado _self;
  final $Res Function(DetalheCarregado) _then;

/// Create a copy of DetalheImovelState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? detalhe = null,}) {
  return _then(DetalheCarregado(
null == detalhe ? _self.detalhe : detalhe // ignore: cast_nullable_to_non_nullable
as DetalheImovel,
  ));
}

/// Create a copy of DetalheImovelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DetalheImovelCopyWith<$Res> get detalhe {
  
  return $DetalheImovelCopyWith<$Res>(_self.detalhe, (value) {
    return _then(_self.copyWith(detalhe: value));
  });
}
}

/// @nodoc


class DetalheErro implements DetalheImovelState {
  const DetalheErro();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DetalheErro);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DetalheImovelState.erro()';
}


}




/// @nodoc


class DetalheNaoEncontrado implements DetalheImovelState {
  const DetalheNaoEncontrado();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DetalheNaoEncontrado);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DetalheImovelState.naoEncontrado()';
}


}




// dart format on
