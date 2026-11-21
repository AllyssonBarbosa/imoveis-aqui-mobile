// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'perfil_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PerfilState<T> {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PerfilState<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PerfilState<$T>()';
}


}

/// @nodoc
class $PerfilStateCopyWith<T,$Res>  {
$PerfilStateCopyWith(PerfilState<T> _, $Res Function(PerfilState<T>) __);
}


/// Adds pattern-matching-related methods to [PerfilState].
extension PerfilStatePatterns<T> on PerfilState<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PerfilCarregando<T> value)?  carregando,TResult Function( PerfilCarregado<T> value)?  carregado,TResult Function( PerfilErro<T> value)?  erro,TResult Function( PerfilNaoEncontrado<T> value)?  naoEncontrado,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PerfilCarregando() when carregando != null:
return carregando(_that);case PerfilCarregado() when carregado != null:
return carregado(_that);case PerfilErro() when erro != null:
return erro(_that);case PerfilNaoEncontrado() when naoEncontrado != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PerfilCarregando<T> value)  carregando,required TResult Function( PerfilCarregado<T> value)  carregado,required TResult Function( PerfilErro<T> value)  erro,required TResult Function( PerfilNaoEncontrado<T> value)  naoEncontrado,}){
final _that = this;
switch (_that) {
case PerfilCarregando():
return carregando(_that);case PerfilCarregado():
return carregado(_that);case PerfilErro():
return erro(_that);case PerfilNaoEncontrado():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PerfilCarregando<T> value)?  carregando,TResult? Function( PerfilCarregado<T> value)?  carregado,TResult? Function( PerfilErro<T> value)?  erro,TResult? Function( PerfilNaoEncontrado<T> value)?  naoEncontrado,}){
final _that = this;
switch (_that) {
case PerfilCarregando() when carregando != null:
return carregando(_that);case PerfilCarregado() when carregado != null:
return carregado(_that);case PerfilErro() when erro != null:
return erro(_that);case PerfilNaoEncontrado() when naoEncontrado != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  carregando,TResult Function( T dados)?  carregado,TResult Function()?  erro,TResult Function()?  naoEncontrado,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PerfilCarregando() when carregando != null:
return carregando();case PerfilCarregado() when carregado != null:
return carregado(_that.dados);case PerfilErro() when erro != null:
return erro();case PerfilNaoEncontrado() when naoEncontrado != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  carregando,required TResult Function( T dados)  carregado,required TResult Function()  erro,required TResult Function()  naoEncontrado,}) {final _that = this;
switch (_that) {
case PerfilCarregando():
return carregando();case PerfilCarregado():
return carregado(_that.dados);case PerfilErro():
return erro();case PerfilNaoEncontrado():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  carregando,TResult? Function( T dados)?  carregado,TResult? Function()?  erro,TResult? Function()?  naoEncontrado,}) {final _that = this;
switch (_that) {
case PerfilCarregando() when carregando != null:
return carregando();case PerfilCarregado() when carregado != null:
return carregado(_that.dados);case PerfilErro() when erro != null:
return erro();case PerfilNaoEncontrado() when naoEncontrado != null:
return naoEncontrado();case _:
  return null;

}
}

}

/// @nodoc


class PerfilCarregando<T> implements PerfilState<T> {
  const PerfilCarregando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PerfilCarregando<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PerfilState<$T>.carregando()';
}


}




/// @nodoc


class PerfilCarregado<T> implements PerfilState<T> {
  const PerfilCarregado(this.dados);
  

 final  T dados;

/// Create a copy of PerfilState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerfilCarregadoCopyWith<T, PerfilCarregado<T>> get copyWith => _$PerfilCarregadoCopyWithImpl<T, PerfilCarregado<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PerfilCarregado<T>&&const DeepCollectionEquality().equals(other.dados, dados));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(dados));
}

@override
String toString() {
    return 'PerfilState<$T>.carregado(dados: $dados)';
}


}

/// @nodoc
abstract mixin class $PerfilCarregadoCopyWith<T,$Res> implements $PerfilStateCopyWith<T, $Res> {
  factory $PerfilCarregadoCopyWith(PerfilCarregado<T> value, $Res Function(PerfilCarregado<T>) _then) = _$PerfilCarregadoCopyWithImpl;
@useResult
$Res call({
 T dados
});




}
/// @nodoc
class _$PerfilCarregadoCopyWithImpl<T,$Res>
    implements $PerfilCarregadoCopyWith<T, $Res> {
  _$PerfilCarregadoCopyWithImpl(this._self, this._then);

  final PerfilCarregado<T> _self;
  final $Res Function(PerfilCarregado<T>) _then;

/// Create a copy of PerfilState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? dados = freezed,}) {
  return _then(PerfilCarregado<T>(
freezed == dados ? _self.dados : dados // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class PerfilErro<T> implements PerfilState<T> {
  const PerfilErro();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PerfilErro<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PerfilState<$T>.erro()';
}


}




/// @nodoc


class PerfilNaoEncontrado<T> implements PerfilState<T> {
  const PerfilNaoEncontrado();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PerfilNaoEncontrado<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PerfilState<$T>.naoEncontrado()';
}


}




// dart format on
