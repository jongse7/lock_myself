import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:lock_myself/component/custom_text_field.dart';
import 'package:lock_myself/const/color.dart';
import '../main.dart';
import '../model/diary_model.dart';
import '../utils/data_utils.dart';
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();
  String? title;
  String? content;
  String? status;
  TextEditingController _controllerTitle = TextEditingController();
  TextEditingController _controllerContent = TextEditingController();
  int backspaceCount = 0;

  @override
  void initState() {
    super.initState();
    _controllerTitle.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // Text change handling logic if needed
  }

  @override
  void dispose() {
    _controllerTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: renderAppbar(),
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        child: Form(
          key: formKey,
          child: Column(
            children: [
              _Title(
                  backspaceTextInputFormatter: [
                    BackspaceTextInputFormatter(_onBackspaceDetected)
                  ],
                  controller: _controllerTitle,
                  onTitleSaved: (String? val) {
                    title = val;
                  }),
              _Content(
                backspaceTextInputFormatter: [
                  BackspaceTextInputFormatter(_onBackspaceDetected)
                ],
                controller: _controllerContent,
                onContentSaved: (String? val) {
                  content = val;
                },
              ),
              _SubmitButton(
                onSavePressed: onSavePressed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget renderAppbar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        '일기 작성',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 23.0),
      ),
      centerTitle: true,
      toolbarHeight: 120,
      leading: IconButton(
        icon: ImageIcon(
          AssetImage("asset/icons/left_arrow.png"),
          size: 27.5,
        ),
        padding: EdgeInsets.only(left: 25.0, top: 5),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _onBackspaceDetected() {
    backspaceCount++;
    print(backspaceCount);
  }

  void onSavePressed() {
    // title, content null 검사
    if(title == null){
      title = '제목 없음';
    }
    if(content == null){
      content = '내용 없음';
    }

    status = DataUtils.backspaceToStatus(backspaceCount);

    // userBox 접근
    final userData = Hive.box(userBox);
    // 전체 backspace 횟수 갱신
    int newTotalBackspace = userData.get('totalBackspace') + backspaceCount;
    userData.put('totalBackspace', newTotalBackspace);

    // 다른 개발자의 실수를 대비 예외처리
    if (formKey.currentState == null) {
      return;
    }
    // 모든 하위 TextFormField의 validate에서 null을 return할 때
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      // DiaryModel 생성 및 데이터 삽입
      DiaryModel diaryModel = DiaryModel(
          dateTime: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day
          ),
          title: title!,
          content: content!,
          status: status!);
      // diaryBox 접근
      final diaryData = Hive.box<DiaryModel>(diaryBox);

      // 일기 매일 쓰기 챌린지 갱신 -> diaryBox에 저장하기 전 제일 최신 날짜와 비교
      final challengeDay = userData.get('challengeDay');

      final lastDate;
      if(diaryData.isNotEmpty){lastDate = diaryData.values.last.dateTime;}
      else{lastDate = null;}
      final newChallenge = DataUtils.updateChallengeDay(challengeDay, DateTime.now(), lastDate);
      userData.put('challengeDay', newChallenge);

      // diary 저장
      diaryData.put(DateTime.now().toString(), diaryModel);
      // 전체 일기 개수 갱신
      final totalNum = diaryData.length;
      userData.put('totalNumber', totalNum);
      // 평균 backspace 횟수 갱신
      userData.put('averageBackspace', newTotalBackspace/totalNum);
    }
    // 하위 TextFormField의 validate에서 에러(text)를 return할 때
    else {
      print('에러가 있습니다.');
    }
    print('pop');
    Navigator.of(context).pop();
  }
}

class _Title extends StatelessWidget {
  final List<TextInputFormatter> backspaceTextInputFormatter;
  final TextEditingController controller;
  final FormFieldSetter<String> onTitleSaved;

  const _Title(
      {required this.backspaceTextInputFormatter,
      required this.controller,
      required this.onTitleSaved,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
        backspaceTextInputFormatter: backspaceTextInputFormatter,
        controller: controller,
        label: 'Title',
        labelText: '제목을 작성해주세요',
        onSaved: onTitleSaved);
  }
}

class _Content extends StatelessWidget {
  final List<TextInputFormatter> backspaceTextInputFormatter;
  final TextEditingController controller;
  final FormFieldSetter<String> onContentSaved;

  const _Content(
      {required this.backspaceTextInputFormatter,
      required this.controller,
      required this.onContentSaved,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: CustomTextField(
      backspaceTextInputFormatter: backspaceTextInputFormatter,
      controller: controller,
      label: 'Content',
      labelText: '일기를 작성해주세요',
      onSaved: onContentSaved,
    ));
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback onSavePressed;

  const _SubmitButton({required this.onSavePressed, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 2.0, color: Color(0XFFE0E0E0)),
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 140,
          height: 50,
          child: ElevatedButton(
            onPressed: onSavePressed,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27.5),
              ),
              backgroundColor: PRIMARY_COLOR,
            ),
            child: Text(
              '작성완료',
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        )
      ),
    );
  }
}

class BackspaceTextInputFormatter extends TextInputFormatter {
  final VoidCallback onBackspaceDetected;

  BackspaceTextInputFormatter(this.onBackspaceDetected);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue.text.length > newValue.text.length) {
      onBackspaceDetected();
    }
    return newValue;
  }
}
