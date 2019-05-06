import 'package:SimpleNovel/utils/net.dart';
import 'package:SimpleNovel/novel/w_book_info.dart';
import 'package:SimpleNovel/utils/thread_utils.dart';
import 'package:SimpleNovel/widget/list_view_child_delegate.dart';
import 'package:SimpleNovel/widget/title_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  String titleStr = "";
  TitleWidget titleWidget;
  ListContent listWidget;
  void changeTitle(String title) {
    if(titleStr != title) {
      ThreadUtils.doOnMain(() {
        titleStr = title;
        titleWidget.updateTitle(titleStr);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    titleStr = widget.info?.title;
    titleWidget = new TitleWidget(titleStr);
    listWidget = ListContent(
        widget._context,
        widget.contentList,
        widget.info,
        (ContentInfo info) {
          String title = info?.title;
          changeTitle(title);
        });
    return new Scaffold (
      appBar: new AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(widget._context).pop(),
        ),
        title: titleWidget,
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.list), onPressed: (){
            changeTitle("IconButton");
          }),
        ],
      ),
      body: Container(
        color: Colors.greenAccent,
        child: listWidget,
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
  Function(ContentInfo) firstChange;
  ListContent(this._context, List<ContentInfo> contentList, ContentInfo curInfo, this.firstChange) {
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
  @override
  Widget build(BuildContext context) {
    double minItemHeight = 2 * MediaQuery.of(context).size.height * 85 / 100;
    ScrollController controller = ScrollController();
    Future.delayed(Duration(milliseconds: 200), () {
      controller.jumpTo(curPosition * minItemHeight);
    });
    return ListView.custom(
      shrinkWrap: true,
      controller: controller,
      childrenDelegate: MyChildrenDelegate(
        (BuildContext context, int i) {
          ContentInfo info = contentList.elementAt(i);
          return itemWidget(info, minItemHeight);
        },
        childCount: contentList.length,
        firstVisibleChange: (int firstIndex, int lastIndex) {
          ContentInfo info = contentList.elementAt(lastIndex);
          if(widget.firstChange != null) {
            widget.firstChange(info);
          }
        },
      ),
    );
  }

  Widget itemWidget(ContentInfo info, double minItemHeight) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      constraints: BoxConstraints(
        minHeight: minItemHeight,
      ),
      alignment: Alignment.topCenter,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            info.title,
            style: TextStyle(
              fontSize: 20,
              color: Colors.blueAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
          _ItemContentWidget(info),
        ],
      ),
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

class _ItemContentWidget extends StatefulWidget {
  ContentInfo info;
  _ItemContentWidget(this.info);
  @override
  State<StatefulWidget> createState() {
    return _ItemContentState();
  }
}

class _ItemContentState extends State<_ItemContentWidget> {
  @override
  Widget build(BuildContext context) {
    String contentStr = widget.info?.content;
    if(contentStr == null || contentStr.isEmpty) {
      return Container(
        child: CupertinoActivityIndicator(),
        alignment: Alignment.center,
      );
    }
    return Html(
      data: widget.info.content,
      defaultTextStyle: TextStyle(
        color: Colors.lightBlue,
        fontSize: 16,
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    loadContent(context, this, widget.info);
  }
  void updateContent(String contentStr) {
    setState(() {
      widget.info.content = contentStr;
    });
  }
}

void loadContent(BuildContext context, _ItemContentState state, ContentInfo info) {
  if(info == null || info.url.isEmpty) return;

  Future<String> body = NetUtils.queryGbk(info.url);

  body.then((bodyStr) {
    return parseHtml(bodyStr);
  }).then((contentStr) {
    ThreadUtils.doOnMain(() {
      state.updateContent(contentStr);
    });
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