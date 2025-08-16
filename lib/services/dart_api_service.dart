import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

/// DART 공시정보 응답 모델
class DartDisclosureResponse {
  final String status;
  final String message;
  final int pageNo;
  final int pageCount;
  final int totalCount;
  final int totalPage;
  final List<DartDisclosure> list;

  DartDisclosureResponse({
    required this.status,
    required this.message,
    required this.pageNo,
    required this.pageCount,
    required this.totalCount,
    required this.totalPage,
    required this.list,
  });

  factory DartDisclosureResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>;
    final list = (result['list'] as List<dynamic>?)
        ?.map((item) => DartDisclosure.fromJson(item))
        .toList() ?? [];

    return DartDisclosureResponse(
      status: result['status'] ?? '',
      message: result['message'] ?? '',
      pageNo: int.tryParse(result['page_no']?.toString() ?? '1') ?? 1,
      pageCount: int.tryParse(result['page_count']?.toString() ?? '10') ?? 10,
      totalCount: int.tryParse(result['total_count']?.toString() ?? '0') ?? 0,
      totalPage: int.tryParse(result['total_page']?.toString() ?? '0') ?? 0,
      list: list,
    );
  }
}

/// DART 공시정보 모델
class DartDisclosure {
  final String corpCls;
  final String corpName;
  final String corpCode;
  final String stockCode;
  final String reportNm;
  final String rceptNo;
  final String flrNm;
  final String rceptDt;
  final String rm;

  DartDisclosure({
    required this.corpCls,
    required this.corpName,
    required this.corpCode,
    required this.stockCode,
    required this.reportNm,
    required this.rceptNo,
    required this.flrNm,
    required this.rceptDt,
    required this.rm,
  });

  factory DartDisclosure.fromJson(Map<String, dynamic> json) {
    return DartDisclosure(
      corpCls: json['corp_cls'] ?? '',
      corpName: json['corp_name'] ?? '',
      corpCode: json['corp_code'] ?? '',
      stockCode: json['stock_code'] ?? '',
      reportNm: json['report_nm'] ?? '',
      rceptNo: json['rcept_no'] ?? '',
      flrNm: json['flr_nm'] ?? '',
      rceptDt: json['rcept_dt'] ?? '',
      rm: json['rm'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'corp_cls': corpCls,
      'corp_name': corpName,
      'corp_code': corpCode,
      'stock_code': stockCode,
      'report_nm': reportNm,
      'rcept_no': rceptNo,
      'flr_nm': flrNm,
      'rcept_dt': rceptDt,
      'rm': rm,
    };
  }
}

/// DART API 서비스 클래스
class DartApiService {
  final EnvConfig _envConfig = EnvConfig();

  /// 공시정보 검색
  Future<DartDisclosureResponse> searchDisclosures({
    String? corpCode,
    String? bgnDe,
    String? endDe,
    String? lastReprtAt,
    String? pblntfTy,
    String? pblntfDetailTy,
    String? corpCls,
    String? sort,
    String? sortMth,
    int pageNo = 1,
    int pageCount = 10,
  }) async {
    if (!_envConfig.isInitialized) {
      throw Exception('환경 변수가 초기화되지 않았습니다.');
    }

    final apiKey = _envConfig.dartApiKey;
    if (apiKey.isEmpty) {
      throw Exception('DART API 키가 설정되지 않았습니다.');
    }

    final baseUrl = _envConfig.dartApiBaseUrl;
    final uri = Uri.parse('$baseUrl/list.json').replace(
      queryParameters: {
        'crtfc_key': apiKey,
        if (corpCode != null) 'corp_code': corpCode,
        if (bgnDe != null) 'bgn_de': bgnDe,
        if (endDe != null) 'end_de': endDe,
        if (lastReprtAt != null) 'last_reprt_at': lastReprtAt,
        if (pblntfTy != null) 'pblntf_ty': pblntfTy,
        if (pblntfDetailTy != null) 'pblntf_detail_ty': pblntfDetailTy,
        if (corpCls != null) 'corp_cls': corpCls,
        if (sort != null) 'sort': sort,
        if (sortMth != null) 'sort_mth': sortMth,
        'page_no': pageNo.toString(),
        'page_count': pageCount.toString(),
      },
    );

    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return DartDisclosureResponse.fromJson(jsonData);
      } else {
        throw Exception('API 호출 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('DART API 호출 중 오류 발생: $e');
    }
  }

  /// 회사코드 목록 다운로드 (CSV 파일로 저장)
  Future<String> downloadCompanyCodes({
    String? corpCls,
    String? bgnDe,
    String? endDe,
    String outputPath = 'company_codes.csv',
  }) async {
    try {
      // 최대 페이지 수로 설정하여 모든 데이터 가져오기
      final response = await searchDisclosures(
        corpCls: corpCls,
        bgnDe: bgnDe,
        endDe: endDe,
        pageCount: 100, // 최대 페이지당 건수
      );

      if (response.status != '000') {
        throw Exception('DART API 오류: ${response.message}');
      }

      // CSV 파일 생성
      final file = File(outputPath);
      final csvContent = _generateCsvContent(response.list);
      await file.writeAsString(csvContent, encoding: utf8);

      return '회사코드 다운로드 완료: $outputPath (${response.list.length}건)';
    } catch (e) {
      throw Exception('회사코드 다운로드 실패: $e');
    }
  }

  /// CSV 내용 생성
  String _generateCsvContent(List<DartDisclosure> disclosures) {
    final buffer = StringBuffer();
    
    // CSV 헤더
    buffer.writeln('법인구분,종목명(법인명),고유번호,종목코드,보고서명,접수번호,공시제출인명,접수일자,비고');
    
    // 데이터 행
    for (final disclosure in disclosures) {
      buffer.writeln([
        disclosure.corpCls,
        _escapeCsvField(disclosure.corpName),
        disclosure.corpCode,
        disclosure.stockCode,
        _escapeCsvField(disclosure.reportNm),
        disclosure.rceptNo,
        _escapeCsvField(disclosure.flrNm),
        disclosure.rceptDt,
        disclosure.rm,
      ].join(','));
    }
    
    return buffer.toString();
  }

  /// CSV 필드 이스케이프 처리
  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// 특정 회사의 공시정보 검색
  Future<DartDisclosureResponse> searchCompanyDisclosures({
    required String corpCode,
    String? bgnDe,
    String? endDe,
    String? pblntfTy,
  }) async {
    return await searchDisclosures(
      corpCode: corpCode,
      bgnDe: bgnDe,
      endDe: endDe,
      pblntfTy: pblntfTy,
      pageCount: 100,
    );
  }

  /// 오늘 공시정보 검색
  Future<DartDisclosureResponse> searchTodayDisclosures({
    String? corpCls,
    String? pblntfTy,
  }) async {
    final today = DateTime.now();
    final todayStr = '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
    
    return await searchDisclosures(
      bgnDe: todayStr,
      endDe: todayStr,
      corpCls: corpCls,
      pblntfTy: pblntfTy,
      pageCount: 100,
    );
  }

  /// 에러 메시지 해석
  String getErrorMessage(String status) {
    switch (status) {
      case '000':
        return '정상';
      case '010':
        return '등록되지 않은 키입니다.';
      case '011':
        return '사용할 수 없는 키입니다.';
      case '012':
        return '접근할 수 없는 IP입니다.';
      case '013':
        return '조회된 데이터가 없습니다.';
      case '014':
        return '파일이 존재하지 않습니다.';
      case '020':
        return '요청 제한을 초과하였습니다.';
      case '021':
        return '조회 가능한 회사 개수가 초과하였습니다.';
      case '100':
        return '필드의 부적절한 값입니다.';
      case '101':
        return '부적절한 접근입니다.';
      case '800':
        return '시스템 점검으로 인한 서비스가 중지 중입니다.';
      case '900':
        return '정의되지 않은 오류가 발생하였습니다.';
      case '901':
        return '사용자 계정의 개인정보 보유기간이 만료되었습니다.';
      default:
        return '알 수 없는 오류입니다.';
    }
  }
}
