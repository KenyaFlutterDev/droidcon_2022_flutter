import 'dart:io';

import 'package:dio/dio.dart';
import 'package:droidcon_app/providers/token_provider/token_provider.dart';
import 'package:get_it/get_it.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    TokenProvider tokenProvider = GetIt.I.get<TokenProvider>();
    String token = tokenProvider.state;

    /// Add the bearer token header to all requests if the token is not null
    if (token.isNotEmpty) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    handler.next(options);
  }
}