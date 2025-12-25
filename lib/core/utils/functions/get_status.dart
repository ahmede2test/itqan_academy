import 'package:dio/dio.dart';
import 'package:itqan_academy/core/utils/api_service.dart';

import '../cash_helper.dart';

Future<bool> getStatus() async {
  try {
    Dio dio = Dio();
    var response = await dio.get('http://status0-1.runasp.net/api/Status');
    return response.data;
  } catch (e) {
    return false;
  }
}
Future<bool> tryCourses() async {
  try {
    ApiService apiService = ApiService();
    await apiService.get(
      endPoint: 'custom-api/v1/user-courses',
      token: '${CashHelper.getData('token')}',
    );
    return true;
  } catch (e) {
    return false;
  }
}
