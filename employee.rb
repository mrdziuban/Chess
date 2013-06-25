class Employee
  attr_accessor :name, :title, :salary, :boss

  def initialize(name, title, salary, boss=nil)
    @name = name
    @title = title
    @salary = salary
    @boss = boss
  end

  def assign_manager(manager)
    @boss = manager
    manager.employees << self
  end

  def calculate_bonus(multiplier)
    @salary * multiplier
  end

end

class Manager < Employee
  attr_accessor :employees

  def initialize
    @employees = []
  end

  def calculate_bonus(multiplier)
    bonus = 0
    total = 0
    @employees.each do |x|
      if x.is_a? Manager
        bonus = x.calculate_bonus(multiplier)
      else
        bonus = x.salary
      end
      total += bonus
    end

    total * multiplier

  end

end