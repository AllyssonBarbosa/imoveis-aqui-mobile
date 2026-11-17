// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contato_registrado_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContatoRegistradoModel {

 String get canal; String get link;
/// Create a copy of ContatoRegistradoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContatoRegistradoModelCopyWith<ContatoRegistradoModel> get copyWith => _$ContatoRegistradoModelCopyWithImpl<ContatoRegistradoModel>(this as ContatoRegistradoModel, _$identity);

  /// Serializes this ContatoRegistradoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ContatoRegistradoModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContatoRegistradoModel&&(identical(other.canal, _this.canal) || other.canal == _this.canal)&&(identical(other.link, _this.link) || other.link == _this.link));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ContatoRegistradoModel;
  return Object.hash(runtimeType,_this.canal,_this.link);
}



}

/// @nodoc
abstract mixin class $ContatoRegistradoModelCopyWith<$Res>  {
  factory $ContatoRegistradoModelCopyWith(ContatoRegistradoModel value, $Res Function(ContatoRegistradoModel) _then) = _$ContatoRegistradoModelCopyWithImpl;
@useResult
$Res call({
 String canal, String link
});




}
/// @nodoc
class _$ContatoRegistradoModelCopyWithImpl<$Res>
    implements $ContatoRegistradoModelCopyWith<$Res> {
  _$ContatoRegistradoModelCopyWithImpl(this._self, this._then);

  final ContatoRegistradoModel _self;
  final $Res Function(ContatoRegistradoModel) _then;

/// Create a copy of ContatoRegistradoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? canal = null,Object? link = null,}) {
  return _then(ContatoRegistradoModel(
canal: null == canal ? _self.canal : canal // ignore: cast_nullable_to_non_nullable
as String,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ContatoRegistradoModel].
extension ContatoRegistradoModelPatterns on ContatoRegistradoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContatoRegistradoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContatoRegistradoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContatoRegistradoModel value)  $default,){
final _that = this;
switch (_that) {
case _ContatoRegistradoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContatoRegistradoModel value)?  $default,){
final _that = this;
switch (_that) {
case _ContatoRegistradoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String canal,  String link)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContatoRegistradoModel() when $default != null:
return $default(_that.canal,_that.link);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String canal,  String link)  $default,) {final _that = this;
switch (_that) {
case _ContatoRegistradoModel():
return $default(_that.canal,_that.link);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String canal,  String link)?  $default,) {final _that = this;
switch (_that) {
case _ContatoRegistradoModel() when $default != null:
return $default(_that.canal,_that.link);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContatoRegistradoModel extends ContatoRegistradoModel {
  const _ContatoRegistradoModel({required this.canal, required this.link}): super._();
  factory _ContatoRegistradoModel.fromJson(Map<String, dynamic> json) => _$ContatoRegistradoModelFromJson(json);

@override final  String canal;
@override final  String link;

/// Create a copy of ContatoRegistradoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContatoRegistradoModelCopyWith<_ContatoRegistradoModel> get copyWith => __$ContatoRegistradoModelCopyWithImpl<_ContatoRegistradoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContatoRegistradoModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContatoRegistradoModel&&(identical(other.canal, canal) || other.canal == canal)&&(identical(other.link, link) || other.link == link));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,canal,link);
}



}

/// @nodoc
abstract mixin class _$ContatoRegistradoModelCopyWith<$Res> implements $ContatoRegistradoModelCopyWith<$Res> {
  factory _$ContatoRegistradoModelCopyWith(_ContatoRegistradoModel value, $Res Function(_ContatoRegistradoModel) _then) = __$ContatoRegistradoModelCopyWithImpl;
@override @useResult
$Res call({
 String canal, String link
});




}
/// @nodoc
class __$ContatoRegistradoModelCopyWithImpl<$Res>
    implements _$ContatoRegistradoModelCopyWith<$Res> {
  __$ContatoRegistradoModelCopyWithImpl(this._self, this._then);

  final _ContatoRegistradoModel _self;
  final $Res Function(_ContatoRegistradoModel) _then;

/// Create a copy of ContatoRegistradoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? canal = null,Object? link = null,}) {
  return _then(_ContatoRegistradoModel(
canal: null == canal ? _self.canal : canal // ignore: cast_nullable_to_non_nullable
as String,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
