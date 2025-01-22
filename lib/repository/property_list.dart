import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/total_bymonth_single_type_unit.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/api_endpoint.dart';
import 'package:mana_mana_app/provider/api_service.dart';
import 'package:mana_mana_app/provider/global_user_state.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class PropertyListRepository {
  final ApiService _apiService = ApiService();

  Future<List<OwnerPropertyList>> getOwnerUnit() async {
    return await _apiService.post(ApiEndpoint.ownerUnit).then((res) {
      List<dynamic> value = res ?? [];
      List<OwnerPropertyList> _ = [];
      for (int i = 0; i < value.length; i++) {
        _.add(OwnerPropertyList.fromJson(value[i], i, _apiService.baseUrl));
      }
      _.sort((a, b) => a.lseqid.compareTo(b.lseqid));
      return _;
    });
  }
  @override
  Future<Uint8List?> downloadPdfStatement(BuildContext context, property, selectedYearValue, selectedMonthValue, selectedType, selectedUnitNo, userData) async {
    final Map<String, dynamic> data = {
      "month": selectedMonthValue,
      "year": selectedYearValue,
      "unitModel": {
        "unitNo": selectedUnitNo,
        "type": selectedType,
        "location": property,
        "ownerName": userData.first.ownerFullName,
        "email": userData.first.ownerEmail
      }
    };

    final res = await _apiService.postWithBytes(ApiEndpoint.downloadPdfStatement, data: data);
    if (res is Uint8List) {
      return res;
    } else if (res == "Incorrect result size") {
      // Show pop-up message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No Record'),
            content: const Text('No record available for this unit in the selected month.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
          );
        },
      );
      return null;
    } else if (res is Map<String, dynamic>) {
      throw Exception('Failed to process PDF data: ${res['error'] ?? 'Unexpected response format'}');
    } else {
      throw Exception('Failed to process PDF data: Unexpected response type ${res.runtimeType}');
    }
  }

  // Future<void> downloadPdfStatement(BuildContext context, property, selectedYearValue, selectedMonthValue, selectedType, selectedUnitNo, userData) async {
  //   // List<User> users = GlobalUserState.instance.getUsers();   
  //   final Map<String, dynamic> data = {
  //     "month": selectedMonthValue,
  //     "year": selectedYearValue,
  //     "unitModel": {
  //       "unitNo": selectedUnitNo,
  //       "type": selectedType,
  //       "location": property,
  //       "ownerName": userData.first.ownerFullName,
  //       "email": userData.first.ownerEmail
  //     }
  //   };
  
  //   final res = await _apiService.postWithBytes(ApiEndpoint.downloadPdfStatement, data: data);
    
  //   if (res is Uint8List) {
  //     final pdfBytes = res;
  //     final tempDir = await getTemporaryDirectory();
  //     final file = File('${tempDir.path}/statement.pdf');
  //     await file.writeAsBytes(pdfBytes);
  //     await OpenFile.open(file.path);
      
      
  //   } else if (res == "Incorrect result size") {
  //     // Show pop-up message
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('No Record'),
  //           content: const Text('No record available for this unit in the selected month.'),
  //           actions: <Widget>[
  //             TextButton(
  //               child: const Text('OK'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //           contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
  //           titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
  //           actionsPadding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
  //         );
  //       },
  //     );
  //   } else if (res is Map<String, dynamic>) {
  //     throw Exception('Failed to process PDF data: ${res['error'] ?? 'Unexpected response format'}');
  //   } else {
  //     throw Exception('Failed to process PDF data: Unexpected response type ${res.runtimeType}');
  //   }
  // }
  
  Future<List<Map<String, dynamic>>> revenueByYear() async {
    return await _apiService.post(ApiEndpoint.dashboardReveueByYear).then((res) {
      if (res is List && res.isNotEmpty) {
        return res.map((item) => {
          'total': item['total'] ?? 0.0,
          'transcode': item['stranscode'] ?? '',
          'year': item['iyear'] ?? 0,
        }).toList();
      }
      return [];
    });
  }

  Future<List<Map<String, dynamic>>> totalByMonth() async {
    return await _apiService.post(ApiEndpoint.dashboardTotalByMonth).then((res) {
      if (res is List && res.isNotEmpty) {
        return res.map((item) => {
          'total': item['total'] ?? 0.0,
          'transcode': item['stranscode'] ?? '',
          'year': item['iyear'] ?? 0,
          'month': item['imonth'] ?? 0,
        }).toList()
          ..sort((a, b) {
            int yearComparison = a['year'].compareTo(b['year']);
            if (yearComparison != 0) {
              return yearComparison;
            }
            return a['month'].compareTo(b['month']);
          });
      }
      return [];
    });
  }

  Future<List<Map<String, dynamic>>> locationByMonth() async {
    return await _apiService.post(ApiEndpoint.locationByMonth).then((res) {
      if (res is List && res.isNotEmpty) {
        return res.map((item) => {
          'total': item['total'] ?? 0.0,
          'year': item['iyear'] ?? 0,
          'month': item['imonth'] ?? 0,
          'location': item['slocation'] ?? '',
        }).toList();
      }
      return [];
    });
  }

  Future<List<SingleUnitByMonth>> getUnitByMonth() async {
    return await _apiService.post(ApiEndpoint.getUnitByMonth).then((res) {
      List<dynamic> value = res ?? [];
      List<SingleUnitByMonth> _ = [];
      for (int i = 0; i < value.length; i++) {
        _.add(SingleUnitByMonth.fromJson(value[i], i, _apiService.baseUrl));
      }
      return _;
    });
  }
}

