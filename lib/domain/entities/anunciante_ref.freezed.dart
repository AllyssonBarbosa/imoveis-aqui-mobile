// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'anunciante_ref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnuncianteRef {

 int get id;
/// Create a copy of AnuncianteRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnuncianteRefCopyWith<AnuncianteRef> get copyWith => _$AnuncianteRefCopyWithImpl<AnuncianteRef>(this as AnuncianteRef, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AnuncianteRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnuncianteRef&&(identical(other.id, _this.id) || other.id == _this.id));
}


@override
int get hashCode {
  final _this = this as AnuncianteRef;
  return Object.hash(runtimeType,_this.id);
}

@override
String toString() {
  final _this = this as AnuncianteRef;
  return 'AnuncianteRef(id: ${_this.id})';
}


}

/// @nodoc
abstract mixin class $AnuncianteRefCopyWith<$Res>  {
  factory $AnuncianteRefCopyWith(AnuncianteRef value, $Res Function(AnuncianteRef) _then) = _$AnuncianteRefCopyWithImpl;
@useResult
$Res call({
 int id
});




}
/// @nodoc
class _$AnuncianteRefCopyWithImpl<$Res>
    implements $AnuncianteRefCopyWith<$Res> {
  _$AnuncianteRefCopyWithImpl(this._self, this._then);

  final AnuncianteRef _self;
  final $Res Function(AnuncianteRef) _then;

/// Create a copy of AnuncianteRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AnuncianteRef].
extension AnuncianteRefPatterns on AnuncianteRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AnuncianteCorretor value)?  corretor,TResult Function( AnuncianteEmpresa value)?  empresa,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AnuncianteCorretor() when corretor != null:
return corretor(_that);case AnuncianteEmpresa() when empresa != null:
return empresa(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AnuncianteCorretor value)  corretor,required TResult Function( AnuncianteEmpresa value)  empresa,}){
final _that = this;
switch (_that) {
case AnuncianteCorretor():
return corretor(_that);case AnuncianteEmpresa():
return empresa(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AnuncianteCorretor value)?  corretor,TResult? Function( AnuncianteEmpresa value)?  empresa,}){
final _that = this;
switch (_that) {
case AnuncianteCorretor() when corretor != null:
return corretor(_that);case AnuncianteEmpresa() when empresa != null:
return empresa(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int id)?  corretor,TResult Function( int id)?  empresa,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AnuncianteCorretor() when corretor != null:
return corretor(_that.id);case AnuncianteEmpresa() when empresa != null:
return empresa(_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int id)  corretor,required TResult Function( int id)  empresa,}) {final _that = this;
switch (_that) {
case AnuncianteCorretor():
return corretor(_that.id);case AnuncianteEmpresa():
return empresa(_that.id);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int id)?  corretor,TResult? Function( int id)?  empresa,}) {final _that = this;
switch (_that) {
case AnuncianteCorretor() when corretor != null:
return corretor(_that.id);case AnuncianteEmpresa() when empresa != null:
return empresa(_that.id);case _:
  return null;

}
}

}

/// @nodoc


class AnuncianteCorretor implements AnuncianteRef {
  const AnuncianteCorretor(this.id);
  

@override final  int id;

/// Create a copy of AnuncianteRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnuncianteCorretorCopyWith<AnuncianteCorretor> get copyWith => _$AnuncianteCorretorCopyWithImpl<AnuncianteCorretor>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AnuncianteCorretor&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id);
}

@override
String toString() {
    return 'AnuncianteRef.corretor(id: $id)';
}


}

/// @nodoc
abstract mixin class $AnuncianteCorretorCopyWith<$Res> implements $AnuncianteRefCopyWith<$Res> {
  factory $AnuncianteCorretorCopyWith(AnuncianteCorretor value, $Res Function(AnuncianteCorretor) _then) = _$AnuncianteCorretorCopyWithImpl;
@override @useResult
$Res call({
 int id
});




}
/// @nodoc
class _$AnuncianteCorretorCopyWithImpl<$Res>
    implements $AnuncianteCorretorCopyWith<$Res> {
  _$AnuncianteCorretorCopyWithImpl(this._self, this._then);

  final AnuncianteCorretor _self;
  final $Res Function(AnuncianteCorretor) _then;

/// Create a copy of AnuncianteRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(AnuncianteCorretor(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class AnuncianteEmpresa implements AnuncianteRef {
  const AnuncianteEmpresa(this.id);
  

@override final  int id;

/// Create a copy of AnuncianteRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnuncianteEmpresaCopyWith<AnuncianteEmpresa> get copyWith => _$AnuncianteEmpresaCopyWithImpl<AnuncianteEmpresa>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AnuncianteEmpresa&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id);
}

@override
String toString() {
    return 'AnuncianteRef.empresa(id: $id)';
}


}

/// @nodoc
abstract mixin class $AnuncianteEmpresaCopyWith<$Res> implements $AnuncianteRefCopyWith<$Res> {
  factory $AnuncianteEmpresaCopyWith(AnuncianteEmpresa value, $Res Function(AnuncianteEmpresa) _then) = _$AnuncianteEmpresaCopyWithImpl;
@override @useResult
$Res call({
 int id
});




}
/// @nodoc
class _$AnuncianteEmpresaCopyWithImpl<$Res>
    implements $AnuncianteEmpresaCopyWith<$Res> {
  _$AnuncianteEmpresaCopyWithImpl(this._self, this._then);

  final AnuncianteEmpresa _self;
  final $Res Function(AnuncianteEmpresa) _then;

/// Create a copy of AnuncianteRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(AnuncianteEmpresa(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
