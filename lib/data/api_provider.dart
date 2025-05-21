import 'package:burningbros_test/models/product_response.dart';
import 'package:burningbros_test/utils/constants.dart';
import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';

class ApiProvider {
  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl))
    ..interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: false));

  Future<ProductResponse> fetchProducts({
    int limit = defaultLimit,
    int skip = 0,
    String searchText = "",
  }) async {
    final response = await _dio.get(
      '/products/search',
      queryParameters: {'q': searchText, 'limit': limit, 'skip': skip},
    );
    return ProductResponse.fromJson(response.data);
  }
}
