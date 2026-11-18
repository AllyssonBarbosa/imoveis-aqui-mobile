// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contato_do_imovel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContatoDoImovel {

 int get imovelId; String get titulo; List<CanalContato> get canais;
/// Create a copy of ContatoDoImovel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContatoDoImovelCopyWith<ContatoDoImovel> get copyWith => _$ContatoDoImovelCopyWithImpl<ContatoDoImovel>(this as ContatoDoImovel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ContatoDoImovel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContatoDoImovel&&(identical(other.imovelId, _this.imovelId) || other.imovelId == _this.imovelId)&&(identical(other.titulo, _this.titulo) || other.titulo == _this.titulo)&&const DeepCollectionEquality().equals(other.canais, _this.canais));
}


@override
int get hashCode {
  final _this = this as ContatoDoImovel;
  return Object.hash(runtimeType,_this.imovelId,_this.titulo,const DeepCollectionEquality().hash(_this.canais));
}

@override
String toString() {
  final _this = this as ContatoDoImovel;
  return 'ContatoDoImovel(imovelId: ${_this.imovelId}, titulo: ${_this.titulo}, canais: ${_this.canais})';
}


}

/// @nodoc
abstract mixin class $ContatoDoImovelCopyWith<$Res>  {
  factory $ContatoDoImovelCopyWith(ContatoDoImovel value, $Res Function(ContatoDoImovel) _then) = _$ContatoDoImovelCopyWithImpl;
@useResult
$Res call({
 int imovelId, String titulo, List<CanalContato> canais
});




}
/// @nodoc
class _$ContatoDoImovelCopyWithImpl<$Res>
    implements $ContatoDoImovelCopyWith<$Res> {
  _$ContatoDoImovelCopyWithImpl(this._self, this._then);

  final ContatoDoImovel _self;
  final $Res Function(ContatoDoImovel) _then;

/// Create a copy of ContatoDoImovel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imovelId = null,Object? titulo = null,Object? canais = null,}) {
  return _then(ContatoDoImovel(
imovelId: null == imovelId ? _self.imovelId : imovelId // ignore: cast_nullable_to_non_nullable
as int,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,canais: null == canais ? _self.canais : canais // ignore: cast_nullable_to_non_nullable
as List<CanalContato>,
  ));
}

}


/// Adds pattern-matching-related methods to [ContatoDoImovel].
extension ContatoDoImovelPatterns on ContatoDoImovel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContatoDoImovel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContatoDoImovel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContatoDoImovel value)  $default,){
final _that = this;
switch (_that) {
case _ContatoDoImovel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContatoDoImovel value)?  $default,){
final _that = this;
switch (_that) {
case _ContatoDoImovel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int imovelId,  String titulo,  List<CanalContato> canais)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContatoDoImovel() when $default != null:
return $default(_that.imovelId,_that.titulo,_that.canais);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int imovelId,  String titulo,  List<CanalContato> canais)  $default,) {final _that = this;
switch (_that) {
case _ContatoDoImovel():
return $default(_that.imovelId,_that.titulo,_that.canais);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int imovelId,  String titulo,  List<CanalContato> canais)?  $default,) {final _that = this;
switch (_that) {
case _ContatoDoImovel() when $default != null:
return $default(_that.imovelId,_that.titulo,_that.canais);case _:
  return null;

}
}

}

/// @nodoc


class _ContatoDoImovel implements ContatoDoImovel {
  const _ContatoDoImovel({required this.imovelId, required this.titulo, required  List<CanalContato> canais}): _canais = canais;
  

@override final  int imovelId;
@override final  String titulo;
 final  List<CanalContato> _canais;
@override List<CanalContato> get canais {
  if (_canais is EqualUnmodifiableListView) return _canais;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_canais);
}


/// Create a copy of ContatoDoImovel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContatoDoImovelCopyWith<_ContatoDoImovel> get copyWith => __$ContatoDoImovelCopyWithImpl<_ContatoDoImovel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContatoDoImovel&&(identical(other.imovelId, imovelId) || other.imovelId == imovelId)&&(identical(other.titulo, titulo) || other.titulo == titulo)&&const DeepCollectionEquality().equals(other.canais, _canais));
}


@override
int get hashCode {
    return Object.hash(runtimeType,imovelId,titulo,const DeepCollectionEquality().hash(_canais));
}

@override
String toString() {
    return 'ContatoDoImovel(imovelId: $imovelId, titulo: $titulo, canais: $canais)';
}


}

/// @nodoc
abstract mixin class _$ContatoDoImovelCopyWith<$Res> implements $ContatoDoImovelCopyWith<$Res> {
  factory _$ContatoDoImovelCopyWith(_ContatoDoImovel value, $Res Function(_ContatoDoImovel) _then) = __$ContatoDoImovelCopyWithImpl;
@override @useResult
$Res call({
 int imovelId, String titulo, List<CanalContato> canais
});




}
/// @nodoc
class __$ContatoDoImovelCopyWithImpl<$Res>
    implements _$ContatoDoImovelCopyWith<$Res> {
  __$ContatoDoImovelCopyWithImpl(this._self, this._then);

  final _ContatoDoImovel _self;
  final $Res Function(_ContatoDoImovel) _then;

/// Create a copy of ContatoDoImovel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imovelId = null,Object? titulo = null,Object? canais = null,}) {
  return _then(_ContatoDoImovel(
imovelId: null == imovelId ? _self.imovelId : imovelId // ignore: cast_nullable_to_non_nullable
as int,titulo: null == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String,canais: null == canais ? _self._canais : canais // ignore: cast_nullable_to_non_nullable
as List<CanalContato>,
  ));
}


}

// dart format on
