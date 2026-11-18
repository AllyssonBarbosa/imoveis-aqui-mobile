// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contato_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContatoState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ContatoState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ContatoState()';
}


}

/// @nodoc
class $ContatoStateCopyWith<$Res>  {
$ContatoStateCopyWith(ContatoState _, $Res Function(ContatoState) __);
}


/// Adds pattern-matching-related methods to [ContatoState].
extension ContatoStatePatterns on ContatoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ContatoOcioso value)?  ocioso,TResult Function( ContatoEnviando value)?  enviando,TResult Function( ContatoFalhou value)?  falhou,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ContatoOcioso() when ocioso != null:
return ocioso(_that);case ContatoEnviando() when enviando != null:
return enviando(_that);case ContatoFalhou() when falhou != null:
return falhou(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ContatoOcioso value)  ocioso,required TResult Function( ContatoEnviando value)  enviando,required TResult Function( ContatoFalhou value)  falhou,}){
final _that = this;
switch (_that) {
case ContatoOcioso():
return ocioso(_that);case ContatoEnviando():
return enviando(_that);case ContatoFalhou():
return falhou(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ContatoOcioso value)?  ocioso,TResult? Function( ContatoEnviando value)?  enviando,TResult? Function( ContatoFalhou value)?  falhou,}){
final _that = this;
switch (_that) {
case ContatoOcioso() when ocioso != null:
return ocioso(_that);case ContatoEnviando() when enviando != null:
return enviando(_that);case ContatoFalhou() when falhou != null:
return falhou(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  ocioso,TResult Function( CanalContato canal)?  enviando,TResult Function( MotivoFalhaContato motivo)?  falhou,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ContatoOcioso() when ocioso != null:
return ocioso();case ContatoEnviando() when enviando != null:
return enviando(_that.canal);case ContatoFalhou() when falhou != null:
return falhou(_that.motivo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  ocioso,required TResult Function( CanalContato canal)  enviando,required TResult Function( MotivoFalhaContato motivo)  falhou,}) {final _that = this;
switch (_that) {
case ContatoOcioso():
return ocioso();case ContatoEnviando():
return enviando(_that.canal);case ContatoFalhou():
return falhou(_that.motivo);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  ocioso,TResult? Function( CanalContato canal)?  enviando,TResult? Function( MotivoFalhaContato motivo)?  falhou,}) {final _that = this;
switch (_that) {
case ContatoOcioso() when ocioso != null:
return ocioso();case ContatoEnviando() when enviando != null:
return enviando(_that.canal);case ContatoFalhou() when falhou != null:
return falhou(_that.motivo);case _:
  return null;

}
}

}

/// @nodoc


class ContatoOcioso implements ContatoState {
  const ContatoOcioso();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ContatoOcioso);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ContatoState.ocioso()';
}


}




/// @nodoc


class ContatoEnviando implements ContatoState {
  const ContatoEnviando(this.canal);
  

 final  CanalContato canal;

/// Create a copy of ContatoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContatoEnviandoCopyWith<ContatoEnviando> get copyWith => _$ContatoEnviandoCopyWithImpl<ContatoEnviando>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ContatoEnviando&&(identical(other.canal, canal) || other.canal == canal));
}


@override
int get hashCode {
    return Object.hash(runtimeType,canal);
}

@override
String toString() {
    return 'ContatoState.enviando(canal: $canal)';
}


}

/// @nodoc
abstract mixin class $ContatoEnviandoCopyWith<$Res> implements $ContatoStateCopyWith<$Res> {
  factory $ContatoEnviandoCopyWith(ContatoEnviando value, $Res Function(ContatoEnviando) _then) = _$ContatoEnviandoCopyWithImpl;
@useResult
$Res call({
 CanalContato canal
});




}
/// @nodoc
class _$ContatoEnviandoCopyWithImpl<$Res>
    implements $ContatoEnviandoCopyWith<$Res> {
  _$ContatoEnviandoCopyWithImpl(this._self, this._then);

  final ContatoEnviando _self;
  final $Res Function(ContatoEnviando) _then;

/// Create a copy of ContatoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? canal = null,}) {
  return _then(ContatoEnviando(
null == canal ? _self.canal : canal // ignore: cast_nullable_to_non_nullable
as CanalContato,
  ));
}


}

/// @nodoc


class ContatoFalhou implements ContatoState {
  const ContatoFalhou(this.motivo);
  

 final  MotivoFalhaContato motivo;

/// Create a copy of ContatoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContatoFalhouCopyWith<ContatoFalhou> get copyWith => _$ContatoFalhouCopyWithImpl<ContatoFalhou>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ContatoFalhou&&(identical(other.motivo, motivo) || other.motivo == motivo));
}


@override
int get hashCode {
    return Object.hash(runtimeType,motivo);
}

@override
String toString() {
    return 'ContatoState.falhou(motivo: $motivo)';
}


}

/// @nodoc
abstract mixin class $ContatoFalhouCopyWith<$Res> implements $ContatoStateCopyWith<$Res> {
  factory $ContatoFalhouCopyWith(ContatoFalhou value, $Res Function(ContatoFalhou) _then) = _$ContatoFalhouCopyWithImpl;
@useResult
$Res call({
 MotivoFalhaContato motivo
});




}
/// @nodoc
class _$ContatoFalhouCopyWithImpl<$Res>
    implements $ContatoFalhouCopyWith<$Res> {
  _$ContatoFalhouCopyWithImpl(this._self, this._then);

  final ContatoFalhou _self;
  final $Res Function(ContatoFalhou) _then;

/// Create a copy of ContatoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? motivo = null,}) {
  return _then(ContatoFalhou(
null == motivo ? _self.motivo : motivo // ignore: cast_nullable_to_non_nullable
as MotivoFalhaContato,
  ));
}


}

// dart format on
