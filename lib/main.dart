import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'auto scroll test',
      home: _MyHomePage(),
    );
  }
}

class _MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  var index = 0;
  final itemNum = 8;

  // スクロールを司るコントローラ
  final ItemScrollController _itemScrollController = ItemScrollController();

  // リストアイテムのインデックスを司るリスナー
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  void startTimer() {
    Timer.periodic(
        Duration(seconds: 3), //1秒ごとに処理
        (Timer timer) => _autoScroll());
  }

  @override
  void initState() {
    super.initState();
    //タイマーイベントをセット
    startTimer();
    // 表示中のアイテムを知るためにリスナー登録
    _itemPositionsListener.itemPositions.addListener(_itemPositionsCallback);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('auto scroll test'),
      ),
      body: Container(
        child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
          //スクロールさせて表示するカード
          Container(
            height: 400,
            child: ScrollablePositionedList.builder(
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.all(40),
                  width: 300,
                  color: Colors.blue,
                  child: Card(
                    elevation: 2.0,
                    child:
                        Text((index+1).toString(), style: TextStyle(fontSize: 50)),
                  ),
                );
              },
              itemCount: itemNum,
              itemScrollController: _itemScrollController,
              // コントローラ指定
              itemPositionsListener: _itemPositionsListener,
              // リスナー指定
              scrollDirection: Axis.horizontal, //横スクロール指定
            ),
          ),
          //カードの下に出ているボタン
          Container(
            height: 100,
            margin: EdgeInsets.only(left: 100),
            child: ListView.builder(
              scrollDirection: Axis.horizontal, //横スクロール指定
              itemCount: itemNum,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.only(right: 10),
                  width: 20,
                  child: RaisedButton(
                    color: Colors.lightBlue,
                    shape: const CircleBorder(
                      side: BorderSide(
                        color: Colors.lightBlue,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                    onPressed: () {
                      _jump(index); //ボタンタップで対応するカードに遷移する
                    },
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    // 使い終わったら破棄
    _itemPositionsListener.itemPositions.removeListener(_itemPositionsCallback);
    super.dispose();
  }

  void _jump(int index) {
    _itemScrollController.scrollTo(
      index: index, //遷移するWidgetを指定
      duration: Duration(seconds: 1), //遷移するための時間
      curve: Curves.easeInOutCubic,
    );
    this.index = index;
  }

  void _autoScroll() {
    this.index = (this.index + 1 > itemNum) ? 0 : this.index + 1;
    // スムーズスクロールを実行する
    _itemScrollController.scrollTo(
      index: this.index, //遷移するWidgetを指定
      duration: Duration(seconds: 1), //遷移するための時間
      curve: Curves.easeInOutCubic,
    );
  }

  void _itemPositionsCallback() {
    // 表示中のリストアイテムのインデックス情報を取得
    final visibleIndexes = _itemPositionsListener.itemPositions.value
        .toList()
        .map((itemPosition) => itemPosition.index);
    this.index = visibleIndexes.last;
  }
}
