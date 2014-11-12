#!perl6

use v6;

# 空白通常是忽略的，除非用 :s 或 :sigspace 声明
# 注释是从 # 开始到结尾的部分
# 字面量用单引号或双引号引起

say so 'two words' ~~ / 'two words' /; # True

say so 'a:b' ~~ / "a:b" /; # True

# 井号也需要引起

say so '#' ~~ / '#' /;

# match 结果保存在 $/ 内部变量中：

if 'abcdef' ~~ / de / {
    say ~$/;  # de
    say $/.prematch; # abc
    say $/.postmatch; # f
    say $/.from; # 3
    say $/.to; # 5
};

# 点可以 . 匹配任何字符，包括 \0 和 \n

say so 'perl' ~~ /per./;

# \w, \W, \d, \D, \t, \T, \v, \V, \n, \N, \h, \H
# 保持原有 Perl 5 的含义

# Perl6 还从 Perl5 借鉴了许多字符类型的定义：
# <:L>  Letter
# <:LC> Cased_Letter
# <:Lu> Uppercase_Letter
# <:Ll> Lowercase_Letter
# <:Lt> Titlecase_Letter
# <:Lm> Modifer_Letter
# <:Lo> Other_Letter
# <:M>  Mark
# <:Mn> Nonspacing_Mark
# <:Mc> Spacing_Mark
# <:Me> Enclosing_Mark
# <:N>  Number
# <:Nd> Decimal_Number
# <:Nl> Letter_Number
# <:No> Other Number
# <:P>  Punctuation (also Punct)
# <:Pc> Connector_Punctuation
# <:Pd>	Dash_Punctuation
# <:Ps>	Open_Punctuation
# <:Pe>	Close_Punctuation
# <:Pi>	Initial_Punctuation
# <:Pf>	Final_Punctuation
# <:Po>	Other_Punctuation
# <:S>	Symbol
# <:Sm>	Math_Symbol
# <:Sc>	Currency_Symbol
# <:Sk>	Modifier_Symbol
# <:So>	Other_Symbol
# <:Z>	Separator
# <:Zs>	Space_Separator
# <:Zl>	Line_Separator
# <:Zp>	Paragraph_Separator
# <:C>	Other
# <:Cc>	Control (also Cntrl)
# <:Cf>	Format
# <:Cs>	Surrogate
# <:Co>	Private_Use
# <:Cn>	Unassigned
# <:!Lu> match a single character that isn't <:Lu>

# 在尖括号内可以使用算术运算符

# 不能通过测试
say so '123' ~~ { <:Ll + :N> }; 
say so '123' ~~ { <:Ll - :N> };
say so '123' ~~ { <:Ll | :N> };
say so '123' ~~ { <:Ll & :N> };
say so '123' ~~ { <:Ll ^ :N> };

say so 'abc' ~~ { <:Ll> }; 

# 自定义字符集

say so 'abc123' ~~ / <[a .. c123]> /;
say so '24680' ~~ / <[\d] - [13579]> /;
say so '2468' ~~ / <[02468]> /;

# +, *, ?, 在 Perl6 中的行为和 Perl5 是相同的

say so 'int = 1' ~~ /'[' \w+ ']' || \S+ \s* '=' \s* \S* /;

# 锚定符 定位符
# 定位字符串的开始用 ^

say so 'properly' ~~ /perl/; # True
say so 'properly' ~~ /^perl/; # False
say so 'perly' ~~ /^perl/; # True

# 匹配数量用 ** min..max

say so 'aooob' ~~ / ao**1..3b /;

# 行开始用 ^^, 行结束用 $$
my $str = "hello world\nevery one";
say so $str ~~ /^^ hello/; # True
say so $str ~~ /^^ world/; # False
say so $str ~~ /^^ every/; # True
say so $str ~~ /^^ one/; # False

# 单词的边界用 << 和 >>
# question one: 如果单词的定义不同，如何重新
# 定义边界的定义
# question two: 如果有类似 << <regex> 的定义
# answer: use space

$str = 'The quick brown fox';
say so $str ~~ /br/;     # True
say so $str ~~ /<< brown <ws> >>/;  # True
say so $str ~~ /<< <ws> >>/; # 
say so $str ~~ /br >>/;  # False
say so $str ~~ /own/;    # True
say so $str ~~ /<< own/; # False
say so $str ~~ /own >>/; # True

# 分组和捕获

say so 'bc' ~~ / a || b c /;  # True
say so 'ac' ~~ / (a || b) c /; # False

if 'abc' ~~ m{ (a) b (c) } { say "0: $0; 1: $1" }
if 'abc' ~~ m{ (a) b (c) } { say $/.list.join: ',' }

# 不捕获的分组 [ .. ]

if 'abc' ~~ / [a|b] (c) / { say ~$0 }

# 当然可以用 '..' ".." 来分不用捕获的分组

if 'abc' ~~ / 'ab'+ (c) / { say ~$0 }

# 捕获的内置变量是从 0 索引开始的：

if 'xyabc' ~~ / (x) (y) || (a) (.) (.) / { say 'ok' }
#               $0   $1     $0  $1  $2

# 捕获的结果是嵌套的一个数据结构，这和 Perl5 不同

if 'abc' ~~ / (a (.) (.) ) / {
    say $0.WHAT; # (Match)
    say "Outer: $0"; # abc
    say "Inner: $0[0] and $0[1]"; # b and c
}

# 命名捕获

if 'abc' ~~ / $<myname> = [ \w+ ] / {
    say ~$<myname>; # abc
    say ~$/{ 'myname' }; # abc
    say ~$/<myname>; # abc
}

# 定义规则

my regex line { \N*\n }
if "abc\ndef" ~~ /<line> def/ {
    say "Fist line: ", $<line>.chomp;
    # output -> first line: abc
}

# my regex 定义的规则会自动捕获，除非前面加点

if "abc\ndef" ~~ /<.line> def/ {
    say "match last line add def";
}

# 如果捕获的内容和规则名字不同，可以 <capturename=regexname>

my regex header { \s* '[' (\w+) ']' \h* \n+ }
my regex identifier  { \w+ }
my regex kvpair { \s* <key=identifier> '=' <value=identifier> \n+ }
my regex section {
    <header>
    <kvpair>*
}
my $contents = q:to/EOI/;
    [passwords]
        jack=password1
        joy=muchmoresecure123
    [quotas]
        jack=123
        joy=42
EOI

my %config;
if $contents ~~ /<section>*/ {
    for $<section>.list -> $section {
        my %section;
        for $section<kvpair>.list -> $p {
            say ~$p<value>;
            %section{ $p<key> } = ~$p<value>;
        }
        %config{ $section<header>[0] } = %section;
    }
}
say %config.perl;
# ("passwords" => {"jack" => "password1", "joy" => "muchmoresecure123"},
#    "quotas" => {"jack" => "123", "joy" => "42"}).hash

# 匹配的另外一种写法，看起来更好
# 尤其是动态生成的正则表达式

my $regex = /../;           # 定义
if 'abc'.match($regex) {    # 匹配
    say "'abc' has at least two characters";
}

# 正则限定词

# 正则限定词 Adverbs 改变正则表达式的许多默认行为

# :i 忽略大小写 :ignorecase 的缩写

say so 'a' ~~ /A/; # Flase
say so 'a' ~~ /:i A/; # True
say so 'a' ~~ m:i/A/; # True

# output:
#     ba
#     aA

# 这两种写法是相同的

my $rx1 = rx:i/a/;      # 表达式前面的写法
my $rx2 = rx/:i a/;     # 在表达式内部的写法

# 这两个不同

my $rx3 = rx/a :i b/;   # 匹配只忽略 b 的大小写
my $rx4 = rx/:i a b/;   # 匹配所有的内容都忽略大小写

# 分组中的限定词只作用域分组内部

my $rx5 = rx/ (:i a b) c /;   # 只匹配 'ABc' 但不匹配 'ABC'
my $rx6 = rx/ [:i a b] c /;   # 匹配 'ABc' 但不匹配 'ABC'

# :r 禁止回溯 :ratchet 的缩写
# 回溯会严重降低匹配的效率，一个依靠回溯的匹配总是
# 可以优化成不需要回溯的匹配，从而提高效率

say so 'abc' ~~ / \w+ . /;  # True
say so 'abc' ~~ / :r \w+ ./; # False

# :r 模式如此有用，Perl6 专门定义了一个关键字来声明它
# regex token rule 的命名规则，不能有减号
my token thing1 { ... };
# 相当于 
my regex thing2 { :r ... };

# 空格恢复 :s or :sigspace 

# :s 模式让正则表达式中的空格成为匹配自身的符号

say so "I used Photoshop " ~~ m:i/ photo shop /; # True
say so "I used Photoshop " ~~ m:i:s/ photo shop /; # False
say so "I used photo shop " ~~ m:i:s/ photo shop /; # True

# 关键字 rule 的默认行为相当于 { :r :s ... }
# 用空格代表一个以上的空格

if "a  b" ~~ m:s/a b/ {
    say '"a  b" match m:s/a b/';
}

if "a  b" ~~ /a <.ws> b/ {
    say '"a  b" match /a <.ws> b/';
}

# 指定匹配位置 :c or :continue
# 默认匹配是从字符串的开始进行的，但 :c 改变了这个行为

given 'a1xa2' {
    say ~m/a./;         # a1
    say ~m:c(2)/a./;    # a2
}

# 书写 regex 的建议
# 1. 尽量用空格增加可读性

# 可读性差的写法
my regex float { <[+-]>?\d*'.'\d+[e<[+-]>?\d+]? };

# 可读性好的写法
my regex float {
    <[+-]>?     # optional sign
    \d*         # leading digits, optional
    '.'
    \d+
    [           # optional exponent
        e <[+-]>?  \d+
    ]?
}

# 更好的写法

my token sign { <[+-]> }
my token decimal { \d+ }
my token exponent { 'e' <sign>? <decimal> }
my regex float {
    <sign>?
    <decimal>?
    '.'
    <decimal>
    <exponent>?
}

# 扩展写法变得容易

my regex float {
    <sign>?
    [
    || <decimal>?  '.' <decimal> <exponent>?
    || <decimal> <exponent>
    ]
}

# 解析 ini 的新的写法

grammar IniFormat {
    token ws { <!ww> \h* }
    rule header { '[' (\w+) ']' \n+ }
    token identifier  { \w+ }
    rule kvpair { \s* <key=identifier> '=' <value=identifier> \n+ }
    token section {
        <header>
        <kvpair>*
    }
}

    token TOP {
        <section>*
    }
}

my $contents = q:to/EOI/;
    [passwords]
        jack = password1
        joy = muchmoresecure123
    [quotas]
        jack = 123
        joy = 42
EOI
say so IniFormat.parse($contents);

