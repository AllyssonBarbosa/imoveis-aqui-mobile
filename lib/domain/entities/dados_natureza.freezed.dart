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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String? areaTerreno,  String? areaConstruida,  String? areaLivre,  int? quartos,  int? suites,  int? banheiros,  int? salas,  int? vagas,  int? pavimentos,  int? anoConstrucao,  bool? piscina,  bool? quintal,  bool? churrasqueira,  bool? mobiliada)?  casa,TResult Function( String? areaTotal,  String? frente,  String? fundo,  String? laterais,  Topografia? topografia,  bool? murado,  bool? esquina,  String? usoPermitido)?  terreno,TResult Function( int? andar,  String? numero,  String? areaPrivativa,  String? areaTotal,  int? quartos,  int? suites,  int? banheiros,  int? vagas,  bool? varanda,  String? posicaoSolar)?  apartamento,TResult Function( String? numero,  String? area,  String? frente,  String? fundo,  String? preco,  String? condicoesParcelamento)?  lote,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DadosCasa() when casa != null:
return casa(_that.areaTerreno,_that.areaConstruida,_that.areaLivre,_that.quartos,_that.suites,_that.banheiros,_that.salas,_that.vagas,_that.pavimentos,_that.anoConstrucao,_that.piscina,_that.quintal,_that.churrasqueira,_that.mobiliada);case DadosTerreno() when terreno != null:
return terreno(_that.areaTotal,_that.frente,_that.fundo,_that.laterais,_that.topografia,_that.murado,_that.esquina,_that.usoPermitido);case DadosApartamento() when apartamento != null:
return apartamento(_that.andar,_that.numero,_that.areaPrivativa,_that.areaTotal,_that.quartos,_that.suites,_that.banheiros,_that.vagas,_that.varanda,_that.posicaoSolar);case DadosLote() when lote != null:
return lote(_that.numero,_that.area,_that.frente,_that.fundo,_that.preco,_that.condicoesParcelamento);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String? areaTerreno,  String? areaConstruida,  String? areaLivre,  int? quartos,  int? suites,  int? banheiros,  int? salas,  int? vagas,  int? pavimentos,  int? anoConstrucao,  bool? piscina,  bool? quintal,  bool? churrasqueira,  bool? mobiliada)  casa,required TResult Function( String? areaTotal,  String? frente,  String? fundo,  String? laterais,  Topografia? topografia,  bool? murado,  bool? esquina,  String? usoPermitido)  terreno,required TResult Function( int? andar,  String? numero,  String? areaPrivativa,  String? areaTotal,  int? quartos,  int? suites,  int? banheiros,  int? vagas,  bool? varanda,  String? posicaoSolar)  apartamento,required TResult Function( String? numero,  String? area,  String? frente,  String? fundo,  String? preco,  String? condicoesParcelamento)  lote,}) {final _that = this;
switch (_that) {
case DadosCasa():
return casa(_that.areaTerreno,_that.areaConstruida,_that.areaLivre,_that.quartos,_that.suites,_that.banheiros,_that.salas,_that.vagas,_that.pavimentos,_that.anoConstrucao,_that.piscina,_that.quintal,_that.churrasqueira,_that.mobiliada);case DadosTerreno():
return terreno(_that.areaTotal,_that.frente,_that.fundo,_that.laterais,_that.topografia,_that.murado,_that.esquina,_that.usoPermitido);case DadosApartamento():
return apartamento(_that.andar,_that.numero,_that.areaPrivativa,_that.areaTotal,_that.quartos,_that.suites,_that.banheiros,_that.vagas,_that.varanda,_that.posicaoSolar);case DadosLote():
return lote(_that.numero,_that.area,_that.frente,_that.fundo,_that.preco,_that.condicoesParcelamento);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String? areaTerreno,  String? areaConstruida,  String? areaLivre,  int? quartos,  int? suites,  int? banheiros,  int? salas,  int? vagas,  int? pavimentos,  int? anoConstrucao,  bool? piscina,  bool? quintal,  bool? churrasqueira,  bool? mobiliada)?  casa,TResult? Function( String? areaTotal,  String? frente,  String? fundo,  String? laterais,  Topografia? topografia,  bool? murado,  bool? esquina,  String? usoPermitido)?  terreno,TResult? Function( int? andar,  String? numero,  String? areaPrivativa,  String? areaTotal,  int? quartos,  int? suites,  int? banheiros,  int? vagas,  bool? varanda,  String? posicaoSolar)?  apartamento,TResult? Function( String? numero,  String? area,  String? frente,  String? fundo,  String? preco,  String? condicoesParcelamento)?  lote,}) {final _that = this;
switch (_that) {
case DadosCasa() when casa != null:
return casa(_that.areaTerreno,_that.areaConstruida,_that.areaLivre,_that.quartos,_that.suites,_that.banheiros,_that.salas,_that.vagas,_that.pavimentos,_that.anoConstrucao,_that.piscina,_that.quintal,_that.churrasqueira,_that.mobiliada);case DadosTerreno() when terreno != null:
return terreno(_that.areaTotal,_that.frente,_that.fundo,_that.laterais,_that.topografia,_that.murado,_that.esquina,_that.usoPermitido);case DadosApartamento() when apartamento != null:
return apartamento(_that.andar,_that.numero,_that.areaPrivativa,_that.areaTotal,_that.quartos,_that.suites,_that.banheiros,_that.vagas,_that.varanda,_that.posicaoSolar);case DadosLote() when lote != null:
return lote(_that.numero,_that.area,_that.frente,_that.fundo,_that.preco,_that.condicoesParcelamento);case _:
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
  const DadosApartamento({this.andar, this.numero, this.areaPrivativa, this.areaTotal, this.quartos, this.suites, this.banheiros, this.vagas, this.varanda, this.posicaoSolar});
  

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

/// Create a copy of DadosNatureza
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DadosApartamentoCopyWith<DadosApartamento> get copyWith => _$DadosApartamentoCopyWithImpl<DadosApartamento>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DadosApartamento&&(identical(other.andar, andar) || other.andar == andar)&&(identical(other.numero, numero) || other.numero == numero)&&(identical(other.areaPrivativa, areaPrivativa) || other.areaPrivativa == areaPrivativa)&&(identical(other.areaTotal, areaTotal) || other.areaTotal == areaTotal)&&(identical(other.quartos, quartos) || other.quartos == quartos)&&(identical(other.suites, suites) || other.suites == suites)&&(identical(other.banheiros, banheiros) || other.banheiros == banheiros)&&(identical(other.vagas, vagas) || other.vagas == vagas)&&(identical(other.varanda, varanda) || other.varanda == varanda)&&(identical(other.posicaoSolar, posicaoSolar) || other.posicaoSolar == posicaoSolar));
}


@override
int get hashCode {
    return Object.hash(runtimeType,andar,numero,areaPrivativa,areaTotal,quartos,suites,banheiros,vagas,varanda,posicaoSolar);
}

@override
String toString() {
    return 'DadosNatureza.apartamento(andar: $andar, numero: $numero, areaPrivativa: $areaPrivativa, areaTotal: $areaTotal, quartos: $quartos, suites: $suites, banheiros: $banheiros, vagas: $vagas, varanda: $varanda, posicaoSolar: $posicaoSolar)';
}


}

/// @nodoc
abstract mixin class $DadosApartamentoCopyWith<$Res> implements $DadosNaturezaCopyWith<$Res> {
  factory $DadosApartamentoCopyWith(DadosApartamento value, $Res Function(DadosApartamento) _then) = _$DadosApartamentoCopyWithImpl;
@useResult
$Res call({
 int? andar, String? numero, String? areaPrivativa, String? areaTotal, int? quartos, int? suites, int? banheiros, int? vagas, bool? varanda, String? posicaoSolar
});




}
/// @nodoc
class _$DadosApartamentoCopyWithImpl<$Res>
    implements $DadosApartamentoCopyWith<$Res> {
  _$DadosApartamentoCopyWithImpl(this._self, this._then);

  final DadosApartamento _self;
  final $Res Function(DadosApartamento) _then;

/// Create a copy of DadosNatureza
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? andar = freezed,Object? numero = freezed,Object? areaPrivativa = freezed,Object? areaTotal = freezed,Object? quartos = freezed,Object? suites = freezed,Object? banheiros = freezed,Object? vagas = freezed,Object? varanda = freezed,Object? posicaoSolar = freezed,}) {
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
as String?,
  ));
}


}

/// @nodoc


class DadosLote implements DadosNatureza {
  const DadosLote({this.numero, this.area, this.frente, this.fundo, this.preco, this.condicoesParcelamento});
  

 final  String? numero;
 final  String? area;
 final  String? frente;
 final  String? fundo;
 final  String? preco;
 final  String? condicoesParcelamento;

/// Create a copy of DadosNatureza
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DadosLoteCopyWith<DadosLote> get copyWith => _$DadosLoteCopyWithImpl<DadosLote>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DadosLote&&(identical(other.numero, numero) || other.numero == numero)&&(identical(other.area, area) || other.area == area)&&(identical(other.frente, frente) || other.frente == frente)&&(identical(other.fundo, fundo) || other.fundo == fundo)&&(identical(other.preco, preco) || other.preco == preco)&&(identical(other.condicoesParcelamento, condicoesParcelamento) || other.condicoesParcelamento == condicoesParcelamento));
}


@override
int get hashCode {
    return Object.hash(runtimeType,numero,area,frente,fundo,preco,condicoesParcelamento);
}

@override
String toString() {
    return 'DadosNatureza.lote(numero: $numero, area: $area, frente: $frente, fundo: $fundo, preco: $preco, condicoesParcelamento: $condicoesParcelamento)';
}


}

/// @nodoc
abstract mixin class $DadosLoteCopyWith<$Res> implements $DadosNaturezaCopyWith<$Res> {
  factory $DadosLoteCopyWith(DadosLote value, $Res Function(DadosLote) _then) = _$DadosLoteCopyWithImpl;
@useResult
$Res call({
 String? numero, String? area, String? frente, String? fundo, String? preco, String? condicoesParcelamento
});




}
/// @nodoc
class _$DadosLoteCopyWithImpl<$Res>
    implements $DadosLoteCopyWith<$Res> {
  _$DadosLoteCopyWithImpl(this._self, this._then);

  final DadosLote _self;
  final $Res Function(DadosLote) _then;

/// Create a copy of DadosNatureza
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? numero = freezed,Object? area = freezed,Object? frente = freezed,Object? fundo = freezed,Object? preco = freezed,Object? condicoesParcelamento = freezed,}) {
  return _then(DadosLote(
numero: freezed == numero ? _self.numero : numero // ignore: cast_nullable_to_non_nullable
as String?,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String?,frente: freezed == frente ? _self.frente : frente // ignore: cast_nullable_to_non_nullable
as String?,fundo: freezed == fundo ? _self.fundo : fundo // ignore: cast_nullable_to_non_nullable
as String?,preco: freezed == preco ? _self.preco : preco // ignore: cast_nullable_to_non_nullable
as String?,condicoesParcelamento: freezed == condicoesParcelamento ? _self.condicoesParcelamento : condicoesParcelamento // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
