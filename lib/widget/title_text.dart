import 'package:flutter/cupertino.dart';

class TitleWidget extends StatefulWidget {
  TitleState state;
  TitleWidget(String titleStr) {
    state = TitleState(titleStr);
  }
  @override
  State<StatefulWidget> createState() {
    return state;
  }
  void updateTitle(String titleStr) {
    state.updateTitle(titleStr);
  }
}

class TitleState extends State<TitleWidget> {
  String _titleStr;
  TitleState(this._titleStr);
  @override
  Widget build(BuildContext context) {
    return Text(_titleStr);
  }
  void updateTitle(String titleStr) {
    setState((){
      _titleStr = titleStr;
    });
  }
}