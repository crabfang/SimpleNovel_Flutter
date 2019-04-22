import 'package:flutter/material.dart';
import 'package:flutter_demo/detail.dart';
import 'package:flutter_demo/list_ui.dart';
import 'package:flutter_demo/net.dart';
import 'package:flutter_demo/novel/w_book_info.dart';
import 'package:flutter_demo/waitingDialog.dart' as Waiting;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:html/dom.dart' as Dom;
import 'package:html/parser.dart' show parse;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'CF Flutter Demo',
      theme: new ThemeData(
        primaryColor: Colors.white,
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
//    final wordPair = new WordPair.random();
//    return new Text(wordPair.asPascalCase);
    return new Scaffold (
      appBar: new AppBar(
        title: new Text('Flutter Demo'),
      ),
      body: new ListView(
        children: <Widget>[
            createRowBtn(context, "List", 0),
            new Divider(),
            createRowBtn(context, "Detail", 1),
            new Divider(),
            createRowBtn(context, "Load", 2),
            createEdit(searchInputController),
            listContent,
        ],
      ),
    );
  }
}

Widget createEdit(TextEditingController controller) {
  return new TextField(
    controller: controller,
    maxLines: 1,//最大行数
    autofocus: false,//是否自动对焦
    style: TextStyle(fontSize: 16.0, color: Colors.black),//输入文本的样式
    decoration: new InputDecoration(
      contentPadding: const EdgeInsets.all(10.0),
      hintText: "请输入小说名或者作者",
    ),
    onSubmitted: (text) {
      toastInfo(text);
    },
  );
}

Widget createRowBtn(BuildContext context, String label, int type) {
  void onPressed() {
    actionClick(context, type);
  }
  return new MaterialButton(
    onPressed: onPressed,
    child: new Text(label),
    height: 60,
  );
}

void actionClick(BuildContext context, int type) {
  switch(type) {
    case 0:
      Navigator.of(context).push(
        new MaterialPageRoute(builder: (context) => new BookDetail()),
      );
      break;
    case 1:
      Navigator.of(context).push(
        new MaterialPageRoute(builder: (context) => new Detail()),
      );
      break;
    case 2:
      Waiting.WaitingDialog waitingDialog = Waiting.showWaiting(context, "...");
      waitingDialog.updateContent("正在获取数据");

      Map<String, String> params = new Map();
      params["searchtype"] = "keywords";
      params["searchkey"] = searchInputController.text;
//      params["searchkey"] = Uri.encodeQueryComponent(searchInputController.text, encoding: gbk);

      String url = "https://www.fpzw.com/modules/article/search.php";
      Uri uri = Uri.dataFromString(url, encoding: gbk, parameters: params);

      Future<String> body = NetUtils.queryUri(uri);
      body.then((bodyStr) {
        waitingDialog.updateContent("数据解析");
        return parseHtml(bodyStr);
      }).then((bookList) {
        listContent.setListData(bookList);
        waitingDialog.updateContent("解析完成");
      }).catchError((e) => Navigator.pop(context))
          .whenComplete(() => Navigator.pop(context));
      break;
  }
}

Future<List<BookInfo>> parseHtml(String htmlStr) async {
  List<BookInfo> bookList = new List();
  Dom.Document document = parse(htmlStr);
  var list = document.body.getElementsByClassName("eachitem");
  list.forEach((dl) => bookList.add(parseHtmlDl(dl)));
  return bookList;
}

BookInfo parseHtmlDl(Dom.Element dl) {
  Dom.Element domTitle = dl.getElementsByClassName("caption").elementAt(0);
  Dom.Element domImg = dl.getElementsByTagName("img").elementAt(0);
  Dom.Element domText = dl.getElementsByClassName("text").elementAt(0);

  List<String> infoList = domText.innerHtml.split("<br>");
  String author = "";
  String updateTime = "";
  String state = "";
  if(infoList.length >= 3) {
    author = parse(infoList.elementAt(0)).body.text;
    updateTime = infoList.elementAt(1);
    state = infoList.elementAt(2);
  }

  String title = domTitle.firstChild.text;
  String url = domTitle.attributes.remove("href");
  String pic = "https://www.fpzw.com" + domImg.attributes.remove("src");

  return new BookInfo(pic, title, url, author: author, source: "富品", state: state, size: updateTime);
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