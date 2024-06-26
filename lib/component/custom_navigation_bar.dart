import 'package:flutter/material.dart';
import 'package:lock_myself/container/user_screen.dart';
import '../const/color.dart';
import '../const/icon.dart';
import '../container/calendar_screen.dart';
import '../container/home_screen.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar>
    with TickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: 1,
      length: ICONS_LIST.length,
      vsync: this,
    );
    tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: TabBarView(
          controller: tabController,
          children: [
            CalendarScreen(),
            HomeScreen(),
            UserScreen(),
          ]
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(width: 2.0, color: Color(0XFFE0E0E0)),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          items: ICONS_LIST[tabController.index]
              .map((icon) => BottomNavigationBarItem(icon: icon, label: ''))
              .toList(),
          currentIndex: tabController.index,
          unselectedItemColor: PRIMARY_COLOR,
          fixedColor: PRIMARY_COLOR,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index){
            tabController.animateTo(index);
          },
        ),
      ),
    );
  }
}
