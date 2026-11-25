// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mudancas_recentes_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MudancaRecenteModel {

 int get id;@JsonKey(name: 'imovel_id') int get imovelId;@JsonKey(name: 'imovel_codigo') String get imovelCodigo;@JsonKey(name: 'imovel_titulo') String get imovelTitulo;@JsonKey(name: 'situacao_anterior') String get situacaoAnterior;@JsonKey(name: 'situacao_nova') String get situacaoNova;@JsonKey(name: 'alterado_por') String get alteradoPor;@JsonKey(name: 'alterado_em') String get alteradoEm; String get observacao;
/// Create a copy of MudancaRecenteModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MudancaRecenteModelCopyWith<MudancaRecenteModel> get copyWith => _$MudancaRecenteModelCopyWithImpl<MudancaRecenteModel>(this as MudancaRecenteModel, _$identity);

  /// Serializes this MudancaRecenteModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MudancaRecenteModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MudancaRecenteModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.imovelId, _this.imovelId) || other.imovelId == _this.imovelId)&&(identical(other.imovelCodigo, _this.imovelCodigo) || other.imovelCodigo == _this.imovelCodigo)&&(identical(other.imovelTitulo, _this.imovelTitulo) || other.imovelTitulo == _this.imovelTitulo)&&(identical(other.situacaoAnterior, _this.situacaoAnterior) || other.situacaoAnterior == _this.situacaoAnterior)&&(identical(other.situacaoNova, _this.situacaoNova) || other.situacaoNova == _this.situacaoNova)&&(identical(other.alteradoPor, _this.alteradoPor) || other.alteradoPor == _this.alteradoPor)&&(identical(other.alteradoEm, _this.alteradoEm) || other.alteradoEm == _this.alteradoEm)&&(identical(other.observacao, _this.observacao) || other.observacao == _this.observacao));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MudancaRecenteModel;
  return Object.hash(runtimeType,_this.id,_this.imovelId,_this.imovelCodigo,_this.imovelTitulo,_this.situacaoAnterior,_this.situacaoNova,_this.alteradoPor,_this.alteradoEm,_this.observacao);
}

@override
String toString() {
  final _this = this as MudancaRecenteModel;
  return 'MudancaRecenteModel(id: ${_this.id}, imovelId: ${_this.imovelId}, imovelCodigo: ${_this.imovelCodigo}, imovelTitulo: ${_this.imovelTitulo}, situacaoAnterior: ${_this.situacaoAnterior}, situacaoNova: ${_this.situacaoNova}, alteradoPor: ${_this.alteradoPor}, alteradoEm: ${_this.alteradoEm}, observacao: ${_this.observacao})';
}


}

/// @nodoc
abstract mixin class $MudancaRecenteModelCopyWith<$Res>  {
  factory $MudancaRecenteModelCopyWith(MudancaRecenteModel value, $Res Function(MudancaRecenteModel) _then) = _$MudancaRecenteModelCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'imovel_id') int imovelId,@JsonKey(name: 'imovel_codigo') String imovelCodigo,@JsonKey(name: 'imovel_titulo') String imovelTitulo,@JsonKey(name: 'situacao_anterior') String situacaoAnterior,@JsonKey(name: 'situacao_nova') String situacaoNova,@JsonKey(name: 'alterado_por') String alteradoPor,@JsonKey(name: 'alterado_em') String alteradoEm, String observacao
});




}
/// @nodoc
class _$MudancaRecenteModelCopyWithImpl<$Res>
    implements $MudancaRecenteModelCopyWith<$Res> {
  _$MudancaRecenteModelCopyWithImpl(this._self, this._then);

  final MudancaRecenteModel _self;
  final $Res Function(MudancaRecenteModel) _then;

/// Create a copy of MudancaRecenteModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? imovelId = null,Object? imovelCodigo = null,Object? imovelTitulo = null,Object? situacaoAnterior = null,Object? situacaoNova = null,Object? alteradoPor = null,Object? alteradoEm = null,Object? observacao = null,}) {
  return _then(MudancaRecenteModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,imovelId: null == imovelId ? _self.imovelId : imovelId // ignore: cast_nullable_to_non_nullable
as int,imovelCodigo: null == imovelCodigo ? _self.imovelCodigo : imovelCodigo // ignore: cast_nullable_to_non_nullable
as String,imovelTitulo: null == imovelTitulo ? _self.imovelTitulo : imovelTitulo // ignore: cast_nullable_to_non_nullable
as String,situacaoAnterior: null == situacaoAnterior ? _self.situacaoAnterior : situacaoAnterior // ignore: cast_nullable_to_non_nullable
as String,situacaoNova: null == situacaoNova ? _self.situacaoNova : situacaoNova // ignore: cast_nullable_to_non_nullable
as String,alteradoPor: null == alteradoPor ? _self.alteradoPor : alteradoPor // ignore: cast_nullable_to_non_nullable
as String,alteradoEm: null == alteradoEm ? _self.alteradoEm : alteradoEm // ignore: cast_nullable_to_non_nullable
as String,observacao: null == observacao ? _self.observacao : observacao // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MudancaRecenteModel].
extension MudancaRecenteModelPatterns on MudancaRecenteModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MudancaRecenteModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MudancaRecenteModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MudancaRecenteModel value)  $default,){
final _that = this;
switch (_that) {
case _MudancaRecenteModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MudancaRecenteModel value)?  $default,){
final _that = this;
switch (_that) {
case _MudancaRecenteModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'imovel_id')  int imovelId, @JsonKey(name: 'imovel_codigo')  String imovelCodigo, @JsonKey(name: 'imovel_titulo')  String imovelTitulo, @JsonKey(name: 'situacao_anterior')  String situacaoAnterior, @JsonKey(name: 'situacao_nova')  String situacaoNova, @JsonKey(name: 'alterado_por')  String alteradoPor, @JsonKey(name: 'alterado_em')  String alteradoEm,  String observacao)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MudancaRecenteModel() when $default != null:
return $default(_that.id,_that.imovelId,_that.imovelCodigo,_that.imovelTitulo,_that.situacaoAnterior,_that.situacaoNova,_that.alteradoPor,_that.alteradoEm,_that.observacao);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'imovel_id')  int imovelId, @JsonKey(name: 'imovel_codigo')  String imovelCodigo, @JsonKey(name: 'imovel_titulo')  String imovelTitulo, @JsonKey(name: 'situacao_anterior')  String situacaoAnterior, @JsonKey(name: 'situacao_nova')  String situacaoNova, @JsonKey(name: 'alterado_por')  String alteradoPor, @JsonKey(name: 'alterado_em')  String alteradoEm,  String observacao)  $default,) {final _that = this;
switch (_that) {
case _MudancaRecenteModel():
return $default(_that.id,_that.imovelId,_that.imovelCodigo,_that.imovelTitulo,_that.situacaoAnterior,_that.situacaoNova,_that.alteradoPor,_that.alteradoEm,_that.observacao);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'imovel_id')  int imovelId, @JsonKey(name: 'imovel_codigo')  String imovelCodigo, @JsonKey(name: 'imovel_titulo')  String imovelTitulo, @JsonKey(name: 'situacao_anterior')  String situacaoAnterior, @JsonKey(name: 'situacao_nova')  String situacaoNova, @JsonKey(name: 'alterado_por')  String alteradoPor, @JsonKey(name: 'alterado_em')  String alteradoEm,  String observacao)?  $default,) {final _that = this;
switch (_that) {
case _MudancaRecenteModel() when $default != null:
return $default(_that.id,_that.imovelId,_that.imovelCodigo,_that.imovelTitulo,_that.situacaoAnterior,_that.situacaoNova,_that.alteradoPor,_that.alteradoEm,_that.observacao);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MudancaRecenteModel extends MudancaRecenteModel {
  const _MudancaRecenteModel({required this.id, @JsonKey(name: 'imovel_id') required this.imovelId, @JsonKey(name: 'imovel_codigo') required this.imovelCodigo, @JsonKey(name: 'imovel_titulo') required this.imovelTitulo, @JsonKey(name: 'situacao_anterior') required this.situacaoAnterior, @JsonKey(name: 'situacao_nova') required this.situacaoNova, @JsonKey(name: 'alterado_por') required this.alteradoPor, @JsonKey(name: 'alterado_em') required this.alteradoEm, this.observacao = ''}): super._();
  factory _MudancaRecenteModel.fromJson(Map<String, dynamic> json) => _$MudancaRecenteModelFromJson(json);

@override final  int id;
@override@JsonKey(name: 'imovel_id') final  int imovelId;
@override@JsonKey(name: 'imovel_codigo') final  String imovelCodigo;
@override@JsonKey(name: 'imovel_titulo') final  String imovelTitulo;
@override@JsonKey(name: 'situacao_anterior') final  String situacaoAnterior;
@override@JsonKey(name: 'situacao_nova') final  String situacaoNova;
@override@JsonKey(name: 'alterado_por') final  String alteradoPor;
@override@JsonKey(name: 'alterado_em') final  String alteradoEm;
@override@JsonKey() final  String observacao;

/// Create a copy of MudancaRecenteModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MudancaRecenteModelCopyWith<_MudancaRecenteModel> get copyWith => __$MudancaRecenteModelCopyWithImpl<_MudancaRecenteModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MudancaRecenteModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MudancaRecenteModel&&(identical(other.id, id) || other.id == id)&&(identical(other.imovelId, imovelId) || other.imovelId == imovelId)&&(identical(other.imovelCodigo, imovelCodigo) || other.imovelCodigo == imovelCodigo)&&(identical(other.imovelTitulo, imovelTitulo) || other.imovelTitulo == imovelTitulo)&&(identical(other.situacaoAnterior, situacaoAnterior) || other.situacaoAnterior == situacaoAnterior)&&(identical(other.situacaoNova, situacaoNova) || other.situacaoNova == situacaoNova)&&(identical(other.alteradoPor, alteradoPor) || other.alteradoPor == alteradoPor)&&(identical(other.alteradoEm, alteradoEm) || other.alteradoEm == alteradoEm)&&(identical(other.observacao, observacao) || other.observacao == observacao));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,imovelId,imovelCodigo,imovelTitulo,situacaoAnterior,situacaoNova,alteradoPor,alteradoEm,observacao);
}

@override
String toString() {
    return 'MudancaRecenteModel(id: $id, imovelId: $imovelId, imovelCodigo: $imovelCodigo, imovelTitulo: $imovelTitulo, situacaoAnterior: $situacaoAnterior, situacaoNova: $situacaoNova, alteradoPor: $alteradoPor, alteradoEm: $alteradoEm, observacao: $observacao)';
}


}

/// @nodoc
abstract mixin class _$MudancaRecenteModelCopyWith<$Res> implements $MudancaRecenteModelCopyWith<$Res> {
  factory _$MudancaRecenteModelCopyWith(_MudancaRecenteModel value, $Res Function(_MudancaRecenteModel) _then) = __$MudancaRecenteModelCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'imovel_id') int imovelId,@JsonKey(name: 'imovel_codigo') String imovelCodigo,@JsonKey(name: 'imovel_titulo') String imovelTitulo,@JsonKey(name: 'situacao_anterior') String situacaoAnterior,@JsonKey(name: 'situacao_nova') String situacaoNova,@JsonKey(name: 'alterado_por') String alteradoPor,@JsonKey(name: 'alterado_em') String alteradoEm, String observacao
});




}
/// @nodoc
class __$MudancaRecenteModelCopyWithImpl<$Res>
    implements _$MudancaRecenteModelCopyWith<$Res> {
  __$MudancaRecenteModelCopyWithImpl(this._self, this._then);

  final _MudancaRecenteModel _self;
  final $Res Function(_MudancaRecenteModel) _then;

/// Create a copy of MudancaRecenteModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? imovelId = null,Object? imovelCodigo = null,Object? imovelTitulo = null,Object? situacaoAnterior = null,Object? situacaoNova = null,Object? alteradoPor = null,Object? alteradoEm = null,Object? observacao = null,}) {
  return _then(_MudancaRecenteModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,imovelId: null == imovelId ? _self.imovelId : imovelId // ignore: cast_nullable_to_non_nullable
as int,imovelCodigo: null == imovelCodigo ? _self.imovelCodigo : imovelCodigo // ignore: cast_nullable_to_non_nullable
as String,imovelTitulo: null == imovelTitulo ? _self.imovelTitulo : imovelTitulo // ignore: cast_nullable_to_non_nullable
as String,situacaoAnterior: null == situacaoAnterior ? _self.situacaoAnterior : situacaoAnterior // ignore: cast_nullable_to_non_nullable
as String,situacaoNova: null == situacaoNova ? _self.situacaoNova : situacaoNova // ignore: cast_nullable_to_non_nullable
as String,alteradoPor: null == alteradoPor ? _self.alteradoPor : alteradoPor // ignore: cast_nullable_to_non_nullable
as String,alteradoEm: null == alteradoEm ? _self.alteradoEm : alteradoEm // ignore: cast_nullable_to_non_nullable
as String,observacao: null == observacao ? _self.observacao : observacao // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MudancasRecentesModel {

 int get dias; List<MudancaRecenteModel> get mudancas;
/// Create a copy of MudancasRecentesModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MudancasRecentesModelCopyWith<MudancasRecentesModel> get copyWith => _$MudancasRecentesModelCopyWithImpl<MudancasRecentesModel>(this as MudancasRecentesModel, _$identity);

  /// Serializes this MudancasRecentesModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MudancasRecentesModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MudancasRecentesModel&&(identical(other.dias, _this.dias) || other.dias == _this.dias)&&const DeepCollectionEquality().equals(other.mudancas, _this.mudancas));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MudancasRecentesModel;
  return Object.hash(runtimeType,_this.dias,const DeepCollectionEquality().hash(_this.mudancas));
}

@override
String toString() {
  final _this = this as MudancasRecentesModel;
  return 'MudancasRecentesModel(dias: ${_this.dias}, mudancas: ${_this.mudancas})';
}


}

/// @nodoc
abstract mixin class $MudancasRecentesModelCopyWith<$Res>  {
  factory $MudancasRecentesModelCopyWith(MudancasRecentesModel value, $Res Function(MudancasRecentesModel) _then) = _$MudancasRecentesModelCopyWithImpl;
@useResult
$Res call({
 int dias, List<MudancaRecenteModel> mudancas
});




}
/// @nodoc
class _$MudancasRecentesModelCopyWithImpl<$Res>
    implements $MudancasRecentesModelCopyWith<$Res> {
  _$MudancasRecentesModelCopyWithImpl(this._self, this._then);

  final MudancasRecentesModel _self;
  final $Res Function(MudancasRecentesModel) _then;

/// Create a copy of MudancasRecentesModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dias = null,Object? mudancas = null,}) {
  return _then(MudancasRecentesModel(
dias: null == dias ? _self.dias : dias // ignore: cast_nullable_to_non_nullable
as int,mudancas: null == mudancas ? _self.mudancas : mudancas // ignore: cast_nullable_to_non_nullable
as List<MudancaRecenteModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [MudancasRecentesModel].
extension MudancasRecentesModelPatterns on MudancasRecentesModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MudancasRecentesModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MudancasRecentesModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MudancasRecentesModel value)  $default,){
final _that = this;
switch (_that) {
case _MudancasRecentesModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MudancasRecentesModel value)?  $default,){
final _that = this;
switch (_that) {
case _MudancasRecentesModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int dias,  List<MudancaRecenteModel> mudancas)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MudancasRecentesModel() when $default != null:
return $default(_that.dias,_that.mudancas);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int dias,  List<MudancaRecenteModel> mudancas)  $default,) {final _that = this;
switch (_that) {
case _MudancasRecentesModel():
return $default(_that.dias,_that.mudancas);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int dias,  List<MudancaRecenteModel> mudancas)?  $default,) {final _that = this;
switch (_that) {
case _MudancasRecentesModel() when $default != null:
return $default(_that.dias,_that.mudancas);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MudancasRecentesModel extends MudancasRecentesModel {
  const _MudancasRecentesModel({required this.dias, required  List<MudancaRecenteModel> mudancas}): _mudancas = mudancas,super._();
  factory _MudancasRecentesModel.fromJson(Map<String, dynamic> json) => _$MudancasRecentesModelFromJson(json);

@override final  int dias;
 final  List<MudancaRecenteModel> _mudancas;
@override List<MudancaRecenteModel> get mudancas {
  if (_mudancas is EqualUnmodifiableListView) return _mudancas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mudancas);
}


/// Create a copy of MudancasRecentesModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MudancasRecentesModelCopyWith<_MudancasRecentesModel> get copyWith => __$MudancasRecentesModelCopyWithImpl<_MudancasRecentesModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MudancasRecentesModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MudancasRecentesModel&&(identical(other.dias, dias) || other.dias == dias)&&const DeepCollectionEquality().equals(other.mudancas, _mudancas));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,dias,const DeepCollectionEquality().hash(_mudancas));
}

@override
String toString() {
    return 'MudancasRecentesModel(dias: $dias, mudancas: $mudancas)';
}


}

/// @nodoc
abstract mixin class _$MudancasRecentesModelCopyWith<$Res> implements $MudancasRecentesModelCopyWith<$Res> {
  factory _$MudancasRecentesModelCopyWith(_MudancasRecentesModel value, $Res Function(_MudancasRecentesModel) _then) = __$MudancasRecentesModelCopyWithImpl;
@override @useResult
$Res call({
 int dias, List<MudancaRecenteModel> mudancas
});




}
/// @nodoc
class __$MudancasRecentesModelCopyWithImpl<$Res>
    implements _$MudancasRecentesModelCopyWith<$Res> {
  __$MudancasRecentesModelCopyWithImpl(this._self, this._then);

  final _MudancasRecentesModel _self;
  final $Res Function(_MudancasRecentesModel) _then;

/// Create a copy of MudancasRecentesModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dias = null,Object? mudancas = null,}) {
  return _then(_MudancasRecentesModel(
dias: null == dias ? _self.dias : dias // ignore: cast_nullable_to_non_nullable
as int,mudancas: null == mudancas ? _self._mudancas : mudancas // ignore: cast_nullable_to_non_nullable
as List<MudancaRecenteModel>,
  ));
}


}

// dart format on
