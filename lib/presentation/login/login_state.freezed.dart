// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LoginState()';
}


}

/// @nodoc
class $LoginStateCopyWith<$Res>  {
$LoginStateCopyWith(LoginState _, $Res Function(LoginState) __);
}


/// Adds pattern-matching-related methods to [LoginState].
extension LoginStatePatterns on LoginState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LoginEditando value)?  editando,TResult Function( LoginEnviando value)?  enviando,TResult Function( LoginFalha value)?  falha,TResult Function( LoginEntrou value)?  entrou,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LoginEditando() when editando != null:
return editando(_that);case LoginEnviando() when enviando != null:
return enviando(_that);case LoginFalha() when falha != null:
return falha(_that);case LoginEntrou() when entrou != null:
return entrou(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LoginEditando value)  editando,required TResult Function( LoginEnviando value)  enviando,required TResult Function( LoginFalha value)  falha,required TResult Function( LoginEntrou value)  entrou,}){
final _that = this;
switch (_that) {
case LoginEditando():
return editando(_that);case LoginEnviando():
return enviando(_that);case LoginFalha():
return falha(_that);case LoginEntrou():
return entrou(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LoginEditando value)?  editando,TResult? Function( LoginEnviando value)?  enviando,TResult? Function( LoginFalha value)?  falha,TResult? Function( LoginEntrou value)?  entrou,}){
final _that = this;
switch (_that) {
case LoginEditando() when editando != null:
return editando(_that);case LoginEnviando() when enviando != null:
return enviando(_that);case LoginFalha() when falha != null:
return falha(_that);case LoginEntrou() when entrou != null:
return entrou(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  editando,TResult Function()?  enviando,TResult Function( String mensagem)?  falha,TResult Function( Papel papel)?  entrou,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LoginEditando() when editando != null:
return editando();case LoginEnviando() when enviando != null:
return enviando();case LoginFalha() when falha != null:
return falha(_that.mensagem);case LoginEntrou() when entrou != null:
return entrou(_that.papel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  editando,required TResult Function()  enviando,required TResult Function( String mensagem)  falha,required TResult Function( Papel papel)  entrou,}) {final _that = this;
switch (_that) {
case LoginEditando():
return editando();case LoginEnviando():
return enviando();case LoginFalha():
return falha(_that.mensagem);case LoginEntrou():
return entrou(_that.papel);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  editando,TResult? Function()?  enviando,TResult? Function( String mensagem)?  falha,TResult? Function( Papel papel)?  entrou,}) {final _that = this;
switch (_that) {
case LoginEditando() when editando != null:
return editando();case LoginEnviando() when enviando != null:
return enviando();case LoginFalha() when falha != null:
return falha(_that.mensagem);case LoginEntrou() when entrou != null:
return entrou(_that.papel);case _:
  return null;

}
}

}

/// @nodoc


class LoginEditando implements LoginState {
  const LoginEditando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginEditando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LoginState.editando()';
}


}




/// @nodoc


class LoginEnviando implements LoginState {
  const LoginEnviando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginEnviando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LoginState.enviando()';
}


}




/// @nodoc


class LoginFalha implements LoginState {
  const LoginFalha({required this.mensagem});
  

 final  String mensagem;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginFalhaCopyWith<LoginFalha> get copyWith => _$LoginFalhaCopyWithImpl<LoginFalha>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginFalha&&(identical(other.mensagem, mensagem) || other.mensagem == mensagem));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mensagem);
}

@override
String toString() {
    return 'LoginState.falha(mensagem: $mensagem)';
}


}

/// @nodoc
abstract mixin class $LoginFalhaCopyWith<$Res> implements $LoginStateCopyWith<$Res> {
  factory $LoginFalhaCopyWith(LoginFalha value, $Res Function(LoginFalha) _then) = _$LoginFalhaCopyWithImpl;
@useResult
$Res call({
 String mensagem
});




}
/// @nodoc
class _$LoginFalhaCopyWithImpl<$Res>
    implements $LoginFalhaCopyWith<$Res> {
  _$LoginFalhaCopyWithImpl(this._self, this._then);

  final LoginFalha _self;
  final $Res Function(LoginFalha) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? mensagem = null,}) {
  return _then(LoginFalha(
mensagem: null == mensagem ? _self.mensagem : mensagem // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LoginEntrou implements LoginState {
  const LoginEntrou(this.papel);
  

 final  Papel papel;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginEntrouCopyWith<LoginEntrou> get copyWith => _$LoginEntrouCopyWithImpl<LoginEntrou>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginEntrou&&(identical(other.papel, papel) || other.papel == papel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,papel);
}

@override
String toString() {
    return 'LoginState.entrou(papel: $papel)';
}


}

/// @nodoc
abstract mixin class $LoginEntrouCopyWith<$Res> implements $LoginStateCopyWith<$Res> {
  factory $LoginEntrouCopyWith(LoginEntrou value, $Res Function(LoginEntrou) _then) = _$LoginEntrouCopyWithImpl;
@useResult
$Res call({
 Papel papel
});




}
/// @nodoc
class _$LoginEntrouCopyWithImpl<$Res>
    implements $LoginEntrouCopyWith<$Res> {
  _$LoginEntrouCopyWithImpl(this._self, this._then);

  final LoginEntrou _self;
  final $Res Function(LoginEntrou) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? papel = null,}) {
  return _then(LoginEntrou(
null == papel ? _self.papel : papel // ignore: cast_nullable_to_non_nullable
as Papel,
  ));
}


}

// dart format on
