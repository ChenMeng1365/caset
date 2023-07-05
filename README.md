# caset

这是一个用例组织框架，是学习block的基本练手

简化spec，在一些没有spec的场合组织代码用（现在应该没有这样的地方了）

## How To Use

```ruby
require 'caset'
include Caset

scenario 'Your scenario name',[:bm_step] do
  before [:all] do
    msg "起床"
  end
  
  before [:each] do
    mark "准备"
  end
  
  ustep 1,"符号" do|param|
    star "梳头"
    plus "刷牙"
    minus "洗脸"
  end
  
  ustep 2,"符号简写" do|param|
    星 "穿鞋"
    加 "喝粥"
    减 "出行"
  end
  
  ustep 3,"序号" do|param|
    1.is "卖蛋"
    2.is "买茶"
  end
  
  ustep 4,"文字" do|param|
    '一'.是 "为了维生"
    '二'.是 "为了兴趣"
    "当然".是 "也不一定的", '咳咳,','...'
  end
  
  ustep '5',"Cucumber" do|param|
    Give "some conditions"
    When "something happen"
    Then "will get the results"
    And "some exceptions maybe"
  end
  
  ustep '6',"中文Cucumber" do|param|
    如果 "存在某种条件"
    而且 "处于这种场合"
    当 "发生某些行为"
    那么 "会有这些结果"
  end
  
  ustory "书写方法1" do
    run_step(1,"使用符号简写")
    run_step(2,"使用符号简写")
    run_step(3,"使用序号")
    run_step(4,"使用文字")
  end
  
  ustory "书写方法2" do
    run_steps [ {id:'5',desc: "使用Cucumber"}, {id:'6', desc:"使用中文Cucumber"} ]
  end
  
  ustory "待定" do
    pending
  end
  
  after [:each] do
    记录 "躺下"
  end
  
  after [:all] do
    标记 "放松"
  end
end

puts "","The Running Report is",Caset.report,"","The Specific Document is",Caset.document
```

## AutoGenerate

运行下列脚本生成用例集

```ruby
include Caset
auto_story(casename)
```

如果你想使用BDD/Spec框架，也可以通过一些方法生成对应的简单模板

```ruby
BDD::gen((ARGV[0] || "xxx"),(ARGV[1] || "standard" || "background" || "outlines" || "steptables"))

Spec.gen ARGV,template 
```

## Pytest.gen

对于一个或一组python代码，给出其YAML摘要文件，生成对应pytest的单元测试框架tests

```ruby
Caset::Pytest.gen option={path: 'xxx.yml', level: %{pending false}.map{|a|a.to_sym}, head: 'xxx'}
```

```shell
vim ./pytest.ini
[pytest]
markers = 
  unfinished: aaa
  finished: zzz

pytest .
```
