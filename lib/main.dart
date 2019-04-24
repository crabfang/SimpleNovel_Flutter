import 'package:flutter/material.dart';
import 'package:flutter_demo/detail.dart';
import 'package:flutter_demo/list_ui.dart';
import 'package:flutter_demo/net.dart';
import 'package:flutter_demo/novel/w_book_info.dart';
import 'package:flutter_demo/waitingDialog.dart' as Waiting;
import 'package:fluttertoast/fluttertoast.dart';
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
//            createRowBtn(context, "List", 0),
//            new Divider(),
//            createRowBtn(context, "Detail", 1),
            new Divider(),
            createRowBtn(context, "Search", 2),
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

      Map<String, dynamic> params = new Map();
      params["search_field"] = "0";
      params["q"] = searchInputController.text;

      String url = "https://so.88dush.com/search/so.php";
      Future<String> body = NetUtils.query(url, queryParameters: params);

//      String searchUrl = url + "?searchtype=keywords&searchkey=" + Uri.encodeQueryComponent(searchInputController.text, encoding: gbk);
//      Uri searchUri = Uri.parse(searchUrl);
//      print(searchUri);
//      Future<String> body = NetUtils.clientQuery(searchUrl);

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
  var list = document.body.getElementsByClassName("block");
  list.forEach((dl) {
    BookInfo bookInfo = parseHtmlDl(dl);
    if(bookInfo != null) {
      bookList.add(bookInfo);
    }
  });
  return bookList;
}

BookInfo parseHtmlDl(Dom.Element div) {
  Dom.Element domImg = div.getElementsByTagName("img").elementAt(0);
  Dom.Element domInfo = div.getElementsByClassName("div.block_txt").elementAt(0);

  String title = domInfo.getElementsByTagName("h2").elementAt(0).text;
  String url = domInfo.getElementsByTagName("a").elementAt(0).attributes["href"];
  String pic = domImg.attributes["src"];
  String author = domInfo.getElementsByTagName("p").elementAt(2).text;
  String novelType = domInfo.getElementsByTagName("p").elementAt(3).text;

  return new BookInfo(pic, title, url, author: author, source: "八八", state: novelType);
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