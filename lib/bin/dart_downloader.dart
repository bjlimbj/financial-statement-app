#!/usr/bin/env dart

import 'dart:io';
import '../lib/config/env_config.dart';
import '../lib/services/dart_api_service.dart';

void main(List<String> args) async {
  print('🚀 DART 회사코드 다운로더');
  print('=' * 50);

  try {
    // 환경 변수 초기화
    await EnvConfig().initialize();
    
    final dartService = DartApiService();
    
    // 명령줄 인수 파싱
    final options = _parseArguments(args);
    
    if (options['help'] == true) {
      _showHelp();
      return;
    }

    print('📋 설정 정보:');
    print('- DART API 키: ${EnvConfig().dartApiKey.isNotEmpty ? "설정됨" : "설정되지 않음"}');
    print('- 출력 파일: ${options['output']}');
    print('- 법인구분: ${options['corp_cls'] ?? '전체'}');
    print('- 시작일: ${options['bgn_de'] ?? '미설정'}');
    print('- 종료일: ${options['end_de'] ?? '미설정'}');
    print('');

    if (EnvConfig().dartApiKey.isEmpty) {
      print('❌ DART API 키가 설정되지 않았습니다.');
      print('   .env 파일에 DART_API_KEY를 설정해주세요.');
      return;
    }

    print('⏳ 회사코드 다운로드 중...');
    
    final result = await dartService.downloadCompanyCodes(
      corpCls: options['corp_cls'],
      bgnDe: options['bgn_de'],
      endDe: options['end_de'],
      outputPath: options['output'],
    );

    print('✅ $result');
    print('');
    print('📁 파일 위치: ${Directory.current.path}/${options['output']}');

  } catch (e) {
    print('❌ 오류 발생: $e');
    exit(1);
  }
}

Map<String, dynamic> _parseArguments(List<String> args) {
  final options = <String, dynamic>{
    'output': 'company_codes.csv',
    'corp_cls': null,
    'bgn_de': null,
    'end_de': null,
    'help': false,
  };

  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    
    switch (arg) {
      case '--help':
      case '-h':
        options['help'] = true;
        break;
      case '--output':
      case '-o':
        if (i + 1 < args.length) {
          options['output'] = args[++i];
        }
        break;
      case '--corp-cls':
      case '-c':
        if (i + 1 < args.length) {
          options['corp_cls'] = args[++i];
        }
        break;
      case '--bgn-de':
      case '-b':
        if (i + 1 < args.length) {
          options['bgn_de'] = args[++i];
        }
        break;
      case '--end-de':
      case '-e':
        if (i + 1 < args.length) {
          options['end_de'] = args[++i];
        }
        break;
      default:
        if (arg.startsWith('-')) {
          print('⚠️  알 수 없는 옵션: $arg');
          print('   --help를 사용하여 사용법을 확인하세요.');
        }
    }
  }

  return options;
}

void _showHelp() {
  print('''
📖 DART 회사코드 다운로더 사용법

사용법:
  dart run bin/dart_downloader.dart [옵션]

옵션:
  -h, --help              도움말 표시
  -o, --output <파일명>    출력 파일명 (기본값: company_codes.csv)
  -c, --corp-cls <구분>    법인구분 (Y:유가, K:코스닥, N:코넥스, E:기타)
  -b, --bgn-de <날짜>      시작일 (YYYYMMDD 형식)
  -e, --end-de <날짜>      종료일 (YYYYMMDD 형식)

예시:
  # 전체 회사코드 다운로드
  dart run bin/dart_downloader.dart

  # 유가증권 회사만 다운로드
  dart run bin/dart_downloader.dart -c Y

  # 특정 기간 회사코드 다운로드
  dart run bin/dart_downloader.dart -b 20240101 -e 20240131

  # 다른 파일명으로 저장
  dart run bin/dart_downloader.dart -o my_companies.csv

법인구분:
  Y: 유가증권시장 상장법인
  K: 코스닥시장 상장법인  
  N: 코넥스시장 상장법인
  E: 기타법인

날짜 형식:
  YYYYMMDD (예: 20240101)
''');
}
