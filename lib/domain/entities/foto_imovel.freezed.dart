// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'foto_imovel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FotoImovel {

 int get id;/// URL absoluta da imagem no servidor.
 String get url;/// Posição definida pelo corretor (`0..n-1` nas listas do servidor).
 int get ordem;/// Se é a capa do imóvel — exatamente uma por imóvel com foto.
 bool get capa;
/// Create a copy of FotoImovel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FotoImovelCopyWith<FotoImovel> get copyWith => _$FotoImovelCopyWithImpl<FotoImovel>(this as FotoImovel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FotoImovel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FotoImovel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.ordem, _this.ordem) || other.ordem == _this.ordem)&&(identical(other.capa, _this.capa) || other.capa == _this.capa));
}


@override
int get hashCode {
  final _this = this as FotoImovel;
  return Object.hash(runtimeType,_this.id,_this.url,_this.ordem,_this.capa);
}

@override
String toString() {
  final _this = this as FotoImovel;
  return 'FotoImovel(id: ${_this.id}, url: ${_this.url}, ordem: ${_this.ordem}, capa: ${_this.capa})';
}


}

/// @nodoc
abstract mixin class $FotoImovelCopyWith<$Res>  {
  factory $FotoImovelCopyWith(FotoImovel value, $Res Function(FotoImovel) _then) = _$FotoImovelCopyWithImpl;
@useResult
$Res call({
 int id, String url, int ordem, bool capa
});




}
/// @nodoc
class _$FotoImovelCopyWithImpl<$Res>
    implements $FotoImovelCopyWith<$Res> {
  _$FotoImovelCopyWithImpl(this._self, this._then);

  final FotoImovel _self;
  final $Res Function(FotoImovel) _then;

/// Create a copy of FotoImovel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? ordem = null,Object? capa = null,}) {
  return _then(FotoImovel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,ordem: null == ordem ? _self.ordem : ordem // ignore: cast_nullable_to_non_nullable
as int,capa: null == capa ? _self.capa : capa // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FotoImovel].
extension FotoImovelPatterns on FotoImovel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FotoImovel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FotoImovel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FotoImovel value)  $default,){
final _that = this;
switch (_that) {
case _FotoImovel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FotoImovel value)?  $default,){
final _that = this;
switch (_that) {
case _FotoImovel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String url,  int ordem,  bool capa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FotoImovel() when $default != null:
return $default(_that.id,_that.url,_that.ordem,_that.capa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String url,  int ordem,  bool capa)  $default,) {final _that = this;
switch (_that) {
case _FotoImovel():
return $default(_that.id,_that.url,_that.ordem,_that.capa);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String url,  int ordem,  bool capa)?  $default,) {final _that = this;
switch (_that) {
case _FotoImovel() when $default != null:
return $default(_that.id,_that.url,_that.ordem,_that.capa);case _:
  return null;

}
}

}

/// @nodoc


class _FotoImovel implements FotoImovel {
  const _FotoImovel({required this.id, required this.url, required this.ordem, required this.capa});
  

@override final  int id;
/// URL absoluta da imagem no servidor.
@override final  String url;
/// Posição definida pelo corretor (`0..n-1` nas listas do servidor).
@override final  int ordem;
/// Se é a capa do imóvel — exatamente uma por imóvel com foto.
@override final  bool capa;

/// Create a copy of FotoImovel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FotoImovelCopyWith<_FotoImovel> get copyWith => __$FotoImovelCopyWithImpl<_FotoImovel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FotoImovel&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.ordem, ordem) || other.ordem == ordem)&&(identical(other.capa, capa) || other.capa == capa));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,url,ordem,capa);
}

@override
String toString() {
    return 'FotoImovel(id: $id, url: $url, ordem: $ordem, capa: $capa)';
}


}

/// @nodoc
abstract mixin class _$FotoImovelCopyWith<$Res> implements $FotoImovelCopyWith<$Res> {
  factory _$FotoImovelCopyWith(_FotoImovel value, $Res Function(_FotoImovel) _then) = __$FotoImovelCopyWithImpl;
@override @useResult
$Res call({
 int id, String url, int ordem, bool capa
});




}
/// @nodoc
class __$FotoImovelCopyWithImpl<$Res>
    implements _$FotoImovelCopyWith<$Res> {
  __$FotoImovelCopyWithImpl(this._self, this._then);

  final _FotoImovel _self;
  final $Res Function(_FotoImovel) _then;

/// Create a copy of FotoImovel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? ordem = null,Object? capa = null,}) {
  return _then(_FotoImovel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,ordem: null == ordem ? _self.ordem : ordem // ignore: cast_nullable_to_non_nullable
as int,capa: null == capa ? _self.capa : capa // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$FotoEscolhida {

/// Caminho do arquivo local (cache do app).
 String get caminho;
/// Create a copy of FotoEscolhida
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FotoEscolhidaCopyWith<FotoEscolhida> get copyWith => _$FotoEscolhidaCopyWithImpl<FotoEscolhida>(this as FotoEscolhida, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FotoEscolhida;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FotoEscolhida&&(identical(other.caminho, _this.caminho) || other.caminho == _this.caminho));
}


@override
int get hashCode {
  final _this = this as FotoEscolhida;
  return Object.hash(runtimeType,_this.caminho);
}

@override
String toString() {
  final _this = this as FotoEscolhida;
  return 'FotoEscolhida(caminho: ${_this.caminho})';
}


}

/// @nodoc
abstract mixin class $FotoEscolhidaCopyWith<$Res>  {
  factory $FotoEscolhidaCopyWith(FotoEscolhida value, $Res Function(FotoEscolhida) _then) = _$FotoEscolhidaCopyWithImpl;
@useResult
$Res call({
 String caminho
});




}
/// @nodoc
class _$FotoEscolhidaCopyWithImpl<$Res>
    implements $FotoEscolhidaCopyWith<$Res> {
  _$FotoEscolhidaCopyWithImpl(this._self, this._then);

  final FotoEscolhida _self;
  final $Res Function(FotoEscolhida) _then;

/// Create a copy of FotoEscolhida
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? caminho = null,}) {
  return _then(FotoEscolhida(
caminho: null == caminho ? _self.caminho : caminho // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FotoEscolhida].
extension FotoEscolhidaPatterns on FotoEscolhida {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FotoEscolhida value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FotoEscolhida() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FotoEscolhida value)  $default,){
final _that = this;
switch (_that) {
case _FotoEscolhida():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FotoEscolhida value)?  $default,){
final _that = this;
switch (_that) {
case _FotoEscolhida() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String caminho)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FotoEscolhida() when $default != null:
return $default(_that.caminho);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String caminho)  $default,) {final _that = this;
switch (_that) {
case _FotoEscolhida():
return $default(_that.caminho);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String caminho)?  $default,) {final _that = this;
switch (_that) {
case _FotoEscolhida() when $default != null:
return $default(_that.caminho);case _:
  return null;

}
}

}

/// @nodoc


class _FotoEscolhida implements FotoEscolhida {
  const _FotoEscolhida({required this.caminho});
  

/// Caminho do arquivo local (cache do app).
@override final  String caminho;

/// Create a copy of FotoEscolhida
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FotoEscolhidaCopyWith<_FotoEscolhida> get copyWith => __$FotoEscolhidaCopyWithImpl<_FotoEscolhida>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FotoEscolhida&&(identical(other.caminho, caminho) || other.caminho == caminho));
}


@override
int get hashCode {
    return Object.hash(runtimeType,caminho);
}

@override
String toString() {
    return 'FotoEscolhida(caminho: $caminho)';
}


}

/// @nodoc
abstract mixin class _$FotoEscolhidaCopyWith<$Res> implements $FotoEscolhidaCopyWith<$Res> {
  factory _$FotoEscolhidaCopyWith(_FotoEscolhida value, $Res Function(_FotoEscolhida) _then) = __$FotoEscolhidaCopyWithImpl;
@override @useResult
$Res call({
 String caminho
});




}
/// @nodoc
class __$FotoEscolhidaCopyWithImpl<$Res>
    implements _$FotoEscolhidaCopyWith<$Res> {
  __$FotoEscolhidaCopyWithImpl(this._self, this._then);

  final _FotoEscolhida _self;
  final $Res Function(_FotoEscolhida) _then;

/// Create a copy of FotoEscolhida
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? caminho = null,}) {
  return _then(_FotoEscolhida(
caminho: null == caminho ? _self.caminho : caminho // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
