import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/financial_statement_service.dart';

/// 재무제표 차트 위젯들
class FinancialCharts {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'ko_KR',
    symbol: '₩',
    decimalDigits: 0,
  );

  /// 매출액 추이 차트
  static Widget buildRevenueChart(List<FinancialStatement> statements) {
    final revenueData = statements
        .where((s) => s.accountNm.contains('매출액') || s.accountNm.contains('매출'))
        .toList();

    if (revenueData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('매출액 데이터가 없습니다.'),
        ),
      );
    }

    final spots = <FlSpot>[];
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < revenueData.length; i++) {
      final statement = revenueData[i];
      final amount = statement.thstrmAmountAsDouble ?? 0;
      
      if (amount > 0) {
        spots.add(FlSpot(i.toDouble(), amount));
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: amount,
                color: Colors.blue,
                width: 20,
              ),
            ],
          ),
        );
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '매출액 추이',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: spots.isNotEmpty ? spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2 : 1000,
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < revenueData.length) {
                            final statement = revenueData[value.toInt()];
                            return Text(
                              statement.bsnsYear,
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatCurrency(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 자산/부채 비교 차트
  static Widget buildBalanceSheetChart(List<FinancialStatement> statements) {
    final assets = statements
        .where((s) => s.accountNm.contains('자산총계') || s.accountNm.contains('총자산'))
        .toList();
    
    final liabilities = statements
        .where((s) => s.accountNm.contains('부채총계') || s.accountNm.contains('총부채'))
        .toList();

    if (assets.isEmpty && liabilities.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('재무상태표 데이터가 없습니다.'),
        ),
      );
    }

    final assetSpots = <FlSpot>[];
    final liabilitySpots = <FlSpot>[];

    for (int i = 0; i < assets.length; i++) {
      final asset = assets[i];
      final amount = asset.thstrmAmountAsDouble ?? 0;
      if (amount > 0) {
        assetSpots.add(FlSpot(i.toDouble(), amount));
      }
    }

    for (int i = 0; i < liabilities.length; i++) {
      final liability = liabilities[i];
      final amount = liability.thstrmAmountAsDouble ?? 0;
      if (amount > 0) {
        liabilitySpots.add(FlSpot(i.toDouble(), amount));
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '자산/부채 비교',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < assets.length) {
                            final statement = assets[value.toInt()];
                            return Text(
                              statement.bsnsYear,
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatCurrency(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    if (assetSpots.isNotEmpty)
                      LineChartBarData(
                        spots: assetSpots,
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                      ),
                    if (liabilitySpots.isNotEmpty)
                      LineChartBarData(
                        spots: liabilitySpots,
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                const Text('자산'),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 12,
                  color: Colors.red,
                ),
                const SizedBox(width: 4),
                const Text('부채'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 수익성 지표 차트
  static Widget buildProfitabilityChart(List<FinancialStatement> statements) {
    final netIncome = statements
        .where((s) => s.accountNm.contains('당기순이익') || s.accountNm.contains('순이익'))
        .toList();

    final operatingIncome = statements
        .where((s) => s.accountNm.contains('영업이익'))
        .toList();

    if (netIncome.isEmpty && operatingIncome.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('수익성 지표 데이터가 없습니다.'),
        ),
      );
    }

    final netIncomeSpots = <FlSpot>[];
    final operatingIncomeSpots = <FlSpot>[];

    for (int i = 0; i < netIncome.length; i++) {
      final income = netIncome[i];
      final amount = income.thstrmAmountAsDouble ?? 0;
      if (amount != 0) {
        netIncomeSpots.add(FlSpot(i.toDouble(), amount));
      }
    }

    for (int i = 0; i < operatingIncome.length; i++) {
      final income = operatingIncome[i];
      final amount = income.thstrmAmountAsDouble ?? 0;
      if (amount != 0) {
        operatingIncomeSpots.add(FlSpot(i.toDouble(), amount));
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '수익성 지표',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final data = netIncome.isNotEmpty ? netIncome : operatingIncome;
                          if (value.toInt() < data.length) {
                            final statement = data[value.toInt()];
                            return Text(
                              statement.bsnsYear,
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatCurrency(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    if (netIncomeSpots.isNotEmpty)
                      LineChartBarData(
                        spots: netIncomeSpots,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                      ),
                    if (operatingIncomeSpots.isNotEmpty)
                      LineChartBarData(
                        spots: operatingIncomeSpots,
                        isCurved: true,
                        color: Colors.orange,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                const Text('당기순이익'),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 12,
                  color: Colors.orange,
                ),
                const SizedBox(width: 4),
                const Text('영업이익'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 재무제표 요약 테이블
  static Widget buildSummaryTable(List<FinancialStatement> statements) {
    final groupedData = <String, List<FinancialStatement>>{};
    
    for (final statement in statements) {
      final key = statement.accountNm;
      if (!groupedData.containsKey(key)) {
        groupedData[key] = [];
      }
      groupedData[key]!.add(statement);
    }

    final importantAccounts = [
      '매출액',
      '영업이익',
      '당기순이익',
      '자산총계',
      '부채총계',
      '자본총계',
    ];

    final filteredData = <String, List<FinancialStatement>>{};
    for (final account in importantAccounts) {
      for (final key in groupedData.keys) {
        if (key.contains(account)) {
          filteredData[key] = groupedData[key]!;
          break;
        }
      }
    }

    if (filteredData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('재무제표 요약 데이터가 없습니다.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '재무제표 요약',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('계정과목')),
                  DataColumn(label: Text('당기')),
                  DataColumn(label: Text('전기')),
                ],
                rows: filteredData.entries.map((entry) {
                  final statements = entry.value;
                  final latest = statements.isNotEmpty ? statements.first : null;
                  final previous = statements.length > 1 ? statements[1] : null;

                  return DataRow(
                    cells: [
                      DataCell(Text(entry.key)),
                      DataCell(Text(latest?.thstrmAmount ?? '-')),
                      DataCell(Text(previous?.thstrmAmount ?? '-')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 통화 포맷팅 헬퍼 함수
  static String _formatCurrency(double value) {
    if (value >= 1e12) {
      return '${(value / 1e12).toStringAsFixed(1)}조';
    } else if (value >= 1e8) {
      return '${(value / 1e8).toStringAsFixed(1)}억';
    } else if (value >= 1e4) {
      return '${(value / 1e4).toStringAsFixed(1)}만';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}
