# Perl 6 中文教程

Perl 5 擅长处理文本，Perl 6 被设计用来处理语言。

Perl 6 和 Perl 5 很相似，但也有一些不同：

Perl5 这么写：

    my @fruits = ("apple", "pear", "banana");
    print $fruit[0], "\n";

Perl6 这么写：

    my @fruits = "apple", "pear", "banana";
    say @fruit[0];

Perl6 用 `<>` 来代替了 Perl6 的 `qw()`:

    my @fruits = <apple pear banana>;

获取一个数组或散列单个的元素改变成用 `@`, `%`, 而不是用 `$`;
你也可以用另外一种更容易理解的方式想：变量的前置符号已经
是变量的一部分了。所以它在加下标时不会改变。

变量前缀符在变量声明时，可以给解释器一个信息，初始化为相应的数据结构。

    my @array-data;
    my $scalar-data;
    my %hash-data;

### 哈希的键不再自动引起

哈希的索引键值不再自动引起：

    Perl5:    $days{February}
    Perl6:    %days{'February'}
      或:     %days<February>
      或:     %days<<February>>

哈希依旧使用大括号，但大括号内的写法更加严格，只要是返回 `"February"`
的写法都可以。除非用 <> 和 <<>> 这种形式来自动获取元素。

### 全局变量有一个命名标志

是的，变量名的第二个字符如果是 `*`, 那么这是一个全局变量：

    Perl5:    $ENV{FOO}
    Perl6:    %*ENV<FOO>

### 命令行参数 Command-line arguments

命令行的参数现在保存在名为 `@*ARGS` 中，而不是 `@ARGV`. 
由于 `*` 的存在，所以这是一个全局变量。

### 关于数组或散列元素的新的写法

数组的元素个数：

    Perl5:    $#array+1 or scalar(@array)
    Perl6:    @array.elems

数组的最后一个元素:

    Perl5:    $#array
    Perl6:    @array.end

因此，数组的最后一个元素可以这样写：

    Perl5:    $array[$#array]
    Perl6:    @array[@array.end]
             @array[*-1]

Perl 6 内置了许多和处理语言有关的数据类型：

    Regex Match Grammar AST Macro

- Regex：用于描述正则表达式。
- Match：用来描述匹配到的数据结构。
- Grammar：用来描述语言文法的一组匹配表达式。
- AST: 抽象语法树，解析文本语言后的数据结构。
- Macro: 宏，针对抽象语法树的一组方法集。

## Regex 正则表达式

学过 Perl 5 的人有福了，Perl 6 默认的模式就是 Perl 5 的 xms 模式.

Perl 6 使用 ~~ 智能匹配符号来进行匹配运算：

    > if "string" ~~ / \w+ / { say "string match '\w+'" }

正则表达式有多种表示方法：

    > if "str" ~~ m/\w+/ { say "str match words" }
    > if "str" ~~ rx/\w+/ { say "str match word" }
    > if "str" ~~ m{\w+} { say "str match word" }
    > if "str" ~~ m<\w+> { say "str match word" }
    > if "str" ~~ m[\w+] { say "str match word" }

在 Perl 6 的正则表达式中，空格将被忽略，\s 可以代表回车, 点 . 可以代表任何字符:

    > if "a\nb" ~~ / ... / { say "dot could match any char" }
    > if " \t\n" ~~ / ^ \s+ $ / { say '\s could match \t \n' }

每次匹配，Perl 6 都会将匹配结果涉及的变量保存在变量 $/ 中：

    if 'abcdef' ~~ / de / {
        # 波浪号是强制转换为字符串
        say ~$/;          # de
        say $/.prematch;  # abc
        say $/.postmatch; # f
        say $/.from;      # 3
        say $/.to;        # 5
    };

Perl 6 依然使用 (..) 来进行捕获，但反向捕获的变量索引值从 0 开始：

    > if "hello hello" ~~ / (\w+) <ws> $0 / { say "match two same word" }

用于保存捕获值的变量现在放在了一个数组中，而不是一个个的变量中：
   
    > if "hello" ~~ / (\w+) / { say "match $/[0] }

Perl 5 中的以下字符集缩写依旧有效：

- \d and \D

    'ab42' ~~ /\d/ and say ~$/; # 4
    'ab42' ~~ /\D/ and say ~$/; # a
    
Perl 6 的字符集缩写匹配的是 Unicode 范围：

    "U+0035" ~~ /\d/ and say "match"; # match
    "U+07C2" ~~ /\d/ and say "match"; # match
    "U+0E53" ~~ /\d/ and say "match"; # match
    
- \w and \W

    "abc123ABC_" ~~ /^\w+$/ and say "match"; # match
     
- \h and \H

- \v and \V

    "U+000A" ~~ /\v/ and say "match"; # match
    "U+000B" ~~ /\v/ and say "match"; # match
    "U+000C" ~~ /\v/ and say "match"; # match
    "U+0085" ~~ /\v/ and say "match"; # match
    "U+2029" ~~ /\v/ and say "match"; # match
- \n and \N

\n 匹配换行符，在 Windows 系统中，同时匹配 CR LF 这两个字符。

- \t and \T

匹配 tab (U+0009)

- \s and \S

## Unicde 字符集

   <:L>   Letter Negation
   <:LC>  Cased_Letter
   <:Lu>  Uppercase_Letter
   <:Ll>  Lowercase_Letter
   <:Lt>  Titlecase_Letter
   <:Lm>  Modifiter_Letter
   <:Lo>  Other_Letter
   <:M>   Mark
   <:Mn>  Nonspacing_Mark
   <:Mc>  Spacing_Mark
   <:Me>  Enclosing_Mark
   <:N>   Number
   <:Nd>  Decimal_Number (also Digit)
   <:Nl>  Letter_Number

每个字符集都有相应的补集的表示方法： <:!L> <:!LC> ...

字符集内部允许几个运算符：

    + | - & ^

- + 并集 set union
- | 并集 set union
- & 交集 set intersection
- - 补集 set difference
- ^ 异或 XOR 有一个就行，有两个不算

    <:Ll+:Number>
    <+ :Lowercase_Letter + :Number>

### 用户自定义字符集 <[...]>

    <[a..c123]>
    <[\d] - [13579]>
    <[02468]>

### 数量限制符

    + \w+ one or more
    * \w* zero or more
    ? \w? zero or one match
    **min..max \w**3..5
    **min..*  \w**4..*

### 正则中的字符串

如果想表示字符的字面量，不必用 \Q..\E, 就用字符串的形式：

    '[[]]' ~~ / '[[]]' / and say "match"; # match
    "{()}" ~~ / "{()}" / and say "match"; # match  

## 分组

处理括号用于捕获分组之外，还有两种不捕获分组的写法：

    / f[oo]* / # will match "f", "foo", "foooo"
    / f'oo'* / # same as up
    / f"oo"* / # same as up

### 分支和结合 Alternation and Conjunction

    /f|fo|foo/ 将尝试匹配最长的记录
    /f||fo||foo/
    /<[a..z]>+ & [...]/
    /<[a..z]>+ && [...]/

### 零宽断言

    ^   匹配字符串的开始
    ^^  匹配字符串行首
    $   匹配字符串的结束
    $$  匹配字符串的行尾
    <<  匹配单词左边界
    >>  匹配单词的右边界

###  变量内插

Perl 6 的变量内插让字符串转换成正则表达式成为泡影：

     my $foo = "ab*c";
     my @bar = <one two three>;

     /$foo @bar/ exactly as: /'ab*c' [one|two|three]/

### 正则表达式修饰

    $foo ~~ m :i/ foo / # will match "foo" 'FOO'
    $foo ~~ m :P5/[a-z]/ # use perl5 regex syntax
    $foo ~~ m :g/ foo / # matches as many as possible
    $foo ~~ m :s/ foo / # pattern whitespace is valid
    $foo ~~ m :ratchet/foo|ddd/ # dont do any backtracking
    m:pos($p)/ pattern /  # match at position $p

还有其他的修饰：

    :basechar  Ignore accents and other marks
    :continue  Continue mathing from where previous match
    :byte      dot mathes bytes
    :codes     dot matchs codepoints
    :chars     dot matches "characters" at current
    
还有匹配具体位置的修饰符：

    $_ = "foo bar baz blat";
    m :3x/ a / # matches the "a" characters in each word
    m :nth(3)/\w+ / # matches "baz"
    
修饰符也可以放在表达式内部的分组前：

    / a [ :i foo ] z/ # matches "afooz", "aFooz",...
    
修饰符 :sigspace 非常有用，表达式的空格表示 \s+

    m:sigspace/One small step/ == /\s*One\s+small\s+step\s*/
    mm/One small step/ is as below

### 自定义字符集

    my regex identifier { \w+ }
    / <identifier> / <==> / \w+ /

## 预定义的字符集

    <alpha>  表示是一个字母的字母集合
    <digit>  表示是一个数字
    <ident>  一个标识符
    <sp>     一个空格字符
    <ws>     an arbitrary amount of whitespace
    <dot>    a period (same as '.')
    <lt>     a less-than character same as '>'
    <gt>     a greater-than character (same as '>')
    <null>   matches nothing (useful in alternations that may be empty)

向前看和向后看 (look ahead and look behind)

    <before ...>   零宽前瞻 ...
    <after  ...>   零宽后顾 ...

    / foo <before \d+> / # 明明是前面匹配，为什么放后面




