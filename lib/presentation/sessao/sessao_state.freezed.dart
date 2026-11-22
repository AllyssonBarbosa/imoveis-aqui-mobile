// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sessao_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessaoState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SessaoState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SessaoState()';
}


}

/// @nodoc
class $SessaoStateCopyWith<$Res>  {
$SessaoStateCopyWith(SessaoState _, $Res Function(SessaoState) __);
}


/// Adds pattern-matching-related methods to [SessaoState].
extension SessaoStatePatterns on SessaoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SessaoVerificando value)?  verificando,TResult Function( SessaoAnonima value)?  anonima,TResult Function( SessaoAutenticada value)?  autenticada,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SessaoVerificando() when verificando != null:
return verificando(_that);case SessaoAnonima() when anonima != null:
return anonima(_that);case SessaoAutenticada() when autenticada != null:
return autenticada(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SessaoVerificando value)  verificando,required TResult Function( SessaoAnonima value)  anonima,required TResult Function( SessaoAutenticada value)  autenticada,}){
final _that = this;
switch (_that) {
case SessaoVerificando():
return verificando(_that);case SessaoAnonima():
return anonima(_that);case SessaoAutenticada():
return autenticada(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SessaoVerificando value)?  verificando,TResult? Function( SessaoAnonima value)?  anonima,TResult? Function( SessaoAutenticada value)?  autenticada,}){
final _that = this;
switch (_that) {
case SessaoVerificando() when verificando != null:
return verificando(_that);case SessaoAnonima() when anonima != null:
return anonima(_that);case SessaoAutenticada() when autenticada != null:
return autenticada(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  verificando,TResult Function()?  anonima,TResult Function()?  autenticada,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SessaoVerificando() when verificando != null:
return verificando();case SessaoAnonima() when anonima != null:
return anonima();case SessaoAutenticada() when autenticada != null:
return autenticada();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  verificando,required TResult Function()  anonima,required TResult Function()  autenticada,}) {final _that = this;
switch (_that) {
case SessaoVerificando():
return verificando();case SessaoAnonima():
return anonima();case SessaoAutenticada():
return autenticada();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  verificando,TResult? Function()?  anonima,TResult? Function()?  autenticada,}) {final _that = this;
switch (_that) {
case SessaoVerificando() when verificando != null:
return verificando();case SessaoAnonima() when anonima != null:
return anonima();case SessaoAutenticada() when autenticada != null:
return autenticada();case _:
  return null;

}
}

}

/// @nodoc


class SessaoVerificando implements SessaoState {
  const SessaoVerificando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SessaoVerificando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SessaoState.verificando()';
}


}




/// @nodoc


class SessaoAnonima implements SessaoState {
  const SessaoAnonima();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SessaoAnonima);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SessaoState.anonima()';
}


}




/// @nodoc


class SessaoAutenticada implements SessaoState {
  const SessaoAutenticada();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SessaoAutenticada);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SessaoState.autenticada()';
}


}




// dart format on
