import 'package:dio/dio.dart';
import 'dio_exception.dart';

class DioUtil {
  static Dio? _instance;

//method for getting dio instance
  static Dio getInstance() {
    _instance ??= createDioInstance();
    return _instance!;
  }

  static Dio createDioInstance() {
    var dio = Dio();
    // adding interceptor
    dio.interceptors.clear();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      return handler.next(options); //modify your request
    }, onResponse: (response, handler) {
      if (response != null) {
        //on success it is getting called here
        return handler.next(response);
      } else {
        return;
      }
    }, onError: (DioError e, handler) async {
      final errorMessage = DioException.fromDioError(e).toString();
      throw errorMessage;
    }));
    return dio;
  }
}
