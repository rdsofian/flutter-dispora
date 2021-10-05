import 'dart:convert';

import 'package:dispora/configs/app.config.dart';
import 'package:dispora/models/dashboard.model.dart';
import 'package:http/http.dart' as http;

class DesaApi {
  static Future<List<DashboardModel>> getDesaSugestion(String query) async {
      AppConfig config = AppConfig();
      final url = Uri.parse("${config.apiURL}/get-dashboard");
      final response = await http.get(url);

      if(response.statusCode == 200) {
        final List desa = json.decode(response.body);
        return desa.map((json) => DashboardModel.fromJson(json)).where((desa){
          final nameLower = desa.namaDesa.toLowerCase();
          final queryLower = query.toLowerCase();

          return nameLower.contains(queryLower);
        }).toList();
      } else {
        throw Exception();
      }
  }
}