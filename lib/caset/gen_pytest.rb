#coding:utf-8
require 'yaml'

=begin
INPUT: PYCODE.py + ABSTRACT.yml
OUTPUT: tests/PYTEST
=end

=begin # ABSTRACT TEMPLATE
--- # MODULE_NAME

# [basic header]
path: THE_FOLDER_PATH_OF_MODULE_SOURCE
module: MODULE_NAME
file:
  FILENAME: # FILENAME INCLUDE ".py"

  # [import]
  import:
    - REFMOD_NAME # => import REFMOD_NAME
    - [REFMOD_NAME, SUB_REFMOD_NAME] # => from REFMOD_NAME import SUB_REFMOD_NAME
    - [REFMOD_NAME, SUB_REFMOD_NAME, ALIAS_NAME] # => from REFMOD_NAME import SUB_REFMOD_NAME as ALIAS_NAME

  # [external variables and functions]
  varc:
    - VAR_GLOBAL
    - [VAR_GLOBAL, MODE]
    - [VAR_GLOBAL, MODE, OG_VAR]
    - [VAR_GLOBAL, MODE, OG_VAR, TYPE] # => [VAR_NAME|WRAPPER_NAME, null, null, TYPE|null]
  func:
    - [[EXTN_FUN_NAME, ARGV...], [REF_VAR_NAME|REF_FUN_NAME...], [RETN_VAL...]] # => [[MUST, OPTIONAL...], [OPTIONAL...], [OPTIONAL...]]
    # no need to complete REF_STATEMENT and RETN_STATEMENT
  
  # [two way to note vars and funs in class]
  # one: only one class
  CLASS: 
    BODY
  # two: two or more classes
  CLASSES:
    - BODY

  # [body of class]
  CLASS:
    name: CLASS_NAME
    base: PARENT_CLASS_NAME

    varc: 
    - CLASS_VAR
    - [CLASS_VAR, MODE]
    - [CLASS_VAR, MODE, OG_VAR]
    - [CLASS_VAR, MODE, OG_VAR, TYPE] # => [VAR_NAME|WRAPPER_NAME, c|null, null, TYPE|null]
    func:
    - [[CLS_FUN_NAME]]
    - [[CLS_FUN_NAME, ARGV...]]
    - [[CLS_FUN_NAME, ARGV...], [REF_VAR_NAME|REF_FUN_NAME...]]
    - [[CLS_FUN_NAME, ARGV...], [REF_VAR_NAME|REF_FUN_NAME...], [RETN_VAL...]] # => [[MUST, OPTIONAL...], [OPTIONAL...], [OPTIONAL...]]
    # no need to complete REF_STATEMENT and RETN_STATEMENT

    attr: 
    - INS_VAR
    - [INS_VAR, MODE]
    - [INS_VAR, MODE, OG_VAR]
    - [INS_VAR, MODE, OG_VAR, TYPE] # => [VAR_NAME|WRAPPER_NAME, r|w|rw|i|null, ORIGINAL_VAR_NAME|null, TYPE|null]
    fun:
    - [[INS_FUN_NAME]]
    - [[INS_FUN_NAME, ARGV...]]
    - [[INS_FUN_NAME, ARGV...], [REF_VAR_NAME|REF_FUN_NAME...]]
    - [[INS_FUN_NAME, ARGV...], [REF_VAR_NAME|REF_FUN_NAME...], [RETN_VAL...]] # => [[MUST, OPTIONAL...], [OPTIONAL...], [OPTIONAL...]]
    # no need to complete REF_STATEMENT and RETN_STATEMENT
=end


=begin # EXAMPLE
--- # SERVICE_A
path: ~/workspace/dev/server/service_a
module: service_a

file: 
  service_a.py: 
    import: 
      - [__future__, absolute_import]
      - sys
      - [server.base_template, base_service, Service]
      - [server.service_b, ServiceB]

    classes: # or class and the value is only one item of hash
      - name: ServiceA
        base: Service
        attr: 
          - [result, rw, dict, ResultA] # attr as r|w|rw methods
          - [tmp, null, null]
        fun: 
          - [[__init__],[tmp]]
          - [[tmp_cal, tmp_val],[tmp, result], [result,size(result)]]
        varc:
          - a
          - [b, null, null, str]
          - c
        func: 
          - [[tmp_zzZ, a,b,c]]
    
    varc:
      - d
      - [e, null, null]
      - [f, null, null, int]
    func: 
      - [[tmp_ooO, d, e, f]]

=end


module Caset
  module Pytest
    module_function

    def gen option
      path, head, level = option[:path], option[:head], option[:level]
      doc = YAML.load(File.read(path))
      ohead = "#{doc['path']}/#{doc['module'] ? doc['module']+"/" : ''}"
      pkgroute = head+ohead.split(head)[-1].gsub('/','.')
      `mkdir -p tests/#{path.sub('.yml','')}`
    
      doc['file'].each do|filename, abstract|
        inner_fun_set = []
        classes = (abstract['classes'] || [abstract['class']] || []).compact
        classes.each do|klass|
          inner_funcs,inner_funs = [], []
    
          vars = klass['varc'] || []
          vars.each do|var|
            varname,varattr = var.instance_of?(Array) ? var[0..1] : [var,nil]
            handle = level.include?(:strict) ? "raise Exception(\"No Implement\")" : ""
            handle = level.include?(:fail) ? "assert False" : ""
            tips   = level.include?(:pending) ? "\"TODO: #{varname}#{varattr ? " :#{varattr}" : varattr}\"" : ""
            adaptr = level.include?(:pending) ? "  @pytest.mark.unfinished\n" : ""
            inner_funcs << "#{adaptr}  def test_#{varname}(self):\n    #{handle}#{tips.empty? ? tips : "\n    "+tips}\n"
          end
    
          funcs = klass['func'] || []
          funcs.each do|func|
            sign = func[0]
            next if sign[0]=='__init__'
            handle = level.include?(:strict) ?  "raise Exception(\"No Implement\")" : ""
            handle = level.include?(:fail) ? "assert False" : ""
            tips   = level.include?(:pending) ? "\"TODO: #{sign[0]}(#{sign[1..-1].join(', ')})\"" : ""
            adaptr = level.include?(:pending) ? "  @pytest.mark.unfinished\n" : ""
            inner_funcs << "#{adaptr}  def test_#{sign[0]}(self):\n    #{handle}#{tips.empty? ? tips : "\n    "+tips}\n"
          end
    
          vars = klass['attr'] || []
          vars.each do|var|
            varname,varattr = var.instance_of?(Array) ? var[0..1] : [var,nil]
            handle = level.include?(:strict) ? "raise Exception(\"No Implement\")" : ""
            handle = level.include?(:fail) ? "assert False" : ""
            tips   = level.include?(:pending) ? "\"TODO: #{varname}#{varattr ? " :#{varattr}" : varattr}\"" : ""
            adaptr = level.include?(:pending) ? "  @pytest.mark.unfinished\n" : ""
            inner_funs << "#{adaptr}  def test_#{varname}(self):\n    #{handle}#{tips.empty? ? tips : "\n    "+tips}\n"
          end
    
          funs = klass['fun'] || []
          funs.each do|fun|
            sign = fun[0]
            next if sign[0]=='__init__'
            handle = level.include?(:strict) ?  "raise Exception(\"No Implement\")" : ""
            handle = level.include?(:fail) ? "assert False" : ""
            tips   = level.include?(:pending) ? "\"TODO: #{sign[0]}(#{sign[1..-1].join(', ')})\"" : ""
            adaptr = level.include?(:pending) ? "  @pytest.mark.unfinished\n" : ""
            inner_funs << "#{adaptr}  def test_#{sign[0]}(self):\n    #{handle}#{tips.empty? ? tips : "\n    "+tips}\n"
          end 
    
          unless inner_funcs.empty?
            inner_funcs.unshift "  def teardown_class(self):\n    \"TODO: TEARDOWN CLASSMETHOD\"\n"
            inner_funcs.unshift "  def setup_class(self):\n    \"TODO: SETUP CLASSMETHOD\"\n"
          end
          unless inner_funs.empty?
            inner_funs.unshift "  def teardown_method(self):\n    \"TODO: TEARDOWN METHOD\"\n"
            inner_funs.unshift "  def setup_method(self):\n    \"TODO: SETUP METHOD\"\n"
          end
    
          inner_tmp = inner_funcs + inner_funs
          inner_tmp.unshift "class #{klass['name']}Test():" unless inner_tmp.empty?
          inner_fun_set += inner_tmp
        end
        
        outer_funcs = []
        funcs = abstract['func'] || []
        funcs.each do|func|
          sign = func[0]
          handle = level.include?(:strict) ?  "raise Exception(\"No Implement\")" : ""
          handle = level.include?(:fail) ? "assert False" : ""
          tips   = level.include?(:pending) ? "\"TODO: #{sign[0]}(#{sign[1..-1].join(', ')})\"" : ""
          adaptr = level.include?(:pending) ? "@pytest.mark.unfinished\n" : ""
          outer_funcs << "#{adaptr}def test_#{sign[0]}():\n  #{handle}#{tips.empty? ? tips : "\n  "+tips}\n"
        end
    
        unless outer_funcs.empty?
          outer_funcs.unshift "def teardown_function():\n  \"TODO: TEARDOWN FUNCTION\"\n"
          outer_funcs.unshift "def setup_function():\n  \"TODO: SETUP FUNCTION\"\n"
        end
    
        content = (inner_fun_set + outer_funcs)
        unless content.empty?
          content.unshift "# import sys\n# sys.path.append(\".\")\n# PACKAGE ROUTE: #{pkgroute}#{filename[0..-4]}\n"
          content.unshift "#coding:utf-8\nimport pytest\n"
          testpath = "tests/#{path.sub('.yml','')}/test_#{filename}"
          File.write testpath, content.join("\n") unless File.exist?(testpath)
        end
      end
    end
  end
end
