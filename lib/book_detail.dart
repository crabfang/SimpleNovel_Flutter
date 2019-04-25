import 'package:SimpleNoval/net.dart';
import 'package:SimpleNoval/novel/w_book_info.dart';
import 'package:flutter/material.dart';
import 'package:SimpleNoval/book_content.dart';
import 'package:SimpleNoval/waitingDialog.dart' as Waiting;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/dom.dart' as Dom;
import 'package:html/parser.dart' show parse;

class BookDetailWidget extends StatelessWidget {
  BookInfo info;
  BookDetailWidget(this.info);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: info?.name,
      theme: new ThemeData(
        primaryColor: Colors.blue,
      ),
      home: new BookDetailView(context, info),
    );
  }
}

class BookDetailView extends StatefulWidget {
  BuildContext _context;
  BookInfo info;
  BookDetailView(this._context, this.info);
  @override
  createState() => new BookDetailViewState();
}

Widget detailWidget = contentWidget();
String state = "";
String updateTime = "";
String lastContent = "";
class BookDetailViewState extends State<BookDetailView> {
  void gotoContent() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new BookContentWidget(BookInfo("cover", "name", "url"))),
    );
  }
  void actionBack() {
    Navigator.of(widget._context).pop();
  }
  @override
  Widget build(BuildContext context) {
//    loadDetail(context, widget.info);
    return new Scaffold (
      appBar: new AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: actionBack,
        ),
        title: new Text(widget.info?.name),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.list), onPressed: gotoContent),
        ],
      ),
      body: new ListView(
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Text(state),
              new Text(updateTime),
              new Text(lastContent),
            ],
          ),
          detailWidget,
        ],
      ),
    );
  }

  List<ContentInfo> contentList = List<ContentInfo>();
  Widget contentListWidget() {
    return new GridView.builder(
        padding: const EdgeInsets.all(10.0),
        physics:NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
        ),
        itemCount: contentList.length,
        itemBuilder: (BuildContext context, int index) {
          ContentInfo info = contentList.elementAt(index);
          return new GestureDetector(
            onTap: () {
            },
            child: new Text(info.title),
          );
        },
    );
  }

  void loadDetail(BuildContext context, BookInfo info) {
    Waiting.WaitingDialog waitingDialog = Waiting.showWaiting(context, "...");
    waitingDialog.updateContent("正在获取数据");

    String url = info?.url;
    Future<String> body = NetUtils.query(url);

    body.then((bodyStr) {
      waitingDialog.updateContent("数据解析");
      return parseHtml(bodyStr);
    }).then((list) {
      contentList.addAll(list);
      waitingDialog.updateContent("解析完成");
    }).catchError((e) => Navigator.pop(context))
        .whenComplete(() => Navigator.pop(context));
  }

  Future<List<ContentInfo>> parseHtml(String htmlStr) async {
    List<ContentInfo> contentList = new List();
    Dom.Document document = parse(htmlStr);
    var infoDom = document.body.querySelectorAll("div.msg").elementAt(0);
    if(infoDom != null) {
      state = infoDom.getElementsByTagName("em").elementAt(1).text;
      updateTime = infoDom.getElementsByTagName("em").elementAt(2).text;
      lastContent = infoDom.getElementsByTagName("em").elementAt(3).text;
    }

    var list = document.body.querySelectorAll("div>ul>li");
    list.forEach((dl) {
      ContentInfo contentInfo = parseHtmlDl(dl);
      if(contentInfo != null) {
        contentList.add(contentInfo);
      }
    });
    return contentList;
  }

  ContentInfo parseHtmlDl(Dom.Element div) {
    Dom.Element domInfo = div.getElementsByClassName("block_txt").elementAt(0);

    String title = getHtmlText(domInfo.getElementsByTagName("h2").elementAt(0));
    String url = domInfo.getElementsByTagName("a").elementAt(0).attributes["href"];

    return new ContentInfo(title, url);
  }

  String getHtmlText(Dom.Element element) {
    return element?.text
        ?.replaceAll("\n", "")
        ?.replaceAll("\t", "")
        ?.trim();
  }

  void toastInfo(String info) {
    Fluttertoast.showToast(
      msg: info,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
    );
  }
}