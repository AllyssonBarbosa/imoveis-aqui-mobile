// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contatos_por_corretor_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LinhaContatosCorretorModel {

@JsonKey(name: 'corretor_id') int? get corretorId; String? get corretor; bool? get ativo; int get total; int get pendentes;
/// Create a copy of LinhaContatosCorretorModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinhaContatosCorretorModelCopyWith<LinhaContatosCorretorModel> get copyWith => _$LinhaContatosCorretorModelCopyWithImpl<LinhaContatosCorretorModel>(this as LinhaContatosCorretorModel, _$identity);

  /// Serializes this LinhaContatosCorretorModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LinhaContatosCorretorModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinhaContatosCorretorModel&&(identical(other.corretorId, _this.corretorId) || other.corretorId == _this.corretorId)&&(identical(other.corretor, _this.corretor) || other.corretor == _this.corretor)&&(identical(other.ativo, _this.ativo) || other.ativo == _this.ativo)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.pendentes, _this.pendentes) || other.pendentes == _this.pendentes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LinhaContatosCorretorModel;
  return Object.hash(runtimeType,_this.corretorId,_this.corretor,_this.ativo,_this.total,_this.pendentes);
}

@override
String toString() {
  final _this = this as LinhaContatosCorretorModel;
  return 'LinhaContatosCorretorModel(corretorId: ${_this.corretorId}, corretor: ${_this.corretor}, ativo: ${_this.ativo}, total: ${_this.total}, pendentes: ${_this.pendentes})';
}


}

/// @nodoc
abstract mixin class $LinhaContatosCorretorModelCopyWith<$Res>  {
  factory $LinhaContatosCorretorModelCopyWith(LinhaContatosCorretorModel value, $Res Function(LinhaContatosCorretorModel) _then) = _$LinhaContatosCorretorModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'corretor_id') int? corretorId, String? corretor, bool? ativo, int total, int pendentes
});




}
/// @nodoc
class _$LinhaContatosCorretorModelCopyWithImpl<$Res>
    implements $LinhaContatosCorretorModelCopyWith<$Res> {
  _$LinhaContatosCorretorModelCopyWithImpl(this._self, this._then);

  final LinhaContatosCorretorModel _self;
  final $Res Function(LinhaContatosCorretorModel) _then;

/// Create a copy of LinhaContatosCorretorModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? corretorId = freezed,Object? corretor = freezed,Object? ativo = freezed,Object? total = null,Object? pendentes = null,}) {
  return _then(LinhaContatosCorretorModel(
corretorId: freezed == corretorId ? _self.corretorId : corretorId // ignore: cast_nullable_to_non_nullable
as int?,corretor: freezed == corretor ? _self.corretor : corretor // ignore: cast_nullable_to_non_nullable
as String?,ativo: freezed == ativo ? _self.ativo : ativo // ignore: cast_nullable_to_non_nullable
as bool?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,pendentes: null == pendentes ? _self.pendentes : pendentes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LinhaContatosCorretorModel].
extension LinhaContatosCorretorModelPatterns on LinhaContatosCorretorModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinhaContatosCorretorModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinhaContatosCorretorModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinhaContatosCorretorModel value)  $default,){
final _that = this;
switch (_that) {
case _LinhaContatosCorretorModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinhaContatosCorretorModel value)?  $default,){
final _that = this;
switch (_that) {
case _LinhaContatosCorretorModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'corretor_id')  int? corretorId,  String? corretor,  bool? ativo,  int total,  int pendentes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinhaContatosCorretorModel() when $default != null:
return $default(_that.corretorId,_that.corretor,_that.ativo,_that.total,_that.pendentes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'corretor_id')  int? corretorId,  String? corretor,  bool? ativo,  int total,  int pendentes)  $default,) {final _that = this;
switch (_that) {
case _LinhaContatosCorretorModel():
return $default(_that.corretorId,_that.corretor,_that.ativo,_that.total,_that.pendentes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'corretor_id')  int? corretorId,  String? corretor,  bool? ativo,  int total,  int pendentes)?  $default,) {final _that = this;
switch (_that) {
case _LinhaContatosCorretorModel() when $default != null:
return $default(_that.corretorId,_that.corretor,_that.ativo,_that.total,_that.pendentes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LinhaContatosCorretorModel extends LinhaContatosCorretorModel {
  const _LinhaContatosCorretorModel({@JsonKey(name: 'corretor_id') this.corretorId, this.corretor, this.ativo, required this.total, required this.pendentes}): super._();
  factory _LinhaContatosCorretorModel.fromJson(Map<String, dynamic> json) => _$LinhaContatosCorretorModelFromJson(json);

@override@JsonKey(name: 'corretor_id') final  int? corretorId;
@override final  String? corretor;
@override final  bool? ativo;
@override final  int total;
@override final  int pendentes;

/// Create a copy of LinhaContatosCorretorModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinhaContatosCorretorModelCopyWith<_LinhaContatosCorretorModel> get copyWith => __$LinhaContatosCorretorModelCopyWithImpl<_LinhaContatosCorretorModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LinhaContatosCorretorModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinhaContatosCorretorModel&&(identical(other.corretorId, corretorId) || other.corretorId == corretorId)&&(identical(other.corretor, corretor) || other.corretor == corretor)&&(identical(other.ativo, ativo) || other.ativo == ativo)&&(identical(other.total, total) || other.total == total)&&(identical(other.pendentes, pendentes) || other.pendentes == pendentes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,corretorId,corretor,ativo,total,pendentes);
}

@override
String toString() {
    return 'LinhaContatosCorretorModel(corretorId: $corretorId, corretor: $corretor, ativo: $ativo, total: $total, pendentes: $pendentes)';
}


}

/// @nodoc
abstract mixin class _$LinhaContatosCorretorModelCopyWith<$Res> implements $LinhaContatosCorretorModelCopyWith<$Res> {
  factory _$LinhaContatosCorretorModelCopyWith(_LinhaContatosCorretorModel value, $Res Function(_LinhaContatosCorretorModel) _then) = __$LinhaContatosCorretorModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'corretor_id') int? corretorId, String? corretor, bool? ativo, int total, int pendentes
});




}
/// @nodoc
class __$LinhaContatosCorretorModelCopyWithImpl<$Res>
    implements _$LinhaContatosCorretorModelCopyWith<$Res> {
  __$LinhaContatosCorretorModelCopyWithImpl(this._self, this._then);

  final _LinhaContatosCorretorModel _self;
  final $Res Function(_LinhaContatosCorretorModel) _then;

/// Create a copy of LinhaContatosCorretorModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? corretorId = freezed,Object? corretor = freezed,Object? ativo = freezed,Object? total = null,Object? pendentes = null,}) {
  return _then(_LinhaContatosCorretorModel(
corretorId: freezed == corretorId ? _self.corretorId : corretorId // ignore: cast_nullable_to_non_nullable
as int?,corretor: freezed == corretor ? _self.corretor : corretor // ignore: cast_nullable_to_non_nullable
as String?,ativo: freezed == ativo ? _self.ativo : ativo // ignore: cast_nullable_to_non_nullable
as bool?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,pendentes: null == pendentes ? _self.pendentes : pendentes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ContatosPorCorretorModel {

 List<LinhaContatosCorretorModel> get linhas; int get total; int get pendentes;
/// Create a copy of ContatosPorCorretorModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContatosPorCorretorModelCopyWith<ContatosPorCorretorModel> get copyWith => _$ContatosPorCorretorModelCopyWithImpl<ContatosPorCorretorModel>(this as ContatosPorCorretorModel, _$identity);

  /// Serializes this ContatosPorCorretorModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ContatosPorCorretorModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContatosPorCorretorModel&&const DeepCollectionEquality().equals(other.linhas, _this.linhas)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.pendentes, _this.pendentes) || other.pendentes == _this.pendentes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ContatosPorCorretorModel;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.linhas),_this.total,_this.pendentes);
}

@override
String toString() {
  final _this = this as ContatosPorCorretorModel;
  return 'ContatosPorCorretorModel(linhas: ${_this.linhas}, total: ${_this.total}, pendentes: ${_this.pendentes})';
}


}

/// @nodoc
abstract mixin class $ContatosPorCorretorModelCopyWith<$Res>  {
  factory $ContatosPorCorretorModelCopyWith(ContatosPorCorretorModel value, $Res Function(ContatosPorCorretorModel) _then) = _$ContatosPorCorretorModelCopyWithImpl;
@useResult
$Res call({
 List<LinhaContatosCorretorModel> linhas, int total, int pendentes
});




}
/// @nodoc
class _$ContatosPorCorretorModelCopyWithImpl<$Res>
    implements $ContatosPorCorretorModelCopyWith<$Res> {
  _$ContatosPorCorretorModelCopyWithImpl(this._self, this._then);

  final ContatosPorCorretorModel _self;
  final $Res Function(ContatosPorCorretorModel) _then;

/// Create a copy of ContatosPorCorretorModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? linhas = null,Object? total = null,Object? pendentes = null,}) {
  return _then(ContatosPorCorretorModel(
linhas: null == linhas ? _self.linhas : linhas // ignore: cast_nullable_to_non_nullable
as List<LinhaContatosCorretorModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,pendentes: null == pendentes ? _self.pendentes : pendentes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ContatosPorCorretorModel].
extension ContatosPorCorretorModelPatterns on ContatosPorCorretorModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContatosPorCorretorModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContatosPorCorretorModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContatosPorCorretorModel value)  $default,){
final _that = this;
switch (_that) {
case _ContatosPorCorretorModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContatosPorCorretorModel value)?  $default,){
final _that = this;
switch (_that) {
case _ContatosPorCorretorModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LinhaContatosCorretorModel> linhas,  int total,  int pendentes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContatosPorCorretorModel() when $default != null:
return $default(_that.linhas,_that.total,_that.pendentes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LinhaContatosCorretorModel> linhas,  int total,  int pendentes)  $default,) {final _that = this;
switch (_that) {
case _ContatosPorCorretorModel():
return $default(_that.linhas,_that.total,_that.pendentes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LinhaContatosCorretorModel> linhas,  int total,  int pendentes)?  $default,) {final _that = this;
switch (_that) {
case _ContatosPorCorretorModel() when $default != null:
return $default(_that.linhas,_that.total,_that.pendentes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContatosPorCorretorModel extends ContatosPorCorretorModel {
  const _ContatosPorCorretorModel({required  List<LinhaContatosCorretorModel> linhas, required this.total, required this.pendentes}): _linhas = linhas,super._();
  factory _ContatosPorCorretorModel.fromJson(Map<String, dynamic> json) => _$ContatosPorCorretorModelFromJson(json);

 final  List<LinhaContatosCorretorModel> _linhas;
@override List<LinhaContatosCorretorModel> get linhas {
  if (_linhas is EqualUnmodifiableListView) return _linhas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_linhas);
}

@override final  int total;
@override final  int pendentes;

/// Create a copy of ContatosPorCorretorModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContatosPorCorretorModelCopyWith<_ContatosPorCorretorModel> get copyWith => __$ContatosPorCorretorModelCopyWithImpl<_ContatosPorCorretorModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContatosPorCorretorModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContatosPorCorretorModel&&const DeepCollectionEquality().equals(other.linhas, _linhas)&&(identical(other.total, total) || other.total == total)&&(identical(other.pendentes, pendentes) || other.pendentes == pendentes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_linhas),total,pendentes);
}

@override
String toString() {
    return 'ContatosPorCorretorModel(linhas: $linhas, total: $total, pendentes: $pendentes)';
}


}

/// @nodoc
abstract mixin class _$ContatosPorCorretorModelCopyWith<$Res> implements $ContatosPorCorretorModelCopyWith<$Res> {
  factory _$ContatosPorCorretorModelCopyWith(_ContatosPorCorretorModel value, $Res Function(_ContatosPorCorretorModel) _then) = __$ContatosPorCorretorModelCopyWithImpl;
@override @useResult
$Res call({
 List<LinhaContatosCorretorModel> linhas, int total, int pendentes
});




}
/// @nodoc
class __$ContatosPorCorretorModelCopyWithImpl<$Res>
    implements _$ContatosPorCorretorModelCopyWith<$Res> {
  __$ContatosPorCorretorModelCopyWithImpl(this._self, this._then);

  final _ContatosPorCorretorModel _self;
  final $Res Function(_ContatosPorCorretorModel) _then;

/// Create a copy of ContatosPorCorretorModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? linhas = null,Object? total = null,Object? pendentes = null,}) {
  return _then(_ContatosPorCorretorModel(
linhas: null == linhas ? _self._linhas : linhas // ignore: cast_nullable_to_non_nullable
as List<LinhaContatosCorretorModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,pendentes: null == pendentes ? _self.pendentes : pendentes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
