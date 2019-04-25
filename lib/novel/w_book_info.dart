import 'package:SimpleNoval/book_detail.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WBookInfo extends StatelessWidget {
  BookInfo bookInfo;
  WBookInfo(BookInfo bookInfo):bookInfo = bookInfo;
  @override
  Widget build(BuildContext context) {
    return createBook(context, bookInfo);
  }
}

InkWell createBook(BuildContext context, BookInfo bookInfo) {
  return new InkWell(
    onTap: () {
      Navigator.of(context).push(
          new MaterialPageRoute(builder: (context) => new BookDetailWidget(bookInfo))
      );
    },
    child: new Container(
        height: 160.0,
        padding: EdgeInsets.all(16.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      bookInfo.name,
                      maxLines: 1,
                      style: TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    new Text(
                      bookInfo.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    new Text(
                      bookInfo.type,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    new Text(
                      bookInfo.source,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    new Text(
                      bookInfo.desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )),
            new Container(
              width: 90,
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 10.0),
              child: new CachedNetworkImage(
                fit: BoxFit.fitWidth,
                imageUrl: bookInfo.cover,
                errorWidget: new Icon(Icons.error),
              ),
            )
          ],
        ),
        decoration: new BoxDecoration(
            color: Colors.white,
            border: new Border(
                bottom: new BorderSide(width: 0.33, color: Colors.grey)
            )
        )
    ),
  );
}

class BookInfo {
  String cover;
  String name;
  String url;
  String author;
  String type;
  String source;
  String desc;
  BookInfo(this.cover, this.name, this.url, {
    this.author: "",
    this.type: "",
    this.source: "",
    this.desc: "",});
}

class ContentInfo {
  String title;
  String url;
  String content;
  ContentInfo(this.title, this.url, {this.content: ""});
}