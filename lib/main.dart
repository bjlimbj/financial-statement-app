import 'package:flutter/material.dart';
import 'config/env_config.dart';
import 'services/api_service.dart';
import 'services/dart_api_service.dart';
import 'services/financial_statement_service.dart';
import 'services/company_code_service.dart';
import 'widgets/financial_charts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 환경 변수 초기화
  await EnvConfig().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API 키 관리 예시',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ApiKeyDemoPage(),
    );
  }
}

class ApiKeyDemoPage extends StatefulWidget {
  const ApiKeyDemoPage({super.key});

  @override
  State<ApiKeyDemoPage> createState() => _ApiKeyDemoPageState();
}

class _ApiKeyDemoPageState extends State<ApiKeyDemoPage> {
  final EnvConfig _envConfig = EnvConfig();
  final ApiService _apiService = ApiService();
  final DartApiService _dartService = DartApiService();
  final FinancialStatementService _financialService = FinancialStatementService();
  final CompanyCodeService _companyService = CompanyCodeService();
  
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _corpCodeController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _bsnsYearController = TextEditingController();
  
  String _response = '';
  bool _isLoading = false;
  String? _selectedCorpCls;
  String? _selectedPblntfTy;
  
  // 재무제표 관련 상태
  List<FinancialStatement> _financialStatements = [];
  List<CompanyInfo> _searchResults = [];
  CompanyInfo? _selectedCompany;
  bool _isCompanyCodesLoaded = false;

  @override
  void initState() {
    super.initState();
    _envConfig.printAllEnvVars();
    
    // 오늘 날짜로 기본값 설정
    final today = DateTime.now();
    final todayStr = '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
    _startDateController.text = todayStr;
    _endDateController.text = todayStr;
    
    // 사업연도 기본값 설정 (현재 연도)
    _bsnsYearController.text = today.year.toString();
    
    // 회사코드 로드
    _loadCompanyCodes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API 키 관리 데모'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 환경 변수 상태 표시
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
