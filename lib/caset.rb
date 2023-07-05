#coding:utf-8
require "caset/version"
require 'caset/gen_caset'
require 'caset/gen_bdd'
require 'caset/gen_spec'
require 'caset/gen_pytest'

module Caset
  class Error < StandardError; end
  
  #### 基础管道 ####
  def self.construct
    @__caset_register__ = { before_each: [], after_each: [], before_all: [], after_all: [], steps: {}, story: [] }
    @__caset_report__ = []
    @__caset_document__ = []
    @__caset_indent__ = ""
  end
  
  def self.register
    @__caset_register__
  end
  
  def self.report
    @__caset_report__
  end
  
  def self.document
    @__caset_document__
  end
  
  def self.indent
    @__caset_indent__
  end
  
  def msg context
    if context.instance_of?(Array)
      context.each do|pile|
        Caset.report << Caset.indent+pile.to_s
      end
    else
      Caset.report << Caset.indent+context.to_s
    end
    Caset.report[-1]
  end
  alias :记录 :msg
  
  def mark context
    if context.instance_of?(Array)
      context.each do|pile|
        Caset.document << Caset.indent+pile.to_s
      end
    else
      Caset.document << Caset.indent+context.to_s
    end
    Caset.document[-1]
  end
  alias :标记 :mark
  
  def pending reason=nil
    mark "pending"+(reason ? ":#{reason}" : '')
    msg "pending"+(reason ? ":#{reason}" : '')
  end
  
  def 待定 原因=nil
    mark "待定"+(原因 ? ":#{原因}" : '')
    msg "待定"+(原因 ? ":#{原因}" : '')
  end
  
  def star context
    mark "* #{context}"
  end
  alias :星 :star
  
  def plus context
    mark "+ #{context}"
  end
  alias :加 :plus

  def minus context
    mark "- #{context}"
  end
  alias :减 :minus
  
  def Give context
    mark "Give #{context}"
  end
  
  def When context
    mark "When #{context}"
  end
  
  def Then context
    mark "Then #{context}"
  end
  
  def And context
    mark "     #{context}"
  end
  
  def 如果 上下文
    mark "如果#{上下文}"
  end
  
  def 当 上下文
    mark "当#{上下文}"
  end
  
  def 那么 上下文
    mark "那么#{上下文}"
  end
  
  def 而且 上下文
    mark "而且#{上下文}"
  end
  
  def self.indent= indent
    @__caset_indent__ = indent
  end
  
  #### 设定结构 ####
  def scenario description,options=[],&block
    # registration
    Caset.construct
    unless options.include?(:bm_story) or options.include?(:bm_step)
      block.call # all blocks regist
    else
      require 'benchmark'
    end
    Benchmark.bm{|x| @_bm_story_ = x;block.call } if options.include?(:bm_story)
    Benchmark.bm{|x| @_bm_step_ = x;block.call } if options.include?(:bm_step)
    
    # execution
    msg "====#{description}===="
    mark "====#{description}===="
    
    Caset.indent = "  " # for before-all
    msg "== before all ==" unless Caset.register[:before_all].empty?
    mark "preconfig:" unless Caset.register[:before_all].empty?
    Caset.register[:before_all].each do|before_all_transaction|
      Caset.indent = "    " # for inner before-all
      before_all_transaction.call
    end
    
    Caset.register[:story].each do|stories|
      description,story = stories
      run_case(description,story)
    end
    
    Caset.indent = "  " # for after-all
    msg "== after all ==" unless Caset.register[:after_all].empty?
    mark "postconfig:" unless Caset.register[:after_all].empty?
    Caset.register[:after_all].each do|after_all_transaction|
      Caset.indent = "    " # for inner after-all
      after_all_transaction.call
    end
    
    Caset.indent = "" # for scenario
    msg "==== end scenario ===="
    mark "==== end scenario ===="
  end
  
  def before options=[:each],&block
    if options.include?(:each)
      Caset.register[:before_each] << block
    elsif options.include?(:all)
      Caset.register[:before_all] << block
    else
      # :off
    end
  end
  
  def after options=[:each],&block
    if options.include?(:each)
      Caset.register[:after_each] << block
    elsif options.include?(:all)
      Caset.register[:after_all] << block
    else
      # :off
    end
  end
  
  def usecase description,options=[],&block
    unless options.include?(:off)
      Caset.register[:story] << [description,block]
    end
  end
  alias :ustory :usecase
  
  def ustep id, description=nil,options=[], &block
    unless options.include?(:off)
      Caset.register[:step] ||= {}
      Caset.register[:step][id] = block
    end
  end
  
  #### 控制结构 ####
  def run_step(id, description=nil, *args)
    Caset.indent = "    "
    mark "#{id}.#{description}"
    if Caset.register[:step][id]
      msg "<#{id}>#{description}"
      Caset.indent = "      "
      
      unless @_bm_step_
        Caset.register[:step][id].call(*args)
      else
        @_bm_step_.report(id.to_s+"."+description.to_s){Caset.register[:step][id].call(*args)}
      end
  
    else
      msg "<Warning>You are trying to call a step(#{id}) yet defined!"
    end
    Caset.indent = "    "
  end
  
  # steps = [step,...]
  # step = {:id=>id, :desc=>description, :args=>args}
  def run_steps(steps)
    steps.each do|step|
      run_step step[:id],step[:desc],*(step[:args]||[])
    end
  end
  
  def run_case description,block
    Caset.indent = "  " # for before-each
    msg "== before_each ==" unless Caset.register[:before_each].empty?
    mark "prepare:" unless Caset.register[:before_each].empty?
    Caset.indent = "    " # for inner before-each
    Caset.register[:before_each].each do|before_each_transaction|
      before_each_transaction.call
    end
    
    Caset.indent = "  " # for ustory
    msg "#{description}"
    mark "[#{description}]"
    Caset.indent = "    " # for inner ustory
    unless @_bm_story_
      block.call
    else
      @_bm_story_.report(description){block.call}
    end
    
    Caset.indent = "  " # for after-each 
    msg "== after each ==" unless Caset.register[:after_each].empty?
    mark "posthandle:" unless Caset.register[:after_each].empty?
    Caset.indent = "    " # for inner after-each
    Caset.register[:after_each].each do|after_each_transaction|
      after_each_transaction.call
    end
    
    Caset.indent = "  " # return to ustory level
  end
end

class Numeric
  def is title,left='(',right=')'
    Caset.document
    Caset.document << "#{Caset.indent}#{left}#{self}#{right}#{title}\n"
  end
  
  def 是 标题,左='（',右='）';is 标题,左,右;end
end

class String
  def is title,left='(',right=')'
    Caset.document
    Caset.document << "#{Caset.indent}#{left}#{self}#{right}#{title}\n"
  end
  
  def 是 标题,左='（',右='）';is 标题,左,右;end
end

