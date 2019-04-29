import 'package:SimpleNoval/net.dart';
import 'package:SimpleNoval/novel/w_book_info.dart';
import 'package:SimpleNoval/waitingDialog.dart' as Waiting;
import 'package:flutter/material.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as Dom;
import 'package:html/parser.dart' show parse;

class BookContentsWidget extends StatelessWidget {
  List<ContentInfo> contentList;
  ContentInfo info;
  BookContentsWidget(this.contentList, this.info);

  @override
  Widget build(BuildContext context) {
    return new BookContentsView(context, contentList, info);
  }
}

class BookContentsView extends StatefulWidget {
  BuildContext _context;
  List<ContentInfo> contentList;
  ContentInfo info;
  BookContentsState contentsState = BookContentsState();
  BookContentsView(this._context, this.contentList, this.info);
  @override
  createState() => contentsState;
}

class BookContentsState extends State<BookContentsView> {
  ListContent listWidget;
  @override
  Widget build(BuildContext context) {
    listWidget = ListContent(widget._context, widget.contentList, widget.info);
    return new Scaffold (
      appBar: new AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(widget._context).pop(),
        ),
        title: new Text(widget.info?.title),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.list), onPressed: (){
          }),
        ],
      ),
      body: new ListView(
        children: <Widget>[
          listWidget,
        ],
      ),
    );
  }

  ContentInfo createDemo(String title) {
    return ContentInfo(title, "");
  }
}

// ignore: must_be_immutable
class ListContent extends StatefulWidget {
  BuildContext _context;
  ContentState state;
  ListContent(this._context, List<ContentInfo> contentList, ContentInfo curInfo) {
    int curIndex = contentList == null || curInfo == null ? 0 : contentList.indexOf(curInfo);
    state = ContentState(contentList, curIndex);
  }
  @override
  createState() => state;
  void updateData(ContentInfo info) {
    state.updateData(info);
  }
}

class ContentState extends State<ListContent> {
  List<ContentInfo> contentList = new List();
  int curPosition = 0;
  ContentState(this.contentList, this.curPosition);
  double preListOffset = -1;
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: contentList.length,
      itemBuilder: (context, index) {
        ContentInfo info = contentList.elementAt(index);
        return new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
            Text(
              info.title,
              style: TextStyle(
                color: Colors.lightBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            Html(data: info.content),
        ],
        );
      },
    );
  }
  void updateData(ContentInfo curContent) {
    contentList.forEach((info) {
      if(info.url == curContent.url) {
        info.content = curContent.content;
      }
    });
    setState(() {
    });
  }
}

void loadContent(BuildContext context, ContentState state, ContentInfo info) {
  Waiting.WaitingDialog waitingDialog = Waiting.showWaiting(context, "请稍候...");
  waitingDialog.updateContent("正在获取数据");

  if(info == null || info.url.isEmpty) return;

  Future<String> body = NetUtils.queryGbk(info.url);

  body.then((bodyStr) {
    waitingDialog.updateContent("数据解析");
    return parseHtml(bodyStr);
  }).then((contentStr) {
    info.content = contentStr;
    state.updateData(info);
    Navigator.pop(context);
  }).catchError((e) {
    Navigator.pop(context);
  });
}

Future<String> parseHtml(String htmlStr) async {
  Dom.Document document = parse(htmlStr);

  var contentDom = document.body.querySelectorAll("div.yd_text2");
  if(contentDom != null) {
    return contentDom.elementAt(0).text;
  }
  return "";
}

String getHtmlText(Dom.Element element) {
  return element?.text
      ?.replaceAll("\n", "")
      ?.replaceAll("\t", "")
      ?.trim();
}