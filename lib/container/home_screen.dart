import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lock_myself/component/diary_box.dart';
import 'package:lock_myself/screen/diary_screen.dart';
import '../component/logo.dart';
import '../main.dart';
import '../model/diary_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box<DiaryModel>(diaryBox).listenable(),
      builder: (context, box, widget) {
        final List diaryData = List.from(box.values.toList().reversed);
        final List filteredDiaryData = diaryData
            .where((diary) =>
            diary.title.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        return Scaffold(
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(Duration(seconds: 1));
            },
            child: Stack(children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.white,
                    expandedHeight: 165,
                    flexibleSpace: FlexibleSpaceBar(
                      background: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Logo(),
                              SearchBar(
                                controller: _searchController,
                                onChanged: (query) {
                                  setState(() {
                                    _searchQuery = query;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  DiaryListBuilder(diaryData: filteredDiaryData),
                ],
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => DiaryScreen()));
                  },
                  child: Image.asset('asset/icons/plus_diary.png'),
                ),
                width: 100,
              ),
            ]),
          ),
        );
      },
    );
  }
}

class DiaryListBuilder extends StatelessWidget {
  final List diaryData;
  DiaryListBuilder({required this.diaryData, super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: DiaryBox(
                index: index,
                diaryData: diaryData,
              ));
        },
        childCount: diaryData.length,
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const SearchBar({this.controller, this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    const defaultBorderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(21.5)),
      borderSide: BorderSide.none,
    );
    const defaultTextStyle =
    TextStyle(color: Color(0XFF616D71), fontSize: 16.0);

    return Padding(
      padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
      child: SizedBox(
        width: 1000,
        height: 50,
        child: TextField(
          controller: controller,
          style: TextStyle(fontSize: 16.0, decorationThickness: 0.0),
          textAlignVertical: TextAlignVertical(y: -1.0),
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFFB0BEC5),
            prefixIcon: Icon(Icons.search, size: 30.0),
            prefixIconColor: Color(0XFF616D71),
            labelText: '검색',
            labelStyle: defaultTextStyle,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: defaultBorderStyle,
            focusedBorder: defaultBorderStyle,
            enabledBorder: defaultBorderStyle,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
