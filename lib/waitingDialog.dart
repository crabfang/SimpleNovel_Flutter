import 'package:flutter/material.dart';

class WaitingDialog extends Dialog {
  _WaitingContent content;

  WaitingDialog(String text) : content = new _WaitingContent(text);

  @override
  Widget build(BuildContext context) {
    return new Material( //创建透明层
      type: MaterialType.transparency, //透明类型
      child: new Center( //保证控件居中效果
        child: new SizedBox(
          width: 120.0,
          height: 120.0,
          child: content,
        ),
      ),
    );
  }

  void updateContent(String text) {
    content.updateText(text);
  }
}

class _WaitingContent extends StatefulWidget {
  String _text;

  _WaitingContent(this._text);

  @override
  State<StatefulWidget> createState() {
    return new _WaitingState();
  }

  void updateText(String text) {
    this._text = text;

  }
}

class _WaitingState extends State<_WaitingContent> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: ShapeDecoration(
        color: Color(0xffffffff),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
      ),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new CircularProgressIndicator(),
          new Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
            ),
            child: new Text(
              widget._text,
              style: new TextStyle(fontSize: 12.0),
            ),
          ),
        ],
      ),
    );
  }
  void updateText() {
    setState(() {

    });
  }
}

WaitingDialog showWaiting(BuildContext context, String text) {
  WaitingDialog waiting = new WaitingDialog(text);
  showDialog<Null>(
    context: context, //BuildContext对象
    barrierDismissible: false,
    builder: (BuildContext context) {
      return waiting;
  });
  return waiting;
}