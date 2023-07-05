#coding:utf-8

# Usage:
# Spec.gen(ARGV,template)

module Spec
  THE_SPEC_TEMPLATE = %Q{#coding:utf-8
$LOAD_PATH << "spec"

describe ((name)) do
  context "..." do
    before(:each) do
      
    end

    it "..." do
      pending
    end
    
    after(:each) do
      
    end
  end
end}

  def self.gen names,template=THE_SPEC_TEMPLATE
    Dir.mkdir("spec") unless File.exist?("spec")
    ["middleware","asset","support"].each do|subdir|
      Dir.mkdir("spec/#{subdir}") unless File.exist?("spec/#{subdir}")
    end
    File.write("spec/spec_helper.rb","#coding:utf-8\n\n") unless File.exist?("spec/spec_helper.rb")
    names.each do|name|
      File.write("spec/#{name}_spec.rb",template.gsub("((name))",name)) unless File.exist?("spec/#{name}_spec.rb")
    end
  end
end
