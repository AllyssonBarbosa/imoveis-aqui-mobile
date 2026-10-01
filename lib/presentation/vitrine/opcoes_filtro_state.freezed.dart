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

 CarregamentoOpcoes get bairros; CarregamentoOpcoes get caracteristicas;
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
 CarregamentoOpcoes bairros, CarregamentoOpcoes caracteristicas
});


$CarregamentoOpcoesCopyWith<$Res> get bairros;$CarregamentoOpcoesCopyWith<$Res> get caracteristicas;

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
as CarregamentoOpcoes,caracteristicas: null == caracteristicas ? _self.caracteristicas : caracteristicas // ignore: cast_nullable_to_non_nullable
as CarregamentoOpcoes,
  ));
}
/// Create a copy of OpcoesFiltroState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CarregamentoOpcoesCopyWith<$Res> get bairros {
  
  return $CarregamentoOpcoesCopyWith<$Res>(_self.bairros, (value) {
    return _then(_self.copyWith(bairros: value));
  });
}/// Create a copy of OpcoesFiltroState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CarregamentoOpcoesCopyWith<$Res> get caracteristicas {
  
  return $CarregamentoOpcoesCopyWith<$Res>(_self.caracteristicas, (value) {
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CarregamentoOpcoes bairros,  CarregamentoOpcoes caracteristicas)?  $default,{required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CarregamentoOpcoes bairros,  CarregamentoOpcoes caracteristicas)  $default,) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CarregamentoOpcoes bairros,  CarregamentoOpcoes caracteristicas)?  $default,) {final _that = this;
switch (_that) {
case _OpcoesFiltroState() when $default != null:
return $default(_that.bairros,_that.caracteristicas);case _:
  return null;

}
}

}

/// @nodoc


class _OpcoesFiltroState implements OpcoesFiltroState {
  const _OpcoesFiltroState({this.bairros = const CarregamentoOpcoes.carregando(), this.caracteristicas = const CarregamentoOpcoes.carregando()});
  

@override@JsonKey() final  CarregamentoOpcoes bairros;
@override@JsonKey() final  CarregamentoOpcoes caracteristicas;

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
 CarregamentoOpcoes bairros, CarregamentoOpcoes caracteristicas
});


@override $CarregamentoOpcoesCopyWith<$Res> get bairros;@override $CarregamentoOpcoesCopyWith<$Res> get caracteristicas;

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
as CarregamentoOpcoes,caracteristicas: null == caracteristicas ? _self.caracteristicas : caracteristicas // ignore: cast_nullable_to_non_nullable
as CarregamentoOpcoes,
  ));
}

/// Create a copy of OpcoesFiltroState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CarregamentoOpcoesCopyWith<$Res> get bairros {
  
  return $CarregamentoOpcoesCopyWith<$Res>(_self.bairros, (value) {
    return _then(_self.copyWith(bairros: value));
  });
}/// Create a copy of OpcoesFiltroState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CarregamentoOpcoesCopyWith<$Res> get caracteristicas {
  
  return $CarregamentoOpcoesCopyWith<$Res>(_self.caracteristicas, (value) {
    return _then(_self.copyWith(caracteristicas: value));
  });
}
}

/// @nodoc
mixin _$CarregamentoOpcoes {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CarregamentoOpcoes);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CarregamentoOpcoes()';
}


}

/// @nodoc
class $CarregamentoOpcoesCopyWith<$Res>  {
$CarregamentoOpcoesCopyWith(CarregamentoOpcoes _, $Res Function(CarregamentoOpcoes) __);
}


/// Adds pattern-matching-related methods to [CarregamentoOpcoes].
extension CarregamentoOpcoesPatterns on CarregamentoOpcoes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OpcoesCarregando value)?  carregando,TResult Function( OpcoesCarregadas value)?  carregadas,TResult Function( OpcoesFalha value)?  falha,required TResult orElse(),}){
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OpcoesCarregando value)  carregando,required TResult Function( OpcoesCarregadas value)  carregadas,required TResult Function( OpcoesFalha value)  falha,}){
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OpcoesCarregando value)?  carregando,TResult? Function( OpcoesCarregadas value)?  carregadas,TResult? Function( OpcoesFalha value)?  falha,}){
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  carregando,TResult Function( List<String> opcoes)?  carregadas,TResult Function()?  falha,required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  carregando,required TResult Function( List<String> opcoes)  carregadas,required TResult Function()  falha,}) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  carregando,TResult? Function( List<String> opcoes)?  carregadas,TResult? Function()?  falha,}) {final _that = this;
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


class OpcoesCarregando implements CarregamentoOpcoes {
  const OpcoesCarregando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OpcoesCarregando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CarregamentoOpcoes.carregando()';
}


}




/// @nodoc


class OpcoesCarregadas implements CarregamentoOpcoes {
  const OpcoesCarregadas( List<String> opcoes): _opcoes = opcoes;
  

 final  List<String> _opcoes;
 List<String> get opcoes {
  if (_opcoes is EqualUnmodifiableListView) return _opcoes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_opcoes);
}


/// Create a copy of CarregamentoOpcoes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpcoesCarregadasCopyWith<OpcoesCarregadas> get copyWith => _$OpcoesCarregadasCopyWithImpl<OpcoesCarregadas>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OpcoesCarregadas&&const DeepCollectionEquality().equals(other.opcoes, _opcoes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_opcoes));
}

@override
String toString() {
    return 'CarregamentoOpcoes.carregadas(opcoes: $opcoes)';
}


}

/// @nodoc
abstract mixin class $OpcoesCarregadasCopyWith<$Res> implements $CarregamentoOpcoesCopyWith<$Res> {
  factory $OpcoesCarregadasCopyWith(OpcoesCarregadas value, $Res Function(OpcoesCarregadas) _then) = _$OpcoesCarregadasCopyWithImpl;
@useResult
$Res call({
 List<String> opcoes
});




}
/// @nodoc
class _$OpcoesCarregadasCopyWithImpl<$Res>
    implements $OpcoesCarregadasCopyWith<$Res> {
  _$OpcoesCarregadasCopyWithImpl(this._self, this._then);

  final OpcoesCarregadas _self;
  final $Res Function(OpcoesCarregadas) _then;

/// Create a copy of CarregamentoOpcoes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? opcoes = null,}) {
  return _then(OpcoesCarregadas(
null == opcoes ? _self._opcoes : opcoes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class OpcoesFalha implements CarregamentoOpcoes {
  const OpcoesFalha();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OpcoesFalha);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CarregamentoOpcoes.falha()';
}


}




// dart format on
