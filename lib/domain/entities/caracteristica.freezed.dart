// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'caracteristica.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Caracteristica {

 int get id; String get nome;
/// Create a copy of Caracteristica
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaracteristicaCopyWith<Caracteristica> get copyWith => _$CaracteristicaCopyWithImpl<Caracteristica>(this as Caracteristica, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Caracteristica;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Caracteristica&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nome, _this.nome) || other.nome == _this.nome));
}


@override
int get hashCode {
  final _this = this as Caracteristica;
  return Object.hash(runtimeType,_this.id,_this.nome);
}

@override
String toString() {
  final _this = this as Caracteristica;
  return 'Caracteristica(id: ${_this.id}, nome: ${_this.nome})';
}


}

/// @nodoc
abstract mixin class $CaracteristicaCopyWith<$Res>  {
  factory $CaracteristicaCopyWith(Caracteristica value, $Res Function(Caracteristica) _then) = _$CaracteristicaCopyWithImpl;
@useResult
$Res call({
 int id, String nome
});




}
/// @nodoc
class _$CaracteristicaCopyWithImpl<$Res>
    implements $CaracteristicaCopyWith<$Res> {
  _$CaracteristicaCopyWithImpl(this._self, this._then);

  final Caracteristica _self;
  final $Res Function(Caracteristica) _then;

/// Create a copy of Caracteristica
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nome = null,}) {
  return _then(Caracteristica(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Caracteristica].
extension CaracteristicaPatterns on Caracteristica {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Caracteristica value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Caracteristica() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Caracteristica value)  $default,){
final _that = this;
switch (_that) {
case _Caracteristica():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Caracteristica value)?  $default,){
final _that = this;
switch (_that) {
case _Caracteristica() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String nome)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Caracteristica() when $default != null:
return $default(_that.id,_that.nome);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String nome)  $default,) {final _that = this;
switch (_that) {
case _Caracteristica():
return $default(_that.id,_that.nome);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String nome)?  $default,) {final _that = this;
switch (_that) {
case _Caracteristica() when $default != null:
return $default(_that.id,_that.nome);case _:
  return null;

}
}

}

/// @nodoc


class _Caracteristica implements Caracteristica {
  const _Caracteristica({required this.id, required this.nome});
  

@override final  int id;
@override final  String nome;

/// Create a copy of Caracteristica
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaracteristicaCopyWith<_Caracteristica> get copyWith => __$CaracteristicaCopyWithImpl<_Caracteristica>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Caracteristica&&(identical(other.id, id) || other.id == id)&&(identical(other.nome, nome) || other.nome == nome));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,nome);
}

@override
String toString() {
    return 'Caracteristica(id: $id, nome: $nome)';
}


}

/// @nodoc
abstract mixin class _$CaracteristicaCopyWith<$Res> implements $CaracteristicaCopyWith<$Res> {
  factory _$CaracteristicaCopyWith(_Caracteristica value, $Res Function(_Caracteristica) _then) = __$CaracteristicaCopyWithImpl;
@override @useResult
$Res call({
 int id, String nome
});




}
/// @nodoc
class __$CaracteristicaCopyWithImpl<$Res>
    implements _$CaracteristicaCopyWith<$Res> {
  __$CaracteristicaCopyWithImpl(this._self, this._then);

  final _Caracteristica _self;
  final $Res Function(_Caracteristica) _then;

/// Create a copy of Caracteristica
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nome = null,}) {
  return _then(_Caracteristica(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
