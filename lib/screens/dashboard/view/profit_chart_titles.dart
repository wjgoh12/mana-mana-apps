import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineTitles {
  static getTitleData() => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            getTitlesWidget: (value, meta) {
              final style = const TextStyle(
                color: Color(0xff68737d),
                fontWeight: FontWeight.bold,
                fontSize: AppDimens.fontSizeBig,
              );
              String text;
              switch (value.toInt()) {
                case 2:
                  text = 'MAR';
                  break;
                case 5:
                  text = 'JUN';
                  break;
                case 8:
                  text = 'SEP';
                  break;
                default:
                  text = '';
                  break;
              }
              return Text(text, style: style);
            },
            interval: 8,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            getTitlesWidget: (value, meta) {
              final style = const TextStyle(
                color: Color(0xff67727d),
                fontWeight: FontWeight.bold,
                fontSize: AppDimens.fontSizeBig,
              );
              String text;
              switch (value.toInt()) {
                case 1:
                  text = '10k';
                  break;
                case 3:
                  text = '30k';
                  break;
                case 5:
                  text = '50k';
                  break;
                default:
                  text = '';
                  break;
              }
              return Text(text, style: style);
            },
            interval: 12,
          ),
        ),
      );
}
