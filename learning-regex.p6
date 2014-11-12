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
