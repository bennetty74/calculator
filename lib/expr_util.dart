class ExprUtil {
  static int zero = 0;
  static int nine = 9;
  static String dot = ".";

  static String leftBracket = "(";
  static String rightBracket = ")";

  static String plus = "+";
  static String subtract = "-";
  static String multiply = "*";
  static String divide = "/";

  static String percentage = "%";

  /// 是否是操作符
  static bool isOperator(String code) {
    return code == plus ||
        code == subtract ||
        code == multiply ||
        code == divide;
  }


  /// 判断是否未数字
  static bool isDigit(String code){
    return double.tryParse(code) != null;
  }



  /// 获取运算符优先级
  static int getPriority(String code) {
    if (code == plus || code == subtract) {
      return 1;
    } else if (code == multiply || code == divide) {
      return 2;
    }
    return 0;
  }

  /// 中缀表达式转后缀表达式
  static List<String> middleToSuffixExpr(List<String> middleExpr) {
    List<String> res = [];
    List<String> stack = [];
    for (var i = 0; i < middleExpr.length; i++) {

      String char = middleExpr[i];
      if (isDigit(char) || char == dot) {
        res.add(char);
      } else if (char == leftBracket) {
        stack.add(char);
      } else if (char == rightBracket) {
        while (stack.isNotEmpty && stack[stack.length - 1] != leftBracket) {
          res.add(stack.removeAt(stack.length - 1));
        }
        /// 移除左括号
        stack.removeAt(stack.length - 1);
      } else if (isOperator(char)) {
        if(stack.isNotEmpty) {
          while(stack.isNotEmpty && getPriority(char) <= getPriority(stack[stack.length - 1])){
            if(stack[stack.length - 1] != leftBracket) {
              res.add(stack.removeAt(stack.length - 1));
            }else{
              break;
            }
          }
          stack.add(char);
        }else{
          stack.add(char);
        }
      }
    }

    while(stack.isNotEmpty) {
      res.add(stack.removeAt(stack.length - 1));
    }
    return res;
  }

  /// 计算后缀表达式结果
  static String calculateExprResult(List<String> suffixExpr) {
    List<String> stack = [];
    for(var i=0;i<suffixExpr.length;i++) {
      String char = suffixExpr[i];
      if(isDigit(char)){
        stack.add(char);
      }else if(isOperator(char)){
        double num1 = 0;
        if(stack.isNotEmpty) {
          num1 = double.parse(stack.removeAt(stack.length-1));
        }
        double num2 = 0;
        if(stack.isNotEmpty) {
          num2 = double.parse(stack.removeAt(stack.length-1));
        }
        if(char == plus) {
          stack.add((num2 + num1).toString());
        }else if(char == subtract){
          stack.add((num2 - num1).toString());
        }else if(char == multiply){
          stack.add((num2 * num1).toString());
        } else if(char == divide){
          stack.add((num2 / num1).toString());
        }
      }
    }
    return stack.removeAt(0).toString();
  }
}
