// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filtros_vitrine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FiltrosVitrine {

/// `null` = "Qualquer" (D-11).
 FinalidadeFiltro? get finalidade;/// OU entre valores (D-05).
 Set<NaturezaImovel> get naturezas;/// Depende da finalidade escolhida (D-03) — comparado com `preco_venda`
/// ou `preco_aluguel` conforme [finalidade], decisão que fica em
/// `data/`.
 int? get precoMin; int? get precoMax;/// "N ou mais" (D-01) — nunca "exatamente N".
 int? get quartosMin; int? get suitesMin; int? get vagasMin;/// OU entre valores (D-05).
 Set<String> get bairros; int? get areaMin; int? get areaMax;/// E entre valores (D-04) — o imóvel precisa ter TODAS as marcadas.
 Set<String> get caracteristicas;
/// Create a copy of FiltrosVitrine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FiltrosVitrineCopyWith<FiltrosVitrine> get copyWith => _$FiltrosVitrineCopyWithImpl<FiltrosVitrine>(this as FiltrosVitrine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FiltrosVitrine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FiltrosVitrine&&(identical(other.finalidade, _this.finalidade) || other.finalidade == _this.finalidade)&&const DeepCollectionEquality().equals(other.naturezas, _this.naturezas)&&(identical(other.precoMin, _this.precoMin) || other.precoMin == _this.precoMin)&&(identical(other.precoMax, _this.precoMax) || other.precoMax == _this.precoMax)&&(identical(other.quartosMin, _this.quartosMin) || other.quartosMin == _this.quartosMin)&&(identical(other.suitesMin, _this.suitesMin) || other.suitesMin == _this.suitesMin)&&(identical(other.vagasMin, _this.vagasMin) || other.vagasMin == _this.vagasMin)&&const DeepCollectionEquality().equals(other.bairros, _this.bairros)&&(identical(other.areaMin, _this.areaMin) || other.areaMin == _this.areaMin)&&(identical(other.areaMax, _this.areaMax) || other.areaMax == _this.areaMax)&&const DeepCollectionEquality().equals(other.caracteristicas, _this.caracteristicas));
}


@override
int get hashCode {
  final _this = this as FiltrosVitrine;
  return Object.hash(runtimeType,_this.finalidade,const DeepCollectionEquality().hash(_this.naturezas),_this.precoMin,_this.precoMax,_this.quartosMin,_this.suitesMin,_this.vagasMin,const DeepCollectionEquality().hash(_this.bairros),_this.areaMin,_this.areaMax,const DeepCollectionEquality().hash(_this.caracteristicas));
}

@override
String toString() {
  final _this = this as FiltrosVitrine;
  return 'FiltrosVitrine(finalidade: ${_this.finalidade}, naturezas: ${_this.naturezas}, precoMin: ${_this.precoMin}, precoMax: ${_this.precoMax}, quartosMin: ${_this.quartosMin}, suitesMin: ${_this.suitesMin}, vagasMin: ${_this.vagasMin}, bairros: ${_this.bairros}, areaMin: ${_this.areaMin}, areaMax: ${_this.areaMax}, caracteristicas: ${_this.caracteristicas})';
}


}

/// @nodoc
abstract mixin class $FiltrosVitrineCopyWith<$Res>  {
  factory $FiltrosVitrineCopyWith(FiltrosVitrine value, $Res Function(FiltrosVitrine) _then) = _$FiltrosVitrineCopyWithImpl;
@useResult
$Res call({
 FinalidadeFiltro? finalidade, Set<NaturezaImovel> naturezas, int? precoMin, int? precoMax, int? quartosMin, int? suitesMin, int? vagasMin, Set<String> bairros, int? areaMin, int? areaMax, Set<String> caracteristicas
});




}
/// @nodoc
class _$FiltrosVitrineCopyWithImpl<$Res>
    implements $FiltrosVitrineCopyWith<$Res> {
  _$FiltrosVitrineCopyWithImpl(this._self, this._then);

  final FiltrosVitrine _self;
  final $Res Function(FiltrosVitrine) _then;

/// Create a copy of FiltrosVitrine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? finalidade = freezed,Object? naturezas = null,Object? precoMin = freezed,Object? precoMax = freezed,Object? quartosMin = freezed,Object? suitesMin = freezed,Object? vagasMin = freezed,Object? bairros = null,Object? areaMin = freezed,Object? areaMax = freezed,Object? caracteristicas = null,}) {
  return _then(FiltrosVitrine(
finalidade: freezed == finalidade ? _self.finalidade : finalidade // ignore: cast_nullable_to_non_nullable
as FinalidadeFiltro?,naturezas: null == naturezas ? _self.naturezas : naturezas // ignore: cast_nullable_to_non_nullable
as Set<NaturezaImovel>,precoMin: freezed == precoMin ? _self.precoMin : precoMin // ignore: cast_nullable_to_non_nullable
as int?,precoMax: freezed == precoMax ? _self.precoMax : precoMax // ignore: cast_nullable_to_non_nullable
as int?,quartosMin: freezed == quartosMin ? _self.quartosMin : quartosMin // ignore: cast_nullable_to_non_nullable
as int?,suitesMin: freezed == suitesMin ? _self.suitesMin : suitesMin // ignore: cast_nullable_to_non_nullable
as int?,vagasMin: freezed == vagasMin ? _self.vagasMin : vagasMin // ignore: cast_nullable_to_non_nullable
as int?,bairros: null == bairros ? _self.bairros : bairros // ignore: cast_nullable_to_non_nullable
as Set<String>,areaMin: freezed == areaMin ? _self.areaMin : areaMin // ignore: cast_nullable_to_non_nullable
as int?,areaMax: freezed == areaMax ? _self.areaMax : areaMax // ignore: cast_nullable_to_non_nullable
as int?,caracteristicas: null == caracteristicas ? _self.caracteristicas : caracteristicas // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [FiltrosVitrine].
extension FiltrosVitrinePatterns on FiltrosVitrine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FiltrosVitrine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FiltrosVitrine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FiltrosVitrine value)  $default,){
final _that = this;
switch (_that) {
case _FiltrosVitrine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FiltrosVitrine value)?  $default,){
final _that = this;
switch (_that) {
case _FiltrosVitrine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FinalidadeFiltro? finalidade,  Set<NaturezaImovel> naturezas,  int? precoMin,  int? precoMax,  int? quartosMin,  int? suitesMin,  int? vagasMin,  Set<String> bairros,  int? areaMin,  int? areaMax,  Set<String> caracteristicas)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FiltrosVitrine() when $default != null:
return $default(_that.finalidade,_that.naturezas,_that.precoMin,_that.precoMax,_that.quartosMin,_that.suitesMin,_that.vagasMin,_that.bairros,_that.areaMin,_that.areaMax,_that.caracteristicas);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FinalidadeFiltro? finalidade,  Set<NaturezaImovel> naturezas,  int? precoMin,  int? precoMax,  int? quartosMin,  int? suitesMin,  int? vagasMin,  Set<String> bairros,  int? areaMin,  int? areaMax,  Set<String> caracteristicas)  $default,) {final _that = this;
switch (_that) {
case _FiltrosVitrine():
return $default(_that.finalidade,_that.naturezas,_that.precoMin,_that.precoMax,_that.quartosMin,_that.suitesMin,_that.vagasMin,_that.bairros,_that.areaMin,_that.areaMax,_that.caracteristicas);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FinalidadeFiltro? finalidade,  Set<NaturezaImovel> naturezas,  int? precoMin,  int? precoMax,  int? quartosMin,  int? suitesMin,  int? vagasMin,  Set<String> bairros,  int? areaMin,  int? areaMax,  Set<String> caracteristicas)?  $default,) {final _that = this;
switch (_that) {
case _FiltrosVitrine() when $default != null:
return $default(_that.finalidade,_that.naturezas,_that.precoMin,_that.precoMax,_that.quartosMin,_that.suitesMin,_that.vagasMin,_that.bairros,_that.areaMin,_that.areaMax,_that.caracteristicas);case _:
  return null;

}
}

}

/// @nodoc


class _FiltrosVitrine extends FiltrosVitrine {
  const _FiltrosVitrine({this.finalidade,  Set<NaturezaImovel> naturezas = const <NaturezaImovel>{}, this.precoMin, this.precoMax, this.quartosMin, this.suitesMin, this.vagasMin,  Set<String> bairros = const <String>{}, this.areaMin, this.areaMax,  Set<String> caracteristicas = const <String>{}}): _naturezas = naturezas,_bairros = bairros,_caracteristicas = caracteristicas,super._();
  

/// `null` = "Qualquer" (D-11).
@override final  FinalidadeFiltro? finalidade;
/// OU entre valores (D-05).
 final  Set<NaturezaImovel> _naturezas;
/// OU entre valores (D-05).
@override@JsonKey() Set<NaturezaImovel> get naturezas {
  if (_naturezas is EqualUnmodifiableSetView) return _naturezas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_naturezas);
}

/// Depende da finalidade escolhida (D-03) — comparado com `preco_venda`
/// ou `preco_aluguel` conforme [finalidade], decisão que fica em
/// `data/`.
@override final  int? precoMin;
@override final  int? precoMax;
/// "N ou mais" (D-01) — nunca "exatamente N".
@override final  int? quartosMin;
@override final  int? suitesMin;
@override final  int? vagasMin;
/// OU entre valores (D-05).
 final  Set<String> _bairros;
/// OU entre valores (D-05).
@override@JsonKey() Set<String> get bairros {
  if (_bairros is EqualUnmodifiableSetView) return _bairros;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_bairros);
}

@override final  int? areaMin;
@override final  int? areaMax;
/// E entre valores (D-04) — o imóvel precisa ter TODAS as marcadas.
 final  Set<String> _caracteristicas;
/// E entre valores (D-04) — o imóvel precisa ter TODAS as marcadas.
@override@JsonKey() Set<String> get caracteristicas {
  if (_caracteristicas is EqualUnmodifiableSetView) return _caracteristicas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_caracteristicas);
}


/// Create a copy of FiltrosVitrine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FiltrosVitrineCopyWith<_FiltrosVitrine> get copyWith => __$FiltrosVitrineCopyWithImpl<_FiltrosVitrine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FiltrosVitrine&&(identical(other.finalidade, finalidade) || other.finalidade == finalidade)&&const DeepCollectionEquality().equals(other.naturezas, _naturezas)&&(identical(other.precoMin, precoMin) || other.precoMin == precoMin)&&(identical(other.precoMax, precoMax) || other.precoMax == precoMax)&&(identical(other.quartosMin, quartosMin) || other.quartosMin == quartosMin)&&(identical(other.suitesMin, suitesMin) || other.suitesMin == suitesMin)&&(identical(other.vagasMin, vagasMin) || other.vagasMin == vagasMin)&&const DeepCollectionEquality().equals(other.bairros, _bairros)&&(identical(other.areaMin, areaMin) || other.areaMin == areaMin)&&(identical(other.areaMax, areaMax) || other.areaMax == areaMax)&&const DeepCollectionEquality().equals(other.caracteristicas, _caracteristicas));
}


@override
int get hashCode {
    return Object.hash(runtimeType,finalidade,const DeepCollectionEquality().hash(_naturezas),precoMin,precoMax,quartosMin,suitesMin,vagasMin,const DeepCollectionEquality().hash(_bairros),areaMin,areaMax,const DeepCollectionEquality().hash(_caracteristicas));
}

@override
String toString() {
    return 'FiltrosVitrine(finalidade: $finalidade, naturezas: $naturezas, precoMin: $precoMin, precoMax: $precoMax, quartosMin: $quartosMin, suitesMin: $suitesMin, vagasMin: $vagasMin, bairros: $bairros, areaMin: $areaMin, areaMax: $areaMax, caracteristicas: $caracteristicas)';
}


}

/// @nodoc
abstract mixin class _$FiltrosVitrineCopyWith<$Res> implements $FiltrosVitrineCopyWith<$Res> {
  factory _$FiltrosVitrineCopyWith(_FiltrosVitrine value, $Res Function(_FiltrosVitrine) _then) = __$FiltrosVitrineCopyWithImpl;
@override @useResult
$Res call({
 FinalidadeFiltro? finalidade, Set<NaturezaImovel> naturezas, int? precoMin, int? precoMax, int? quartosMin, int? suitesMin, int? vagasMin, Set<String> bairros, int? areaMin, int? areaMax, Set<String> caracteristicas
});




}
/// @nodoc
class __$FiltrosVitrineCopyWithImpl<$Res>
    implements _$FiltrosVitrineCopyWith<$Res> {
  __$FiltrosVitrineCopyWithImpl(this._self, this._then);

  final _FiltrosVitrine _self;
  final $Res Function(_FiltrosVitrine) _then;

/// Create a copy of FiltrosVitrine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? finalidade = freezed,Object? naturezas = null,Object? precoMin = freezed,Object? precoMax = freezed,Object? quartosMin = freezed,Object? suitesMin = freezed,Object? vagasMin = freezed,Object? bairros = null,Object? areaMin = freezed,Object? areaMax = freezed,Object? caracteristicas = null,}) {
  return _then(_FiltrosVitrine(
finalidade: freezed == finalidade ? _self.finalidade : finalidade // ignore: cast_nullable_to_non_nullable
as FinalidadeFiltro?,naturezas: null == naturezas ? _self._naturezas : naturezas // ignore: cast_nullable_to_non_nullable
as Set<NaturezaImovel>,precoMin: freezed == precoMin ? _self.precoMin : precoMin // ignore: cast_nullable_to_non_nullable
as int?,precoMax: freezed == precoMax ? _self.precoMax : precoMax // ignore: cast_nullable_to_non_nullable
as int?,quartosMin: freezed == quartosMin ? _self.quartosMin : quartosMin // ignore: cast_nullable_to_non_nullable
as int?,suitesMin: freezed == suitesMin ? _self.suitesMin : suitesMin // ignore: cast_nullable_to_non_nullable
as int?,vagasMin: freezed == vagasMin ? _self.vagasMin : vagasMin // ignore: cast_nullable_to_non_nullable
as int?,bairros: null == bairros ? _self._bairros : bairros // ignore: cast_nullable_to_non_nullable
as Set<String>,areaMin: freezed == areaMin ? _self.areaMin : areaMin // ignore: cast_nullable_to_non_nullable
as int?,areaMax: freezed == areaMax ? _self.areaMax : areaMax // ignore: cast_nullable_to_non_nullable
as int?,caracteristicas: null == caracteristicas ? _self._caracteristicas : caracteristicas // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
