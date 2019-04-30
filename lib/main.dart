import 'package:SimpleNovel/book_detail.dart';
import 'package:flutter/material.dart';
import 'package:SimpleNovel/novel/w_book_info.dart';
import 'package:SimpleNovel/search.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '简易小说',
      theme: new ThemeData(
        primaryColor: Colors.blueAccent,
      ),
      home: new Main(),
    );
  }
}

class Main extends StatefulWidget {
  @override
  createState() => new MainState();
}

TextEditingController searchInputController = new TextEditingController();
ListContent listContent = new ListContent();
class MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold (
      appBar: new AppBar(
        title: new Text('我的书架'),
        elevation: 0,
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.search), onPressed: () {
            Navigator.of(context).push(
                new MaterialPageRoute(builder: (context) => new SearchWidget())
            );
          }),
          new IconButton(icon: new Icon(Icons.book), onPressed: () {
            BookInfo bookInfo = new BookInfo("", "元尊", "https://www.88dush.com/xiaoshuo/95/95770/", author: "作者：天蚕土豆");
            Navigator.of(context).push(
                new MaterialPageRoute(builder: (context) => new BookDetailWidget(bookInfo))
            );
          }),
        ],
      ),
      body: listContent
    );
  }
}

void toastInfo(String info) {
  Fluttertoast.showToast(
    msg: info,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIos: 1,
  );
}

// ignore: must_be_immutable
class ListContent extends StatefulWidget {
  ContentState state = new ContentState();
  @override
  createState() => state;
  void setListData(List<BookInfo> bookList) {
    state.updateState(bookList);
  }
}

class ContentState extends State<ListContent> {
  List<BookInfo> _bookList = new List();
  @override
  Widget build(BuildContext context) {
//    return ListView.builder(
//        scrollDirection: Axis.vertical,
//        itemBuilder: (BuildContext context, int position) {
//          return new WBookInfo(_bookList.elementAt(position));
//        });
    return ListView.builder(
        shrinkWrap: true,
        physics:NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => WBookInfo(_bookList.elementAt(index)),
        itemCount: _bookList.length);
  }
  void updateState(List<BookInfo> bookList) {
    _bookList = bookList;
    setState(() {
    });
  }
}