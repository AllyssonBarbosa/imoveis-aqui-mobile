// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'acervo_por_corretor_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LinhaAcervoCorretorModel {

@JsonKey(name: 'corretor_id') int get corretorId; String get corretor; bool get ativo; int get total;
/// Create a copy of LinhaAcervoCorretorModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinhaAcervoCorretorModelCopyWith<LinhaAcervoCorretorModel> get copyWith => _$LinhaAcervoCorretorModelCopyWithImpl<LinhaAcervoCorretorModel>(this as LinhaAcervoCorretorModel, _$identity);

  /// Serializes this LinhaAcervoCorretorModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LinhaAcervoCorretorModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinhaAcervoCorretorModel&&(identical(other.corretorId, _this.corretorId) || other.corretorId == _this.corretorId)&&(identical(other.corretor, _this.corretor) || other.corretor == _this.corretor)&&(identical(other.ativo, _this.ativo) || other.ativo == _this.ativo)&&(identical(other.total, _this.total) || other.total == _this.total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LinhaAcervoCorretorModel;
  return Object.hash(runtimeType,_this.corretorId,_this.corretor,_this.ativo,_this.total);
}

@override
String toString() {
  final _this = this as LinhaAcervoCorretorModel;
  return 'LinhaAcervoCorretorModel(corretorId: ${_this.corretorId}, corretor: ${_this.corretor}, ativo: ${_this.ativo}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $LinhaAcervoCorretorModelCopyWith<$Res>  {
  factory $LinhaAcervoCorretorModelCopyWith(LinhaAcervoCorretorModel value, $Res Function(LinhaAcervoCorretorModel) _then) = _$LinhaAcervoCorretorModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'corretor_id') int corretorId, String corretor, bool ativo, int total
});




}
/// @nodoc
class _$LinhaAcervoCorretorModelCopyWithImpl<$Res>
    implements $LinhaAcervoCorretorModelCopyWith<$Res> {
  _$LinhaAcervoCorretorModelCopyWithImpl(this._self, this._then);

  final LinhaAcervoCorretorModel _self;
  final $Res Function(LinhaAcervoCorretorModel) _then;

/// Create a copy of LinhaAcervoCorretorModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? corretorId = null,Object? corretor = null,Object? ativo = null,Object? total = null,}) {
  return _then(LinhaAcervoCorretorModel(
corretorId: null == corretorId ? _self.corretorId : corretorId // ignore: cast_nullable_to_non_nullable
as int,corretor: null == corretor ? _self.corretor : corretor // ignore: cast_nullable_to_non_nullable
as String,ativo: null == ativo ? _self.ativo : ativo // ignore: cast_nullable_to_non_nullable
as bool,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LinhaAcervoCorretorModel].
extension LinhaAcervoCorretorModelPatterns on LinhaAcervoCorretorModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinhaAcervoCorretorModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinhaAcervoCorretorModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinhaAcervoCorretorModel value)  $default,){
final _that = this;
switch (_that) {
case _LinhaAcervoCorretorModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinhaAcervoCorretorModel value)?  $default,){
final _that = this;
switch (_that) {
case _LinhaAcervoCorretorModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'corretor_id')  int corretorId,  String corretor,  bool ativo,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinhaAcervoCorretorModel() when $default != null:
return $default(_that.corretorId,_that.corretor,_that.ativo,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'corretor_id')  int corretorId,  String corretor,  bool ativo,  int total)  $default,) {final _that = this;
switch (_that) {
case _LinhaAcervoCorretorModel():
return $default(_that.corretorId,_that.corretor,_that.ativo,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'corretor_id')  int corretorId,  String corretor,  bool ativo,  int total)?  $default,) {final _that = this;
switch (_that) {
case _LinhaAcervoCorretorModel() when $default != null:
return $default(_that.corretorId,_that.corretor,_that.ativo,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LinhaAcervoCorretorModel extends LinhaAcervoCorretorModel {
  const _LinhaAcervoCorretorModel({@JsonKey(name: 'corretor_id') required this.corretorId, required this.corretor, required this.ativo, required this.total}): super._();
  factory _LinhaAcervoCorretorModel.fromJson(Map<String, dynamic> json) => _$LinhaAcervoCorretorModelFromJson(json);

@override@JsonKey(name: 'corretor_id') final  int corretorId;
@override final  String corretor;
@override final  bool ativo;
@override final  int total;

/// Create a copy of LinhaAcervoCorretorModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinhaAcervoCorretorModelCopyWith<_LinhaAcervoCorretorModel> get copyWith => __$LinhaAcervoCorretorModelCopyWithImpl<_LinhaAcervoCorretorModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LinhaAcervoCorretorModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinhaAcervoCorretorModel&&(identical(other.corretorId, corretorId) || other.corretorId == corretorId)&&(identical(other.corretor, corretor) || other.corretor == corretor)&&(identical(other.ativo, ativo) || other.ativo == ativo)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,corretorId,corretor,ativo,total);
}

@override
String toString() {
    return 'LinhaAcervoCorretorModel(corretorId: $corretorId, corretor: $corretor, ativo: $ativo, total: $total)';
}


}

/// @nodoc
abstract mixin class _$LinhaAcervoCorretorModelCopyWith<$Res> implements $LinhaAcervoCorretorModelCopyWith<$Res> {
  factory _$LinhaAcervoCorretorModelCopyWith(_LinhaAcervoCorretorModel value, $Res Function(_LinhaAcervoCorretorModel) _then) = __$LinhaAcervoCorretorModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'corretor_id') int corretorId, String corretor, bool ativo, int total
});




}
/// @nodoc
class __$LinhaAcervoCorretorModelCopyWithImpl<$Res>
    implements _$LinhaAcervoCorretorModelCopyWith<$Res> {
  __$LinhaAcervoCorretorModelCopyWithImpl(this._self, this._then);

  final _LinhaAcervoCorretorModel _self;
  final $Res Function(_LinhaAcervoCorretorModel) _then;

/// Create a copy of LinhaAcervoCorretorModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? corretorId = null,Object? corretor = null,Object? ativo = null,Object? total = null,}) {
  return _then(_LinhaAcervoCorretorModel(
corretorId: null == corretorId ? _self.corretorId : corretorId // ignore: cast_nullable_to_non_nullable
as int,corretor: null == corretor ? _self.corretor : corretor // ignore: cast_nullable_to_non_nullable
as String,ativo: null == ativo ? _self.ativo : ativo // ignore: cast_nullable_to_non_nullable
as bool,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AcervoPorCorretorModel {

 List<LinhaAcervoCorretorModel> get linhas; int get total;
/// Create a copy of AcervoPorCorretorModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcervoPorCorretorModelCopyWith<AcervoPorCorretorModel> get copyWith => _$AcervoPorCorretorModelCopyWithImpl<AcervoPorCorretorModel>(this as AcervoPorCorretorModel, _$identity);

  /// Serializes this AcervoPorCorretorModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AcervoPorCorretorModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AcervoPorCorretorModel&&const DeepCollectionEquality().equals(other.linhas, _this.linhas)&&(identical(other.total, _this.total) || other.total == _this.total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AcervoPorCorretorModel;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.linhas),_this.total);
}

@override
String toString() {
  final _this = this as AcervoPorCorretorModel;
  return 'AcervoPorCorretorModel(linhas: ${_this.linhas}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $AcervoPorCorretorModelCopyWith<$Res>  {
  factory $AcervoPorCorretorModelCopyWith(AcervoPorCorretorModel value, $Res Function(AcervoPorCorretorModel) _then) = _$AcervoPorCorretorModelCopyWithImpl;
@useResult
$Res call({
 List<LinhaAcervoCorretorModel> linhas, int total
});




}
/// @nodoc
class _$AcervoPorCorretorModelCopyWithImpl<$Res>
    implements $AcervoPorCorretorModelCopyWith<$Res> {
  _$AcervoPorCorretorModelCopyWithImpl(this._self, this._then);

  final AcervoPorCorretorModel _self;
  final $Res Function(AcervoPorCorretorModel) _then;

/// Create a copy of AcervoPorCorretorModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? linhas = null,Object? total = null,}) {
  return _then(AcervoPorCorretorModel(
linhas: null == linhas ? _self.linhas : linhas // ignore: cast_nullable_to_non_nullable
as List<LinhaAcervoCorretorModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AcervoPorCorretorModel].
extension AcervoPorCorretorModelPatterns on AcervoPorCorretorModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AcervoPorCorretorModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AcervoPorCorretorModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AcervoPorCorretorModel value)  $default,){
final _that = this;
switch (_that) {
case _AcervoPorCorretorModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AcervoPorCorretorModel value)?  $default,){
final _that = this;
switch (_that) {
case _AcervoPorCorretorModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LinhaAcervoCorretorModel> linhas,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AcervoPorCorretorModel() when $default != null:
return $default(_that.linhas,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LinhaAcervoCorretorModel> linhas,  int total)  $default,) {final _that = this;
switch (_that) {
case _AcervoPorCorretorModel():
return $default(_that.linhas,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LinhaAcervoCorretorModel> linhas,  int total)?  $default,) {final _that = this;
switch (_that) {
case _AcervoPorCorretorModel() when $default != null:
return $default(_that.linhas,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AcervoPorCorretorModel extends AcervoPorCorretorModel {
  const _AcervoPorCorretorModel({required  List<LinhaAcervoCorretorModel> linhas, required this.total}): _linhas = linhas,super._();
  factory _AcervoPorCorretorModel.fromJson(Map<String, dynamic> json) => _$AcervoPorCorretorModelFromJson(json);

 final  List<LinhaAcervoCorretorModel> _linhas;
@override List<LinhaAcervoCorretorModel> get linhas {
  if (_linhas is EqualUnmodifiableListView) return _linhas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_linhas);
}

@override final  int total;

/// Create a copy of AcervoPorCorretorModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcervoPorCorretorModelCopyWith<_AcervoPorCorretorModel> get copyWith => __$AcervoPorCorretorModelCopyWithImpl<_AcervoPorCorretorModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AcervoPorCorretorModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AcervoPorCorretorModel&&const DeepCollectionEquality().equals(other.linhas, _linhas)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_linhas),total);
}

@override
String toString() {
    return 'AcervoPorCorretorModel(linhas: $linhas, total: $total)';
}


}

/// @nodoc
abstract mixin class _$AcervoPorCorretorModelCopyWith<$Res> implements $AcervoPorCorretorModelCopyWith<$Res> {
  factory _$AcervoPorCorretorModelCopyWith(_AcervoPorCorretorModel value, $Res Function(_AcervoPorCorretorModel) _then) = __$AcervoPorCorretorModelCopyWithImpl;
@override @useResult
$Res call({
 List<LinhaAcervoCorretorModel> linhas, int total
});




}
/// @nodoc
class __$AcervoPorCorretorModelCopyWithImpl<$Res>
    implements _$AcervoPorCorretorModelCopyWith<$Res> {
  __$AcervoPorCorretorModelCopyWithImpl(this._self, this._then);

  final _AcervoPorCorretorModel _self;
  final $Res Function(_AcervoPorCorretorModel) _then;

/// Create a copy of AcervoPorCorretorModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? linhas = null,Object? total = null,}) {
  return _then(_AcervoPorCorretorModel(
linhas: null == linhas ? _self._linhas : linhas // ignore: cast_nullable_to_non_nullable
as List<LinhaAcervoCorretorModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
