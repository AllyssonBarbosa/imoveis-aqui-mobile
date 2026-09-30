// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vitrine_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VitrineState {

 OrdenacaoVitrine get ordenacao; String? get termoBusca; ConteudoVitrine get conteudo;
/// Create a copy of VitrineState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VitrineStateCopyWith<VitrineState> get copyWith => _$VitrineStateCopyWithImpl<VitrineState>(this as VitrineState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VitrineState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VitrineState&&(identical(other.ordenacao, _this.ordenacao) || other.ordenacao == _this.ordenacao)&&(identical(other.termoBusca, _this.termoBusca) || other.termoBusca == _this.termoBusca)&&(identical(other.conteudo, _this.conteudo) || other.conteudo == _this.conteudo));
}


@override
int get hashCode {
  final _this = this as VitrineState;
  return Object.hash(runtimeType,_this.ordenacao,_this.termoBusca,_this.conteudo);
}

@override
String toString() {
  final _this = this as VitrineState;
  return 'VitrineState(ordenacao: ${_this.ordenacao}, termoBusca: ${_this.termoBusca}, conteudo: ${_this.conteudo})';
}


}

/// @nodoc
abstract mixin class $VitrineStateCopyWith<$Res>  {
  factory $VitrineStateCopyWith(VitrineState value, $Res Function(VitrineState) _then) = _$VitrineStateCopyWithImpl;
@useResult
$Res call({
 OrdenacaoVitrine ordenacao, String? termoBusca, ConteudoVitrine conteudo
});


$ConteudoVitrineCopyWith<$Res> get conteudo;

}
/// @nodoc
class _$VitrineStateCopyWithImpl<$Res>
    implements $VitrineStateCopyWith<$Res> {
  _$VitrineStateCopyWithImpl(this._self, this._then);

  final VitrineState _self;
  final $Res Function(VitrineState) _then;

/// Create a copy of VitrineState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ordenacao = null,Object? termoBusca = freezed,Object? conteudo = null,}) {
  return _then(VitrineState(
ordenacao: null == ordenacao ? _self.ordenacao : ordenacao // ignore: cast_nullable_to_non_nullable
as OrdenacaoVitrine,termoBusca: freezed == termoBusca ? _self.termoBusca : termoBusca // ignore: cast_nullable_to_non_nullable
as String?,conteudo: null == conteudo ? _self.conteudo : conteudo // ignore: cast_nullable_to_non_nullable
as ConteudoVitrine,
  ));
}
/// Create a copy of VitrineState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConteudoVitrineCopyWith<$Res> get conteudo {
  
  return $ConteudoVitrineCopyWith<$Res>(_self.conteudo, (value) {
    return _then(_self.copyWith(conteudo: value));
  });
}
}


/// Adds pattern-matching-related methods to [VitrineState].
extension VitrineStatePatterns on VitrineState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VitrineState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VitrineState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VitrineState value)  $default,){
final _that = this;
switch (_that) {
case _VitrineState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VitrineState value)?  $default,){
final _that = this;
switch (_that) {
case _VitrineState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OrdenacaoVitrine ordenacao,  String? termoBusca,  ConteudoVitrine conteudo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VitrineState() when $default != null:
return $default(_that.ordenacao,_that.termoBusca,_that.conteudo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OrdenacaoVitrine ordenacao,  String? termoBusca,  ConteudoVitrine conteudo)  $default,) {final _that = this;
switch (_that) {
case _VitrineState():
return $default(_that.ordenacao,_that.termoBusca,_that.conteudo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OrdenacaoVitrine ordenacao,  String? termoBusca,  ConteudoVitrine conteudo)?  $default,) {final _that = this;
switch (_that) {
case _VitrineState() when $default != null:
return $default(_that.ordenacao,_that.termoBusca,_that.conteudo);case _:
  return null;

}
}

}

/// @nodoc


class _VitrineState implements VitrineState {
  const _VitrineState({this.ordenacao = OrdenacaoVitrine.maisRecentes, this.termoBusca, this.conteudo = const ConteudoVitrine.carregando()});
  

@override@JsonKey() final  OrdenacaoVitrine ordenacao;
@override final  String? termoBusca;
@override@JsonKey() final  ConteudoVitrine conteudo;

/// Create a copy of VitrineState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VitrineStateCopyWith<_VitrineState> get copyWith => __$VitrineStateCopyWithImpl<_VitrineState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VitrineState&&(identical(other.ordenacao, ordenacao) || other.ordenacao == ordenacao)&&(identical(other.termoBusca, termoBusca) || other.termoBusca == termoBusca)&&(identical(other.conteudo, conteudo) || other.conteudo == conteudo));
}


@override
int get hashCode {
    return Object.hash(runtimeType,ordenacao,termoBusca,conteudo);
}

@override
String toString() {
    return 'VitrineState(ordenacao: $ordenacao, termoBusca: $termoBusca, conteudo: $conteudo)';
}


}

/// @nodoc
abstract mixin class _$VitrineStateCopyWith<$Res> implements $VitrineStateCopyWith<$Res> {
  factory _$VitrineStateCopyWith(_VitrineState value, $Res Function(_VitrineState) _then) = __$VitrineStateCopyWithImpl;
@override @useResult
$Res call({
 OrdenacaoVitrine ordenacao, String? termoBusca, ConteudoVitrine conteudo
});


@override $ConteudoVitrineCopyWith<$Res> get conteudo;

}
/// @nodoc
class __$VitrineStateCopyWithImpl<$Res>
    implements _$VitrineStateCopyWith<$Res> {
  __$VitrineStateCopyWithImpl(this._self, this._then);

  final _VitrineState _self;
  final $Res Function(_VitrineState) _then;

/// Create a copy of VitrineState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ordenacao = null,Object? termoBusca = freezed,Object? conteudo = null,}) {
  return _then(_VitrineState(
ordenacao: null == ordenacao ? _self.ordenacao : ordenacao // ignore: cast_nullable_to_non_nullable
as OrdenacaoVitrine,termoBusca: freezed == termoBusca ? _self.termoBusca : termoBusca // ignore: cast_nullable_to_non_nullable
as String?,conteudo: null == conteudo ? _self.conteudo : conteudo // ignore: cast_nullable_to_non_nullable
as ConteudoVitrine,
  ));
}

/// Create a copy of VitrineState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConteudoVitrineCopyWith<$Res> get conteudo {
  
  return $ConteudoVitrineCopyWith<$Res>(_self.conteudo, (value) {
    return _then(_self.copyWith(conteudo: value));
  });
}
}

/// @nodoc
mixin _$ConteudoVitrine {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConteudoVitrine);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoVitrine()';
}


}

/// @nodoc
class $ConteudoVitrineCopyWith<$Res>  {
$ConteudoVitrineCopyWith(ConteudoVitrine _, $Res Function(ConteudoVitrine) __);
}


/// Adds pattern-matching-related methods to [ConteudoVitrine].
extension ConteudoVitrinePatterns on ConteudoVitrine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( VitrineCarregando value)?  carregando,TResult Function( VitrineVaziaNaCidade value)?  vazioNaCidade,TResult Function( VitrineSemResultado value)?  semResultado,TResult Function( VitrineErro value)?  erro,TResult Function( VitrineCarregada value)?  carregada,required TResult orElse(),}){
final _that = this;
switch (_that) {
case VitrineCarregando() when carregando != null:
return carregando(_that);case VitrineVaziaNaCidade() when vazioNaCidade != null:
return vazioNaCidade(_that);case VitrineSemResultado() when semResultado != null:
return semResultado(_that);case VitrineErro() when erro != null:
return erro(_that);case VitrineCarregada() when carregada != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( VitrineCarregando value)  carregando,required TResult Function( VitrineVaziaNaCidade value)  vazioNaCidade,required TResult Function( VitrineSemResultado value)  semResultado,required TResult Function( VitrineErro value)  erro,required TResult Function( VitrineCarregada value)  carregada,}){
final _that = this;
switch (_that) {
case VitrineCarregando():
return carregando(_that);case VitrineVaziaNaCidade():
return vazioNaCidade(_that);case VitrineSemResultado():
return semResultado(_that);case VitrineErro():
return erro(_that);case VitrineCarregada():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( VitrineCarregando value)?  carregando,TResult? Function( VitrineVaziaNaCidade value)?  vazioNaCidade,TResult? Function( VitrineSemResultado value)?  semResultado,TResult? Function( VitrineErro value)?  erro,TResult? Function( VitrineCarregada value)?  carregada,}){
final _that = this;
switch (_that) {
case VitrineCarregando() when carregando != null:
return carregando(_that);case VitrineVaziaNaCidade() when vazioNaCidade != null:
return vazioNaCidade(_that);case VitrineSemResultado() when semResultado != null:
return semResultado(_that);case VitrineErro() when erro != null:
return erro(_that);case VitrineCarregada() when carregada != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  carregando,TResult Function()?  vazioNaCidade,TResult Function( String termo)?  semResultado,TResult Function()?  erro,TResult Function( List<Imovel> itens,  String? proximaPagina,  bool carregandoMais,  bool erroAoCarregarMais)?  carregada,required TResult orElse(),}) {final _that = this;
switch (_that) {
case VitrineCarregando() when carregando != null:
return carregando();case VitrineVaziaNaCidade() when vazioNaCidade != null:
return vazioNaCidade();case VitrineSemResultado() when semResultado != null:
return semResultado(_that.termo);case VitrineErro() when erro != null:
return erro();case VitrineCarregada() when carregada != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  carregando,required TResult Function()  vazioNaCidade,required TResult Function( String termo)  semResultado,required TResult Function()  erro,required TResult Function( List<Imovel> itens,  String? proximaPagina,  bool carregandoMais,  bool erroAoCarregarMais)  carregada,}) {final _that = this;
switch (_that) {
case VitrineCarregando():
return carregando();case VitrineVaziaNaCidade():
return vazioNaCidade();case VitrineSemResultado():
return semResultado(_that.termo);case VitrineErro():
return erro();case VitrineCarregada():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  carregando,TResult? Function()?  vazioNaCidade,TResult? Function( String termo)?  semResultado,TResult? Function()?  erro,TResult? Function( List<Imovel> itens,  String? proximaPagina,  bool carregandoMais,  bool erroAoCarregarMais)?  carregada,}) {final _that = this;
switch (_that) {
case VitrineCarregando() when carregando != null:
return carregando();case VitrineVaziaNaCidade() when vazioNaCidade != null:
return vazioNaCidade();case VitrineSemResultado() when semResultado != null:
return semResultado(_that.termo);case VitrineErro() when erro != null:
return erro();case VitrineCarregada() when carregada != null:
return carregada(_that.itens,_that.proximaPagina,_that.carregandoMais,_that.erroAoCarregarMais);case _:
  return null;

}
}

}

/// @nodoc


class VitrineCarregando implements ConteudoVitrine {
  const VitrineCarregando();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VitrineCarregando);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoVitrine.carregando()';
}


}




/// @nodoc


class VitrineVaziaNaCidade implements ConteudoVitrine {
  const VitrineVaziaNaCidade();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VitrineVaziaNaCidade);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoVitrine.vazioNaCidade()';
}


}




/// @nodoc


class VitrineSemResultado implements ConteudoVitrine {
  const VitrineSemResultado(this.termo);
  

 final  String termo;

/// Create a copy of ConteudoVitrine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VitrineSemResultadoCopyWith<VitrineSemResultado> get copyWith => _$VitrineSemResultadoCopyWithImpl<VitrineSemResultado>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VitrineSemResultado&&(identical(other.termo, termo) || other.termo == termo));
}


@override
int get hashCode {
    return Object.hash(runtimeType,termo);
}

@override
String toString() {
    return 'ConteudoVitrine.semResultado(termo: $termo)';
}


}

/// @nodoc
abstract mixin class $VitrineSemResultadoCopyWith<$Res> implements $ConteudoVitrineCopyWith<$Res> {
  factory $VitrineSemResultadoCopyWith(VitrineSemResultado value, $Res Function(VitrineSemResultado) _then) = _$VitrineSemResultadoCopyWithImpl;
@useResult
$Res call({
 String termo
});




}
/// @nodoc
class _$VitrineSemResultadoCopyWithImpl<$Res>
    implements $VitrineSemResultadoCopyWith<$Res> {
  _$VitrineSemResultadoCopyWithImpl(this._self, this._then);

  final VitrineSemResultado _self;
  final $Res Function(VitrineSemResultado) _then;

/// Create a copy of ConteudoVitrine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? termo = null,}) {
  return _then(VitrineSemResultado(
null == termo ? _self.termo : termo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class VitrineErro implements ConteudoVitrine {
  const VitrineErro();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VitrineErro);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConteudoVitrine.erro()';
}


}




/// @nodoc


class VitrineCarregada implements ConteudoVitrine {
  const VitrineCarregada({required  List<Imovel> itens, this.proximaPagina, this.carregandoMais = false, this.erroAoCarregarMais = false}): _itens = itens;
  

 final  List<Imovel> _itens;
 List<Imovel> get itens {
  if (_itens is EqualUnmodifiableListView) return _itens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_itens);
}

 final  String? proximaPagina;
@JsonKey() final  bool carregandoMais;
@JsonKey() final  bool erroAoCarregarMais;

/// Create a copy of ConteudoVitrine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VitrineCarregadaCopyWith<VitrineCarregada> get copyWith => _$VitrineCarregadaCopyWithImpl<VitrineCarregada>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VitrineCarregada&&const DeepCollectionEquality().equals(other.itens, _itens)&&(identical(other.proximaPagina, proximaPagina) || other.proximaPagina == proximaPagina)&&(identical(other.carregandoMais, carregandoMais) || other.carregandoMais == carregandoMais)&&(identical(other.erroAoCarregarMais, erroAoCarregarMais) || other.erroAoCarregarMais == erroAoCarregarMais));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_itens),proximaPagina,carregandoMais,erroAoCarregarMais);
}

@override
String toString() {
    return 'ConteudoVitrine.carregada(itens: $itens, proximaPagina: $proximaPagina, carregandoMais: $carregandoMais, erroAoCarregarMais: $erroAoCarregarMais)';
}


}

/// @nodoc
abstract mixin class $VitrineCarregadaCopyWith<$Res> implements $ConteudoVitrineCopyWith<$Res> {
  factory $VitrineCarregadaCopyWith(VitrineCarregada value, $Res Function(VitrineCarregada) _then) = _$VitrineCarregadaCopyWithImpl;
@useResult
$Res call({
 List<Imovel> itens, String? proximaPagina, bool carregandoMais, bool erroAoCarregarMais
});




}
/// @nodoc
class _$VitrineCarregadaCopyWithImpl<$Res>
    implements $VitrineCarregadaCopyWith<$Res> {
  _$VitrineCarregadaCopyWithImpl(this._self, this._then);

  final VitrineCarregada _self;
  final $Res Function(VitrineCarregada) _then;

/// Create a copy of ConteudoVitrine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? itens = null,Object? proximaPagina = freezed,Object? carregandoMais = null,Object? erroAoCarregarMais = null,}) {
  return _then(VitrineCarregada(
itens: null == itens ? _self._itens : itens // ignore: cast_nullable_to_non_nullable
as List<Imovel>,proximaPagina: freezed == proximaPagina ? _self.proximaPagina : proximaPagina // ignore: cast_nullable_to_non_nullable
as String?,carregandoMais: null == carregandoMais ? _self.carregandoMais : carregandoMais // ignore: cast_nullable_to_non_nullable
as bool,erroAoCarregarMais: null == erroAoCarregarMais ? _self.erroAoCarregarMais : erroAoCarregarMais // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
