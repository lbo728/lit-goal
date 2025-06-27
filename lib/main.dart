import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lit_goal/views/screens/book_list_screen.dart';
import 'package:lit_goal/views/screens/calendar_screen.dart';
import 'package:lit_goal/views/screens/home_screen.dart';
import 'package:lit_goal/views/screens/reading_start_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '독서 분량 설정기',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainScreen(),
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
        const HomeScreen(),
        const BookListScreen(),
        const CalendarScreen(),
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
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.book),
                label: '독서 목록',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.calendar),
                label: '캘린더',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue,
            onTap: (index) {
              if (!_isDropdownOpen) {
                _onItemTapped(index);
              }
            },
          ),
        ),
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
                                  Text('새 독서 시작',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                        decoration: TextDecoration.none,
                                      )),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 16,
                                top: 8,
                                bottom: 8,
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.camera_alt, color: Colors.black),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text('사진 추가',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                        decoration: TextDecoration.none,
                                      )),
                                ],
                              ),
                            ),
                          ),
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
