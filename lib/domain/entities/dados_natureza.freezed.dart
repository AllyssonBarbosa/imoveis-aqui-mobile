// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dados_natureza.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DadosNatureza {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DadosNatureza);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DadosNatureza()';
}


}

/// @nodoc
class $DadosNaturezaCopyWith<$Res>  {
$DadosNaturezaCopyWith(DadosNatureza _, $Res Function(DadosNatureza) __);
}


/// Adds pattern-matching-related methods to [DadosNatureza].
extension DadosNaturezaPatterns on DadosNatureza {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DadosCasa value)?  casa,TResult Function( DadosTerreno value)?  terreno,TResult Function( DadosApartamento value)?  apartamento,TResult Function( DadosLote value)?  lote,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DadosCasa() when casa != null:
return casa(_that);case DadosTerreno() when terreno != null:
return terreno(_that);case DadosApartamento() when apartamento != null:
return apartamento(_that);case DadosLote() when lote != null:
return lote(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DadosCasa value)  casa,required TResult Function( DadosTerreno value)  terreno,required TResult Function( DadosApartamento value)  apartamento,required TResult Function( DadosLote value)  lote,}){
final _that = this;
switch (_that) {
case DadosCasa():
return casa(_that);case DadosTerreno():
return terreno(_that);case DadosApartamento():
return apartamento(_that);case DadosLote():
return lote(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DadosCasa value)?  casa,TResult? Function( DadosTerreno value)?  terreno,TResult? Function( DadosApartamento value)?  apartamento,TResult? Function( DadosLote value)?  lote,}){
final _that = this;
switch (_that) {
case DadosCasa() when casa != null:
return casa(_that);case DadosTerreno() when terreno != null:
return terreno(_that);case DadosApartamento() when apartamento != null:
return apartamento(_that);case DadosLote() when lote != null:
return lote(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String? areaTerreno,  String? areaConstruida,  String? areaLivre,  int? quartos,  int? suites,  int? banheiros,  int? salas,  int? vagas,  int? pavimentos,  int? anoConstrucao,  bool? piscina,  bool? quintal,  bool? churrasqueira,  bool? mobiliada)?  casa,TResult Function( String? areaTotal,  String? frente,  String? fundo,  String? laterais,  Topografia? topografia,  bool? murado,  bool? esquina,  String? usoPermitido)?  terreno,TResult Function( int? andar,  String? numero,  String? areaPrivativa,  String? areaTotal,  int? quartos,  int? suites,  int? banheiros,  int? vagas,  bool? varanda,  String? posicaoSolar,  DadosPredio? predio)?  apartamento,TResult Function( String? numero,  String? area,  String? frente,  String? fundo,  String? preco,  String? condicoesParcelamento,  DadosQuadra? quadra)?  lote,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DadosCasa() when casa != null:
return casa(_that.areaTerreno,_that.areaConstruida,_that.areaLivre,_that.quartos,_that.suites,_that.banheiros,_that.salas,_that.vagas,_that.pavimentos,_that.anoConstrucao,_that.piscina,_that.quintal,_that.churrasqueira,_that.mobiliada);case DadosTerreno() when terreno != null:
return terreno(_that.areaTotal,_that.frente,_that.fundo,_that.laterais,_that.topografia,_that.murado,_that.esquina,_that.usoPermitido);case DadosApartamento() when apartamento != null:
return apartamento(_that.andar,_that.numero,_that.areaPrivativa,_that.areaTotal,_that.quartos,_that.suites,_that.banheiros,_that.vagas,_that.varanda,_that.posicaoSolar,_that.predio);case DadosLote() when lote != null:
return lote(_that.numero,_that.area,_that.frente,_that.fundo,_that.preco,_that.condicoesParcelamento,_that.quadra);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String? areaTerreno,  String? areaConstruida,  String? areaLivre,  int? quartos,  int? suites,  int? banheiros,  int? salas,  int? vagas,  int? pavimentos,  int? anoConstrucao,  bool? piscina,  bool? quintal,  bool? churrasqueira,  bool? mobiliada)  casa,required TResult Function( String? areaTotal,  String? frente,  String? fundo,  String? laterais,  Topografia? topografia,  bool? murado,  bool? esquina,  String? usoPermitido)  terreno,required TResult Function( int? andar,  String? numero,  String? areaPrivativa,  String? areaTotal,  int? quartos,  int? suites,  int? banheiros,  int? vagas,  bool? varanda,  String? posicaoSolar,  DadosPredio? predio)  apartamento,required TResult Function( String? numero,  String? area,  String? frente,  String? fundo,  String? preco,  String? condicoesParcelamento,  DadosQuadra? quadra)  lote,}) {final _that = this;
switch (_that) {
case DadosCasa():
return casa(_that.areaTerreno,_that.areaConstruida,_that.areaLivre,_that.quartos,_that.suites,_that.banheiros,_that.salas,_that.vagas,_that.pavimentos,_that.anoConstrucao,_that.piscina,_that.quintal,_that.churrasqueira,_that.mobiliada);case DadosTerreno():
return terreno(_that.areaTotal,_that.frente,_that.fundo,_that.laterais,_that.topografia,_that.murado,_that.esquina,_that.usoPermitido);case DadosApartamento():
return apartamento(_that.andar,_that.numero,_that.areaPrivativa,_that.areaTotal,_that.quartos,_that.suites,_that.banheiros,_that.vagas,_that.varanda,_that.posicaoSolar,_that.predio);case DadosLote():
return lote(_that.numero,_that.area,_that.frente,_that.fundo,_that.preco,_that.condicoesParcelamento,_that.quadra);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String? areaTerreno,  String? areaConstruida,  String? areaLivre,  int? quartos,  int? suites,  int? banheiros,  int? salas,  int? vagas,  int? pavimentos,  int? anoConstrucao,  bool? piscina,  bool? quintal,  bool? churrasqueira,  bool? mobiliada)?  casa,TResult? Function( String? areaTotal,  String? frente,  String? fundo,  String? laterais,  Topografia? topografia,  bool? murado,  bool? esquina,  String? usoPermitido)?  terreno,TResult? Function( int? andar,  String? numero,  String? areaPrivativa,  String? areaTotal,  int? quartos,  int? suites,  int? banheiros,  int? vagas,  bool? varanda,  String? posicaoSolar,  DadosPredio? predio)?  apartamento,TResult? Function( String? numero,  String? area,  String? frente,  String? fundo,  String? preco,  String? condicoesParcelamento,  DadosQuadra? quadra)?  lote,}) {final _that = this;
switch (_that) {
case DadosCasa() when casa != null:
return casa(_that.areaTerreno,_that.areaConstruida,_that.areaLivre,_that.quartos,_that.suites,_that.banheiros,_that.salas,_that.vagas,_that.pavimentos,_that.anoConstrucao,_that.piscina,_that.quintal,_that.churrasqueira,_that.mobiliada);case DadosTerreno() when terreno != null:
return terreno(_that.areaTotal,_that.frente,_that.fundo,_that.laterais,_that.topografia,_that.murado,_that.esquina,_that.usoPermitido);case DadosApartamento() when apartamento != null:
return apartamento(_that.andar,_that.numero,_that.areaPrivativa,_that.areaTotal,_that.quartos,_that.suites,_that.banheiros,_that.vagas,_that.varanda,_that.posicaoSolar,_that.predio);case DadosLote() when lote != null:
return lote(_that.numero,_that.area,_that.frente,_that.fundo,_that.preco,_that.condicoesParcelamento,_that.quadra);case _:
  return null;

}
}

}

/// @nodoc


class DadosCasa implements DadosNatureza {
  const DadosCasa({this.areaTerreno, this.areaConstruida, this.areaLivre, this.quartos, this.suites, this.banheiros, this.salas, this.vagas, this.pavimentos, this.anoConstrucao, this.piscina, this.quintal, this.churrasqueira, this.mobiliada});
  

 final  String? areaTerreno;
 final  String? areaConstruida;
 final  String? areaLivre;
 final  int? quartos;
 final  int? suites;
 final  int? banheiros;
 final  int? salas;
 final  int? vagas;
 final  int? pavimentos;
 final  int? anoConstrucao;
 final  bool? piscina;
 final  bool? quintal;
 final  bool? churrasqueira;
 final  bool? mobiliada;

/// Create a copy of DadosNatureza
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DadosCasaCopyWith<DadosCasa> get copyWith => _$DadosCasaCopyWithImpl<DadosCasa>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DadosCasa&&(identical(other.areaTerreno, areaTerreno) || other.areaTerreno == areaTerreno)&&(identical(other.areaConstruida, areaConstruida) || other.areaConstruida == areaConstruida)&&(identical(other.areaLivre, areaLivre) || other.areaLivre == areaLivre)&&(identical(other.quartos, quartos) || other.quartos == quartos)&&(identical(other.suites, suites) || other.suites == suites)&&(identical(other.banheiros, banheiros) || other.banheiros == banheiros)&&(identical(other.salas, salas) || other.salas == salas)&&(identical(other.vagas, vagas) || other.vagas == vagas)&&(identical(other.pavimentos, pavimentos) || other.pavimentos == pavimentos)&&(identical(other.anoConstrucao, anoConstrucao) || other.anoConstrucao == anoConstrucao)&&(identical(other.piscina, piscina) || other.piscina == piscina)&&(identical(other.quintal, quintal) || other.quintal == quintal)&&(identical(other.churrasqueira, churrasqueira) || other.churrasqueira == churrasqueira)&&(identical(other.mobiliada, mobiliada) || other.mobiliada == mobiliada));
}


@override
int get hashCode {
    return Object.hash(runtimeType,areaTerreno,areaConstruida,areaLivre,quartos,suites,banheiros,salas,vagas,pavimentos,anoConstrucao,piscina,quintal,churrasqueira,mobiliada);
}

@override
String toString() {
    return 'DadosNatureza.casa(areaTerreno: $areaTerreno, areaConstruida: $areaConstruida, areaLivre: $areaLivre, quartos: $quartos, suites: $suites, banheiros: $banheiros, salas: $salas, vagas: $vagas, pavimentos: $pavimentos, anoConstrucao: $anoConstrucao, piscina: $piscina, quintal: $quintal, churrasqueira: $churrasqueira, mobiliada: $mobiliada)';
}


}

/// @nodoc
abstract mixin class $DadosCasaCopyWith<$Res> implements $DadosNaturezaCopyWith<$Res> {
  factory $DadosCasaCopyWith(DadosCasa value, $Res Function(DadosCasa) _then) = _$DadosCasaCopyWithImpl;
@useResult
$Res call({
 String? areaTerreno, String? areaConstruida, String? areaLivre, int? quartos, int? suites, int? banheiros, int? salas, int? vagas, int? pavimentos, int? anoConstrucao, bool? piscina, bool? quintal, bool? churrasqueira, bool? mobiliada
});




}
/// @nodoc
class _$DadosCasaCopyWithImpl<$Res>
    implements $DadosCasaCopyWith<$Res> {
  _$DadosCasaCopyWithImpl(this._self, this._then);

  final DadosCasa _self;
  final $Res Function(DadosCasa) _then;

/// Create a copy of DadosNatureza
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? areaTerreno = freezed,Object? areaConstruida = freezed,Object? areaLivre = freezed,Object? quartos = freezed,Object? suites = freezed,Object? banheiros = freezed,Object? salas = freezed,Object? vagas = freezed,Object? pavimentos = freezed,Object? anoConstrucao = freezed,Object? piscina = freezed,Object? quintal = freezed,Object? churrasqueira = freezed,Object? mobiliada = freezed,}) {
  return _then(DadosCasa(
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


class DadosTerreno implements DadosNatureza {
  const DadosTerreno({this.areaTotal, this.frente, this.fundo, this.laterais, this.topografia, this.murado, this.esquina, this.usoPermitido});
  

 final  String? areaTotal;
 final  String? frente;
 final  String? fundo;
 final  String? laterais;
 final  Topografia? topografia;
 final  bool? murado;
 final  bool? esquina;
 final  String? usoPermitido;

/// Create a copy of DadosNatureza
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DadosTerrenoCopyWith<DadosTerreno> get copyWith => _$DadosTerrenoCopyWithImpl<DadosTerreno>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DadosTerreno&&(identical(other.areaTotal, areaTotal) || other.areaTotal == areaTotal)&&(identical(other.frente, frente) || other.frente == frente)&&(identical(other.fundo, fundo) || other.fundo == fundo)&&(identical(other.laterais, laterais) || other.laterais == laterais)&&(identical(other.topografia, topografia) || other.topografia == topografia)&&(identical(other.murado, murado) || other.murado == murado)&&(identical(other.esquina, esquina) || other.esquina == esquina)&&(identical(other.usoPermitido, usoPermitido) || other.usoPermitido == usoPermitido));
}


@override
int get hashCode {
    return Object.hash(runtimeType,areaTotal,frente,fundo,laterais,topografia,murado,esquina,usoPermitido);
}

@override
String toString() {
    return 'DadosNatureza.terreno(areaTotal: $areaTotal, frente: $frente, fundo: $fundo, laterais: $laterais, topografia: $topografia, murado: $murado, esquina: $esquina, usoPermitido: $usoPermitido)';
}


}

/// @nodoc
abstract mixin class $DadosTerrenoCopyWith<$Res> implements $DadosNaturezaCopyWith<$Res> {
  factory $DadosTerrenoCopyWith(DadosTerreno value, $Res Function(DadosTerreno) _then) = _$DadosTerrenoCopyWithImpl;
@useResult
$Res call({
 String? areaTotal, String? frente, String? fundo, String? laterais, Topografia? topografia, bool? murado, bool? esquina, String? usoPermitido
});




}
/// @nodoc
class _$DadosTerrenoCopyWithImpl<$Res>
    implements $DadosTerrenoCopyWith<$Res> {
  _$DadosTerrenoCopyWithImpl(this._self, this._then);

  final DadosTerreno _self;
  final $Res Function(DadosTerreno) _then;

/// Create a copy of DadosNatureza
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? areaTotal = freezed,Object? frente = freezed,Object? fundo = freezed,Object? laterais = freezed,Object? topografia = freezed,Object? murado = freezed,Object? esquina = freezed,Object? usoPermitido = freezed,}) {
  return _then(DadosTerreno(
areaTotal: freezed == areaTotal ? _self.areaTotal : areaTotal // ignore: cast_nullable_to_non_nullable
as String?,frente: freezed == frente ? _self.frente : frente // ignore: cast_nullable_to_non_nullable
as String?,fundo: freezed == fundo ? _self.fundo : fundo // ignore: cast_nullable_to_non_nullable
as String?,laterais: freezed == laterais ? _self.laterais : laterais // ignore: cast_nullable_to_non_nullable
as String?,topografia: freezed == topografia ? _self.topografia : topografia // ignore: cast_nullable_to_non_nullable
as Topografia?,murado: freezed == murado ? _self.murado : murado // ignore: cast_nullable_to_non_nullable
as bool?,esquina: freezed == esquina ? _self.esquina : esquina // ignore: cast_nullable_to_non_nullable
as bool?,usoPermitido: freezed == usoPermitido ? _self.usoPermitido : usoPermitido // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class DadosApartamento implements DadosNatureza {
  const DadosApartamento({this.andar, this.numero, this.areaPrivativa, this.areaTotal, this.quartos, this.suites, this.banheiros, this.vagas, this.varanda, this.posicaoSolar, this.predio});
  

 final  int? andar;
 final  String? numero;
 final  String? areaPrivativa;
 final  String? areaTotal;
 final  int? quartos;
 final  int? suites;
 final  int? banheiros;
 final  int? vagas;
 final  bool? varanda;
 final  String? posicaoSolar;
/// Prédio embutido no detalhe (D-03), sem chamada extra.
 final  DadosPredio? predio;

/// Create a copy of DadosNatureza
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DadosApartamentoCopyWith<DadosApartamento> get copyWith => _$DadosApartamentoCopyWithImpl<DadosApartamento>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DadosApartamento&&(identical(other.andar, andar) || other.andar == andar)&&(identical(other.numero, numero) || other.numero == numero)&&(identical(other.areaPrivativa, areaPrivativa) || other.areaPrivativa == areaPrivativa)&&(identical(other.areaTotal, areaTotal) || other.areaTotal == areaTotal)&&(identical(other.quartos, quartos) || other.quartos == quartos)&&(identical(other.suites, suites) || other.suites == suites)&&(identical(other.banheiros, banheiros) || other.banheiros == banheiros)&&(identical(other.vagas, vagas) || other.vagas == vagas)&&(identical(other.varanda, varanda) || other.varanda == varanda)&&(identical(other.posicaoSolar, posicaoSolar) || other.posicaoSolar == posicaoSolar)&&(identical(other.predio, predio) || other.predio == predio));
}


@override
int get hashCode {
    return Object.hash(runtimeType,andar,numero,areaPrivativa,areaTotal,quartos,suites,banheiros,vagas,varanda,posicaoSolar,predio);
}

@override
String toString() {
    return 'DadosNatureza.apartamento(andar: $andar, numero: $numero, areaPrivativa: $areaPrivativa, areaTotal: $areaTotal, quartos: $quartos, suites: $suites, banheiros: $banheiros, vagas: $vagas, varanda: $varanda, posicaoSolar: $posicaoSolar, predio: $predio)';
}


}

/// @nodoc
abstract mixin class $DadosApartamentoCopyWith<$Res> implements $DadosNaturezaCopyWith<$Res> {
  factory $DadosApartamentoCopyWith(DadosApartamento value, $Res Function(DadosApartamento) _then) = _$DadosApartamentoCopyWithImpl;
@useResult
$Res call({
 int? andar, String? numero, String? areaPrivativa, String? areaTotal, int? quartos, int? suites, int? banheiros, int? vagas, bool? varanda, String? posicaoSolar, DadosPredio? predio
});


$DadosPredioCopyWith<$Res>? get predio;

}
/// @nodoc
class _$DadosApartamentoCopyWithImpl<$Res>
    implements $DadosApartamentoCopyWith<$Res> {
  _$DadosApartamentoCopyWithImpl(this._self, this._then);

  final DadosApartamento _self;
  final $Res Function(DadosApartamento) _then;

/// Create a copy of DadosNatureza
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? andar = freezed,Object? numero = freezed,Object? areaPrivativa = freezed,Object? areaTotal = freezed,Object? quartos = freezed,Object? suites = freezed,Object? banheiros = freezed,Object? vagas = freezed,Object? varanda = freezed,Object? posicaoSolar = freezed,Object? predio = freezed,}) {
  return _then(DadosApartamento(
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
as DadosPredio?,
  ));
}

/// Create a copy of DadosNatureza
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DadosPredioCopyWith<$Res>? get predio {
    if (_self.predio == null) {
    return null;
  }

  return $DadosPredioCopyWith<$Res>(_self.predio!, (value) {
    return _then(_self.copyWith(predio: value));
  });
}
}

/// @nodoc


class DadosLote implements DadosNatureza {
  const DadosLote({this.numero, this.area, this.frente, this.fundo, this.preco, this.condicoesParcelamento, this.quadra});
  

 final  String? numero;
 final  String? area;
 final  String? frente;
 final  String? fundo;
 final  String? preco;
 final  String? condicoesParcelamento;
/// Quadra com o loteamento embutidos no detalhe (D-03).
 final  DadosQuadra? quadra;

/// Create a copy of DadosNatureza
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DadosLoteCopyWith<DadosLote> get copyWith => _$DadosLoteCopyWithImpl<DadosLote>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DadosLote&&(identical(other.numero, numero) || other.numero == numero)&&(identical(other.area, area) || other.area == area)&&(identical(other.frente, frente) || other.frente == frente)&&(identical(other.fundo, fundo) || other.fundo == fundo)&&(identical(other.preco, preco) || other.preco == preco)&&(identical(other.condicoesParcelamento, condicoesParcelamento) || other.condicoesParcelamento == condicoesParcelamento)&&(identical(other.quadra, quadra) || other.quadra == quadra));
}


@override
int get hashCode {
    return Object.hash(runtimeType,numero,area,frente,fundo,preco,condicoesParcelamento,quadra);
}

@override
String toString() {
    return 'DadosNatureza.lote(numero: $numero, area: $area, frente: $frente, fundo: $fundo, preco: $preco, condicoesParcelamento: $condicoesParcelamento, quadra: $quadra)';
}


}

/// @nodoc
abstract mixin class $DadosLoteCopyWith<$Res> implements $DadosNaturezaCopyWith<$Res> {
  factory $DadosLoteCopyWith(DadosLote value, $Res Function(DadosLote) _then) = _$DadosLoteCopyWithImpl;
@useResult
$Res call({
 String? numero, String? area, String? frente, String? fundo, String? preco, String? condicoesParcelamento, DadosQuadra? quadra
});


$DadosQuadraCopyWith<$Res>? get quadra;

}
/// @nodoc
class _$DadosLoteCopyWithImpl<$Res>
    implements $DadosLoteCopyWith<$Res> {
  _$DadosLoteCopyWithImpl(this._self, this._then);

  final DadosLote _self;
  final $Res Function(DadosLote) _then;

/// Create a copy of DadosNatureza
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? numero = freezed,Object? area = freezed,Object? frente = freezed,Object? fundo = freezed,Object? preco = freezed,Object? condicoesParcelamento = freezed,Object? quadra = freezed,}) {
  return _then(DadosLote(
numero: freezed == numero ? _self.numero : numero // ignore: cast_nullable_to_non_nullable
as String?,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String?,frente: freezed == frente ? _self.frente : frente // ignore: cast_nullable_to_non_nullable
as String?,fundo: freezed == fundo ? _self.fundo : fundo // ignore: cast_nullable_to_non_nullable
as String?,preco: freezed == preco ? _self.preco : preco // ignore: cast_nullable_to_non_nullable
as String?,condicoesParcelamento: freezed == condicoesParcelamento ? _self.condicoesParcelamento : condicoesParcelamento // ignore: cast_nullable_to_non_nullable
as String?,quadra: freezed == quadra ? _self.quadra : quadra // ignore: cast_nullable_to_non_nullable
as DadosQuadra?,
  ));
}

/// Create a copy of DadosNatureza
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DadosQuadraCopyWith<$Res>? get quadra {
    if (_self.quadra == null) {
    return null;
  }

  return $DadosQuadraCopyWith<$Res>(_self.quadra!, (value) {
    return _then(_self.copyWith(quadra: value));
  });
}
}

/// @nodoc
mixin _$DadosPredio {

 String? get nome; int? get andares; int? get unidadesPorAndar; int? get ano; int? get elevadores; bool? get portaria24h; bool? get piscina; bool? get academia; bool? get salaoDeFestas; bool? get playground;
/// Create a copy of DadosPredio
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DadosPredioCopyWith<DadosPredio> get copyWith => _$DadosPredioCopyWithImpl<DadosPredio>(this as DadosPredio, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DadosPredio;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DadosPredio&&(identical(other.nome, _this.nome) || other.nome == _this.nome)&&(identical(other.andares, _this.andares) || other.andares == _this.andares)&&(identical(other.unidadesPorAndar, _this.unidadesPorAndar) || other.unidadesPorAndar == _this.unidadesPorAndar)&&(identical(other.ano, _this.ano) || other.ano == _this.ano)&&(identical(other.elevadores, _this.elevadores) || other.elevadores == _this.elevadores)&&(identical(other.portaria24h, _this.portaria24h) || other.portaria24h == _this.portaria24h)&&(identical(other.piscina, _this.piscina) || other.piscina == _this.piscina)&&(identical(other.academia, _this.academia) || other.academia == _this.academia)&&(identical(other.salaoDeFestas, _this.salaoDeFestas) || other.salaoDeFestas == _this.salaoDeFestas)&&(identical(other.playground, _this.playground) || other.playground == _this.playground));
}


@override
int get hashCode {
  final _this = this as DadosPredio;
  return Object.hash(runtimeType,_this.nome,_this.andares,_this.unidadesPorAndar,_this.ano,_this.elevadores,_this.portaria24h,_this.piscina,_this.academia,_this.salaoDeFestas,_this.playground);
}

@override
String toString() {
  final _this = this as DadosPredio;
  return 'DadosPredio(nome: ${_this.nome}, andares: ${_this.andares}, unidadesPorAndar: ${_this.unidadesPorAndar}, ano: ${_this.ano}, elevadores: ${_this.elevadores}, portaria24h: ${_this.portaria24h}, piscina: ${_this.piscina}, academia: ${_this.academia}, salaoDeFestas: ${_this.salaoDeFestas}, playground: ${_this.playground})';
}


}

/// @nodoc
abstract mixin class $DadosPredioCopyWith<$Res>  {
  factory $DadosPredioCopyWith(DadosPredio value, $Res Function(DadosPredio) _then) = _$DadosPredioCopyWithImpl;
@useResult
$Res call({
 String? nome, int? andares, int? unidadesPorAndar, int? ano, int? elevadores, bool? portaria24h, bool? piscina, bool? academia, bool? salaoDeFestas, bool? playground
});




}
/// @nodoc
class _$DadosPredioCopyWithImpl<$Res>
    implements $DadosPredioCopyWith<$Res> {
  _$DadosPredioCopyWithImpl(this._self, this._then);

  final DadosPredio _self;
  final $Res Function(DadosPredio) _then;

/// Create a copy of DadosPredio
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nome = freezed,Object? andares = freezed,Object? unidadesPorAndar = freezed,Object? ano = freezed,Object? elevadores = freezed,Object? portaria24h = freezed,Object? piscina = freezed,Object? academia = freezed,Object? salaoDeFestas = freezed,Object? playground = freezed,}) {
  return _then(DadosPredio(
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


/// Adds pattern-matching-related methods to [DadosPredio].
extension DadosPredioPatterns on DadosPredio {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DadosPredio value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DadosPredio() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DadosPredio value)  $default,){
final _that = this;
switch (_that) {
case _DadosPredio():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DadosPredio value)?  $default,){
final _that = this;
switch (_that) {
case _DadosPredio() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? nome,  int? andares,  int? unidadesPorAndar,  int? ano,  int? elevadores,  bool? portaria24h,  bool? piscina,  bool? academia,  bool? salaoDeFestas,  bool? playground)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DadosPredio() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? nome,  int? andares,  int? unidadesPorAndar,  int? ano,  int? elevadores,  bool? portaria24h,  bool? piscina,  bool? academia,  bool? salaoDeFestas,  bool? playground)  $default,) {final _that = this;
switch (_that) {
case _DadosPredio():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? nome,  int? andares,  int? unidadesPorAndar,  int? ano,  int? elevadores,  bool? portaria24h,  bool? piscina,  bool? academia,  bool? salaoDeFestas,  bool? playground)?  $default,) {final _that = this;
switch (_that) {
case _DadosPredio() when $default != null:
return $default(_that.nome,_that.andares,_that.unidadesPorAndar,_that.ano,_that.elevadores,_that.portaria24h,_that.piscina,_that.academia,_that.salaoDeFestas,_that.playground);case _:
  return null;

}
}

}

/// @nodoc


class _DadosPredio implements DadosPredio {
  const _DadosPredio({this.nome, this.andares, this.unidadesPorAndar, this.ano, this.elevadores, this.portaria24h, this.piscina, this.academia, this.salaoDeFestas, this.playground});
  

@override final  String? nome;
@override final  int? andares;
@override final  int? unidadesPorAndar;
@override final  int? ano;
@override final  int? elevadores;
@override final  bool? portaria24h;
@override final  bool? piscina;
@override final  bool? academia;
@override final  bool? salaoDeFestas;
@override final  bool? playground;

/// Create a copy of DadosPredio
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DadosPredioCopyWith<_DadosPredio> get copyWith => __$DadosPredioCopyWithImpl<_DadosPredio>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DadosPredio&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.andares, andares) || other.andares == andares)&&(identical(other.unidadesPorAndar, unidadesPorAndar) || other.unidadesPorAndar == unidadesPorAndar)&&(identical(other.ano, ano) || other.ano == ano)&&(identical(other.elevadores, elevadores) || other.elevadores == elevadores)&&(identical(other.portaria24h, portaria24h) || other.portaria24h == portaria24h)&&(identical(other.piscina, piscina) || other.piscina == piscina)&&(identical(other.academia, academia) || other.academia == academia)&&(identical(other.salaoDeFestas, salaoDeFestas) || other.salaoDeFestas == salaoDeFestas)&&(identical(other.playground, playground) || other.playground == playground));
}


@override
int get hashCode {
    return Object.hash(runtimeType,nome,andares,unidadesPorAndar,ano,elevadores,portaria24h,piscina,academia,salaoDeFestas,playground);
}

@override
String toString() {
    return 'DadosPredio(nome: $nome, andares: $andares, unidadesPorAndar: $unidadesPorAndar, ano: $ano, elevadores: $elevadores, portaria24h: $portaria24h, piscina: $piscina, academia: $academia, salaoDeFestas: $salaoDeFestas, playground: $playground)';
}


}

/// @nodoc
abstract mixin class _$DadosPredioCopyWith<$Res> implements $DadosPredioCopyWith<$Res> {
  factory _$DadosPredioCopyWith(_DadosPredio value, $Res Function(_DadosPredio) _then) = __$DadosPredioCopyWithImpl;
@override @useResult
$Res call({
 String? nome, int? andares, int? unidadesPorAndar, int? ano, int? elevadores, bool? portaria24h, bool? piscina, bool? academia, bool? salaoDeFestas, bool? playground
});




}
/// @nodoc
class __$DadosPredioCopyWithImpl<$Res>
    implements _$DadosPredioCopyWith<$Res> {
  __$DadosPredioCopyWithImpl(this._self, this._then);

  final _DadosPredio _self;
  final $Res Function(_DadosPredio) _then;

/// Create a copy of DadosPredio
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nome = freezed,Object? andares = freezed,Object? unidadesPorAndar = freezed,Object? ano = freezed,Object? elevadores = freezed,Object? portaria24h = freezed,Object? piscina = freezed,Object? academia = freezed,Object? salaoDeFestas = freezed,Object? playground = freezed,}) {
  return _then(_DadosPredio(
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
mixin _$DadosQuadra {

 String? get identificacao; DadosLoteamento? get loteamento;
/// Create a copy of DadosQuadra
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DadosQuadraCopyWith<DadosQuadra> get copyWith => _$DadosQuadraCopyWithImpl<DadosQuadra>(this as DadosQuadra, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DadosQuadra;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DadosQuadra&&(identical(other.identificacao, _this.identificacao) || other.identificacao == _this.identificacao)&&(identical(other.loteamento, _this.loteamento) || other.loteamento == _this.loteamento));
}


@override
int get hashCode {
  final _this = this as DadosQuadra;
  return Object.hash(runtimeType,_this.identificacao,_this.loteamento);
}

@override
String toString() {
  final _this = this as DadosQuadra;
  return 'DadosQuadra(identificacao: ${_this.identificacao}, loteamento: ${_this.loteamento})';
}


}

/// @nodoc
abstract mixin class $DadosQuadraCopyWith<$Res>  {
  factory $DadosQuadraCopyWith(DadosQuadra value, $Res Function(DadosQuadra) _then) = _$DadosQuadraCopyWithImpl;
@useResult
$Res call({
 String? identificacao, DadosLoteamento? loteamento
});


$DadosLoteamentoCopyWith<$Res>? get loteamento;

}
/// @nodoc
class _$DadosQuadraCopyWithImpl<$Res>
    implements $DadosQuadraCopyWith<$Res> {
  _$DadosQuadraCopyWithImpl(this._self, this._then);

  final DadosQuadra _self;
  final $Res Function(DadosQuadra) _then;

/// Create a copy of DadosQuadra
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? identificacao = freezed,Object? loteamento = freezed,}) {
  return _then(DadosQuadra(
identificacao: freezed == identificacao ? _self.identificacao : identificacao // ignore: cast_nullable_to_non_nullable
as String?,loteamento: freezed == loteamento ? _self.loteamento : loteamento // ignore: cast_nullable_to_non_nullable
as DadosLoteamento?,
  ));
}
/// Create a copy of DadosQuadra
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DadosLoteamentoCopyWith<$Res>? get loteamento {
    if (_self.loteamento == null) {
    return null;
  }

  return $DadosLoteamentoCopyWith<$Res>(_self.loteamento!, (value) {
    return _then(_self.copyWith(loteamento: value));
  });
}
}


/// Adds pattern-matching-related methods to [DadosQuadra].
extension DadosQuadraPatterns on DadosQuadra {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DadosQuadra value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DadosQuadra() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DadosQuadra value)  $default,){
final _that = this;
switch (_that) {
case _DadosQuadra():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DadosQuadra value)?  $default,){
final _that = this;
switch (_that) {
case _DadosQuadra() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? identificacao,  DadosLoteamento? loteamento)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DadosQuadra() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? identificacao,  DadosLoteamento? loteamento)  $default,) {final _that = this;
switch (_that) {
case _DadosQuadra():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? identificacao,  DadosLoteamento? loteamento)?  $default,) {final _that = this;
switch (_that) {
case _DadosQuadra() when $default != null:
return $default(_that.identificacao,_that.loteamento);case _:
  return null;

}
}

}

/// @nodoc


class _DadosQuadra implements DadosQuadra {
  const _DadosQuadra({this.identificacao, this.loteamento});
  

@override final  String? identificacao;
@override final  DadosLoteamento? loteamento;

/// Create a copy of DadosQuadra
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DadosQuadraCopyWith<_DadosQuadra> get copyWith => __$DadosQuadraCopyWithImpl<_DadosQuadra>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DadosQuadra&&(identical(other.identificacao, identificacao) || other.identificacao == identificacao)&&(identical(other.loteamento, loteamento) || other.loteamento == loteamento));
}


@override
int get hashCode {
    return Object.hash(runtimeType,identificacao,loteamento);
}

@override
String toString() {
    return 'DadosQuadra(identificacao: $identificacao, loteamento: $loteamento)';
}


}

/// @nodoc
abstract mixin class _$DadosQuadraCopyWith<$Res> implements $DadosQuadraCopyWith<$Res> {
  factory _$DadosQuadraCopyWith(_DadosQuadra value, $Res Function(_DadosQuadra) _then) = __$DadosQuadraCopyWithImpl;
@override @useResult
$Res call({
 String? identificacao, DadosLoteamento? loteamento
});


@override $DadosLoteamentoCopyWith<$Res>? get loteamento;

}
/// @nodoc
class __$DadosQuadraCopyWithImpl<$Res>
    implements _$DadosQuadraCopyWith<$Res> {
  __$DadosQuadraCopyWithImpl(this._self, this._then);

  final _DadosQuadra _self;
  final $Res Function(_DadosQuadra) _then;

/// Create a copy of DadosQuadra
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? identificacao = freezed,Object? loteamento = freezed,}) {
  return _then(_DadosQuadra(
identificacao: freezed == identificacao ? _self.identificacao : identificacao // ignore: cast_nullable_to_non_nullable
as String?,loteamento: freezed == loteamento ? _self.loteamento : loteamento // ignore: cast_nullable_to_non_nullable
as DadosLoteamento?,
  ));
}

/// Create a copy of DadosQuadra
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DadosLoteamentoCopyWith<$Res>? get loteamento {
    if (_self.loteamento == null) {
    return null;
  }

  return $DadosLoteamentoCopyWith<$Res>(_self.loteamento!, (value) {
    return _then(_self.copyWith(loteamento: value));
  });
}
}

/// @nodoc
mixin _$DadosLoteamento {

 String? get nome; String? get incorporadora; List<String> get infraestrutura; List<String> get areasLazer;
/// Create a copy of DadosLoteamento
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DadosLoteamentoCopyWith<DadosLoteamento> get copyWith => _$DadosLoteamentoCopyWithImpl<DadosLoteamento>(this as DadosLoteamento, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DadosLoteamento;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DadosLoteamento&&(identical(other.nome, _this.nome) || other.nome == _this.nome)&&(identical(other.incorporadora, _this.incorporadora) || other.incorporadora == _this.incorporadora)&&const DeepCollectionEquality().equals(other.infraestrutura, _this.infraestrutura)&&const DeepCollectionEquality().equals(other.areasLazer, _this.areasLazer));
}


@override
int get hashCode {
  final _this = this as DadosLoteamento;
  return Object.hash(runtimeType,_this.nome,_this.incorporadora,const DeepCollectionEquality().hash(_this.infraestrutura),const DeepCollectionEquality().hash(_this.areasLazer));
}

@override
String toString() {
  final _this = this as DadosLoteamento;
  return 'DadosLoteamento(nome: ${_this.nome}, incorporadora: ${_this.incorporadora}, infraestrutura: ${_this.infraestrutura}, areasLazer: ${_this.areasLazer})';
}


}

/// @nodoc
abstract mixin class $DadosLoteamentoCopyWith<$Res>  {
  factory $DadosLoteamentoCopyWith(DadosLoteamento value, $Res Function(DadosLoteamento) _then) = _$DadosLoteamentoCopyWithImpl;
@useResult
$Res call({
 String? nome, String? incorporadora, List<String> infraestrutura, List<String> areasLazer
});




}
/// @nodoc
class _$DadosLoteamentoCopyWithImpl<$Res>
    implements $DadosLoteamentoCopyWith<$Res> {
  _$DadosLoteamentoCopyWithImpl(this._self, this._then);

  final DadosLoteamento _self;
  final $Res Function(DadosLoteamento) _then;

/// Create a copy of DadosLoteamento
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nome = freezed,Object? incorporadora = freezed,Object? infraestrutura = null,Object? areasLazer = null,}) {
  return _then(DadosLoteamento(
nome: freezed == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String?,incorporadora: freezed == incorporadora ? _self.incorporadora : incorporadora // ignore: cast_nullable_to_non_nullable
as String?,infraestrutura: null == infraestrutura ? _self.infraestrutura : infraestrutura // ignore: cast_nullable_to_non_nullable
as List<String>,areasLazer: null == areasLazer ? _self.areasLazer : areasLazer // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DadosLoteamento].
extension DadosLoteamentoPatterns on DadosLoteamento {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DadosLoteamento value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DadosLoteamento() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DadosLoteamento value)  $default,){
final _that = this;
switch (_that) {
case _DadosLoteamento():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DadosLoteamento value)?  $default,){
final _that = this;
switch (_that) {
case _DadosLoteamento() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? nome,  String? incorporadora,  List<String> infraestrutura,  List<String> areasLazer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DadosLoteamento() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? nome,  String? incorporadora,  List<String> infraestrutura,  List<String> areasLazer)  $default,) {final _that = this;
switch (_that) {
case _DadosLoteamento():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? nome,  String? incorporadora,  List<String> infraestrutura,  List<String> areasLazer)?  $default,) {final _that = this;
switch (_that) {
case _DadosLoteamento() when $default != null:
return $default(_that.nome,_that.incorporadora,_that.infraestrutura,_that.areasLazer);case _:
  return null;

}
}

}

/// @nodoc


class _DadosLoteamento implements DadosLoteamento {
  const _DadosLoteamento({this.nome, this.incorporadora,  List<String> infraestrutura = const <String>[],  List<String> areasLazer = const <String>[]}): _infraestrutura = infraestrutura,_areasLazer = areasLazer;
  

@override final  String? nome;
@override final  String? incorporadora;
 final  List<String> _infraestrutura;
@override@JsonKey() List<String> get infraestrutura {
  if (_infraestrutura is EqualUnmodifiableListView) return _infraestrutura;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_infraestrutura);
}

 final  List<String> _areasLazer;
@override@JsonKey() List<String> get areasLazer {
  if (_areasLazer is EqualUnmodifiableListView) return _areasLazer;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_areasLazer);
}


/// Create a copy of DadosLoteamento
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DadosLoteamentoCopyWith<_DadosLoteamento> get copyWith => __$DadosLoteamentoCopyWithImpl<_DadosLoteamento>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DadosLoteamento&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.incorporadora, incorporadora) || other.incorporadora == incorporadora)&&const DeepCollectionEquality().equals(other.infraestrutura, _infraestrutura)&&const DeepCollectionEquality().equals(other.areasLazer, _areasLazer));
}


@override
int get hashCode {
    return Object.hash(runtimeType,nome,incorporadora,const DeepCollectionEquality().hash(_infraestrutura),const DeepCollectionEquality().hash(_areasLazer));
}

@override
String toString() {
    return 'DadosLoteamento(nome: $nome, incorporadora: $incorporadora, infraestrutura: $infraestrutura, areasLazer: $areasLazer)';
}


}

/// @nodoc
abstract mixin class _$DadosLoteamentoCopyWith<$Res> implements $DadosLoteamentoCopyWith<$Res> {
  factory _$DadosLoteamentoCopyWith(_DadosLoteamento value, $Res Function(_DadosLoteamento) _then) = __$DadosLoteamentoCopyWithImpl;
@override @useResult
$Res call({
 String? nome, String? incorporadora, List<String> infraestrutura, List<String> areasLazer
});




}
/// @nodoc
class __$DadosLoteamentoCopyWithImpl<$Res>
    implements _$DadosLoteamentoCopyWith<$Res> {
  __$DadosLoteamentoCopyWithImpl(this._self, this._then);

  final _DadosLoteamento _self;
  final $Res Function(_DadosLoteamento) _then;

/// Create a copy of DadosLoteamento
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nome = freezed,Object? incorporadora = freezed,Object? infraestrutura = null,Object? areasLazer = null,}) {
  return _then(_DadosLoteamento(
nome: freezed == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String?,incorporadora: freezed == incorporadora ? _self.incorporadora : incorporadora // ignore: cast_nullable_to_non_nullable
as String?,infraestrutura: null == infraestrutura ? _self._infraestrutura : infraestrutura // ignore: cast_nullable_to_non_nullable
as List<String>,areasLazer: null == areasLazer ? _self._areasLazer : areasLazer // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
