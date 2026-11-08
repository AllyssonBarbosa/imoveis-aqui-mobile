// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vitrine_anunciante_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VitrineAnuncianteState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VitrineAnuncianteState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'VitrineAnuncianteState()';
}


}

/// @nodoc
class $VitrineAnuncianteStateCopyWith<$Res>  {
$VitrineAnuncianteStateCopyWith(VitrineAnuncianteState _, $Res Function(VitrineAnuncianteState) __);
}


/// Adds pattern-matching-related methods to [VitrineAnuncianteState].
extension VitrineAnuncianteStatePatterns on VitrineAnuncianteState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( VitrineAnuncianteCarregando value)?  carregando,TResult Function( VitrineAnuncianteVazia value)?  vazia,TResult Function( VitrineAnuncianteErro value)?  erro,TResult Function( VitrineAnuncianteCarregada value)?  carregada,required TResult orElse(),}){
final _that = this;
switch (_that) {
case VitrineAnuncianteCarregando() when carregando != null:
return carregando(_that);case VitrineAnuncianteVazia() when vazia != null:
return vazia(_that);case VitrineAnuncianteErro() when erro != null:
return erro(_that);case VitrineAnuncianteCarregada() when carregada != null:
return carregada(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( VitrineAnuncianteCarregando value)  carregando,required TResult Function( VitrineAnuncianteVazia value)  vazia,required TResult Function( VitrineAnuncianteErro value)  erro,required TResult Function( VitrineAnuncianteCarregada value)  carregada,}){
final _that = this;
switch (_that) {
case VitrineAnuncianteCarregando():
return carregando(_that);case VitrineAnuncianteVazia():
return vazia(_that);case VitrineAnuncianteErro():
return erro(_that);case VitrineAnuncianteCarregada():
return carregada(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( VitrineAnuncianteCarregando value)?  carregando,TResult? Function( VitrineAnuncianteVazia value)?  vazia,TResult? Function( VitrineAnuncianteErro value)?  erro,TResult? Function( VitrineAnuncianteCarregada value)?  carregada,}){
final _that = this;
switch (_that) {
case VitrineAnuncianteCarregando() when carregando != null:
return carregando(_that);case VitrineAnuncianteVazia() when vazia != null:
return vazia(_that);case VitrineAnuncianteErro() when erro != null:
return erro(_that);case VitrineAnuncianteCarregada() when carregada != null:
return carregada(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  carregando,TResult Function()?  vazia,TResult Function()?  erro,TResult Function( List<Imovel> itens,  String? proximaPagina,  bool carregandoMais,  bool erroAoCarregarMais)?  carregada,required TResult orElse(),}) {final _that = this;
switch (_that) {
case VitrineAnuncianteCarregando() when carregando != null:
return carregando();case VitrineAnuncianteVazia() when vazia != null:
return vazia();case VitrineAnuncianteErro() when erro != null:
return erro();case VitrineAnuncianteCarregada() when carregada != null:
return carregada(_that.itens,_that.proximaPagina,_that.carregandoMais,_that.erroAoCarregarMais);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  carregando,required TResult Function()  vazia,required TResult Function()  erro,required TResult Function( List<Imovel> itens,  String? proximaPagina,  bool carregandoMais,  bool erroAoCarregarMais)  carregada,}) {final _that = this;
switch (_that) {
case VitrineAnuncianteCarregando():
return carregando();case VitrineAnuncianteVazia():
return vazia();case VitrineAnuncianteErro():
return erro();case VitrineAnuncianteCarregada():
return carregada(_that.itens,_that.proximaPagina,_that.carregandoMais,_that.erroAoCarregarMais);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  carregando,TResult? Function()?  vazia,TResult? Function()?  erro,TResult? Function( List<Imovel> itens,  String? proximaPagina,  bool carregandoMais,  bool erroAoCarregarMais)?  carregada,}) {final _that = this;
switch (_that) {
case VitrineAnuncianteCarregando() when carregando != null:
return carregando();case VitrineAnuncianteVazia() when vazia != null:
return vazia();case VitrineAnuncianteErro() when erro != null:
return erro();case VitrineAnuncianteCarregada() when carregada != null:
return carregada(_that.itens,_that.proximaPagina,_that.carregandoMais,_that.erroAoCarregarMais);case _:
  return null;

}
}

}

/// @nodoc


class VitrineAnuncianteCarregando implements VitrineAnuncianteState {
  const VitrineAnuncianteCarregando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VitrineAnuncianteCarregando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'VitrineAnuncianteState.carregando()';
}


}




/// @nodoc


class VitrineAnuncianteVazia implements VitrineAnuncianteState {
  const VitrineAnuncianteVazia();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VitrineAnuncianteVazia);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'VitrineAnuncianteState.vazia()';
}


}




/// @nodoc


class VitrineAnuncianteErro implements VitrineAnuncianteState {
  const VitrineAnuncianteErro();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VitrineAnuncianteErro);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'VitrineAnuncianteState.erro()';
}


}




/// @nodoc


class VitrineAnuncianteCarregada implements VitrineAnuncianteState {
  const VitrineAnuncianteCarregada({required  List<Imovel> itens, this.proximaPagina, this.carregandoMais = false, this.erroAoCarregarMais = false}): _itens = itens;
  

 final  List<Imovel> _itens;
 List<Imovel> get itens {
  if (_itens is EqualUnmodifiableListView) return _itens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_itens);
}

 final  String? proximaPagina;
@JsonKey() final  bool carregandoMais;
@JsonKey() final  bool erroAoCarregarMais;

/// Create a copy of VitrineAnuncianteState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VitrineAnuncianteCarregadaCopyWith<VitrineAnuncianteCarregada> get copyWith => _$VitrineAnuncianteCarregadaCopyWithImpl<VitrineAnuncianteCarregada>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VitrineAnuncianteCarregada&&const DeepCollectionEquality().equals(other.itens, _itens)&&(identical(other.proximaPagina, proximaPagina) || other.proximaPagina == proximaPagina)&&(identical(other.carregandoMais, carregandoMais) || other.carregandoMais == carregandoMais)&&(identical(other.erroAoCarregarMais, erroAoCarregarMais) || other.erroAoCarregarMais == erroAoCarregarMais));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_itens),proximaPagina,carregandoMais,erroAoCarregarMais);
}

@override
String toString() {
    return 'VitrineAnuncianteState.carregada(itens: $itens, proximaPagina: $proximaPagina, carregandoMais: $carregandoMais, erroAoCarregarMais: $erroAoCarregarMais)';
}


}

/// @nodoc
abstract mixin class $VitrineAnuncianteCarregadaCopyWith<$Res> implements $VitrineAnuncianteStateCopyWith<$Res> {
  factory $VitrineAnuncianteCarregadaCopyWith(VitrineAnuncianteCarregada value, $Res Function(VitrineAnuncianteCarregada) _then) = _$VitrineAnuncianteCarregadaCopyWithImpl;
@useResult
$Res call({
 List<Imovel> itens, String? proximaPagina, bool carregandoMais, bool erroAoCarregarMais
});




}
/// @nodoc
class _$VitrineAnuncianteCarregadaCopyWithImpl<$Res>
    implements $VitrineAnuncianteCarregadaCopyWith<$Res> {
  _$VitrineAnuncianteCarregadaCopyWithImpl(this._self, this._then);

  final VitrineAnuncianteCarregada _self;
  final $Res Function(VitrineAnuncianteCarregada) _then;

/// Create a copy of VitrineAnuncianteState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? itens = null,Object? proximaPagina = freezed,Object? carregandoMais = null,Object? erroAoCarregarMais = null,}) {
  return _then(VitrineAnuncianteCarregada(
itens: null == itens ? _self._itens : itens // ignore: cast_nullable_to_non_nullable
as List<Imovel>,proximaPagina: freezed == proximaPagina ? _self.proximaPagina : proximaPagina // ignore: cast_nullable_to_non_nullable
as String?,carregandoMais: null == carregandoMais ? _self.carregandoMais : carregandoMais // ignore: cast_nullable_to_non_nullable
as bool,erroAoCarregarMais: null == erroAoCarregarMais ? _self.erroAoCarregarMais : erroAoCarregarMais // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
