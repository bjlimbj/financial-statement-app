import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

/// 재무제표 응답 모델
class FinancialStatementResponse {
  final String status;
  final String message;
  final List<FinancialStatement> list;

  FinancialStatementResponse({
    required this.status,
    required this.message,
    required this.list,
  });

  factory FinancialStatementResponse.fromJson(Map<String, dynamic> json) {
    return FinancialStatementResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      list: (json['list'] as List<dynamic>?)
          ?.map((item) => FinancialStatement.fromJson(item))
          .toList() ?? [],
    );
  }
}

/// 재무제표 모델
class FinancialStatement {
  final String rceptNo;           // 접수번호
  final String reprtCode;         // 보고서코드
  final String bsnsYear;          // 사업연도
  final String stockCode;         // 종목코드
  final String reprtCodeNm;       // 보고서명
  final String fsDiv;             // 개별/연결구분
  final String fsNm;              // 재무제표명
  final String sjDiv;             // 재무제표구분
  final String sjNm;              // 재무제표명
  final String accountId;         // 계정과목코드
  final String accountNm;         // 계정과목명
  final String accountDetail;     // 계정과목상세
  final String thstrmNm;          // 당기명
  final String thstrmAmount;      // 당기금액
  final String thstrmAddAmount;   // 당기누적금액
  final String frmtrmNm;          // 전기명
  final String frmtrmAmount;      // 전기금액
  final String frmtrmAddAmount;   // 전기누적금액
  final String bfefrmtrmNm;       // 전전기명
  final String bfefrmtrmAmount;   // 전전기금액
  final String ord;               // 정렬순서

  FinancialStatement({
    required this.rceptNo,
    required this.reprtCode,
    required this.bsnsYear,
    required this.stockCode,
    required this.reprtCodeNm,
    required this.fsDiv,
    required this.fsNm,
    required this.sjDiv,
    required this.sjNm,
    required this.accountId,
    required this.accountNm,
    required this.accountDetail,
    required this.thstrmNm,
    required this.thstrmAmount,
    required this.thstrmAddAmount,
    required this.frmtrmNm,
    required this.frmtrmAmount,
    required this.frmtrmAddAmount,
    required this.bfefrmtrmNm,
    required this.bfefrmtrmAmount,
    required this.ord,
  });

  factory FinancialStatement.fromJson(Map<String, dynamic> json) {
    return FinancialStatement(
      rceptNo: json['rcept_no'] ?? '',
      reprtCode: json['reprt_code'] ?? '',
      bsnsYear: json['bsns_year'] ?? '',
      stockCode: json['stock_code'] ?? '',
      reprtCodeNm: json['reprt_code_nm'] ?? '',
      fsDiv: json['fs_div'] ?? '',
      fsNm: json['fs_nm'] ?? '',
      sjDiv: json['sj_div'] ?? '',
      sjNm: json['sj_nm'] ?? '',
      accountId: json['account_id'] ?? '',
      accountNm: json['account_nm'] ?? '',
      accountDetail: json['account_detail'] ?? '',
      thstrmNm: json['thstrm_nm'] ?? '',
      thstrmAmount: json['thstrm_amount'] ?? '',
      thstrmAddAmount: json['thstrm_add_amount'] ?? '',
      frmtrmNm: json['frmtrm_nm'] ?? '',
      frmtrmAmount: json['frmtrm_amount'] ?? '',
      frmtrmAddAmount: json['frmtrm_add_amount'] ?? '',
      bfefrmtrmNm: json['bfefrmtrm_nm'] ?? '',
      bfefrmtrmAmount: json['bfefrmtrm_amount'] ?? '',
      ord: json['ord'] ?? '',
    );
  }

  /// 금액을 숫자로 변환 (콤마 제거)
  double? get thstrmAmountAsDouble {
    if (thstrmAmount.isEmpty) return null;
    return double.tryParse(thstrmAmount.replaceAll(',', ''));
  }

  double? get frmtrmAmountAsDouble {
    if (frmtrmAmount.isEmpty) return null;
    return double.tryParse(frmtrmAmount.replaceAll(',', ''));
  }

  double? get bfefrmtrmAmountAsDouble {
    if (bfefrmtrmAmount.isEmpty) return null;
    return double.tryParse(bfefrmtrmAmount.replaceAll(',', ''));
  }
}

/// 재무제표 API 서비스 클래스
class FinancialStatementService {
  final EnvConfig _envConfig = EnvConfig();

  /// 단일회사 전체 재무제표 조회
  Future<FinancialStatementResponse> getFinancialStatements({
    required String corpCode,
    String? bsnsYear,
    String? reprtCode,
  }) async {
    final apiKey = _envConfig.dartApiKey;
    if (apiKey.isEmpty) {
      throw Exception('DART API 키가 설정되지 않았습니다.');
    }

    final baseUrl = _envConfig.dartApiBaseUrl;
    final url = '$baseUrl/fnlttSinglAcntAll.json';

    final queryParams = {
      'crtfc_key': apiKey,
      'corp_code': corpCode,
      if (bsnsYear != null) 'bsns_year': bsnsYear,
      if (reprtCode != null) 'reprt_code': reprtCode,
    };

    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return FinancialStatementResponse.fromJson(jsonData);
      } else {
        throw Exception('API 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('재무제표 조회 중 오류 발생: $e');
    }
  }

  /// 재무제표 데이터를 계정과목별로 그룹화
  Map<String, List<FinancialStatement>> groupByAccount(List<FinancialStatement> statements) {
    final grouped = <String, List<FinancialStatement>>{};
    
    for (final statement in statements) {
      final key = statement.accountNm;
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(statement);
    }
    
    return grouped;
  }

  /// 특정 계정과목의 재무제표 데이터만 필터링
  List<FinancialStatement> filterByAccountName(
    List<FinancialStatement> statements,
    String accountName,
  ) {
    return statements.where((statement) => 
      statement.accountNm.contains(accountName)
    ).toList();
  }

  /// 에러 메시지 반환
  String getErrorMessage(String status) {
    switch (status) {
      case '000':
        return '정상';
      case '010':
        return '등록되지 않은 키입니다.';
      case '011':
        return '사용할 수 없는 키입니다. (오픈API에 등록되지 않은 키)';
      case '012':
        return '사용할 수 없는 키입니다. (오픈API에 등록되지 않은 키)';
      case '013':
        return '사용할 수 없는 키입니다. (오픈API에 등록되지 않은 키)';
      case '020':
        return '요청 제한을 초과하였습니다. (일일 요청 한도 초과)';
      case '100':
        return '필수 파라미터가 누락되었습니다.';
      case '101':
        return '파라미터 값이 잘못되었습니다.';
      case '800':
        return '시스템 점검중입니다.';
      case '900':
        return '정의되지 않은 오류가 발생하였습니다.';
      case '901':
        return '사용자 계정의 개인정보보호 동의가 필요합니다.';
      default:
        return '알 수 없는 오류가 발생하였습니다.';
    }
  }
}
