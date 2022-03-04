import 'dart:async';
import 'dart:math';

import 'package:minocalculator/expr_util.dart';
import 'package:minocalculator/hex_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 按钮的字体大小
  double? keyFontSize;

  /// 按钮的宽高比例
  double keyRadio = 4 / 3;

  /// 按钮的水平margin
  double vSpace = 20;

  /// 按钮的垂直margin
  double hSpace = 10;

  /// 表达式的缩放率
  late double exprRadio;
  final double defaultExprRadio = 0.6;

  /// 表达式的高度
  double exprHeight = 120;

  /// 计算结果的显示高度
  double resultHeight = 120;

  /// 计算结果
  late String result;
  final String defaultResult = '0';

  late double resultRadio;
  final double defaultResultRadio = 0.5;

  /// 按钮的背景色
  final Color keyBgColor = HexColor("#202020");
  final Color equalKeyBgColor = HexColor("#29E9BB");
  final Color animationBgColor = HexColor("#404040");

  /// 按钮的文字颜色
  final Color digitColor = HexColor("#FCFCFC");
  final Color operatorColor = HexColor("#29E9BB");
  final Color bracketColor = HexColor("#C29CFF");
  final Color backColor = HexColor("#E92985");
  final Color clearColor = HexColor("#E92985");
  final Color equalColor = HexColor("#FCFCFC");
  final Color dotColor = HexColor("#C29CFF");

  final Color bgColor = HexColor("#161616");

  final Color resultColor = HexColor("#C29CFF");

  late List<String> exprCharList;
  late List<Button> buttons;

  late double keyBorderRadius;

  _HomePageState() : result = "0";

  @override
  void initState() {
    exprRadio = defaultExprRadio;
    resultRadio = defaultResultRadio;
    result = defaultResult;
    exprCharList = [];
    initButtons();
    super.initState();
  }

  void initButtons() {
    buttons = <Button>[];
    buttons.add(Button(key: "C", color: clearColor, bgColor: keyBgColor));
    buttons.add(Button(key: "X", color: backColor, bgColor: keyBgColor));
    buttons.add(Button(key: "(", color: bracketColor, bgColor: keyBgColor));
    buttons.add(Button(key: "+", color: operatorColor, bgColor: keyBgColor));

    buttons.add(Button(key: "1", color: digitColor, bgColor: keyBgColor));
    buttons.add(Button(key: "2", color: digitColor, bgColor: keyBgColor));
    buttons.add(Button(key: "3", color: digitColor, bgColor: keyBgColor));
    buttons.add(Button(key: "-", color: operatorColor, bgColor: keyBgColor));

    buttons.add(Button(key: "4", color: digitColor, bgColor: keyBgColor));
    buttons.add(Button(key: "5", color: digitColor, bgColor: keyBgColor));
    buttons.add(Button(key: "6", color: digitColor, bgColor: keyBgColor));
    buttons.add(Button(key: "*", color: operatorColor, bgColor: keyBgColor));

    buttons.add(Button(key: "7", color: digitColor, bgColor: keyBgColor));
    buttons.add(Button(key: "8", color: digitColor, bgColor: keyBgColor));
    buttons.add(Button(key: "9", color: digitColor, bgColor: keyBgColor));
    buttons.add(Button(key: "/", color: operatorColor, bgColor: keyBgColor));

    buttons.add(Button(key: "0", color: backColor, bgColor: keyBgColor));
    buttons.add(Button(key: ".", color: dotColor, bgColor: keyBgColor));
    buttons.add(Button(key: "%", color: operatorColor, bgColor: keyBgColor));
    buttons.add(Button(key: "=", color: equalColor, bgColor: equalKeyBgColor));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double itemWidth = (size.width - hSpace) / 4;
    double itemHeight = itemWidth / keyRadio;
    keyFontSize = min(itemWidth, itemHeight) / 3;
    keyBorderRadius = min(itemWidth, itemHeight) / 6;
    double keyboardHeight = (itemHeight + vSpace) * 4 + itemHeight;
    // 处理系统状态栏的背景色
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: bgColor,
    ));
    return Scaffold(
        body: Container(
      color: bgColor,
      child: Stack(
        children: <Widget>[
          /// 显示区域
          Positioned(
            top: 40,
            height: exprHeight,
            left: 20,
            right: 0,
            child: Wrap(
              children: buildExprWidgets(),
            ),
          ),

          /// 结果
          Positioned(
              left: 0,
              right: 20,
              height: resultHeight,
              bottom: keyboardHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    result,
                    style: TextStyle(
                        fontSize: resultHeight * resultRadio,
                        color: resultColor),
                  ),
                ],
              )),

          /// 键盘区域
          Positioned(
              bottom: 0,
              height: keyboardHeight,
              left: 0,
              right: 0,
              child: GridView.count(
                padding: const EdgeInsets.all(10),
                crossAxisCount: 4,
                mainAxisSpacing: vSpace,
                crossAxisSpacing: hSpace,
                childAspectRatio: keyRadio,
                shrinkWrap: true,
                children: buildKeyboard(),
              ))
        ],
      ),
    )
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  /// 处理键盘key点击事件
  void handleKeyTapped(String key) {
    switch (key) {
      case 'C':
        clearExprAndResult();
        break;
      case 'X':
        deleteLastExpr();
        break;
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':

        /// 前一个为1-9数字则追加到末尾(9->96)，
        /// 前一个为运算符，列表数组追加新元素数字
        /// 前一个为左括号，列表数组追加新元素数字
        if (exprCharList.isNotEmpty) {
          setState(() {
            if (ExprUtil.isDigit(exprCharList[exprCharList.length - 1]) &&
                exprCharList[exprCharList.length - 1] != '0') {
              exprCharList[exprCharList.length - 1] =
                  exprCharList[exprCharList.length - 1] + key;
            } else if (ExprUtil.isOperator(
                    exprCharList[exprCharList.length - 1]) ||
                exprCharList[exprCharList.length - 1] == ExprUtil.leftBracket) {
              exprCharList.add(key);
            }
          });
        } else {
          exprCharList.add(key);
        }

        break;
      case '0':

        /// 列表为空，直接添加
        /// 以0.或1.这样开头，追加到最后一个字符的末尾
        /// 以11这样开头，追加到最后一个字符的末尾
        /// 运算符，直接追加到列表末尾
        if (exprCharList.isEmpty) {
          exprCharList.add(key);
        } else if (exprCharList[exprCharList.length - 1]
            .startsWith(RegExp(r'[0-9].'))) {
          exprCharList[exprCharList.length - 1] =
              exprCharList[exprCharList.length - 1] + key;
        } else if (exprCharList[exprCharList.length - 1]
            .startsWith(RegExp(r'[1-9]'))) {
          exprCharList[exprCharList.length - 1] =
              exprCharList[exprCharList.length - 1] + key;
        } else if (ExprUtil.isOperator(exprCharList[exprCharList.length - 1])) {
          exprCharList.add(key);
        }
        break;
      case '.':
        // 如果前一个字符为数字，则追加，否则不处理。
        // 如前一个字符为0，则追加为0.
        // 如前一个字符为9.99 则不追加
        if (exprCharList.isNotEmpty &&
            ExprUtil.isDigit(exprCharList[exprCharList.length - 1]) &&
            !exprCharList[exprCharList.length - 1].contains(".")) {
          exprCharList[exprCharList.length - 1] =
              exprCharList[exprCharList.length - 1] + key;
        }
        break;
      case '+':
      case '*':
      case '/':
        if (exprCharList.isNotEmpty &&
            (ExprUtil.isDigit(exprCharList[exprCharList.length - 1]) ||
                ExprUtil.rightBracket ==
                    exprCharList[exprCharList.length - 1])) {
          setState(() {
            exprCharList.add(key);
          });
        }
        break;
      case '%':
        // 直接计算出结果
        if (exprCharList.isNotEmpty &&
            ExprUtil.isDigit(exprCharList[exprCharList.length - 1])) {
          exprCharList[exprCharList.length - 1] =
              (double.parse(exprCharList[exprCharList.length - 1]) / 100.00)
                  .toString();
        }
        break;
      case '-':

        /// 空可谓负数,否则必须加括号
        if (exprCharList.isEmpty) {
          setState(() {
            exprCharList.add(key);
          });
        } else {
          if (exprCharList[exprCharList.length - 1] == ExprUtil.rightBracket ||
              exprCharList[exprCharList.length - 1] == ExprUtil.leftBracket) {
            exprCharList.add(key);
          } else if (ExprUtil.isDigit(exprCharList[exprCharList.length - 1])) {
            exprCharList.add(key);
          }
        }
        break;
      case '(':
        // 空，上一个是数字，上一个是 '('
        if (exprCharList.isEmpty ||
            ExprUtil.isOperator(exprCharList[exprCharList.length - 1]) ||
            ExprUtil.leftBracket == exprCharList[exprCharList.length - 1]) {
          setState(() {
            exprCharList.add(key);
          });
        }
        break;
      case ')':
        if (exprCharList.isNotEmpty) {
          int leftCnt = getCount(exprCharList, "(");
          int rightCnt = getCount(exprCharList, ")");
          if (leftCnt > rightCnt) {
            setState(() {
              exprCharList.add(key);
            });
          }
        }
        break;
      case "=":
        calculateResult();
        break;
    }

    updateExprRadio();
  }

  /// 获取字符串s在列表list的出现次数
  int getCount(List<String> list, String s) {
    var cnt = 0;
    for (var i = 0; i < list.length; i++) {
      if (list[i] == s) {
        cnt++;
      }
    }
    return cnt;
  }

  /// 改变被点击图标的颜色
  void keyTapped(int index, String text) {
    if (kDebugMode) {
      print("点击按钮：$index, $text");
    }

    /// 单独处理 )
    if (text == ")") {
      setState(() {
        buttons[index].anotherTapped = true;
      });
      handleKeyTapped(text);
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {
          buttons[index].anotherTapped = false;
        });
        if (kDebugMode) {
          print("Timer stopped\n");
        }
      });
    } else {
      setState(() {
        buttons[index].tapped = true;
      });
      handleKeyTapped(text);
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {
          buttons[index].tapped = false;
        });
        if (kDebugMode) {
          print("Timer stopped\n");
        }
      });
    }
    if (kDebugMode) {
      print("表达式：$exprCharList");
    }
  }

  /// 根据输入的字符获取对应颜色
  Color getColorByText(String text) {
    switch (text) {
      case 'X':
        return backColor;
      case "(":
      case ")":
        return bracketColor;
      case "+":
      case "-":
      case "*":
      case "/":
        return operatorColor;
    }
    return digitColor;
  }

  /// 构建键盘组件
  List<Widget> buildKeyboard() {
    List<Widget> widgets = [];
    for (var i = 0; i < buttons.length; i++) {
      if (buttons[i].key == "(") {
        widgets.add(Row(
          children: [
            Expanded(
                child: Container(
              margin: const EdgeInsets.only(right: 5),
              child: GestureDetector(
                onTap: () {
                  keyTapped(i, buttons[i].key);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    buttons[i].key,
                    style: TextStyle(
                        color: buttons[i].color, fontSize: keyFontSize),
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: buttons[i].tapped
                          ? animationBgColor
                          : buttons[i].bgColor,
                      borderRadius:
                          BorderRadius.circular(keyBorderRadius * 0.75)),
                ),
              ),
            )),
            Expanded(
                child: Container(
              margin: const EdgeInsets.only(left: 5),
              child: GestureDetector(
                onTap: () {
                  keyTapped(i, ")");
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    ")",
                    style: TextStyle(
                        color: buttons[i].color, fontSize: keyFontSize),
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: buttons[i].anotherTapped
                          ? animationBgColor
                          : buttons[i].anotherBgColor,
                      borderRadius:
                          BorderRadius.circular(keyBorderRadius * 0.75)),
                ),
              ),
            )),
          ],
        ));
        continue;
      }
      widgets.add(GestureDetector(
        onTap: () {
          keyTapped(i, buttons[i].key);
        },
        child: AnimatedContainer(
          key: Key(buttons[i].key),
          duration: const Duration(milliseconds: 100),
          child: Text(
            buttons[i].key,
            style: TextStyle(color: buttons[i].color, fontSize: keyFontSize),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: buttons[i].tapped ? animationBgColor : buttons[i].bgColor,
              borderRadius: BorderRadius.circular(keyBorderRadius)),
        ),
      ));
    }
    return widgets;
  }

  /// 构建表达式组件
  List<Widget> buildExprWidgets() {
    List<Widget> widgets = [];
    for (var i = 0; i < exprCharList.length; i++) {
      widgets.add(Text(
        exprCharList[i],
        style: TextStyle(
            color: getColorByText(exprCharList[i]),
            fontSize: exprHeight * exprRadio),
      ));
    }
    return widgets;
  }

  /// 更新表达式缩放率
  void updateExprRadio() {
    setState(() {
      /// 长度超过多少就变小
      int len = 0;
      for (var i = 0; i < exprCharList.length; i++) {
        len += exprCharList[i].length;
      }
      double expo = len / 4;
      if (len % 4 == 0) {
        if (kDebugMode) {
          print("指数$expo");
        }
        exprRadio = max(pow(0.75, max(1, expo)) * defaultExprRadio, 0.2);
      }
    });
  }

  /// 清空表达式
  void clearExprAndResult() {
    setState(() {
      exprCharList = [];
      result = defaultResult;
      exprRadio = defaultExprRadio;
      resultRadio = defaultResultRadio;
    });
  }

  /// 回退
  void deleteLastExpr() {
    if (exprCharList.isNotEmpty) {
      setState(() {
        /// 如果是数字，回退一个字符就好了
        if (ExprUtil.isDigit(exprCharList[exprCharList.length - 1])) {
          String tmp = exprCharList[exprCharList.length - 1];
          tmp = tmp.substring(0, tmp.length - 1);
          exprCharList[exprCharList.length - 1] = tmp;
          if (tmp == "") {
            exprCharList.removeAt(exprCharList.length - 1);
          }
        } else {
          exprCharList.removeAt(exprCharList.length - 1);
        }
      });
      updateExprRadio();
    }
  }

  /// 计算结果
  void calculateResult() {
    try {
      List<String> suf = ExprUtil.middleToSuffixExpr(exprCharList);
      String res = ExprUtil.calculateExprResult(suf);
      if (kDebugMode) {
        print("中缀表达式$exprCharList");
        print("后缀表达式$suf");
      }
      setState(() {
        /// 超过16位，显示未科学计数法
        if (res.length >= 16) {
          result = double.parse(res).toStringAsExponential(8);
        } else {
          result = res;
        }
        resultRadio = pow(0.88, (result.length / 4)) * defaultResultRadio;
        if (kDebugMode) {
          print("计算结果$res");
          print("结果长度: $resultRadio");
        }

        /// 表达式清空
        exprCharList = [];
        exprCharList.add(result);
      });
    } catch (e) {
      if (kDebugMode) {
        print("计算异常:$e");
      }
    }
  }
}

class Button {
  String key;
  Color color;

  Color? bgColor;
  Color? anotherBgColor;

  bool anotherTapped;
  bool tapped;

  Button({required this.key, required this.color, required this.bgColor})
      : anotherBgColor = bgColor,
        tapped = false,
        anotherTapped = false;
}
