import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

/// União selada para o resultado de qualquer chamada falível (GPS,
/// geocodificação, leitura de asset, chamada de API) — nunca um `try/catch`
/// genérico na UI (constraint não-negociável do projeto).
@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.loading() = Loading<T>;
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Exception erro) = Failure<T>;
}
