#coding:utf-8

# Usage:
# include Caset
# casename = ARGV[0] || "temp"
# auto_story casename

module Caset
THE_USTORY_TEMPLATE = %Q{#coding:utf-8
$:
require 'caset'
include Caset

scenario 'Your scenario name' do # options = [ :bm_step | :bm_story ]
  before do # options = [:each | :all ]
  end
  
  ustep :x,"your step" do|param|
    # msg/记录
    # mark/star/plus/minus/标记/星/加/减
    # number/"string".is/是
    # Give/When/Then/And/如果/当/那么/而且
    # pending/待定
  end
  
  ustory "your ustory" do
    # run_step()
    # run_steps [ ]
  end
  
  after do # options = [:each | :all ]
  end
end

puts "","运行报告：",Caset.report
File.write "<<pathname>>_doc.txt",Caset.document.join("\\n")}

  def auto_story pathname = ""
    File.write "#{pathname}_case.rb",THE_USTORY_TEMPLATE.gsub("<<pathname>>",pathname.split("/")[-1])
  end
end
