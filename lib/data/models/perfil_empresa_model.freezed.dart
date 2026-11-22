// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'perfil_empresa_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PerfilEmpresaModel {

 int get id; String? get tipo;@JsonKey(name: 'razao_social_ou_nome') String get nome; String? get creci; String? get telefone; String? get whatsapp; String? get email; String? get descricao; String? get logomarca;@JsonKey(name: 'cidades_atuacao') List<CidadeModel> get cidadesAtuacao;
/// Create a copy of PerfilEmpresaModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerfilEmpresaModelCopyWith<PerfilEmpresaModel> get copyWith => _$PerfilEmpresaModelCopyWithImpl<PerfilEmpresaModel>(this as PerfilEmpresaModel, _$identity);

  /// Serializes this PerfilEmpresaModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PerfilEmpresaModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PerfilEmpresaModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.tipo, _this.tipo) || other.tipo == _this.tipo)&&(identical(other.nome, _this.nome) || other.nome == _this.nome)&&(identical(other.creci, _this.creci) || other.creci == _this.creci)&&(identical(other.telefone, _this.telefone) || other.telefone == _this.telefone)&&(identical(other.whatsapp, _this.whatsapp) || other.whatsapp == _this.whatsapp)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.descricao, _this.descricao) || other.descricao == _this.descricao)&&(identical(other.logomarca, _this.logomarca) || other.logomarca == _this.logomarca)&&const DeepCollectionEquality().equals(other.cidadesAtuacao, _this.cidadesAtuacao));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PerfilEmpresaModel;
  return Object.hash(runtimeType,_this.id,_this.tipo,_this.nome,_this.creci,_this.telefone,_this.whatsapp,_this.email,_this.descricao,_this.logomarca,const DeepCollectionEquality().hash(_this.cidadesAtuacao));
}

@override
String toString() {
  final _this = this as PerfilEmpresaModel;
  return 'PerfilEmpresaModel(id: ${_this.id}, tipo: ${_this.tipo}, nome: ${_this.nome}, creci: ${_this.creci}, telefone: ${_this.telefone}, whatsapp: ${_this.whatsapp}, email: ${_this.email}, descricao: ${_this.descricao}, logomarca: ${_this.logomarca}, cidadesAtuacao: ${_this.cidadesAtuacao})';
}


}

/// @nodoc
abstract mixin class $PerfilEmpresaModelCopyWith<$Res>  {
  factory $PerfilEmpresaModelCopyWith(PerfilEmpresaModel value, $Res Function(PerfilEmpresaModel) _then) = _$PerfilEmpresaModelCopyWithImpl;
@useResult
$Res call({
 int id, String? tipo,@JsonKey(name: 'razao_social_ou_nome') String nome, String? creci, String? telefone, String? whatsapp, String? email, String? descricao, String? logomarca,@JsonKey(name: 'cidades_atuacao') List<CidadeModel> cidadesAtuacao
});




}
/// @nodoc
class _$PerfilEmpresaModelCopyWithImpl<$Res>
    implements $PerfilEmpresaModelCopyWith<$Res> {
  _$PerfilEmpresaModelCopyWithImpl(this._self, this._then);

  final PerfilEmpresaModel _self;
  final $Res Function(PerfilEmpresaModel) _then;

/// Create a copy of PerfilEmpresaModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tipo = freezed,Object? nome = null,Object? creci = freezed,Object? telefone = freezed,Object? whatsapp = freezed,Object? email = freezed,Object? descricao = freezed,Object? logomarca = freezed,Object? cidadesAtuacao = null,}) {
  return _then(PerfilEmpresaModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,tipo: freezed == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as String?,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,creci: freezed == creci ? _self.creci : creci // ignore: cast_nullable_to_non_nullable
as String?,telefone: freezed == telefone ? _self.telefone : telefone // ignore: cast_nullable_to_non_nullable
as String?,whatsapp: freezed == whatsapp ? _self.whatsapp : whatsapp // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,descricao: freezed == descricao ? _self.descricao : descricao // ignore: cast_nullable_to_non_nullable
as String?,logomarca: freezed == logomarca ? _self.logomarca : logomarca // ignore: cast_nullable_to_non_nullable
as String?,cidadesAtuacao: null == cidadesAtuacao ? _self.cidadesAtuacao : cidadesAtuacao // ignore: cast_nullable_to_non_nullable
as List<CidadeModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [PerfilEmpresaModel].
extension PerfilEmpresaModelPatterns on PerfilEmpresaModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PerfilEmpresaModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PerfilEmpresaModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PerfilEmpresaModel value)  $default,){
final _that = this;
switch (_that) {
case _PerfilEmpresaModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PerfilEmpresaModel value)?  $default,){
final _that = this;
switch (_that) {
case _PerfilEmpresaModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? tipo, @JsonKey(name: 'razao_social_ou_nome')  String nome,  String? creci,  String? telefone,  String? whatsapp,  String? email,  String? descricao,  String? logomarca, @JsonKey(name: 'cidades_atuacao')  List<CidadeModel> cidadesAtuacao)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PerfilEmpresaModel() when $default != null:
return $default(_that.id,_that.tipo,_that.nome,_that.creci,_that.telefone,_that.whatsapp,_that.email,_that.descricao,_that.logomarca,_that.cidadesAtuacao);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? tipo, @JsonKey(name: 'razao_social_ou_nome')  String nome,  String? creci,  String? telefone,  String? whatsapp,  String? email,  String? descricao,  String? logomarca, @JsonKey(name: 'cidades_atuacao')  List<CidadeModel> cidadesAtuacao)  $default,) {final _that = this;
switch (_that) {
case _PerfilEmpresaModel():
return $default(_that.id,_that.tipo,_that.nome,_that.creci,_that.telefone,_that.whatsapp,_that.email,_that.descricao,_that.logomarca,_that.cidadesAtuacao);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? tipo, @JsonKey(name: 'razao_social_ou_nome')  String nome,  String? creci,  String? telefone,  String? whatsapp,  String? email,  String? descricao,  String? logomarca, @JsonKey(name: 'cidades_atuacao')  List<CidadeModel> cidadesAtuacao)?  $default,) {final _that = this;
switch (_that) {
case _PerfilEmpresaModel() when $default != null:
return $default(_that.id,_that.tipo,_that.nome,_that.creci,_that.telefone,_that.whatsapp,_that.email,_that.descricao,_that.logomarca,_that.cidadesAtuacao);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PerfilEmpresaModel extends PerfilEmpresaModel {
  const _PerfilEmpresaModel({required this.id, this.tipo, @JsonKey(name: 'razao_social_ou_nome') required this.nome, this.creci, this.telefone, this.whatsapp, this.email, this.descricao, this.logomarca, @JsonKey(name: 'cidades_atuacao')  List<CidadeModel> cidadesAtuacao = const <CidadeModel>[]}): _cidadesAtuacao = cidadesAtuacao,super._();
  factory _PerfilEmpresaModel.fromJson(Map<String, dynamic> json) => _$PerfilEmpresaModelFromJson(json);

@override final  int id;
@override final  String? tipo;
@override@JsonKey(name: 'razao_social_ou_nome') final  String nome;
@override final  String? creci;
@override final  String? telefone;
@override final  String? whatsapp;
@override final  String? email;
@override final  String? descricao;
@override final  String? logomarca;
 final  List<CidadeModel> _cidadesAtuacao;
@override@JsonKey(name: 'cidades_atuacao') List<CidadeModel> get cidadesAtuacao {
  if (_cidadesAtuacao is EqualUnmodifiableListView) return _cidadesAtuacao;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cidadesAtuacao);
}


/// Create a copy of PerfilEmpresaModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PerfilEmpresaModelCopyWith<_PerfilEmpresaModel> get copyWith => __$PerfilEmpresaModelCopyWithImpl<_PerfilEmpresaModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PerfilEmpresaModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PerfilEmpresaModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.creci, creci) || other.creci == creci)&&(identical(other.telefone, telefone) || other.telefone == telefone)&&(identical(other.whatsapp, whatsapp) || other.whatsapp == whatsapp)&&(identical(other.email, email) || other.email == email)&&(identical(other.descricao, descricao) || other.descricao == descricao)&&(identical(other.logomarca, logomarca) || other.logomarca == logomarca)&&const DeepCollectionEquality().equals(other.cidadesAtuacao, _cidadesAtuacao));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,tipo,nome,creci,telefone,whatsapp,email,descricao,logomarca,const DeepCollectionEquality().hash(_cidadesAtuacao));
}

@override
String toString() {
    return 'PerfilEmpresaModel(id: $id, tipo: $tipo, nome: $nome, creci: $creci, telefone: $telefone, whatsapp: $whatsapp, email: $email, descricao: $descricao, logomarca: $logomarca, cidadesAtuacao: $cidadesAtuacao)';
}


}

/// @nodoc
abstract mixin class _$PerfilEmpresaModelCopyWith<$Res> implements $PerfilEmpresaModelCopyWith<$Res> {
  factory _$PerfilEmpresaModelCopyWith(_PerfilEmpresaModel value, $Res Function(_PerfilEmpresaModel) _then) = __$PerfilEmpresaModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String? tipo,@JsonKey(name: 'razao_social_ou_nome') String nome, String? creci, String? telefone, String? whatsapp, String? email, String? descricao, String? logomarca,@JsonKey(name: 'cidades_atuacao') List<CidadeModel> cidadesAtuacao
});




}
/// @nodoc
class __$PerfilEmpresaModelCopyWithImpl<$Res>
    implements _$PerfilEmpresaModelCopyWith<$Res> {
  __$PerfilEmpresaModelCopyWithImpl(this._self, this._then);

  final _PerfilEmpresaModel _self;
  final $Res Function(_PerfilEmpresaModel) _then;

/// Create a copy of PerfilEmpresaModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tipo = freezed,Object? nome = null,Object? creci = freezed,Object? telefone = freezed,Object? whatsapp = freezed,Object? email = freezed,Object? descricao = freezed,Object? logomarca = freezed,Object? cidadesAtuacao = null,}) {
  return _then(_PerfilEmpresaModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,tipo: freezed == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as String?,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,creci: freezed == creci ? _self.creci : creci // ignore: cast_nullable_to_non_nullable
as String?,telefone: freezed == telefone ? _self.telefone : telefone // ignore: cast_nullable_to_non_nullable
as String?,whatsapp: freezed == whatsapp ? _self.whatsapp : whatsapp // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,descricao: freezed == descricao ? _self.descricao : descricao // ignore: cast_nullable_to_non_nullable
as String?,logomarca: freezed == logomarca ? _self.logomarca : logomarca // ignore: cast_nullable_to_non_nullable
as String?,cidadesAtuacao: null == cidadesAtuacao ? _self._cidadesAtuacao : cidadesAtuacao // ignore: cast_nullable_to_non_nullable
as List<CidadeModel>,
  ));
}


}

// dart format on
