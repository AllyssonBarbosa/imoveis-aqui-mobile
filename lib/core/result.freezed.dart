// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Result<T> {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Result<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Result<$T>()';
}


}

/// @nodoc
class $ResultCopyWith<T,$Res>  {
$ResultCopyWith(Result<T> _, $Res Function(Result<T>) __);
}


/// Adds pattern-matching-related methods to [Result].
extension ResultPatterns<T> on Result<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Loading<T> value)?  loading,TResult Function( Success<T> value)?  success,TResult Function( Failure<T> value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Loading() when loading != null:
return loading(_that);case Success() when success != null:
return success(_that);case Failure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Loading<T> value)  loading,required TResult Function( Success<T> value)  success,required TResult Function( Failure<T> value)  failure,}){
final _that = this;
switch (_that) {
case Loading():
return loading(_that);case Success():
return success(_that);case Failure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Loading<T> value)?  loading,TResult? Function( Success<T> value)?  success,TResult? Function( Failure<T> value)?  failure,}){
final _that = this;
switch (_that) {
case Loading() when loading != null:
return loading(_that);case Success() when success != null:
return success(_that);case Failure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( T data)?  success,TResult Function( Exception erro)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Loading() when loading != null:
return loading();case Success() when success != null:
return success(_that.data);case Failure() when failure != null:
return failure(_that.erro);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( T data)  success,required TResult Function( Exception erro)  failure,}) {final _that = this;
switch (_that) {
case Loading():
return loading();case Success():
return success(_that.data);case Failure():
return failure(_that.erro);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( T data)?  success,TResult? Function( Exception erro)?  failure,}) {final _that = this;
switch (_that) {
case Loading() when loading != null:
return loading();case Success() when success != null:
return success(_that.data);case Failure() when failure != null:
return failure(_that.erro);case _:
  return null;

}
}

}

/// @nodoc


class Loading<T> implements Result<T> {
  const Loading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Loading<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Result<$T>.loading()';
}


}




/// @nodoc


class Success<T> implements Result<T> {
  const Success(this.data);
  

 final  T data;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuccessCopyWith<T, Success<T>> get copyWith => _$SuccessCopyWithImpl<T, Success<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Success<T>&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(data));
}

@override
String toString() {
    return 'Result<$T>.success(data: $data)';
}


}

/// @nodoc
abstract mixin class $SuccessCopyWith<T,$Res> implements $ResultCopyWith<T, $Res> {
  factory $SuccessCopyWith(Success<T> value, $Res Function(Success<T>) _then) = _$SuccessCopyWithImpl;
@useResult
$Res call({
 T data
});




}
/// @nodoc
class _$SuccessCopyWithImpl<T,$Res>
    implements $SuccessCopyWith<T, $Res> {
  _$SuccessCopyWithImpl(this._self, this._then);

  final Success<T> _self;
  final $Res Function(Success<T>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(Success<T>(
freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class Failure<T> implements Result<T> {
  const Failure(this.erro);
  

 final  Exception erro;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FailureCopyWith<T, Failure<T>> get copyWith => _$FailureCopyWithImpl<T, Failure<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Failure<T>&&(identical(other.erro, erro) || other.erro == erro));
}


@override
int get hashCode {
    return Object.hash(runtimeType,erro);
}

@override
String toString() {
    return 'Result<$T>.failure(erro: $erro)';
}


}

/// @nodoc
abstract mixin class $FailureCopyWith<T,$Res> implements $ResultCopyWith<T, $Res> {
  factory $FailureCopyWith(Failure<T> value, $Res Function(Failure<T>) _then) = _$FailureCopyWithImpl;
@useResult
$Res call({
 Exception erro
});




}
/// @nodoc
class _$FailureCopyWithImpl<T,$Res>
    implements $FailureCopyWith<T, $Res> {
  _$FailureCopyWithImpl(this._self, this._then);

  final Failure<T> _self;
  final $Res Function(Failure<T>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? erro = null,}) {
  return _then(Failure<T>(
null == erro ? _self.erro : erro // ignore: cast_nullable_to_non_nullable
as Exception,
  ));
}


}

// dart format on
