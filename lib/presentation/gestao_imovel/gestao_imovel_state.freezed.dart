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

 ConteudoImovelGestao get imovel;
/// Create a copy of GestaoImovelState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GestaoImovelStateCopyWith<GestaoImovelState> get copyWith => _$GestaoImovelStateCopyWithImpl<GestaoImovelState>(this as GestaoImovelState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GestaoImovelState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GestaoImovelState&&(identical(other.imovel, _this.imovel) || other.imovel == _this.imovel));
}


@override
int get hashCode {
  final _this = this as GestaoImovelState;
  return Object.hash(runtimeType,_this.imovel);
}

@override
String toString() {
  final _this = this as GestaoImovelState;
  return 'GestaoImovelState(imovel: ${_this.imovel})';
}


}

/// @nodoc
abstract mixin class $GestaoImovelStateCopyWith<$Res>  {
  factory $GestaoImovelStateCopyWith(GestaoImovelState value, $Res Function(GestaoImovelState) _then) = _$GestaoImovelStateCopyWithImpl;
@useResult
$Res call({
 ConteudoImovelGestao imovel
});


$ConteudoImovelGestaoCopyWith<$Res> get imovel;

}
/// @nodoc
class _$GestaoImovelStateCopyWithImpl<$Res>
    implements $GestaoImovelStateCopyWith<$Res> {
  _$GestaoImovelStateCopyWithImpl(this._self, this._then);

  final GestaoImovelState _self;
  final $Res Function(GestaoImovelState) _then;

/// Create a copy of GestaoImovelState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imovel = null,}) {
  return _then(GestaoImovelState(
imovel: null == imovel ? _self.imovel : imovel // ignore: cast_nullable_to_non_nullable
as ConteudoImovelGestao,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ConteudoImovelGestao imovel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GestaoImovelState() when $default != null:
return $default(_that.imovel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ConteudoImovelGestao imovel)  $default,) {final _that = this;
switch (_that) {
case _GestaoImovelState():
return $default(_that.imovel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ConteudoImovelGestao imovel)?  $default,) {final _that = this;
switch (_that) {
case _GestaoImovelState() when $default != null:
return $default(_that.imovel);case _:
  return null;

}
}

}

/// @nodoc


class _GestaoImovelState implements GestaoImovelState {
  const _GestaoImovelState({this.imovel = const ConteudoImovelGestao.carregando()});
  

@override@JsonKey() final  ConteudoImovelGestao imovel;

/// Create a copy of GestaoImovelState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GestaoImovelStateCopyWith<_GestaoImovelState> get copyWith => __$GestaoImovelStateCopyWithImpl<_GestaoImovelState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GestaoImovelState&&(identical(other.imovel, imovel) || other.imovel == imovel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,imovel);
}

@override
String toString() {
    return 'GestaoImovelState(imovel: $imovel)';
}


}

/// @nodoc
abstract mixin class _$GestaoImovelStateCopyWith<$Res> implements $GestaoImovelStateCopyWith<$Res> {
  factory _$GestaoImovelStateCopyWith(_GestaoImovelState value, $Res Function(_GestaoImovelState) _then) = __$GestaoImovelStateCopyWithImpl;
@override @useResult
$Res call({
 ConteudoImovelGestao imovel
});


@override $ConteudoImovelGestaoCopyWith<$Res> get imovel;

}
/// @nodoc
class __$GestaoImovelStateCopyWithImpl<$Res>
    implements _$GestaoImovelStateCopyWith<$Res> {
  __$GestaoImovelStateCopyWithImpl(this._self, this._then);

  final _GestaoImovelState _self;
  final $Res Function(_GestaoImovelState) _then;

/// Create a copy of GestaoImovelState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imovel = null,}) {
  return _then(_GestaoImovelState(
imovel: null == imovel ? _self.imovel : imovel // ignore: cast_nullable_to_non_nullable
as ConteudoImovelGestao,
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ImovelGestaoCarregando value)?  carregando,TResult Function( ImovelGestaoCarregado value)?  carregado,TResult Function( ImovelGestaoErro value)?  erro,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ImovelGestaoCarregando() when carregando != null:
return carregando(_that);case ImovelGestaoCarregado() when carregado != null:
return carregado(_that);case ImovelGestaoErro() when erro != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ImovelGestaoCarregando value)  carregando,required TResult Function( ImovelGestaoCarregado value)  carregado,required TResult Function( ImovelGestaoErro value)  erro,}){
final _that = this;
switch (_that) {
case ImovelGestaoCarregando():
return carregando(_that);case ImovelGestaoCarregado():
return carregado(_that);case ImovelGestaoErro():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ImovelGestaoCarregando value)?  carregando,TResult? Function( ImovelGestaoCarregado value)?  carregado,TResult? Function( ImovelGestaoErro value)?  erro,}){
final _that = this;
switch (_that) {
case ImovelGestaoCarregando() when carregando != null:
return carregando(_that);case ImovelGestaoCarregado() when carregado != null:
return carregado(_that);case ImovelGestaoErro() when erro != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  carregando,TResult Function( ImovelGestao imovel)?  carregado,TResult Function()?  erro,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ImovelGestaoCarregando() when carregando != null:
return carregando();case ImovelGestaoCarregado() when carregado != null:
return carregado(_that.imovel);case ImovelGestaoErro() when erro != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  carregando,required TResult Function( ImovelGestao imovel)  carregado,required TResult Function()  erro,}) {final _that = this;
switch (_that) {
case ImovelGestaoCarregando():
return carregando();case ImovelGestaoCarregado():
return carregado(_that.imovel);case ImovelGestaoErro():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  carregando,TResult? Function( ImovelGestao imovel)?  carregado,TResult? Function()?  erro,}) {final _that = this;
switch (_that) {
case ImovelGestaoCarregando() when carregando != null:
return carregando();case ImovelGestaoCarregado() when carregado != null:
return carregado(_that.imovel);case ImovelGestaoErro() when erro != null:
return erro();case _:
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




// dart format on
