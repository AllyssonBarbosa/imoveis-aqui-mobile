// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'perfil_corretor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PerfilCorretor {

 int get id;/// Empresa à qual o corretor pertence; `null` quando o servidor não manda.
 int? get empresaId; String? get foto; String get nome; String? get email; String? get creci; String? get telefone; String? get whatsapp; String? get apresentacao;
/// Create a copy of PerfilCorretor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerfilCorretorCopyWith<PerfilCorretor> get copyWith => _$PerfilCorretorCopyWithImpl<PerfilCorretor>(this as PerfilCorretor, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PerfilCorretor;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PerfilCorretor&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.empresaId, _this.empresaId) || other.empresaId == _this.empresaId)&&(identical(other.foto, _this.foto) || other.foto == _this.foto)&&(identical(other.nome, _this.nome) || other.nome == _this.nome)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.creci, _this.creci) || other.creci == _this.creci)&&(identical(other.telefone, _this.telefone) || other.telefone == _this.telefone)&&(identical(other.whatsapp, _this.whatsapp) || other.whatsapp == _this.whatsapp)&&(identical(other.apresentacao, _this.apresentacao) || other.apresentacao == _this.apresentacao));
}


@override
int get hashCode {
  final _this = this as PerfilCorretor;
  return Object.hash(runtimeType,_this.id,_this.empresaId,_this.foto,_this.nome,_this.email,_this.creci,_this.telefone,_this.whatsapp,_this.apresentacao);
}

@override
String toString() {
  final _this = this as PerfilCorretor;
  return 'PerfilCorretor(id: ${_this.id}, empresaId: ${_this.empresaId}, foto: ${_this.foto}, nome: ${_this.nome}, email: ${_this.email}, creci: ${_this.creci}, telefone: ${_this.telefone}, whatsapp: ${_this.whatsapp}, apresentacao: ${_this.apresentacao})';
}


}

/// @nodoc
abstract mixin class $PerfilCorretorCopyWith<$Res>  {
  factory $PerfilCorretorCopyWith(PerfilCorretor value, $Res Function(PerfilCorretor) _then) = _$PerfilCorretorCopyWithImpl;
@useResult
$Res call({
 int id, int? empresaId, String? foto, String nome, String? email, String? creci, String? telefone, String? whatsapp, String? apresentacao
});




}
/// @nodoc
class _$PerfilCorretorCopyWithImpl<$Res>
    implements $PerfilCorretorCopyWith<$Res> {
  _$PerfilCorretorCopyWithImpl(this._self, this._then);

  final PerfilCorretor _self;
  final $Res Function(PerfilCorretor) _then;

/// Create a copy of PerfilCorretor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? empresaId = freezed,Object? foto = freezed,Object? nome = null,Object? email = freezed,Object? creci = freezed,Object? telefone = freezed,Object? whatsapp = freezed,Object? apresentacao = freezed,}) {
  return _then(PerfilCorretor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,empresaId: freezed == empresaId ? _self.empresaId : empresaId // ignore: cast_nullable_to_non_nullable
as int?,foto: freezed == foto ? _self.foto : foto // ignore: cast_nullable_to_non_nullable
as String?,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,creci: freezed == creci ? _self.creci : creci // ignore: cast_nullable_to_non_nullable
as String?,telefone: freezed == telefone ? _self.telefone : telefone // ignore: cast_nullable_to_non_nullable
as String?,whatsapp: freezed == whatsapp ? _self.whatsapp : whatsapp // ignore: cast_nullable_to_non_nullable
as String?,apresentacao: freezed == apresentacao ? _self.apresentacao : apresentacao // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PerfilCorretor].
extension PerfilCorretorPatterns on PerfilCorretor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PerfilCorretor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PerfilCorretor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PerfilCorretor value)  $default,){
final _that = this;
switch (_that) {
case _PerfilCorretor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PerfilCorretor value)?  $default,){
final _that = this;
switch (_that) {
case _PerfilCorretor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? empresaId,  String? foto,  String nome,  String? email,  String? creci,  String? telefone,  String? whatsapp,  String? apresentacao)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PerfilCorretor() when $default != null:
return $default(_that.id,_that.empresaId,_that.foto,_that.nome,_that.email,_that.creci,_that.telefone,_that.whatsapp,_that.apresentacao);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? empresaId,  String? foto,  String nome,  String? email,  String? creci,  String? telefone,  String? whatsapp,  String? apresentacao)  $default,) {final _that = this;
switch (_that) {
case _PerfilCorretor():
return $default(_that.id,_that.empresaId,_that.foto,_that.nome,_that.email,_that.creci,_that.telefone,_that.whatsapp,_that.apresentacao);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? empresaId,  String? foto,  String nome,  String? email,  String? creci,  String? telefone,  String? whatsapp,  String? apresentacao)?  $default,) {final _that = this;
switch (_that) {
case _PerfilCorretor() when $default != null:
return $default(_that.id,_that.empresaId,_that.foto,_that.nome,_that.email,_that.creci,_that.telefone,_that.whatsapp,_that.apresentacao);case _:
  return null;

}
}

}

/// @nodoc


class _PerfilCorretor implements PerfilCorretor {
  const _PerfilCorretor({required this.id, this.empresaId, this.foto, required this.nome, this.email, this.creci, this.telefone, this.whatsapp, this.apresentacao});
  

@override final  int id;
/// Empresa à qual o corretor pertence; `null` quando o servidor não manda.
@override final  int? empresaId;
@override final  String? foto;
@override final  String nome;
@override final  String? email;
@override final  String? creci;
@override final  String? telefone;
@override final  String? whatsapp;
@override final  String? apresentacao;

/// Create a copy of PerfilCorretor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PerfilCorretorCopyWith<_PerfilCorretor> get copyWith => __$PerfilCorretorCopyWithImpl<_PerfilCorretor>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PerfilCorretor&&(identical(other.id, id) || other.id == id)&&(identical(other.empresaId, empresaId) || other.empresaId == empresaId)&&(identical(other.foto, foto) || other.foto == foto)&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.email, email) || other.email == email)&&(identical(other.creci, creci) || other.creci == creci)&&(identical(other.telefone, telefone) || other.telefone == telefone)&&(identical(other.whatsapp, whatsapp) || other.whatsapp == whatsapp)&&(identical(other.apresentacao, apresentacao) || other.apresentacao == apresentacao));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,empresaId,foto,nome,email,creci,telefone,whatsapp,apresentacao);
}

@override
String toString() {
    return 'PerfilCorretor(id: $id, empresaId: $empresaId, foto: $foto, nome: $nome, email: $email, creci: $creci, telefone: $telefone, whatsapp: $whatsapp, apresentacao: $apresentacao)';
}


}

/// @nodoc
abstract mixin class _$PerfilCorretorCopyWith<$Res> implements $PerfilCorretorCopyWith<$Res> {
  factory _$PerfilCorretorCopyWith(_PerfilCorretor value, $Res Function(_PerfilCorretor) _then) = __$PerfilCorretorCopyWithImpl;
@override @useResult
$Res call({
 int id, int? empresaId, String? foto, String nome, String? email, String? creci, String? telefone, String? whatsapp, String? apresentacao
});




}
/// @nodoc
class __$PerfilCorretorCopyWithImpl<$Res>
    implements _$PerfilCorretorCopyWith<$Res> {
  __$PerfilCorretorCopyWithImpl(this._self, this._then);

  final _PerfilCorretor _self;
  final $Res Function(_PerfilCorretor) _then;

/// Create a copy of PerfilCorretor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? empresaId = freezed,Object? foto = freezed,Object? nome = null,Object? email = freezed,Object? creci = freezed,Object? telefone = freezed,Object? whatsapp = freezed,Object? apresentacao = freezed,}) {
  return _then(_PerfilCorretor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,empresaId: freezed == empresaId ? _self.empresaId : empresaId // ignore: cast_nullable_to_non_nullable
as int?,foto: freezed == foto ? _self.foto : foto // ignore: cast_nullable_to_non_nullable
as String?,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,creci: freezed == creci ? _self.creci : creci // ignore: cast_nullable_to_non_nullable
as String?,telefone: freezed == telefone ? _self.telefone : telefone // ignore: cast_nullable_to_non_nullable
as String?,whatsapp: freezed == whatsapp ? _self.whatsapp : whatsapp // ignore: cast_nullable_to_non_nullable
as String?,apresentacao: freezed == apresentacao ? _self.apresentacao : apresentacao // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
