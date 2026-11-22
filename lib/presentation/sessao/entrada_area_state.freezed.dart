// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entrada_area_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EntradaAreaState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EntradaAreaState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EntradaAreaState()';
}


}

/// @nodoc
class $EntradaAreaStateCopyWith<$Res>  {
$EntradaAreaStateCopyWith(EntradaAreaState _, $Res Function(EntradaAreaState) __);
}


/// Adds pattern-matching-related methods to [EntradaAreaState].
extension EntradaAreaStatePatterns on EntradaAreaState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EntradaAreaCarregando value)?  carregando,TResult Function( EntradaAreaPapel value)?  papel,TResult Function( EntradaAreaErro value)?  erro,TResult Function( EntradaAreaSessaoExpirada value)?  sessaoExpirada,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EntradaAreaCarregando() when carregando != null:
return carregando(_that);case EntradaAreaPapel() when papel != null:
return papel(_that);case EntradaAreaErro() when erro != null:
return erro(_that);case EntradaAreaSessaoExpirada() when sessaoExpirada != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EntradaAreaCarregando value)  carregando,required TResult Function( EntradaAreaPapel value)  papel,required TResult Function( EntradaAreaErro value)  erro,required TResult Function( EntradaAreaSessaoExpirada value)  sessaoExpirada,}){
final _that = this;
switch (_that) {
case EntradaAreaCarregando():
return carregando(_that);case EntradaAreaPapel():
return papel(_that);case EntradaAreaErro():
return erro(_that);case EntradaAreaSessaoExpirada():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EntradaAreaCarregando value)?  carregando,TResult? Function( EntradaAreaPapel value)?  papel,TResult? Function( EntradaAreaErro value)?  erro,TResult? Function( EntradaAreaSessaoExpirada value)?  sessaoExpirada,}){
final _that = this;
switch (_that) {
case EntradaAreaCarregando() when carregando != null:
return carregando(_that);case EntradaAreaPapel() when papel != null:
return papel(_that);case EntradaAreaErro() when erro != null:
return erro(_that);case EntradaAreaSessaoExpirada() when sessaoExpirada != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  carregando,TResult Function( Papel papel)?  papel,TResult Function()?  erro,TResult Function()?  sessaoExpirada,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EntradaAreaCarregando() when carregando != null:
return carregando();case EntradaAreaPapel() when papel != null:
return papel(_that.papel);case EntradaAreaErro() when erro != null:
return erro();case EntradaAreaSessaoExpirada() when sessaoExpirada != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  carregando,required TResult Function( Papel papel)  papel,required TResult Function()  erro,required TResult Function()  sessaoExpirada,}) {final _that = this;
switch (_that) {
case EntradaAreaCarregando():
return carregando();case EntradaAreaPapel():
return papel(_that.papel);case EntradaAreaErro():
return erro();case EntradaAreaSessaoExpirada():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  carregando,TResult? Function( Papel papel)?  papel,TResult? Function()?  erro,TResult? Function()?  sessaoExpirada,}) {final _that = this;
switch (_that) {
case EntradaAreaCarregando() when carregando != null:
return carregando();case EntradaAreaPapel() when papel != null:
return papel(_that.papel);case EntradaAreaErro() when erro != null:
return erro();case EntradaAreaSessaoExpirada() when sessaoExpirada != null:
return sessaoExpirada();case _:
  return null;

}
}

}

/// @nodoc


class EntradaAreaCarregando implements EntradaAreaState {
  const EntradaAreaCarregando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EntradaAreaCarregando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EntradaAreaState.carregando()';
}


}




/// @nodoc


class EntradaAreaPapel implements EntradaAreaState {
  const EntradaAreaPapel(this.papel);
  

 final  Papel papel;

/// Create a copy of EntradaAreaState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntradaAreaPapelCopyWith<EntradaAreaPapel> get copyWith => _$EntradaAreaPapelCopyWithImpl<EntradaAreaPapel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EntradaAreaPapel&&(identical(other.papel, papel) || other.papel == papel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,papel);
}

@override
String toString() {
    return 'EntradaAreaState.papel(papel: $papel)';
}


}

/// @nodoc
abstract mixin class $EntradaAreaPapelCopyWith<$Res> implements $EntradaAreaStateCopyWith<$Res> {
  factory $EntradaAreaPapelCopyWith(EntradaAreaPapel value, $Res Function(EntradaAreaPapel) _then) = _$EntradaAreaPapelCopyWithImpl;
@useResult
$Res call({
 Papel papel
});




}
/// @nodoc
class _$EntradaAreaPapelCopyWithImpl<$Res>
    implements $EntradaAreaPapelCopyWith<$Res> {
  _$EntradaAreaPapelCopyWithImpl(this._self, this._then);

  final EntradaAreaPapel _self;
  final $Res Function(EntradaAreaPapel) _then;

/// Create a copy of EntradaAreaState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? papel = null,}) {
  return _then(EntradaAreaPapel(
null == papel ? _self.papel : papel // ignore: cast_nullable_to_non_nullable
as Papel,
  ));
}


}

/// @nodoc


class EntradaAreaErro implements EntradaAreaState {
  const EntradaAreaErro();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EntradaAreaErro);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EntradaAreaState.erro()';
}


}




/// @nodoc


class EntradaAreaSessaoExpirada implements EntradaAreaState {
  const EntradaAreaSessaoExpirada();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EntradaAreaSessaoExpirada);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EntradaAreaState.sessaoExpirada()';
}


}




// dart format on
