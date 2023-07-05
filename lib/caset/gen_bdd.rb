#coding:utf-8

# Usage:
# BDD::gen((ARGV[0] || "xxx"),(ARGV[1] || "standard" || "background" || "outlines" || "steptables"))

module BDD
  module_function
  def step
%Q{
Given(//) do||

end

When(//) do||

end

Then(//) do||

end

And(//) do||

end

Then(//) do||

end
}
  end

  def standard
%Q{
Feature: 
  As a 
  I 
  so that 
  
  # 
  @
  Scenario: 
    Given 
    When 
    Then 
    And 
    But 
      """
      
      """
}
  end

  def background
%Q{
Feature: 
  As a 
  I 
  so that 
  
  Background:
    Given 

  Scenario: 
    When 
    Then 

  Scenario: 
    When 
    Then 
}
  end

  def outlines
%Q{
Feature: 
  As a
  I 
  so that 
  
  Scenario Outline: 
    Given 
    When 
    Then 
    And 
    
    Examples: 
      |  |  |
      |  |  |
      |  |  |
}
  end

  def steptables
%Q{
Feature: 
  As a 
  I 
  so that 
  
  Scenario: 
    Given 
    When 
    Then 
    And 
    But 
      |  |
      |  |
      |  |
}
  end

  def gen name,type 
    Dir.mkdir("features") unless File.exist?("features")
    Dir.mkdir("features/support") unless File.exist?("features/support")
    Dir.mkdir("features/step_definitions") unless File.exist?("features/step_definitions")
    
    File.write("features/support/env.rb","#coding:utf-8\n\n") unless File.exist?("features/support/env.rb")
    File.write("features/#{name}.feature",self.send(type.to_sym)) unless File.exist?("features/#{name}.feature")
    File.write("features/step_definitions/#{name}.rb",step) unless File.exist?("features/step_definitions/#{name}.rb")
  end
end
