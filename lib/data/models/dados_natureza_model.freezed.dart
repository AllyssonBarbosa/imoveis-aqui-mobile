// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dados_natureza_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CasaModel {

@JsonKey(name: 'area_terreno') String? get areaTerreno;@JsonKey(name: 'area_construida') String? get areaConstruida;@JsonKey(name: 'area_livre') String? get areaLivre; int? get quartos; int? get suites; int? get banheiros; int? get salas; int? get vagas; int? get pavimentos;@JsonKey(name: 'ano_construcao') int? get anoConstrucao; bool? get piscina; bool? get quintal; bool? get churrasqueira; bool? get mobiliada;
/// Create a copy of CasaModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CasaModelCopyWith<CasaModel> get copyWith => _$CasaModelCopyWithImpl<CasaModel>(this as CasaModel, _$identity);

  /// Serializes this CasaModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CasaModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CasaModel&&(identical(other.areaTerreno, _this.areaTerreno) || other.areaTerreno == _this.areaTerreno)&&(identical(other.areaConstruida, _this.areaConstruida) || other.areaConstruida == _this.areaConstruida)&&(identical(other.areaLivre, _this.areaLivre) || other.areaLivre == _this.areaLivre)&&(identical(other.quartos, _this.quartos) || other.quartos == _this.quartos)&&(identical(other.suites, _this.suites) || other.suites == _this.suites)&&(identical(other.banheiros, _this.banheiros) || other.banheiros == _this.banheiros)&&(identical(other.salas, _this.salas) || other.salas == _this.salas)&&(identical(other.vagas, _this.vagas) || other.vagas == _this.vagas)&&(identical(other.pavimentos, _this.pavimentos) || other.pavimentos == _this.pavimentos)&&(identical(other.anoConstrucao, _this.anoConstrucao) || other.anoConstrucao == _this.anoConstrucao)&&(identical(other.piscina, _this.piscina) || other.piscina == _this.piscina)&&(identical(other.quintal, _this.quintal) || other.quintal == _this.quintal)&&(identical(other.churrasqueira, _this.churrasqueira) || other.churrasqueira == _this.churrasqueira)&&(identical(other.mobiliada, _this.mobiliada) || other.mobiliada == _this.mobiliada));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CasaModel;
  return Object.hash(runtimeType,_this.areaTerreno,_this.areaConstruida,_this.areaLivre,_this.quartos,_this.suites,_this.banheiros,_this.salas,_this.vagas,_this.pavimentos,_this.anoConstrucao,_this.piscina,_this.quintal,_this.churrasqueira,_this.mobiliada);
}

@override
String toString() {
  final _this = this as CasaModel;
  return 'CasaModel(areaTerreno: ${_this.areaTerreno}, areaConstruida: ${_this.areaConstruida}, areaLivre: ${_this.areaLivre}, quartos: ${_this.quartos}, suites: ${_this.suites}, banheiros: ${_this.banheiros}, salas: ${_this.salas}, vagas: ${_this.vagas}, pavimentos: ${_this.pavimentos}, anoConstrucao: ${_this.anoConstrucao}, piscina: ${_this.piscina}, quintal: ${_this.quintal}, churrasqueira: ${_this.churrasqueira}, mobiliada: ${_this.mobiliada})';
}


}

/// @nodoc
abstract mixin class $CasaModelCopyWith<$Res>  {
  factory $CasaModelCopyWith(CasaModel value, $Res Function(CasaModel) _then) = _$CasaModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'area_terreno') String? areaTerreno,@JsonKey(name: 'area_construida') String? areaConstruida,@JsonKey(name: 'area_livre') String? areaLivre, int? quartos, int? suites, int? banheiros, int? salas, int? vagas, int? pavimentos,@JsonKey(name: 'ano_construcao') int? anoConstrucao, bool? piscina, bool? quintal, bool? churrasqueira, bool? mobiliada
});




}
/// @nodoc
class _$CasaModelCopyWithImpl<$Res>
    implements $CasaModelCopyWith<$Res> {
  _$CasaModelCopyWithImpl(this._self, this._then);

  final CasaModel _self;
  final $Res Function(CasaModel) _then;

/// Create a copy of CasaModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? areaTerreno = freezed,Object? areaConstruida = freezed,Object? areaLivre = freezed,Object? quartos = freezed,Object? suites = freezed,Object? banheiros = freezed,Object? salas = freezed,Object? vagas = freezed,Object? pavimentos = freezed,Object? anoConstrucao = freezed,Object? piscina = freezed,Object? quintal = freezed,Object? churrasqueira = freezed,Object? mobiliada = freezed,}) {
  return _then(CasaModel(
areaTerreno: freezed == areaTerreno ? _self.areaTerreno : areaTerreno // ignore: cast_nullable_to_non_nullable
as String?,areaConstruida: freezed == areaConstruida ? _self.areaConstruida : areaConstruida // ignore: cast_nullable_to_non_nullable
as String?,areaLivre: freezed == areaLivre ? _self.areaLivre : areaLivre // ignore: cast_nullable_to_non_nullable
as String?,quartos: freezed == quartos ? _self.quartos : quartos // ignore: cast_nullable_to_non_nullable
as int?,suites: freezed == suites ? _self.suites : suites // ignore: cast_nullable_to_non_nullable
as int?,banheiros: freezed == banheiros ? _self.banheiros : banheiros // ignore: cast_nullable_to_non_nullable
as int?,salas: freezed == salas ? _self.salas : salas // ignore: cast_nullable_to_non_nullable
as int?,vagas: freezed == vagas ? _self.vagas : vagas // ignore: cast_nullable_to_non_nullable
as int?,pavimentos: freezed == pavimentos ? _self.pavimentos : pavimentos // ignore: cast_nullable_to_non_nullable
as int?,anoConstrucao: freezed == anoConstrucao ? _self.anoConstrucao : anoConstrucao // ignore: cast_nullable_to_non_nullable
as int?,piscina: freezed == piscina ? _self.piscina : piscina // ignore: cast_nullable_to_non_nullable
as bool?,quintal: freezed == quintal ? _self.quintal : quintal // ignore: cast_nullable_to_non_nullable
as bool?,churrasqueira: freezed == churrasqueira ? _self.churrasqueira : churrasqueira // ignore: cast_nullable_to_non_nullable
as bool?,mobiliada: freezed == mobiliada ? _self.mobiliada : mobiliada // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [CasaModel].
extension CasaModelPatterns on CasaModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CasaModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CasaModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CasaModel value)  $default,){
final _that = this;
switch (_that) {
case _CasaModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CasaModel value)?  $default,){
final _that = this;
switch (_that) {
case _CasaModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'area_terreno')  String? areaTerreno, @JsonKey(name: 'area_construida')  String? areaConstruida, @JsonKey(name: 'area_livre')  String? areaLivre,  int? quartos,  int? suites,  int? banheiros,  int? salas,  int? vagas,  int? pavimentos, @JsonKey(name: 'ano_construcao')  int? anoConstrucao,  bool? piscina,  bool? quintal,  bool? churrasqueira,  bool? mobiliada)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CasaModel() when $default != null:
return $default(_that.areaTerreno,_that.areaConstruida,_that.areaLivre,_that.quartos,_that.suites,_that.banheiros,_that.salas,_that.vagas,_that.pavimentos,_that.anoConstrucao,_that.piscina,_that.quintal,_that.churrasqueira,_that.mobiliada);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'area_terreno')  String? areaTerreno, @JsonKey(name: 'area_construida')  String? areaConstruida, @JsonKey(name: 'area_livre')  String? areaLivre,  int? quartos,  int? suites,  int? banheiros,  int? salas,  int? vagas,  int? pavimentos, @JsonKey(name: 'ano_construcao')  int? anoConstrucao,  bool? piscina,  bool? quintal,  bool? churrasqueira,  bool? mobiliada)  $default,) {final _that = this;
switch (_that) {
case _CasaModel():
return $default(_that.areaTerreno,_that.areaConstruida,_that.areaLivre,_that.quartos,_that.suites,_that.banheiros,_that.salas,_that.vagas,_that.pavimentos,_that.anoConstrucao,_that.piscina,_that.quintal,_that.churrasqueira,_that.mobiliada);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'area_terreno')  String? areaTerreno, @JsonKey(name: 'area_construida')  String? areaConstruida, @JsonKey(name: 'area_livre')  String? areaLivre,  int? quartos,  int? suites,  int? banheiros,  int? salas,  int? vagas,  int? pavimentos, @JsonKey(name: 'ano_construcao')  int? anoConstrucao,  bool? piscina,  bool? quintal,  bool? churrasqueira,  bool? mobiliada)?  $default,) {final _that = this;
switch (_that) {
case _CasaModel() when $default != null:
return $default(_that.areaTerreno,_that.areaConstruida,_that.areaLivre,_that.quartos,_that.suites,_that.banheiros,_that.salas,_that.vagas,_that.pavimentos,_that.anoConstrucao,_that.piscina,_that.quintal,_that.churrasqueira,_that.mobiliada);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CasaModel extends CasaModel {
  const _CasaModel({@JsonKey(name: 'area_terreno') this.areaTerreno, @JsonKey(name: 'area_construida') this.areaConstruida, @JsonKey(name: 'area_livre') this.areaLivre, this.quartos, this.suites, this.banheiros, this.salas, this.vagas, this.pavimentos, @JsonKey(name: 'ano_construcao') this.anoConstrucao, this.piscina, this.quintal, this.churrasqueira, this.mobiliada}): super._();
  factory _CasaModel.fromJson(Map<String, dynamic> json) => _$CasaModelFromJson(json);

@override@JsonKey(name: 'area_terreno') final  String? areaTerreno;
@override@JsonKey(name: 'area_construida') final  String? areaConstruida;
@override@JsonKey(name: 'area_livre') final  String? areaLivre;
@override final  int? quartos;
@override final  int? suites;
@override final  int? banheiros;
@override final  int? salas;
@override final  int? vagas;
@override final  int? pavimentos;
@override@JsonKey(name: 'ano_construcao') final  int? anoConstrucao;
@override final  bool? piscina;
@override final  bool? quintal;
@override final  bool? churrasqueira;
@override final  bool? mobiliada;

/// Create a copy of CasaModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CasaModelCopyWith<_CasaModel> get copyWith => __$CasaModelCopyWithImpl<_CasaModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CasaModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CasaModel&&(identical(other.areaTerreno, areaTerreno) || other.areaTerreno == areaTerreno)&&(identical(other.areaConstruida, areaConstruida) || other.areaConstruida == areaConstruida)&&(identical(other.areaLivre, areaLivre) || other.areaLivre == areaLivre)&&(identical(other.quartos, quartos) || other.quartos == quartos)&&(identical(other.suites, suites) || other.suites == suites)&&(identical(other.banheiros, banheiros) || other.banheiros == banheiros)&&(identical(other.salas, salas) || other.salas == salas)&&(identical(other.vagas, vagas) || other.vagas == vagas)&&(identical(other.pavimentos, pavimentos) || other.pavimentos == pavimentos)&&(identical(other.anoConstrucao, anoConstrucao) || other.anoConstrucao == anoConstrucao)&&(identical(other.piscina, piscina) || other.piscina == piscina)&&(identical(other.quintal, quintal) || other.quintal == quintal)&&(identical(other.churrasqueira, churrasqueira) || other.churrasqueira == churrasqueira)&&(identical(other.mobiliada, mobiliada) || other.mobiliada == mobiliada));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,areaTerreno,areaConstruida,areaLivre,quartos,suites,banheiros,salas,vagas,pavimentos,anoConstrucao,piscina,quintal,churrasqueira,mobiliada);
}

@override
String toString() {
    return 'CasaModel(areaTerreno: $areaTerreno, areaConstruida: $areaConstruida, areaLivre: $areaLivre, quartos: $quartos, suites: $suites, banheiros: $banheiros, salas: $salas, vagas: $vagas, pavimentos: $pavimentos, anoConstrucao: $anoConstrucao, piscina: $piscina, quintal: $quintal, churrasqueira: $churrasqueira, mobiliada: $mobiliada)';
}


}

/// @nodoc
abstract mixin class _$CasaModelCopyWith<$Res> implements $CasaModelCopyWith<$Res> {
  factory _$CasaModelCopyWith(_CasaModel value, $Res Function(_CasaModel) _then) = __$CasaModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'area_terreno') String? areaTerreno,@JsonKey(name: 'area_construida') String? areaConstruida,@JsonKey(name: 'area_livre') String? areaLivre, int? quartos, int? suites, int? banheiros, int? salas, int? vagas, int? pavimentos,@JsonKey(name: 'ano_construcao') int? anoConstrucao, bool? piscina, bool? quintal, bool? churrasqueira, bool? mobiliada
});




}
/// @nodoc
class __$CasaModelCopyWithImpl<$Res>
    implements _$CasaModelCopyWith<$Res> {
  __$CasaModelCopyWithImpl(this._self, this._then);

  final _CasaModel _self;
  final $Res Function(_CasaModel) _then;

/// Create a copy of CasaModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? areaTerreno = freezed,Object? areaConstruida = freezed,Object? areaLivre = freezed,Object? quartos = freezed,Object? suites = freezed,Object? banheiros = freezed,Object? salas = freezed,Object? vagas = freezed,Object? pavimentos = freezed,Object? anoConstrucao = freezed,Object? piscina = freezed,Object? quintal = freezed,Object? churrasqueira = freezed,Object? mobiliada = freezed,}) {
  return _then(_CasaModel(
areaTerreno: freezed == areaTerreno ? _self.areaTerreno : areaTerreno // ignore: cast_nullable_to_non_nullable
as String?,areaConstruida: freezed == areaConstruida ? _self.areaConstruida : areaConstruida // ignore: cast_nullable_to_non_nullable
as String?,areaLivre: freezed == areaLivre ? _self.areaLivre : areaLivre // ignore: cast_nullable_to_non_nullable
as String?,quartos: freezed == quartos ? _self.quartos : quartos // ignore: cast_nullable_to_non_nullable
as int?,suites: freezed == suites ? _self.suites : suites // ignore: cast_nullable_to_non_nullable
as int?,banheiros: freezed == banheiros ? _self.banheiros : banheiros // ignore: cast_nullable_to_non_nullable
as int?,salas: freezed == salas ? _self.salas : salas // ignore: cast_nullable_to_non_nullable
as int?,vagas: freezed == vagas ? _self.vagas : vagas // ignore: cast_nullable_to_non_nullable
as int?,pavimentos: freezed == pavimentos ? _self.pavimentos : pavimentos // ignore: cast_nullable_to_non_nullable
as int?,anoConstrucao: freezed == anoConstrucao ? _self.anoConstrucao : anoConstrucao // ignore: cast_nullable_to_non_nullable
as int?,piscina: freezed == piscina ? _self.piscina : piscina // ignore: cast_nullable_to_non_nullable
as bool?,quintal: freezed == quintal ? _self.quintal : quintal // ignore: cast_nullable_to_non_nullable
as bool?,churrasqueira: freezed == churrasqueira ? _self.churrasqueira : churrasqueira // ignore: cast_nullable_to_non_nullable
as bool?,mobiliada: freezed == mobiliada ? _self.mobiliada : mobiliada // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$TerrenoModel {

@JsonKey(name: 'area_total') String? get areaTotal; String? get frente; String? get fundo; String? get laterais;@JsonKey(name: 'topografia') String? get topografia; bool? get murado; bool? get esquina;@JsonKey(name: 'uso_permitido') String? get usoPermitido;
/// Create a copy of TerrenoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TerrenoModelCopyWith<TerrenoModel> get copyWith => _$TerrenoModelCopyWithImpl<TerrenoModel>(this as TerrenoModel, _$identity);

  /// Serializes this TerrenoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TerrenoModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TerrenoModel&&(identical(other.areaTotal, _this.areaTotal) || other.areaTotal == _this.areaTotal)&&(identical(other.frente, _this.frente) || other.frente == _this.frente)&&(identical(other.fundo, _this.fundo) || other.fundo == _this.fundo)&&(identical(other.laterais, _this.laterais) || other.laterais == _this.laterais)&&(identical(other.topografia, _this.topografia) || other.topografia == _this.topografia)&&(identical(other.murado, _this.murado) || other.murado == _this.murado)&&(identical(other.esquina, _this.esquina) || other.esquina == _this.esquina)&&(identical(other.usoPermitido, _this.usoPermitido) || other.usoPermitido == _this.usoPermitido));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TerrenoModel;
  return Object.hash(runtimeType,_this.areaTotal,_this.frente,_this.fundo,_this.laterais,_this.topografia,_this.murado,_this.esquina,_this.usoPermitido);
}

@override
String toString() {
  final _this = this as TerrenoModel;
  return 'TerrenoModel(areaTotal: ${_this.areaTotal}, frente: ${_this.frente}, fundo: ${_this.fundo}, laterais: ${_this.laterais}, topografia: ${_this.topografia}, murado: ${_this.murado}, esquina: ${_this.esquina}, usoPermitido: ${_this.usoPermitido})';
}


}

/// @nodoc
abstract mixin class $TerrenoModelCopyWith<$Res>  {
  factory $TerrenoModelCopyWith(TerrenoModel value, $Res Function(TerrenoModel) _then) = _$TerrenoModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'area_total') String? areaTotal, String? frente, String? fundo, String? laterais,@JsonKey(name: 'topografia') String? topografia, bool? murado, bool? esquina,@JsonKey(name: 'uso_permitido') String? usoPermitido
});




}
/// @nodoc
class _$TerrenoModelCopyWithImpl<$Res>
    implements $TerrenoModelCopyWith<$Res> {
  _$TerrenoModelCopyWithImpl(this._self, this._then);

  final TerrenoModel _self;
  final $Res Function(TerrenoModel) _then;

/// Create a copy of TerrenoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? areaTotal = freezed,Object? frente = freezed,Object? fundo = freezed,Object? laterais = freezed,Object? topografia = freezed,Object? murado = freezed,Object? esquina = freezed,Object? usoPermitido = freezed,}) {
  return _then(TerrenoModel(
areaTotal: freezed == areaTotal ? _self.areaTotal : areaTotal // ignore: cast_nullable_to_non_nullable
as String?,frente: freezed == frente ? _self.frente : frente // ignore: cast_nullable_to_non_nullable
as String?,fundo: freezed == fundo ? _self.fundo : fundo // ignore: cast_nullable_to_non_nullable
as String?,laterais: freezed == laterais ? _self.laterais : laterais // ignore: cast_nullable_to_non_nullable
as String?,topografia: freezed == topografia ? _self.topografia : topografia // ignore: cast_nullable_to_non_nullable
as String?,murado: freezed == murado ? _self.murado : murado // ignore: cast_nullable_to_non_nullable
as bool?,esquina: freezed == esquina ? _self.esquina : esquina // ignore: cast_nullable_to_non_nullable
as bool?,usoPermitido: freezed == usoPermitido ? _self.usoPermitido : usoPermitido // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TerrenoModel].
extension TerrenoModelPatterns on TerrenoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TerrenoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TerrenoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TerrenoModel value)  $default,){
final _that = this;
switch (_that) {
case _TerrenoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TerrenoModel value)?  $default,){
final _that = this;
switch (_that) {
case _TerrenoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'area_total')  String? areaTotal,  String? frente,  String? fundo,  String? laterais, @JsonKey(name: 'topografia')  String? topografia,  bool? murado,  bool? esquina, @JsonKey(name: 'uso_permitido')  String? usoPermitido)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TerrenoModel() when $default != null:
return $default(_that.areaTotal,_that.frente,_that.fundo,_that.laterais,_that.topografia,_that.murado,_that.esquina,_that.usoPermitido);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'area_total')  String? areaTotal,  String? frente,  String? fundo,  String? laterais, @JsonKey(name: 'topografia')  String? topografia,  bool? murado,  bool? esquina, @JsonKey(name: 'uso_permitido')  String? usoPermitido)  $default,) {final _that = this;
switch (_that) {
case _TerrenoModel():
return $default(_that.areaTotal,_that.frente,_that.fundo,_that.laterais,_that.topografia,_that.murado,_that.esquina,_that.usoPermitido);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'area_total')  String? areaTotal,  String? frente,  String? fundo,  String? laterais, @JsonKey(name: 'topografia')  String? topografia,  bool? murado,  bool? esquina, @JsonKey(name: 'uso_permitido')  String? usoPermitido)?  $default,) {final _that = this;
switch (_that) {
case _TerrenoModel() when $default != null:
return $default(_that.areaTotal,_that.frente,_that.fundo,_that.laterais,_that.topografia,_that.murado,_that.esquina,_that.usoPermitido);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TerrenoModel extends TerrenoModel {
  const _TerrenoModel({@JsonKey(name: 'area_total') this.areaTotal, this.frente, this.fundo, this.laterais, @JsonKey(name: 'topografia') this.topografia, this.murado, this.esquina, @JsonKey(name: 'uso_permitido') this.usoPermitido}): super._();
  factory _TerrenoModel.fromJson(Map<String, dynamic> json) => _$TerrenoModelFromJson(json);

@override@JsonKey(name: 'area_total') final  String? areaTotal;
@override final  String? frente;
@override final  String? fundo;
@override final  String? laterais;
@override@JsonKey(name: 'topografia') final  String? topografia;
@override final  bool? murado;
@override final  bool? esquina;
@override@JsonKey(name: 'uso_permitido') final  String? usoPermitido;

/// Create a copy of TerrenoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TerrenoModelCopyWith<_TerrenoModel> get copyWith => __$TerrenoModelCopyWithImpl<_TerrenoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TerrenoModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TerrenoModel&&(identical(other.areaTotal, areaTotal) || other.areaTotal == areaTotal)&&(identical(other.frente, frente) || other.frente == frente)&&(identical(other.fundo, fundo) || other.fundo == fundo)&&(identical(other.laterais, laterais) || other.laterais == laterais)&&(identical(other.topografia, topografia) || other.topografia == topografia)&&(identical(other.murado, murado) || other.murado == murado)&&(identical(other.esquina, esquina) || other.esquina == esquina)&&(identical(other.usoPermitido, usoPermitido) || other.usoPermitido == usoPermitido));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,areaTotal,frente,fundo,laterais,topografia,murado,esquina,usoPermitido);
}

@override
String toString() {
    return 'TerrenoModel(areaTotal: $areaTotal, frente: $frente, fundo: $fundo, laterais: $laterais, topografia: $topografia, murado: $murado, esquina: $esquina, usoPermitido: $usoPermitido)';
}


}

/// @nodoc
abstract mixin class _$TerrenoModelCopyWith<$Res> implements $TerrenoModelCopyWith<$Res> {
  factory _$TerrenoModelCopyWith(_TerrenoModel value, $Res Function(_TerrenoModel) _then) = __$TerrenoModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'area_total') String? areaTotal, String? frente, String? fundo, String? laterais,@JsonKey(name: 'topografia') String? topografia, bool? murado, bool? esquina,@JsonKey(name: 'uso_permitido') String? usoPermitido
});




}
/// @nodoc
class __$TerrenoModelCopyWithImpl<$Res>
    implements _$TerrenoModelCopyWith<$Res> {
  __$TerrenoModelCopyWithImpl(this._self, this._then);

  final _TerrenoModel _self;
  final $Res Function(_TerrenoModel) _then;

/// Create a copy of TerrenoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? areaTotal = freezed,Object? frente = freezed,Object? fundo = freezed,Object? laterais = freezed,Object? topografia = freezed,Object? murado = freezed,Object? esquina = freezed,Object? usoPermitido = freezed,}) {
  return _then(_TerrenoModel(
areaTotal: freezed == areaTotal ? _self.areaTotal : areaTotal // ignore: cast_nullable_to_non_nullable
as String?,frente: freezed == frente ? _self.frente : frente // ignore: cast_nullable_to_non_nullable
as String?,fundo: freezed == fundo ? _self.fundo : fundo // ignore: cast_nullable_to_non_nullable
as String?,laterais: freezed == laterais ? _self.laterais : laterais // ignore: cast_nullable_to_non_nullable
as String?,topografia: freezed == topografia ? _self.topografia : topografia // ignore: cast_nullable_to_non_nullable
as String?,murado: freezed == murado ? _self.murado : murado // ignore: cast_nullable_to_non_nullable
as bool?,esquina: freezed == esquina ? _self.esquina : esquina // ignore: cast_nullable_to_non_nullable
as bool?,usoPermitido: freezed == usoPermitido ? _self.usoPermitido : usoPermitido // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ApartamentoModel {

 int? get andar; String? get numero;@JsonKey(name: 'area_privativa') String? get areaPrivativa;@JsonKey(name: 'area_total') String? get areaTotal; int? get quartos; int? get suites; int? get banheiros; int? get vagas; bool? get varanda;@JsonKey(name: 'posicao_solar') String? get posicaoSolar; PredioModel? get predio;
/// Create a copy of ApartamentoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApartamentoModelCopyWith<ApartamentoModel> get copyWith => _$ApartamentoModelCopyWithImpl<ApartamentoModel>(this as ApartamentoModel, _$identity);

  /// Serializes this ApartamentoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ApartamentoModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApartamentoModel&&(identical(other.andar, _this.andar) || other.andar == _this.andar)&&(identical(other.numero, _this.numero) || other.numero == _this.numero)&&(identical(other.areaPrivativa, _this.areaPrivativa) || other.areaPrivativa == _this.areaPrivativa)&&(identical(other.areaTotal, _this.areaTotal) || other.areaTotal == _this.areaTotal)&&(identical(other.quartos, _this.quartos) || other.quartos == _this.quartos)&&(identical(other.suites, _this.suites) || other.suites == _this.suites)&&(identical(other.banheiros, _this.banheiros) || other.banheiros == _this.banheiros)&&(identical(other.vagas, _this.vagas) || other.vagas == _this.vagas)&&(identical(other.varanda, _this.varanda) || other.varanda == _this.varanda)&&(identical(other.posicaoSolar, _this.posicaoSolar) || other.posicaoSolar == _this.posicaoSolar)&&(identical(other.predio, _this.predio) || other.predio == _this.predio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ApartamentoModel;
  return Object.hash(runtimeType,_this.andar,_this.numero,_this.areaPrivativa,_this.areaTotal,_this.quartos,_this.suites,_this.banheiros,_this.vagas,_this.varanda,_this.posicaoSolar,_this.predio);
}

@override
String toString() {
  final _this = this as ApartamentoModel;
  return 'ApartamentoModel(andar: ${_this.andar}, numero: ${_this.numero}, areaPrivativa: ${_this.areaPrivativa}, areaTotal: ${_this.areaTotal}, quartos: ${_this.quartos}, suites: ${_this.suites}, banheiros: ${_this.banheiros}, vagas: ${_this.vagas}, varanda: ${_this.varanda}, posicaoSolar: ${_this.posicaoSolar}, predio: ${_this.predio})';
}


}

/// @nodoc
abstract mixin class $ApartamentoModelCopyWith<$Res>  {
  factory $ApartamentoModelCopyWith(ApartamentoModel value, $Res Function(ApartamentoModel) _then) = _$ApartamentoModelCopyWithImpl;
@useResult
$Res call({
 int? andar, String? numero,@JsonKey(name: 'area_privativa') String? areaPrivativa,@JsonKey(name: 'area_total') String? areaTotal, int? quartos, int? suites, int? banheiros, int? vagas, bool? varanda,@JsonKey(name: 'posicao_solar') String? posicaoSolar, PredioModel? predio
});


$PredioModelCopyWith<$Res>? get predio;

}
/// @nodoc
class _$ApartamentoModelCopyWithImpl<$Res>
    implements $ApartamentoModelCopyWith<$Res> {
  _$ApartamentoModelCopyWithImpl(this._self, this._then);

  final ApartamentoModel _self;
  final $Res Function(ApartamentoModel) _then;

/// Create a copy of ApartamentoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? andar = freezed,Object? numero = freezed,Object? areaPrivativa = freezed,Object? areaTotal = freezed,Object? quartos = freezed,Object? suites = freezed,Object? banheiros = freezed,Object? vagas = freezed,Object? varanda = freezed,Object? posicaoSolar = freezed,Object? predio = freezed,}) {
  return _then(ApartamentoModel(
andar: freezed == andar ? _self.andar : andar // ignore: cast_nullable_to_non_nullable
as int?,numero: freezed == numero ? _self.numero : numero // ignore: cast_nullable_to_non_nullable
as String?,areaPrivativa: freezed == areaPrivativa ? _self.areaPrivativa : areaPrivativa // ignore: cast_nullable_to_non_nullable
as String?,areaTotal: freezed == areaTotal ? _self.areaTotal : areaTotal // ignore: cast_nullable_to_non_nullable
as String?,quartos: freezed == quartos ? _self.quartos : quartos // ignore: cast_nullable_to_non_nullable
as int?,suites: freezed == suites ? _self.suites : suites // ignore: cast_nullable_to_non_nullable
as int?,banheiros: freezed == banheiros ? _self.banheiros : banheiros // ignore: cast_nullable_to_non_nullable
as int?,vagas: freezed == vagas ? _self.vagas : vagas // ignore: cast_nullable_to_non_nullable
as int?,varanda: freezed == varanda ? _self.varanda : varanda // ignore: cast_nullable_to_non_nullable
as bool?,posicaoSolar: freezed == posicaoSolar ? _self.posicaoSolar : posicaoSolar // ignore: cast_nullable_to_non_nullable
as String?,predio: freezed == predio ? _self.predio : predio // ignore: cast_nullable_to_non_nullable
as PredioModel?,
  ));
}
/// Create a copy of ApartamentoModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PredioModelCopyWith<$Res>? get predio {
    if (_self.predio == null) {
    return null;
  }

  return $PredioModelCopyWith<$Res>(_self.predio!, (value) {
    return _then(_self.copyWith(predio: value));
  });
}
}


/// Adds pattern-matching-related methods to [ApartamentoModel].
extension ApartamentoModelPatterns on ApartamentoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApartamentoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApartamentoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApartamentoModel value)  $default,){
final _that = this;
switch (_that) {
case _ApartamentoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApartamentoModel value)?  $default,){
final _that = this;
switch (_that) {
case _ApartamentoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? andar,  String? numero, @JsonKey(name: 'area_privativa')  String? areaPrivativa, @JsonKey(name: 'area_total')  String? areaTotal,  int? quartos,  int? suites,  int? banheiros,  int? vagas,  bool? varanda, @JsonKey(name: 'posicao_solar')  String? posicaoSolar,  PredioModel? predio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApartamentoModel() when $default != null:
return $default(_that.andar,_that.numero,_that.areaPrivativa,_that.areaTotal,_that.quartos,_that.suites,_that.banheiros,_that.vagas,_that.varanda,_that.posicaoSolar,_that.predio);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? andar,  String? numero, @JsonKey(name: 'area_privativa')  String? areaPrivativa, @JsonKey(name: 'area_total')  String? areaTotal,  int? quartos,  int? suites,  int? banheiros,  int? vagas,  bool? varanda, @JsonKey(name: 'posicao_solar')  String? posicaoSolar,  PredioModel? predio)  $default,) {final _that = this;
switch (_that) {
case _ApartamentoModel():
return $default(_that.andar,_that.numero,_that.areaPrivativa,_that.areaTotal,_that.quartos,_that.suites,_that.banheiros,_that.vagas,_that.varanda,_that.posicaoSolar,_that.predio);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? andar,  String? numero, @JsonKey(name: 'area_privativa')  String? areaPrivativa, @JsonKey(name: 'area_total')  String? areaTotal,  int? quartos,  int? suites,  int? banheiros,  int? vagas,  bool? varanda, @JsonKey(name: 'posicao_solar')  String? posicaoSolar,  PredioModel? predio)?  $default,) {final _that = this;
switch (_that) {
case _ApartamentoModel() when $default != null:
return $default(_that.andar,_that.numero,_that.areaPrivativa,_that.areaTotal,_that.quartos,_that.suites,_that.banheiros,_that.vagas,_that.varanda,_that.posicaoSolar,_that.predio);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApartamentoModel extends ApartamentoModel {
  const _ApartamentoModel({this.andar, this.numero, @JsonKey(name: 'area_privativa') this.areaPrivativa, @JsonKey(name: 'area_total') this.areaTotal, this.quartos, this.suites, this.banheiros, this.vagas, this.varanda, @JsonKey(name: 'posicao_solar') this.posicaoSolar, this.predio}): super._();
  factory _ApartamentoModel.fromJson(Map<String, dynamic> json) => _$ApartamentoModelFromJson(json);

@override final  int? andar;
@override final  String? numero;
@override@JsonKey(name: 'area_privativa') final  String? areaPrivativa;
@override@JsonKey(name: 'area_total') final  String? areaTotal;
@override final  int? quartos;
@override final  int? suites;
@override final  int? banheiros;
@override final  int? vagas;
@override final  bool? varanda;
@override@JsonKey(name: 'posicao_solar') final  String? posicaoSolar;
@override final  PredioModel? predio;

/// Create a copy of ApartamentoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApartamentoModelCopyWith<_ApartamentoModel> get copyWith => __$ApartamentoModelCopyWithImpl<_ApartamentoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApartamentoModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApartamentoModel&&(identical(other.andar, andar) || other.andar == andar)&&(identical(other.numero, numero) || other.numero == numero)&&(identical(other.areaPrivativa, areaPrivativa) || other.areaPrivativa == areaPrivativa)&&(identical(other.areaTotal, areaTotal) || other.areaTotal == areaTotal)&&(identical(other.quartos, quartos) || other.quartos == quartos)&&(identical(other.suites, suites) || other.suites == suites)&&(identical(other.banheiros, banheiros) || other.banheiros == banheiros)&&(identical(other.vagas, vagas) || other.vagas == vagas)&&(identical(other.varanda, varanda) || other.varanda == varanda)&&(identical(other.posicaoSolar, posicaoSolar) || other.posicaoSolar == posicaoSolar)&&(identical(other.predio, predio) || other.predio == predio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,andar,numero,areaPrivativa,areaTotal,quartos,suites,banheiros,vagas,varanda,posicaoSolar,predio);
}

@override
String toString() {
    return 'ApartamentoModel(andar: $andar, numero: $numero, areaPrivativa: $areaPrivativa, areaTotal: $areaTotal, quartos: $quartos, suites: $suites, banheiros: $banheiros, vagas: $vagas, varanda: $varanda, posicaoSolar: $posicaoSolar, predio: $predio)';
}


}

/// @nodoc
abstract mixin class _$ApartamentoModelCopyWith<$Res> implements $ApartamentoModelCopyWith<$Res> {
  factory _$ApartamentoModelCopyWith(_ApartamentoModel value, $Res Function(_ApartamentoModel) _then) = __$ApartamentoModelCopyWithImpl;
@override @useResult
$Res call({
 int? andar, String? numero,@JsonKey(name: 'area_privativa') String? areaPrivativa,@JsonKey(name: 'area_total') String? areaTotal, int? quartos, int? suites, int? banheiros, int? vagas, bool? varanda,@JsonKey(name: 'posicao_solar') String? posicaoSolar, PredioModel? predio
});


@override $PredioModelCopyWith<$Res>? get predio;

}
/// @nodoc
class __$ApartamentoModelCopyWithImpl<$Res>
    implements _$ApartamentoModelCopyWith<$Res> {
  __$ApartamentoModelCopyWithImpl(this._self, this._then);

  final _ApartamentoModel _self;
  final $Res Function(_ApartamentoModel) _then;

/// Create a copy of ApartamentoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? andar = freezed,Object? numero = freezed,Object? areaPrivativa = freezed,Object? areaTotal = freezed,Object? quartos = freezed,Object? suites = freezed,Object? banheiros = freezed,Object? vagas = freezed,Object? varanda = freezed,Object? posicaoSolar = freezed,Object? predio = freezed,}) {
  return _then(_ApartamentoModel(
andar: freezed == andar ? _self.andar : andar // ignore: cast_nullable_to_non_nullable
as int?,numero: freezed == numero ? _self.numero : numero // ignore: cast_nullable_to_non_nullable
as String?,areaPrivativa: freezed == areaPrivativa ? _self.areaPrivativa : areaPrivativa // ignore: cast_nullable_to_non_nullable
as String?,areaTotal: freezed == areaTotal ? _self.areaTotal : areaTotal // ignore: cast_nullable_to_non_nullable
as String?,quartos: freezed == quartos ? _self.quartos : quartos // ignore: cast_nullable_to_non_nullable
as int?,suites: freezed == suites ? _self.suites : suites // ignore: cast_nullable_to_non_nullable
as int?,banheiros: freezed == banheiros ? _self.banheiros : banheiros // ignore: cast_nullable_to_non_nullable
as int?,vagas: freezed == vagas ? _self.vagas : vagas // ignore: cast_nullable_to_non_nullable
as int?,varanda: freezed == varanda ? _self.varanda : varanda // ignore: cast_nullable_to_non_nullable
as bool?,posicaoSolar: freezed == posicaoSolar ? _self.posicaoSolar : posicaoSolar // ignore: cast_nullable_to_non_nullable
as String?,predio: freezed == predio ? _self.predio : predio // ignore: cast_nullable_to_non_nullable
as PredioModel?,
  ));
}

/// Create a copy of ApartamentoModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PredioModelCopyWith<$Res>? get predio {
    if (_self.predio == null) {
    return null;
  }

  return $PredioModelCopyWith<$Res>(_self.predio!, (value) {
    return _then(_self.copyWith(predio: value));
  });
}
}


/// @nodoc
mixin _$LoteModel {

 String? get numero; String? get area; String? get frente; String? get fundo; String? get preco;@JsonKey(name: 'condicoes_parcelamento') String? get condicoesParcelamento; QuadraModel? get quadra;
/// Create a copy of LoteModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoteModelCopyWith<LoteModel> get copyWith => _$LoteModelCopyWithImpl<LoteModel>(this as LoteModel, _$identity);

  /// Serializes this LoteModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoteModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoteModel&&(identical(other.numero, _this.numero) || other.numero == _this.numero)&&(identical(other.area, _this.area) || other.area == _this.area)&&(identical(other.frente, _this.frente) || other.frente == _this.frente)&&(identical(other.fundo, _this.fundo) || other.fundo == _this.fundo)&&(identical(other.preco, _this.preco) || other.preco == _this.preco)&&(identical(other.condicoesParcelamento, _this.condicoesParcelamento) || other.condicoesParcelamento == _this.condicoesParcelamento)&&(identical(other.quadra, _this.quadra) || other.quadra == _this.quadra));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoteModel;
  return Object.hash(runtimeType,_this.numero,_this.area,_this.frente,_this.fundo,_this.preco,_this.condicoesParcelamento,_this.quadra);
}

@override
String toString() {
  final _this = this as LoteModel;
  return 'LoteModel(numero: ${_this.numero}, area: ${_this.area}, frente: ${_this.frente}, fundo: ${_this.fundo}, preco: ${_this.preco}, condicoesParcelamento: ${_this.condicoesParcelamento}, quadra: ${_this.quadra})';
}


}

/// @nodoc
abstract mixin class $LoteModelCopyWith<$Res>  {
  factory $LoteModelCopyWith(LoteModel value, $Res Function(LoteModel) _then) = _$LoteModelCopyWithImpl;
@useResult
$Res call({
 String? numero, String? area, String? frente, String? fundo, String? preco,@JsonKey(name: 'condicoes_parcelamento') String? condicoesParcelamento, QuadraModel? quadra
});


$QuadraModelCopyWith<$Res>? get quadra;

}
/// @nodoc
class _$LoteModelCopyWithImpl<$Res>
    implements $LoteModelCopyWith<$Res> {
  _$LoteModelCopyWithImpl(this._self, this._then);

  final LoteModel _self;
  final $Res Function(LoteModel) _then;

/// Create a copy of LoteModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? numero = freezed,Object? area = freezed,Object? frente = freezed,Object? fundo = freezed,Object? preco = freezed,Object? condicoesParcelamento = freezed,Object? quadra = freezed,}) {
  return _then(LoteModel(
numero: freezed == numero ? _self.numero : numero // ignore: cast_nullable_to_non_nullable
as String?,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String?,frente: freezed == frente ? _self.frente : frente // ignore: cast_nullable_to_non_nullable
as String?,fundo: freezed == fundo ? _self.fundo : fundo // ignore: cast_nullable_to_non_nullable
as String?,preco: freezed == preco ? _self.preco : preco // ignore: cast_nullable_to_non_nullable
as String?,condicoesParcelamento: freezed == condicoesParcelamento ? _self.condicoesParcelamento : condicoesParcelamento // ignore: cast_nullable_to_non_nullable
as String?,quadra: freezed == quadra ? _self.quadra : quadra // ignore: cast_nullable_to_non_nullable
as QuadraModel?,
  ));
}
/// Create a copy of LoteModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuadraModelCopyWith<$Res>? get quadra {
    if (_self.quadra == null) {
    return null;
  }

  return $QuadraModelCopyWith<$Res>(_self.quadra!, (value) {
    return _then(_self.copyWith(quadra: value));
  });
}
}


/// Adds pattern-matching-related methods to [LoteModel].
extension LoteModelPatterns on LoteModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoteModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoteModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoteModel value)  $default,){
final _that = this;
switch (_that) {
case _LoteModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoteModel value)?  $default,){
final _that = this;
switch (_that) {
case _LoteModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? numero,  String? area,  String? frente,  String? fundo,  String? preco, @JsonKey(name: 'condicoes_parcelamento')  String? condicoesParcelamento,  QuadraModel? quadra)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoteModel() when $default != null:
return $default(_that.numero,_that.area,_that.frente,_that.fundo,_that.preco,_that.condicoesParcelamento,_that.quadra);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? numero,  String? area,  String? frente,  String? fundo,  String? preco, @JsonKey(name: 'condicoes_parcelamento')  String? condicoesParcelamento,  QuadraModel? quadra)  $default,) {final _that = this;
switch (_that) {
case _LoteModel():
return $default(_that.numero,_that.area,_that.frente,_that.fundo,_that.preco,_that.condicoesParcelamento,_that.quadra);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? numero,  String? area,  String? frente,  String? fundo,  String? preco, @JsonKey(name: 'condicoes_parcelamento')  String? condicoesParcelamento,  QuadraModel? quadra)?  $default,) {final _that = this;
switch (_that) {
case _LoteModel() when $default != null:
return $default(_that.numero,_that.area,_that.frente,_that.fundo,_that.preco,_that.condicoesParcelamento,_that.quadra);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoteModel extends LoteModel {
  const _LoteModel({this.numero, this.area, this.frente, this.fundo, this.preco, @JsonKey(name: 'condicoes_parcelamento') this.condicoesParcelamento, this.quadra}): super._();
  factory _LoteModel.fromJson(Map<String, dynamic> json) => _$LoteModelFromJson(json);

@override final  String? numero;
@override final  String? area;
@override final  String? frente;
@override final  String? fundo;
@override final  String? preco;
@override@JsonKey(name: 'condicoes_parcelamento') final  String? condicoesParcelamento;
@override final  QuadraModel? quadra;

/// Create a copy of LoteModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoteModelCopyWith<_LoteModel> get copyWith => __$LoteModelCopyWithImpl<_LoteModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoteModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoteModel&&(identical(other.numero, numero) || other.numero == numero)&&(identical(other.area, area) || other.area == area)&&(identical(other.frente, frente) || other.frente == frente)&&(identical(other.fundo, fundo) || other.fundo == fundo)&&(identical(other.preco, preco) || other.preco == preco)&&(identical(other.condicoesParcelamento, condicoesParcelamento) || other.condicoesParcelamento == condicoesParcelamento)&&(identical(other.quadra, quadra) || other.quadra == quadra));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,numero,area,frente,fundo,preco,condicoesParcelamento,quadra);
}

@override
String toString() {
    return 'LoteModel(numero: $numero, area: $area, frente: $frente, fundo: $fundo, preco: $preco, condicoesParcelamento: $condicoesParcelamento, quadra: $quadra)';
}


}

/// @nodoc
abstract mixin class _$LoteModelCopyWith<$Res> implements $LoteModelCopyWith<$Res> {
  factory _$LoteModelCopyWith(_LoteModel value, $Res Function(_LoteModel) _then) = __$LoteModelCopyWithImpl;
@override @useResult
$Res call({
 String? numero, String? area, String? frente, String? fundo, String? preco,@JsonKey(name: 'condicoes_parcelamento') String? condicoesParcelamento, QuadraModel? quadra
});


@override $QuadraModelCopyWith<$Res>? get quadra;

}
/// @nodoc
class __$LoteModelCopyWithImpl<$Res>
    implements _$LoteModelCopyWith<$Res> {
  __$LoteModelCopyWithImpl(this._self, this._then);

  final _LoteModel _self;
  final $Res Function(_LoteModel) _then;

/// Create a copy of LoteModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? numero = freezed,Object? area = freezed,Object? frente = freezed,Object? fundo = freezed,Object? preco = freezed,Object? condicoesParcelamento = freezed,Object? quadra = freezed,}) {
  return _then(_LoteModel(
numero: freezed == numero ? _self.numero : numero // ignore: cast_nullable_to_non_nullable
as String?,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String?,frente: freezed == frente ? _self.frente : frente // ignore: cast_nullable_to_non_nullable
as String?,fundo: freezed == fundo ? _self.fundo : fundo // ignore: cast_nullable_to_non_nullable
as String?,preco: freezed == preco ? _self.preco : preco // ignore: cast_nullable_to_non_nullable
as String?,condicoesParcelamento: freezed == condicoesParcelamento ? _self.condicoesParcelamento : condicoesParcelamento // ignore: cast_nullable_to_non_nullable
as String?,quadra: freezed == quadra ? _self.quadra : quadra // ignore: cast_nullable_to_non_nullable
as QuadraModel?,
  ));
}

/// Create a copy of LoteModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuadraModelCopyWith<$Res>? get quadra {
    if (_self.quadra == null) {
    return null;
  }

  return $QuadraModelCopyWith<$Res>(_self.quadra!, (value) {
    return _then(_self.copyWith(quadra: value));
  });
}
}


/// @nodoc
mixin _$PredioModel {

 String? get nome; int? get andares;@JsonKey(name: 'unidades_por_andar') int? get unidadesPorAndar; int? get ano; int? get elevadores;@JsonKey(name: 'portaria_24h') bool? get portaria24h; bool? get piscina; bool? get academia;@JsonKey(name: 'salao_de_festas') bool? get salaoDeFestas; bool? get playground;
/// Create a copy of PredioModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PredioModelCopyWith<PredioModel> get copyWith => _$PredioModelCopyWithImpl<PredioModel>(this as PredioModel, _$identity);

  /// Serializes this PredioModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PredioModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PredioModel&&(identical(other.nome, _this.nome) || other.nome == _this.nome)&&(identical(other.andares, _this.andares) || other.andares == _this.andares)&&(identical(other.unidadesPorAndar, _this.unidadesPorAndar) || other.unidadesPorAndar == _this.unidadesPorAndar)&&(identical(other.ano, _this.ano) || other.ano == _this.ano)&&(identical(other.elevadores, _this.elevadores) || other.elevadores == _this.elevadores)&&(identical(other.portaria24h, _this.portaria24h) || other.portaria24h == _this.portaria24h)&&(identical(other.piscina, _this.piscina) || other.piscina == _this.piscina)&&(identical(other.academia, _this.academia) || other.academia == _this.academia)&&(identical(other.salaoDeFestas, _this.salaoDeFestas) || other.salaoDeFestas == _this.salaoDeFestas)&&(identical(other.playground, _this.playground) || other.playground == _this.playground));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PredioModel;
  return Object.hash(runtimeType,_this.nome,_this.andares,_this.unidadesPorAndar,_this.ano,_this.elevadores,_this.portaria24h,_this.piscina,_this.academia,_this.salaoDeFestas,_this.playground);
}

@override
String toString() {
  final _this = this as PredioModel;
  return 'PredioModel(nome: ${_this.nome}, andares: ${_this.andares}, unidadesPorAndar: ${_this.unidadesPorAndar}, ano: ${_this.ano}, elevadores: ${_this.elevadores}, portaria24h: ${_this.portaria24h}, piscina: ${_this.piscina}, academia: ${_this.academia}, salaoDeFestas: ${_this.salaoDeFestas}, playground: ${_this.playground})';
}


}

/// @nodoc
abstract mixin class $PredioModelCopyWith<$Res>  {
  factory $PredioModelCopyWith(PredioModel value, $Res Function(PredioModel) _then) = _$PredioModelCopyWithImpl;
@useResult
$Res call({
 String? nome, int? andares,@JsonKey(name: 'unidades_por_andar') int? unidadesPorAndar, int? ano, int? elevadores,@JsonKey(name: 'portaria_24h') bool? portaria24h, bool? piscina, bool? academia,@JsonKey(name: 'salao_de_festas') bool? salaoDeFestas, bool? playground
});




}
/// @nodoc
class _$PredioModelCopyWithImpl<$Res>
    implements $PredioModelCopyWith<$Res> {
  _$PredioModelCopyWithImpl(this._self, this._then);

  final PredioModel _self;
  final $Res Function(PredioModel) _then;

/// Create a copy of PredioModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nome = freezed,Object? andares = freezed,Object? unidadesPorAndar = freezed,Object? ano = freezed,Object? elevadores = freezed,Object? portaria24h = freezed,Object? piscina = freezed,Object? academia = freezed,Object? salaoDeFestas = freezed,Object? playground = freezed,}) {
  return _then(PredioModel(
nome: freezed == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String?,andares: freezed == andares ? _self.andares : andares // ignore: cast_nullable_to_non_nullable
as int?,unidadesPorAndar: freezed == unidadesPorAndar ? _self.unidadesPorAndar : unidadesPorAndar // ignore: cast_nullable_to_non_nullable
as int?,ano: freezed == ano ? _self.ano : ano // ignore: cast_nullable_to_non_nullable
as int?,elevadores: freezed == elevadores ? _self.elevadores : elevadores // ignore: cast_nullable_to_non_nullable
as int?,portaria24h: freezed == portaria24h ? _self.portaria24h : portaria24h // ignore: cast_nullable_to_non_nullable
as bool?,piscina: freezed == piscina ? _self.piscina : piscina // ignore: cast_nullable_to_non_nullable
as bool?,academia: freezed == academia ? _self.academia : academia // ignore: cast_nullable_to_non_nullable
as bool?,salaoDeFestas: freezed == salaoDeFestas ? _self.salaoDeFestas : salaoDeFestas // ignore: cast_nullable_to_non_nullable
as bool?,playground: freezed == playground ? _self.playground : playground // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [PredioModel].
extension PredioModelPatterns on PredioModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PredioModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PredioModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PredioModel value)  $default,){
final _that = this;
switch (_that) {
case _PredioModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PredioModel value)?  $default,){
final _that = this;
switch (_that) {
case _PredioModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? nome,  int? andares, @JsonKey(name: 'unidades_por_andar')  int? unidadesPorAndar,  int? ano,  int? elevadores, @JsonKey(name: 'portaria_24h')  bool? portaria24h,  bool? piscina,  bool? academia, @JsonKey(name: 'salao_de_festas')  bool? salaoDeFestas,  bool? playground)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PredioModel() when $default != null:
return $default(_that.nome,_that.andares,_that.unidadesPorAndar,_that.ano,_that.elevadores,_that.portaria24h,_that.piscina,_that.academia,_that.salaoDeFestas,_that.playground);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? nome,  int? andares, @JsonKey(name: 'unidades_por_andar')  int? unidadesPorAndar,  int? ano,  int? elevadores, @JsonKey(name: 'portaria_24h')  bool? portaria24h,  bool? piscina,  bool? academia, @JsonKey(name: 'salao_de_festas')  bool? salaoDeFestas,  bool? playground)  $default,) {final _that = this;
switch (_that) {
case _PredioModel():
return $default(_that.nome,_that.andares,_that.unidadesPorAndar,_that.ano,_that.elevadores,_that.portaria24h,_that.piscina,_that.academia,_that.salaoDeFestas,_that.playground);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? nome,  int? andares, @JsonKey(name: 'unidades_por_andar')  int? unidadesPorAndar,  int? ano,  int? elevadores, @JsonKey(name: 'portaria_24h')  bool? portaria24h,  bool? piscina,  bool? academia, @JsonKey(name: 'salao_de_festas')  bool? salaoDeFestas,  bool? playground)?  $default,) {final _that = this;
switch (_that) {
case _PredioModel() when $default != null:
return $default(_that.nome,_that.andares,_that.unidadesPorAndar,_that.ano,_that.elevadores,_that.portaria24h,_that.piscina,_that.academia,_that.salaoDeFestas,_that.playground);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PredioModel extends PredioModel {
  const _PredioModel({this.nome, this.andares, @JsonKey(name: 'unidades_por_andar') this.unidadesPorAndar, this.ano, this.elevadores, @JsonKey(name: 'portaria_24h') this.portaria24h, this.piscina, this.academia, @JsonKey(name: 'salao_de_festas') this.salaoDeFestas, this.playground}): super._();
  factory _PredioModel.fromJson(Map<String, dynamic> json) => _$PredioModelFromJson(json);

@override final  String? nome;
@override final  int? andares;
@override@JsonKey(name: 'unidades_por_andar') final  int? unidadesPorAndar;
@override final  int? ano;
@override final  int? elevadores;
@override@JsonKey(name: 'portaria_24h') final  bool? portaria24h;
@override final  bool? piscina;
@override final  bool? academia;
@override@JsonKey(name: 'salao_de_festas') final  bool? salaoDeFestas;
@override final  bool? playground;

/// Create a copy of PredioModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PredioModelCopyWith<_PredioModel> get copyWith => __$PredioModelCopyWithImpl<_PredioModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PredioModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PredioModel&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.andares, andares) || other.andares == andares)&&(identical(other.unidadesPorAndar, unidadesPorAndar) || other.unidadesPorAndar == unidadesPorAndar)&&(identical(other.ano, ano) || other.ano == ano)&&(identical(other.elevadores, elevadores) || other.elevadores == elevadores)&&(identical(other.portaria24h, portaria24h) || other.portaria24h == portaria24h)&&(identical(other.piscina, piscina) || other.piscina == piscina)&&(identical(other.academia, academia) || other.academia == academia)&&(identical(other.salaoDeFestas, salaoDeFestas) || other.salaoDeFestas == salaoDeFestas)&&(identical(other.playground, playground) || other.playground == playground));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,nome,andares,unidadesPorAndar,ano,elevadores,portaria24h,piscina,academia,salaoDeFestas,playground);
}

@override
String toString() {
    return 'PredioModel(nome: $nome, andares: $andares, unidadesPorAndar: $unidadesPorAndar, ano: $ano, elevadores: $elevadores, portaria24h: $portaria24h, piscina: $piscina, academia: $academia, salaoDeFestas: $salaoDeFestas, playground: $playground)';
}


}

/// @nodoc
abstract mixin class _$PredioModelCopyWith<$Res> implements $PredioModelCopyWith<$Res> {
  factory _$PredioModelCopyWith(_PredioModel value, $Res Function(_PredioModel) _then) = __$PredioModelCopyWithImpl;
@override @useResult
$Res call({
 String? nome, int? andares,@JsonKey(name: 'unidades_por_andar') int? unidadesPorAndar, int? ano, int? elevadores,@JsonKey(name: 'portaria_24h') bool? portaria24h, bool? piscina, bool? academia,@JsonKey(name: 'salao_de_festas') bool? salaoDeFestas, bool? playground
});




}
/// @nodoc
class __$PredioModelCopyWithImpl<$Res>
    implements _$PredioModelCopyWith<$Res> {
  __$PredioModelCopyWithImpl(this._self, this._then);

  final _PredioModel _self;
  final $Res Function(_PredioModel) _then;

/// Create a copy of PredioModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nome = freezed,Object? andares = freezed,Object? unidadesPorAndar = freezed,Object? ano = freezed,Object? elevadores = freezed,Object? portaria24h = freezed,Object? piscina = freezed,Object? academia = freezed,Object? salaoDeFestas = freezed,Object? playground = freezed,}) {
  return _then(_PredioModel(
nome: freezed == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String?,andares: freezed == andares ? _self.andares : andares // ignore: cast_nullable_to_non_nullable
as int?,unidadesPorAndar: freezed == unidadesPorAndar ? _self.unidadesPorAndar : unidadesPorAndar // ignore: cast_nullable_to_non_nullable
as int?,ano: freezed == ano ? _self.ano : ano // ignore: cast_nullable_to_non_nullable
as int?,elevadores: freezed == elevadores ? _self.elevadores : elevadores // ignore: cast_nullable_to_non_nullable
as int?,portaria24h: freezed == portaria24h ? _self.portaria24h : portaria24h // ignore: cast_nullable_to_non_nullable
as bool?,piscina: freezed == piscina ? _self.piscina : piscina // ignore: cast_nullable_to_non_nullable
as bool?,academia: freezed == academia ? _self.academia : academia // ignore: cast_nullable_to_non_nullable
as bool?,salaoDeFestas: freezed == salaoDeFestas ? _self.salaoDeFestas : salaoDeFestas // ignore: cast_nullable_to_non_nullable
as bool?,playground: freezed == playground ? _self.playground : playground // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$QuadraModel {

 String? get identificacao; LoteamentoModel? get loteamento;
/// Create a copy of QuadraModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuadraModelCopyWith<QuadraModel> get copyWith => _$QuadraModelCopyWithImpl<QuadraModel>(this as QuadraModel, _$identity);

  /// Serializes this QuadraModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as QuadraModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuadraModel&&(identical(other.identificacao, _this.identificacao) || other.identificacao == _this.identificacao)&&(identical(other.loteamento, _this.loteamento) || other.loteamento == _this.loteamento));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as QuadraModel;
  return Object.hash(runtimeType,_this.identificacao,_this.loteamento);
}

@override
String toString() {
  final _this = this as QuadraModel;
  return 'QuadraModel(identificacao: ${_this.identificacao}, loteamento: ${_this.loteamento})';
}


}

/// @nodoc
abstract mixin class $QuadraModelCopyWith<$Res>  {
  factory $QuadraModelCopyWith(QuadraModel value, $Res Function(QuadraModel) _then) = _$QuadraModelCopyWithImpl;
@useResult
$Res call({
 String? identificacao, LoteamentoModel? loteamento
});


$LoteamentoModelCopyWith<$Res>? get loteamento;

}
/// @nodoc
class _$QuadraModelCopyWithImpl<$Res>
    implements $QuadraModelCopyWith<$Res> {
  _$QuadraModelCopyWithImpl(this._self, this._then);

  final QuadraModel _self;
  final $Res Function(QuadraModel) _then;

/// Create a copy of QuadraModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? identificacao = freezed,Object? loteamento = freezed,}) {
  return _then(QuadraModel(
identificacao: freezed == identificacao ? _self.identificacao : identificacao // ignore: cast_nullable_to_non_nullable
as String?,loteamento: freezed == loteamento ? _self.loteamento : loteamento // ignore: cast_nullable_to_non_nullable
as LoteamentoModel?,
  ));
}
/// Create a copy of QuadraModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoteamentoModelCopyWith<$Res>? get loteamento {
    if (_self.loteamento == null) {
    return null;
  }

  return $LoteamentoModelCopyWith<$Res>(_self.loteamento!, (value) {
    return _then(_self.copyWith(loteamento: value));
  });
}
}


/// Adds pattern-matching-related methods to [QuadraModel].
extension QuadraModelPatterns on QuadraModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuadraModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuadraModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuadraModel value)  $default,){
final _that = this;
switch (_that) {
case _QuadraModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuadraModel value)?  $default,){
final _that = this;
switch (_that) {
case _QuadraModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? identificacao,  LoteamentoModel? loteamento)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuadraModel() when $default != null:
return $default(_that.identificacao,_that.loteamento);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? identificacao,  LoteamentoModel? loteamento)  $default,) {final _that = this;
switch (_that) {
case _QuadraModel():
return $default(_that.identificacao,_that.loteamento);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? identificacao,  LoteamentoModel? loteamento)?  $default,) {final _that = this;
switch (_that) {
case _QuadraModel() when $default != null:
return $default(_that.identificacao,_that.loteamento);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuadraModel extends QuadraModel {
  const _QuadraModel({this.identificacao, this.loteamento}): super._();
  factory _QuadraModel.fromJson(Map<String, dynamic> json) => _$QuadraModelFromJson(json);

@override final  String? identificacao;
@override final  LoteamentoModel? loteamento;

/// Create a copy of QuadraModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuadraModelCopyWith<_QuadraModel> get copyWith => __$QuadraModelCopyWithImpl<_QuadraModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuadraModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuadraModel&&(identical(other.identificacao, identificacao) || other.identificacao == identificacao)&&(identical(other.loteamento, loteamento) || other.loteamento == loteamento));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,identificacao,loteamento);
}

@override
String toString() {
    return 'QuadraModel(identificacao: $identificacao, loteamento: $loteamento)';
}


}

/// @nodoc
abstract mixin class _$QuadraModelCopyWith<$Res> implements $QuadraModelCopyWith<$Res> {
  factory _$QuadraModelCopyWith(_QuadraModel value, $Res Function(_QuadraModel) _then) = __$QuadraModelCopyWithImpl;
@override @useResult
$Res call({
 String? identificacao, LoteamentoModel? loteamento
});


@override $LoteamentoModelCopyWith<$Res>? get loteamento;

}
/// @nodoc
class __$QuadraModelCopyWithImpl<$Res>
    implements _$QuadraModelCopyWith<$Res> {
  __$QuadraModelCopyWithImpl(this._self, this._then);

  final _QuadraModel _self;
  final $Res Function(_QuadraModel) _then;

/// Create a copy of QuadraModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? identificacao = freezed,Object? loteamento = freezed,}) {
  return _then(_QuadraModel(
identificacao: freezed == identificacao ? _self.identificacao : identificacao // ignore: cast_nullable_to_non_nullable
as String?,loteamento: freezed == loteamento ? _self.loteamento : loteamento // ignore: cast_nullable_to_non_nullable
as LoteamentoModel?,
  ));
}

/// Create a copy of QuadraModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoteamentoModelCopyWith<$Res>? get loteamento {
    if (_self.loteamento == null) {
    return null;
  }

  return $LoteamentoModelCopyWith<$Res>(_self.loteamento!, (value) {
    return _then(_self.copyWith(loteamento: value));
  });
}
}


/// @nodoc
mixin _$LoteamentoModel {

 String? get nome; String? get incorporadora; List<String> get infraestrutura;@JsonKey(name: 'areas_lazer') List<String> get areasLazer;
/// Create a copy of LoteamentoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoteamentoModelCopyWith<LoteamentoModel> get copyWith => _$LoteamentoModelCopyWithImpl<LoteamentoModel>(this as LoteamentoModel, _$identity);

  /// Serializes this LoteamentoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoteamentoModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoteamentoModel&&(identical(other.nome, _this.nome) || other.nome == _this.nome)&&(identical(other.incorporadora, _this.incorporadora) || other.incorporadora == _this.incorporadora)&&const DeepCollectionEquality().equals(other.infraestrutura, _this.infraestrutura)&&const DeepCollectionEquality().equals(other.areasLazer, _this.areasLazer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoteamentoModel;
  return Object.hash(runtimeType,_this.nome,_this.incorporadora,const DeepCollectionEquality().hash(_this.infraestrutura),const DeepCollectionEquality().hash(_this.areasLazer));
}

@override
String toString() {
  final _this = this as LoteamentoModel;
  return 'LoteamentoModel(nome: ${_this.nome}, incorporadora: ${_this.incorporadora}, infraestrutura: ${_this.infraestrutura}, areasLazer: ${_this.areasLazer})';
}


}

/// @nodoc
abstract mixin class $LoteamentoModelCopyWith<$Res>  {
  factory $LoteamentoModelCopyWith(LoteamentoModel value, $Res Function(LoteamentoModel) _then) = _$LoteamentoModelCopyWithImpl;
@useResult
$Res call({
 String? nome, String? incorporadora, List<String> infraestrutura,@JsonKey(name: 'areas_lazer') List<String> areasLazer
});




}
/// @nodoc
class _$LoteamentoModelCopyWithImpl<$Res>
    implements $LoteamentoModelCopyWith<$Res> {
  _$LoteamentoModelCopyWithImpl(this._self, this._then);

  final LoteamentoModel _self;
  final $Res Function(LoteamentoModel) _then;

/// Create a copy of LoteamentoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nome = freezed,Object? incorporadora = freezed,Object? infraestrutura = null,Object? areasLazer = null,}) {
  return _then(LoteamentoModel(
nome: freezed == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String?,incorporadora: freezed == incorporadora ? _self.incorporadora : incorporadora // ignore: cast_nullable_to_non_nullable
as String?,infraestrutura: null == infraestrutura ? _self.infraestrutura : infraestrutura // ignore: cast_nullable_to_non_nullable
as List<String>,areasLazer: null == areasLazer ? _self.areasLazer : areasLazer // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [LoteamentoModel].
extension LoteamentoModelPatterns on LoteamentoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoteamentoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoteamentoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoteamentoModel value)  $default,){
final _that = this;
switch (_that) {
case _LoteamentoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoteamentoModel value)?  $default,){
final _that = this;
switch (_that) {
case _LoteamentoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? nome,  String? incorporadora,  List<String> infraestrutura, @JsonKey(name: 'areas_lazer')  List<String> areasLazer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoteamentoModel() when $default != null:
return $default(_that.nome,_that.incorporadora,_that.infraestrutura,_that.areasLazer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? nome,  String? incorporadora,  List<String> infraestrutura, @JsonKey(name: 'areas_lazer')  List<String> areasLazer)  $default,) {final _that = this;
switch (_that) {
case _LoteamentoModel():
return $default(_that.nome,_that.incorporadora,_that.infraestrutura,_that.areasLazer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? nome,  String? incorporadora,  List<String> infraestrutura, @JsonKey(name: 'areas_lazer')  List<String> areasLazer)?  $default,) {final _that = this;
switch (_that) {
case _LoteamentoModel() when $default != null:
return $default(_that.nome,_that.incorporadora,_that.infraestrutura,_that.areasLazer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoteamentoModel extends LoteamentoModel {
  const _LoteamentoModel({this.nome, this.incorporadora,  List<String> infraestrutura = const <String>[], @JsonKey(name: 'areas_lazer')  List<String> areasLazer = const <String>[]}): _infraestrutura = infraestrutura,_areasLazer = areasLazer,super._();
  factory _LoteamentoModel.fromJson(Map<String, dynamic> json) => _$LoteamentoModelFromJson(json);

@override final  String? nome;
@override final  String? incorporadora;
 final  List<String> _infraestrutura;
@override@JsonKey() List<String> get infraestrutura {
  if (_infraestrutura is EqualUnmodifiableListView) return _infraestrutura;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_infraestrutura);
}

 final  List<String> _areasLazer;
@override@JsonKey(name: 'areas_lazer') List<String> get areasLazer {
  if (_areasLazer is EqualUnmodifiableListView) return _areasLazer;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_areasLazer);
}


/// Create a copy of LoteamentoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoteamentoModelCopyWith<_LoteamentoModel> get copyWith => __$LoteamentoModelCopyWithImpl<_LoteamentoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoteamentoModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoteamentoModel&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.incorporadora, incorporadora) || other.incorporadora == incorporadora)&&const DeepCollectionEquality().equals(other.infraestrutura, _infraestrutura)&&const DeepCollectionEquality().equals(other.areasLazer, _areasLazer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,nome,incorporadora,const DeepCollectionEquality().hash(_infraestrutura),const DeepCollectionEquality().hash(_areasLazer));
}

@override
String toString() {
    return 'LoteamentoModel(nome: $nome, incorporadora: $incorporadora, infraestrutura: $infraestrutura, areasLazer: $areasLazer)';
}


}

/// @nodoc
abstract mixin class _$LoteamentoModelCopyWith<$Res> implements $LoteamentoModelCopyWith<$Res> {
  factory _$LoteamentoModelCopyWith(_LoteamentoModel value, $Res Function(_LoteamentoModel) _then) = __$LoteamentoModelCopyWithImpl;
@override @useResult
$Res call({
 String? nome, String? incorporadora, List<String> infraestrutura,@JsonKey(name: 'areas_lazer') List<String> areasLazer
});




}
/// @nodoc
class __$LoteamentoModelCopyWithImpl<$Res>
    implements _$LoteamentoModelCopyWith<$Res> {
  __$LoteamentoModelCopyWithImpl(this._self, this._then);

  final _LoteamentoModel _self;
  final $Res Function(_LoteamentoModel) _then;

/// Create a copy of LoteamentoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nome = freezed,Object? incorporadora = freezed,Object? infraestrutura = null,Object? areasLazer = null,}) {
  return _then(_LoteamentoModel(
nome: freezed == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String?,incorporadora: freezed == incorporadora ? _self.incorporadora : incorporadora // ignore: cast_nullable_to_non_nullable
as String?,infraestrutura: null == infraestrutura ? _self._infraestrutura : infraestrutura // ignore: cast_nullable_to_non_nullable
as List<String>,areasLazer: null == areasLazer ? _self._areasLazer : areasLazer // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
