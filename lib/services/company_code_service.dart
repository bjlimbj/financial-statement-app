import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// 회사 정보 모델
class CompanyInfo {
  final String corpCode;      // 고유번호
  final String corpName;      // 정식명칭
  final String stockCode;     // 종목코드
  final String modifyDate;    // 최종수정일자

  CompanyInfo({
    required this.corpCode,
    required this.corpName,
    required this.stockCode,
    required this.modifyDate,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      corpCode: json['corp_code'] ?? '',
      corpName: json['corp_name'] ?? '',
      stockCode: json['stock_code'] ?? '',
      modifyDate: json['modify_date'] ?? '',
    );
  }
}

/// 회사코드 서비스 클래스
class CompanyCodeService {
  static const String _corpCodesFileName = 'corpCodes.json';
  List<CompanyInfo> _companies = [];
  bool _isLoaded = false;

  /// 회사코드 파일 로드
  Future<void> loadCompanyCodes() async {
    if (_isLoaded) return;

    try {
      final file = File(_corpCodesFileName);
      if (!await file.exists()) {
        throw Exception('corpCodes.json 파일이 존재하지 않습니다. 먼저 회사코드를 다운로드해주세요.');
      }

      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString);
      
      if (jsonData is Map<String, dynamic> && jsonData.containsKey('list')) {
        final list = jsonData['list'] as List<dynamic>;
        _companies = list.map((item) => CompanyInfo.fromJson(item)).toList();
      } else {
        _companies = [];
      }
      
      _isLoaded = true;
      print('회사코드 로드 완료: ${_companies.length}개 회사');
    } catch (e) {
      throw Exception('회사코드 파일 로드 중 오류 발생: $e');
    }
  }

  /// 회사명으로 회사 검색
  List<CompanyInfo> searchCompanies(String companyName) {
    if (!_isLoaded) {
      throw Exception('회사코드가 로드되지 않았습니다. loadCompanyCodes()를 먼저 호출해주세요.');
    }

    if (companyName.isEmpty) return [];

    final normalizedName = companyName.toLowerCase().trim();
    return _companies.where((company) {
      final normalizedCompanyName = company.corpName.toLowerCase();
      return normalizedCompanyName.contains(normalizedName);
    }).toList();
  }

  /// 종목코드로 회사 검색
  CompanyInfo? findCompanyByStockCode(String stockCode) {
    if (!_isLoaded) {
      throw Exception('회사코드가 로드되지 않았습니다. loadCompanyCodes()를 먼저 호출해주세요.');
    }

    if (stockCode.isEmpty) return null;

    try {
      return _companies.firstWhere((company) => company.stockCode == stockCode);
    } catch (e) {
      return null;
    }
  }

  /// 회사코드로 회사 검색
  CompanyInfo? findCompanyByCorpCode(String corpCode) {
    if (!_isLoaded) {
      throw Exception('회사코드가 로드되지 않았습니다. loadCompanyCodes()를 먼저 호출해주세요.');
    }

    if (corpCode.isEmpty) return null;

    try {
      return _companies.firstWhere((company) => company.corpCode == corpCode);
    } catch (e) {
      return null;
    }
  }

  /// 상장회사만 필터링
  List<CompanyInfo> getListedCompanies() {
    if (!_isLoaded) {
      throw Exception('회사코드가 로드되지 않았습니다. loadCompanyCodes()를 먼저 호출해주세요.');
    }

    return _companies.where((company) => company.stockCode.isNotEmpty).toList();
  }

  /// 전체 회사 수 반환
  int get totalCompanyCount => _companies.length;

  /// 로드된 회사 목록 반환
  List<CompanyInfo> get allCompanies => List.unmodifiable(_companies);

  /// 로드 상태 확인
  bool get isLoaded => _isLoaded;
}
