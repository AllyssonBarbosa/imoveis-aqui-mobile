// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mudanca_situacao_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MudancaSituacaoModel {

 int get id;@JsonKey(name: 'situacao_anterior') String? get situacaoAnterior;@JsonKey(name: 'situacao_nova') String? get situacaoNova;@JsonKey(name: 'alterado_por') String? get alteradoPor;@JsonKey(name: 'alterado_em') String get alteradoEm; String get observacao;
/// Create a copy of MudancaSituacaoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MudancaSituacaoModelCopyWith<MudancaSituacaoModel> get copyWith => _$MudancaSituacaoModelCopyWithImpl<MudancaSituacaoModel>(this as MudancaSituacaoModel, _$identity);

  /// Serializes this MudancaSituacaoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MudancaSituacaoModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MudancaSituacaoModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.situacaoAnterior, _this.situacaoAnterior) || other.situacaoAnterior == _this.situacaoAnterior)&&(identical(other.situacaoNova, _this.situacaoNova) || other.situacaoNova == _this.situacaoNova)&&(identical(other.alteradoPor, _this.alteradoPor) || other.alteradoPor == _this.alteradoPor)&&(identical(other.alteradoEm, _this.alteradoEm) || other.alteradoEm == _this.alteradoEm)&&(identical(other.observacao, _this.observacao) || other.observacao == _this.observacao));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MudancaSituacaoModel;
  return Object.hash(runtimeType,_this.id,_this.situacaoAnterior,_this.situacaoNova,_this.alteradoPor,_this.alteradoEm,_this.observacao);
}

@override
String toString() {
  final _this = this as MudancaSituacaoModel;
  return 'MudancaSituacaoModel(id: ${_this.id}, situacaoAnterior: ${_this.situacaoAnterior}, situacaoNova: ${_this.situacaoNova}, alteradoPor: ${_this.alteradoPor}, alteradoEm: ${_this.alteradoEm}, observacao: ${_this.observacao})';
}


}

/// @nodoc
abstract mixin class $MudancaSituacaoModelCopyWith<$Res>  {
  factory $MudancaSituacaoModelCopyWith(MudancaSituacaoModel value, $Res Function(MudancaSituacaoModel) _then) = _$MudancaSituacaoModelCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'situacao_anterior') String? situacaoAnterior,@JsonKey(name: 'situacao_nova') String? situacaoNova,@JsonKey(name: 'alterado_por') String? alteradoPor,@JsonKey(name: 'alterado_em') String alteradoEm, String observacao
});




}
/// @nodoc
class _$MudancaSituacaoModelCopyWithImpl<$Res>
    implements $MudancaSituacaoModelCopyWith<$Res> {
  _$MudancaSituacaoModelCopyWithImpl(this._self, this._then);

  final MudancaSituacaoModel _self;
  final $Res Function(MudancaSituacaoModel) _then;

/// Create a copy of MudancaSituacaoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? situacaoAnterior = freezed,Object? situacaoNova = freezed,Object? alteradoPor = freezed,Object? alteradoEm = null,Object? observacao = null,}) {
  return _then(MudancaSituacaoModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,situacaoAnterior: freezed == situacaoAnterior ? _self.situacaoAnterior : situacaoAnterior // ignore: cast_nullable_to_non_nullable
as String?,situacaoNova: freezed == situacaoNova ? _self.situacaoNova : situacaoNova // ignore: cast_nullable_to_non_nullable
as String?,alteradoPor: freezed == alteradoPor ? _self.alteradoPor : alteradoPor // ignore: cast_nullable_to_non_nullable
as String?,alteradoEm: null == alteradoEm ? _self.alteradoEm : alteradoEm // ignore: cast_nullable_to_non_nullable
as String,observacao: null == observacao ? _self.observacao : observacao // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MudancaSituacaoModel].
extension MudancaSituacaoModelPatterns on MudancaSituacaoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MudancaSituacaoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MudancaSituacaoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MudancaSituacaoModel value)  $default,){
final _that = this;
switch (_that) {
case _MudancaSituacaoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MudancaSituacaoModel value)?  $default,){
final _that = this;
switch (_that) {
case _MudancaSituacaoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'situacao_anterior')  String? situacaoAnterior, @JsonKey(name: 'situacao_nova')  String? situacaoNova, @JsonKey(name: 'alterado_por')  String? alteradoPor, @JsonKey(name: 'alterado_em')  String alteradoEm,  String observacao)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MudancaSituacaoModel() when $default != null:
return $default(_that.id,_that.situacaoAnterior,_that.situacaoNova,_that.alteradoPor,_that.alteradoEm,_that.observacao);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'situacao_anterior')  String? situacaoAnterior, @JsonKey(name: 'situacao_nova')  String? situacaoNova, @JsonKey(name: 'alterado_por')  String? alteradoPor, @JsonKey(name: 'alterado_em')  String alteradoEm,  String observacao)  $default,) {final _that = this;
switch (_that) {
case _MudancaSituacaoModel():
return $default(_that.id,_that.situacaoAnterior,_that.situacaoNova,_that.alteradoPor,_that.alteradoEm,_that.observacao);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'situacao_anterior')  String? situacaoAnterior, @JsonKey(name: 'situacao_nova')  String? situacaoNova, @JsonKey(name: 'alterado_por')  String? alteradoPor, @JsonKey(name: 'alterado_em')  String alteradoEm,  String observacao)?  $default,) {final _that = this;
switch (_that) {
case _MudancaSituacaoModel() when $default != null:
return $default(_that.id,_that.situacaoAnterior,_that.situacaoNova,_that.alteradoPor,_that.alteradoEm,_that.observacao);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MudancaSituacaoModel extends MudancaSituacaoModel {
  const _MudancaSituacaoModel({required this.id, @JsonKey(name: 'situacao_anterior') this.situacaoAnterior, @JsonKey(name: 'situacao_nova') this.situacaoNova, @JsonKey(name: 'alterado_por') this.alteradoPor, @JsonKey(name: 'alterado_em') required this.alteradoEm, this.observacao = ''}): super._();
  factory _MudancaSituacaoModel.fromJson(Map<String, dynamic> json) => _$MudancaSituacaoModelFromJson(json);

@override final  int id;
@override@JsonKey(name: 'situacao_anterior') final  String? situacaoAnterior;
@override@JsonKey(name: 'situacao_nova') final  String? situacaoNova;
@override@JsonKey(name: 'alterado_por') final  String? alteradoPor;
@override@JsonKey(name: 'alterado_em') final  String alteradoEm;
@override@JsonKey() final  String observacao;

/// Create a copy of MudancaSituacaoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MudancaSituacaoModelCopyWith<_MudancaSituacaoModel> get copyWith => __$MudancaSituacaoModelCopyWithImpl<_MudancaSituacaoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MudancaSituacaoModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MudancaSituacaoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.situacaoAnterior, situacaoAnterior) || other.situacaoAnterior == situacaoAnterior)&&(identical(other.situacaoNova, situacaoNova) || other.situacaoNova == situacaoNova)&&(identical(other.alteradoPor, alteradoPor) || other.alteradoPor == alteradoPor)&&(identical(other.alteradoEm, alteradoEm) || other.alteradoEm == alteradoEm)&&(identical(other.observacao, observacao) || other.observacao == observacao));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,situacaoAnterior,situacaoNova,alteradoPor,alteradoEm,observacao);
}

@override
String toString() {
    return 'MudancaSituacaoModel(id: $id, situacaoAnterior: $situacaoAnterior, situacaoNova: $situacaoNova, alteradoPor: $alteradoPor, alteradoEm: $alteradoEm, observacao: $observacao)';
}


}

/// @nodoc
abstract mixin class _$MudancaSituacaoModelCopyWith<$Res> implements $MudancaSituacaoModelCopyWith<$Res> {
  factory _$MudancaSituacaoModelCopyWith(_MudancaSituacaoModel value, $Res Function(_MudancaSituacaoModel) _then) = __$MudancaSituacaoModelCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'situacao_anterior') String? situacaoAnterior,@JsonKey(name: 'situacao_nova') String? situacaoNova,@JsonKey(name: 'alterado_por') String? alteradoPor,@JsonKey(name: 'alterado_em') String alteradoEm, String observacao
});




}
/// @nodoc
class __$MudancaSituacaoModelCopyWithImpl<$Res>
    implements _$MudancaSituacaoModelCopyWith<$Res> {
  __$MudancaSituacaoModelCopyWithImpl(this._self, this._then);

  final _MudancaSituacaoModel _self;
  final $Res Function(_MudancaSituacaoModel) _then;

/// Create a copy of MudancaSituacaoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? situacaoAnterior = freezed,Object? situacaoNova = freezed,Object? alteradoPor = freezed,Object? alteradoEm = null,Object? observacao = null,}) {
  return _then(_MudancaSituacaoModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,situacaoAnterior: freezed == situacaoAnterior ? _self.situacaoAnterior : situacaoAnterior // ignore: cast_nullable_to_non_nullable
as String?,situacaoNova: freezed == situacaoNova ? _self.situacaoNova : situacaoNova // ignore: cast_nullable_to_non_nullable
as String?,alteradoPor: freezed == alteradoPor ? _self.alteradoPor : alteradoPor // ignore: cast_nullable_to_non_nullable
as String?,alteradoEm: null == alteradoEm ? _self.alteradoEm : alteradoEm // ignore: cast_nullable_to_non_nullable
as String,observacao: null == observacao ? _self.observacao : observacao // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
