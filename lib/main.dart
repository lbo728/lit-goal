import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lit_goal/ui/reading/widgets/reading_chart_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:lit_goal/ui/book/widgets/book_list_screen.dart';
import 'package:lit_goal/ui/reading/widgets/reading_start_screen.dart';
import 'package:lit_goal/config/app_config.dart';
import 'package:lit_goal/data/repositories/book_repository.dart';
import 'package:lit_goal/data/services/book_service.dart';
import 'package:lit_goal/ui/home/view_model/home_view_model.dart';
import 'data/services/auth_service.dart';
import 'ui/auth/widgets/login_screen.dart';
import 'ui/auth/widgets/my_page_screen.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize AdMob SDK
  MobileAds.instance.initialize().then((InitializationStatus status) {
    print('AdMob 초기화 완료: ${status.adapterStatuses}');
  });

  AppConfig.validateApiKeys();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  ).then((_) {
    debugPrint('Supabase 초기화 성공');
  }).catchError((error) {
    debugPrint('Supabase 초기화 실패: $error');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BookService>(
          create: (_) => BookService(),
        ),
        Provider<BookRepository>(
          create: (context) => BookRepositoryImpl(
            context.read<BookService>(),
          ),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(
            context.read<BookRepository>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'LitGoal',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (authService.currentUser != null) {
          return const MainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isDropdownOpen = false;

  List<Widget> get _pages => [
        const BookListScreen(),
        const ReadingChartScreen(),
        const MyPageScreen(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chart_bar_fill),
                label: '독서 상태',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person_fill),
                label: '마이페이지',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              if (!_isDropdownOpen) {
                _onItemTapped(index);
              }
            },
          ),
        ),
        if (_isDropdownOpen)
          AnimatedOpacity(
            opacity: _isDropdownOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isDropdownOpen = false;
                });
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color.fromRGBO(0, 0, 0, 0.3),
              ),
            ),
          ),
        Positioned(
          bottom: 108,
          right: 16,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              AnimatedOpacity(
                opacity: _isDropdownOpen ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 64),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.2),
                          offset: Offset(0, 4),
                          blurRadius: 24,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IntrinsicWidth(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isDropdownOpen = false;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ReadingStartScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 16,
                                top: 8,
                                bottom: 8,
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.book,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    '새 독서 시작',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // GestureDetector(
                          //   onTap: () {
                          //     setState(() {
                          //       _isDropdownOpen = false;
                          //     });
                          //   },
                          //   child: Container(
                          //     padding: const EdgeInsets.only(
                          //       left: 12,
                          //       right: 16,
                          //       top: 8,
                          //       bottom: 8,
                          //     ),
                          //     child: const Row(
                          //       children: [
                          //         Icon(
                          //           Icons.camera_alt,
                          //           color: Colors.black,
                          //         ),
                          //         SizedBox(
                          //           width: 8,
                          //         ),
                          //         Text(
                          //           '사진 추가',
                          //           style: TextStyle(
                          //             fontSize: 16,
                          //             fontWeight: FontWeight.w400,
                          //             color: Colors.black,
                          //             decoration: TextDecoration.none,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              FloatingActionButton(
                backgroundColor: Colors.blue,
                elevation: 2,
                shape: const CircleBorder(),
                onPressed: () {
                  setState(() {
                    _isDropdownOpen = !_isDropdownOpen;
                  });
                },
                child: Icon(
                  _isDropdownOpen ? Icons.close : Icons.add,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
