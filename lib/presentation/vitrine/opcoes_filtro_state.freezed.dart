// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'opcoes_filtro_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OpcoesFiltroState {

 CarregamentoOpcoes<String> get bairros; CarregamentoOpcoes<Caracteristica> get caracteristicas;
/// Create a copy of OpcoesFiltroState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpcoesFiltroStateCopyWith<OpcoesFiltroState> get copyWith => _$OpcoesFiltroStateCopyWithImpl<OpcoesFiltroState>(this as OpcoesFiltroState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OpcoesFiltroState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpcoesFiltroState&&(identical(other.bairros, _this.bairros) || other.bairros == _this.bairros)&&(identical(other.caracteristicas, _this.caracteristicas) || other.caracteristicas == _this.caracteristicas));
}


@override
int get hashCode {
  final _this = this as OpcoesFiltroState;
  return Object.hash(runtimeType,_this.bairros,_this.caracteristicas);
}

@override
String toString() {
  final _this = this as OpcoesFiltroState;
  return 'OpcoesFiltroState(bairros: ${_this.bairros}, caracteristicas: ${_this.caracteristicas})';
}


}

/// @nodoc
abstract mixin class $OpcoesFiltroStateCopyWith<$Res>  {
  factory $OpcoesFiltroStateCopyWith(OpcoesFiltroState value, $Res Function(OpcoesFiltroState) _then) = _$OpcoesFiltroStateCopyWithImpl;
@useResult
$Res call({
 CarregamentoOpcoes<String> bairros, CarregamentoOpcoes<Caracteristica> caracteristicas
});


$CarregamentoOpcoesCopyWith<String, $Res> get bairros;$CarregamentoOpcoesCopyWith<Caracteristica, $Res> get caracteristicas;

}
/// @nodoc
class _$OpcoesFiltroStateCopyWithImpl<$Res>
    implements $OpcoesFiltroStateCopyWith<$Res> {
  _$OpcoesFiltroStateCopyWithImpl(this._self, this._then);

  final OpcoesFiltroState _self;
  final $Res Function(OpcoesFiltroState) _then;

/// Create a copy of OpcoesFiltroState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bairros = null,Object? caracteristicas = null,}) {
  return _then(OpcoesFiltroState(
bairros: null == bairros ? _self.bairros : bairros // ignore: cast_nullable_to_non_nullable
as CarregamentoOpcoes<String>,caracteristicas: null == caracteristicas ? _self.caracteristicas : caracteristicas // ignore: cast_nullable_to_non_nullable
as CarregamentoOpcoes<Caracteristica>,
  ));
}
/// Create a copy of OpcoesFiltroState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CarregamentoOpcoesCopyWith<String, $Res> get bairros {
  
  return $CarregamentoOpcoesCopyWith<String, $Res>(_self.bairros, (value) {
    return _then(_self.copyWith(bairros: value));
  });
}/// Create a copy of OpcoesFiltroState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CarregamentoOpcoesCopyWith<Caracteristica, $Res> get caracteristicas {
  
  return $CarregamentoOpcoesCopyWith<Caracteristica, $Res>(_self.caracteristicas, (value) {
    return _then(_self.copyWith(caracteristicas: value));
  });
}
}


/// Adds pattern-matching-related methods to [OpcoesFiltroState].
extension OpcoesFiltroStatePatterns on OpcoesFiltroState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpcoesFiltroState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpcoesFiltroState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpcoesFiltroState value)  $default,){
final _that = this;
switch (_that) {
case _OpcoesFiltroState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpcoesFiltroState value)?  $default,){
final _that = this;
switch (_that) {
case _OpcoesFiltroState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CarregamentoOpcoes<String> bairros,  CarregamentoOpcoes<Caracteristica> caracteristicas)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpcoesFiltroState() when $default != null:
return $default(_that.bairros,_that.caracteristicas);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CarregamentoOpcoes<String> bairros,  CarregamentoOpcoes<Caracteristica> caracteristicas)  $default,) {final _that = this;
switch (_that) {
case _OpcoesFiltroState():
return $default(_that.bairros,_that.caracteristicas);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CarregamentoOpcoes<String> bairros,  CarregamentoOpcoes<Caracteristica> caracteristicas)?  $default,) {final _that = this;
switch (_that) {
case _OpcoesFiltroState() when $default != null:
return $default(_that.bairros,_that.caracteristicas);case _:
  return null;

}
}

}

/// @nodoc


class _OpcoesFiltroState implements OpcoesFiltroState {
  const _OpcoesFiltroState({this.bairros = const CarregamentoOpcoes<String>.carregando(), this.caracteristicas = const CarregamentoOpcoes<Caracteristica>.carregando()});
  

@override@JsonKey() final  CarregamentoOpcoes<String> bairros;
@override@JsonKey() final  CarregamentoOpcoes<Caracteristica> caracteristicas;

/// Create a copy of OpcoesFiltroState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpcoesFiltroStateCopyWith<_OpcoesFiltroState> get copyWith => __$OpcoesFiltroStateCopyWithImpl<_OpcoesFiltroState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpcoesFiltroState&&(identical(other.bairros, bairros) || other.bairros == bairros)&&(identical(other.caracteristicas, caracteristicas) || other.caracteristicas == caracteristicas));
}


@override
int get hashCode {
    return Object.hash(runtimeType,bairros,caracteristicas);
}

@override
String toString() {
    return 'OpcoesFiltroState(bairros: $bairros, caracteristicas: $caracteristicas)';
}


}

/// @nodoc
abstract mixin class _$OpcoesFiltroStateCopyWith<$Res> implements $OpcoesFiltroStateCopyWith<$Res> {
  factory _$OpcoesFiltroStateCopyWith(_OpcoesFiltroState value, $Res Function(_OpcoesFiltroState) _then) = __$OpcoesFiltroStateCopyWithImpl;
@override @useResult
$Res call({
 CarregamentoOpcoes<String> bairros, CarregamentoOpcoes<Caracteristica> caracteristicas
});


@override $CarregamentoOpcoesCopyWith<String, $Res> get bairros;@override $CarregamentoOpcoesCopyWith<Caracteristica, $Res> get caracteristicas;

}
/// @nodoc
class __$OpcoesFiltroStateCopyWithImpl<$Res>
    implements _$OpcoesFiltroStateCopyWith<$Res> {
  __$OpcoesFiltroStateCopyWithImpl(this._self, this._then);

  final _OpcoesFiltroState _self;
  final $Res Function(_OpcoesFiltroState) _then;

/// Create a copy of OpcoesFiltroState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bairros = null,Object? caracteristicas = null,}) {
  return _then(_OpcoesFiltroState(
bairros: null == bairros ? _self.bairros : bairros // ignore: cast_nullable_to_non_nullable
as CarregamentoOpcoes<String>,caracteristicas: null == caracteristicas ? _self.caracteristicas : caracteristicas // ignore: cast_nullable_to_non_nullable
as CarregamentoOpcoes<Caracteristica>,
  ));
}

/// Create a copy of OpcoesFiltroState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CarregamentoOpcoesCopyWith<String, $Res> get bairros {
  
  return $CarregamentoOpcoesCopyWith<String, $Res>(_self.bairros, (value) {
    return _then(_self.copyWith(bairros: value));
  });
}/// Create a copy of OpcoesFiltroState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CarregamentoOpcoesCopyWith<Caracteristica, $Res> get caracteristicas {
  
  return $CarregamentoOpcoesCopyWith<Caracteristica, $Res>(_self.caracteristicas, (value) {
    return _then(_self.copyWith(caracteristicas: value));
  });
}
}

/// @nodoc
mixin _$CarregamentoOpcoes<T> {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CarregamentoOpcoes<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CarregamentoOpcoes<$T>()';
}


}

/// @nodoc
class $CarregamentoOpcoesCopyWith<T,$Res>  {
$CarregamentoOpcoesCopyWith(CarregamentoOpcoes<T> _, $Res Function(CarregamentoOpcoes<T>) __);
}


/// Adds pattern-matching-related methods to [CarregamentoOpcoes].
extension CarregamentoOpcoesPatterns<T> on CarregamentoOpcoes<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OpcoesCarregando<T> value)?  carregando,TResult Function( OpcoesCarregadas<T> value)?  carregadas,TResult Function( OpcoesFalha<T> value)?  falha,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OpcoesCarregando() when carregando != null:
return carregando(_that);case OpcoesCarregadas() when carregadas != null:
return carregadas(_that);case OpcoesFalha() when falha != null:
return falha(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OpcoesCarregando<T> value)  carregando,required TResult Function( OpcoesCarregadas<T> value)  carregadas,required TResult Function( OpcoesFalha<T> value)  falha,}){
final _that = this;
switch (_that) {
case OpcoesCarregando():
return carregando(_that);case OpcoesCarregadas():
return carregadas(_that);case OpcoesFalha():
return falha(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OpcoesCarregando<T> value)?  carregando,TResult? Function( OpcoesCarregadas<T> value)?  carregadas,TResult? Function( OpcoesFalha<T> value)?  falha,}){
final _that = this;
switch (_that) {
case OpcoesCarregando() when carregando != null:
return carregando(_that);case OpcoesCarregadas() when carregadas != null:
return carregadas(_that);case OpcoesFalha() when falha != null:
return falha(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  carregando,TResult Function( List<T> opcoes)?  carregadas,TResult Function()?  falha,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OpcoesCarregando() when carregando != null:
return carregando();case OpcoesCarregadas() when carregadas != null:
return carregadas(_that.opcoes);case OpcoesFalha() when falha != null:
return falha();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  carregando,required TResult Function( List<T> opcoes)  carregadas,required TResult Function()  falha,}) {final _that = this;
switch (_that) {
case OpcoesCarregando():
return carregando();case OpcoesCarregadas():
return carregadas(_that.opcoes);case OpcoesFalha():
return falha();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  carregando,TResult? Function( List<T> opcoes)?  carregadas,TResult? Function()?  falha,}) {final _that = this;
switch (_that) {
case OpcoesCarregando() when carregando != null:
return carregando();case OpcoesCarregadas() when carregadas != null:
return carregadas(_that.opcoes);case OpcoesFalha() when falha != null:
return falha();case _:
  return null;

}
}

}

/// @nodoc


class OpcoesCarregando<T> implements CarregamentoOpcoes<T> {
  const OpcoesCarregando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OpcoesCarregando<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CarregamentoOpcoes<$T>.carregando()';
}


}




/// @nodoc


class OpcoesCarregadas<T> implements CarregamentoOpcoes<T> {
  const OpcoesCarregadas( List<T> opcoes): _opcoes = opcoes;
  

 final  List<T> _opcoes;
 List<T> get opcoes {
  if (_opcoes is EqualUnmodifiableListView) return _opcoes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_opcoes);
}


/// Create a copy of CarregamentoOpcoes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpcoesCarregadasCopyWith<T, OpcoesCarregadas<T>> get copyWith => _$OpcoesCarregadasCopyWithImpl<T, OpcoesCarregadas<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OpcoesCarregadas<T>&&const DeepCollectionEquality().equals(other.opcoes, _opcoes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_opcoes));
}

@override
String toString() {
    return 'CarregamentoOpcoes<$T>.carregadas(opcoes: $opcoes)';
}


}

/// @nodoc
abstract mixin class $OpcoesCarregadasCopyWith<T,$Res> implements $CarregamentoOpcoesCopyWith<T, $Res> {
  factory $OpcoesCarregadasCopyWith(OpcoesCarregadas<T> value, $Res Function(OpcoesCarregadas<T>) _then) = _$OpcoesCarregadasCopyWithImpl;
@useResult
$Res call({
 List<T> opcoes
});




}
/// @nodoc
class _$OpcoesCarregadasCopyWithImpl<T,$Res>
    implements $OpcoesCarregadasCopyWith<T, $Res> {
  _$OpcoesCarregadasCopyWithImpl(this._self, this._then);

  final OpcoesCarregadas<T> _self;
  final $Res Function(OpcoesCarregadas<T>) _then;

/// Create a copy of CarregamentoOpcoes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? opcoes = null,}) {
  return _then(OpcoesCarregadas<T>(
null == opcoes ? _self._opcoes : opcoes // ignore: cast_nullable_to_non_nullable
as List<T>,
  ));
}


}

/// @nodoc


class OpcoesFalha<T> implements CarregamentoOpcoes<T> {
  const OpcoesFalha();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OpcoesFalha<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CarregamentoOpcoes<$T>.falha()';
}


}




// dart format on
