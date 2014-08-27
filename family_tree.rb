require 'bundler/setup'
Bundler.require(:default)
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }

database_configurations = YAML::load(File.open('./db/config.yml'))
development_configuration = database_configurations['development']
ActiveRecord::Base.establish_connection(development_configuration)

def menu
  puts "\nWelcome to the family tree!"
  puts "\nWhat would you like to do?"

  loop do
    puts "\nPress  1 to add a family member"
    puts 'Press  2 to list out the family members'
    puts 'Press  3 to add the spouse'
    puts 'Press  4 to see the spouse'
    puts 'Press  5 to add parent(s)'
    puts 'Press  6 to see parent(s)'
    puts 'Press  7 to see child(ren)'
    puts 'Press  8 to see grandparent(s)'
    puts 'Press  9 to see grandchild(ren)'
    puts 'Press 10 to see sibling(s)'
    puts 'Press  0 to exit'
    choice = gets.chomp

    case choice
    when '1'
      add_person
    when '2'
      list_people
    when '3'
      add_marriage
    when '4'
      show_marriage
    when '5'
      add_parents
    when '6'
      show_parents
    when '7'
      show_children
    when '8'
      show_grandparents
    when '9'
      show_grandchildren
    when '10'
      show_siblings
    when '0'
      puts "\nThanks for looking at the family tree!\n\n"
      exit
    else
      puts "\nInvalid input, try again\n"
    end
  end
end

def valid_index?(index)
  if index != "" && index.to_i != 0 && index.to_i <= Person.all.length
    return true
  else
    return false
  end
end

def add_person
  puts "\nWhat is the name of the family member?"
  name = gets.chomp
  new_person = Person.new(:name => name)
  if new_person.save
    puts name + " was added to the family tree\n\n"
  else
    puts "No one was added because name #{new_person.errors.messages[:name].first}"
  end
end

def add_marriage
  list_people
  puts "\nWhat is the number of the first spouse?"
  spouse1_id = ""
  spouse1_id = gets.chomp
  if valid_index?(spouse1_id)
    spouse1 = Person.find(spouse1_id)
    puts 'What is the number of the second spouse?'
    spouse2_id = ""
    spouse2_id = gets.chomp
    if valid_index?(spouse2_id)
      spouse2 = Person.find(spouse2_id)
      spouse1.update(:spouse_id => spouse2.id)
      puts spouse1.name + " is now married to " + spouse2.name +  "\n\n"
    else
      puts "No second spouse was identified; you need to enter a valid number"
      puts "You may need to add a person"
    end
  else
    puts "No first spouse was identified; you need to enter a valid number"
    puts "You may need to add a person"
  end
end

def add_parents
  list_people
  puts "\nWhat is the number of the child?"
  child_id = ""
  child_id = gets.chomp
  if valid_index?(child_id)
    child = Person.find(child_id)
    puts 'What is the number of the first parent?'
    parent1_id = ""
    parent1_id = gets.chomp
    if valid_index?(parent1_id)
      parent1 = Person.find(parent1_id)
      puts 'What is the number of the second parent?'
      parent2_id = ""
      parent2_id = gets.chomp
      if valid_index?(parent2_id)
        parent2 = Person.find(parent2_id)
        child.update(:parent1_id=>parent1.id, :parent2_id=>parent2.id)
      else
        child.update(:parent1_id=>parent1.id)
      end
    else
      puts "No parents were identified; you need to enter at least 1 valid number"
      puts "You may need to add one or more people"
    end
  else
   puts "No person was identified; you need to enter a valid number"
   puts "You may need to add a person"
  end
end

def list_people
  puts "\nHere are all of the people in the database:\n"
  people = Person.all.order(:id)
  people.each do |person|
    puts person.id.to_s + " " + person.name
  end
  puts "\n"
end

def show_marriage
  list_people
  puts "\nEnter the number of the person and I'll show you to whom they are married"
  person_id = ""
  person_id = gets.chomp
  if valid_index?(person_id)
    person = Person.find(person_id)
    if person.spouse_id != nil
      puts person.name + " is married to " + person.spouse.name + "\n"
    else
      puts person.name + " is not married\n\n"
    end
  else
    puts "No person was identified; you need to enter a valid number"
    puts "You may need to add a person"
  end
end

def show_parents
  list_people
  puts "\nEnter the number of the person and I'll show you their parent(s)"
  child_id = ""
  child_id = gets.chomp
  if valid_index?(child_id)
    child = Person.find(child_id)
    if !child.parent1_id.nil?
      parent1 = Person.find(child.parent1_id)
      if !child.parent2_id.nil?
        parent2 = Person.find(child.parent2_id)
        puts "#{child.name}'s parents are #{parent1.name} and #{parent2.name}\n\n"
      else
        puts "#{child.name}'s parent is #{parent1.name}\n\n"
      end
    else
     puts "#{child.name} has no parents in the database"
     puts "You may need to add one or more people\n"
    end
  else
    puts "No person was identified; you need to enter a valid number"
    puts "You may need to add a person"
  end
end

def show_children
  list_people
  puts "\nEnter the number of the person and I'll show you their child(ren)"
  parent_id = ""
  parent_id = gets.chomp
  if valid_index?(parent_id)
    parent = Person.find(parent_id)
    children_array = parent.children
    if children_array.empty?
      puts "#{parent.name} has no children\n\n"
    elsif children_array.length == 1
      puts "#{parent.name}'s child is #{children_array.first.name}\n"
    else
      puts "#{parent.name}'s children are:"
      children_array.each do |child|
        puts "#{child.name}"
      end
      puts "\n\n"
    end
  else
   puts "No person was identified; you need to enter a valid number"
   puts "You may need to add a person"
  end
end

def show_siblings
  list_people
  puts "\nEnter the number of the person and I'll show you their sibling(s)"
  person_id = ""
  person_id = gets.chomp
  if valid_index?(person_id)
    the_person = Person.find(person_id)
    parent_array = the_person.parents
    parent1_child_array = []
    parent2_child_array = []
    if !parent_array.empty?
      parent1_child_array = parent_array[0].children.delete_if { |child| child.id == the_person.id }
      if parent_array.length == 2
        parent2_child_array = parent_array[1].children.delete_if { |child| child.id == the_person.id }
        parent_child_array = (parent1_child_array | parent2_child_array)
      else
        parent_child_array = parent1_child_array
      end
      if !parent_child_array.empty?
        if parent_child_array.length == 1
          plural = "sibling"
        else
          plural = "siblings"
        end
        puts "\nThe #{plural} of #{the_person.name}"
        parent_child_array.each do |the_sibling|
          the_sibling_type = the_person.sibling_type(the_sibling)
          puts "#{the_sibling.name} is a #{the_sibling_type} sibling"
        end
      else
        puts "#{the_person.name} has no siblings in the database"
        puts "You may need to add one or more people\n"
      end
    else
      puts "#{the_person.name} has no parents in the database"
      puts "You may need to add one or more people\n"
    end
  else
   puts "No person was identified; you need to enter a valid number"
   puts "You may need to add a person.\n"
  end
end

def show_grandparents
  list_people
  puts "\nEnter the number of the person and I'll show you their grandparent(s)"
  person_id = ""
  person_id = gets.chomp
  if valid_index?(person_id)
    the_person = Person.find(person_id)
    parent_array = the_person.parents
    parent1_parent_array = []
    parent2_parent_array = []
    if !parent_array.empty?
      parent1_parent_array = parent_array[0].parents
      if parent_array.length == 2
        parent2_parent_array = parent_array[1].parents
        parent_parent_array = (parent1_parent_array | parent2_parent_array)
      else
        parent_parent_array = parent1_parent_array
      end
      if !parent_parent_array.empty?
        if parent_parent_array.length == 1
          plural = "grandparent"
        else
          plural = "grandparents"
        end
        puts "\nThe #{plural} of #{the_person.name}"
        parent_parent_array.each do |the_grandparent|
          puts "#{the_grandparent.name}"
        end
      else
        puts "#{the_person.name} has no grandparents in the database"
        puts "You may need to add one or more people\n"
      end
    else
      puts "#{the_person.name} has no parents in the database"
      puts "You may need to add one or more people\n"
    end
  else
   puts "No person was identified; you need to enter a valid number"
   puts "You may need to add a person\n"
  end
end

def show_grandchildren
  list_people
  puts "\nEnter the number of the person and I'll show you their grandchild(ren)"
  parent_id = ""
  parent_id = gets.chomp
  if valid_index?(parent_id)
    parent = Person.find(parent_id)
    children_array = parent.children
    if !children_array.empty?
      grandchildren_array = []
      children_array.each do |child|
        child_children_array = child.children
        if !child_children_array.empty?
          child_children_array.each do |grandchild|
            grandchildren_array << grandchild
          end
        end
      end
      if !grandchildren_array.empty?
        if grandchildren_array.length == 1
          plural = "grandchild"
        else
          plural = "grandchildren"
        end
        puts "\nThe #{plural} of #{parent.name}"
        grandchildren_array.each do |grandchild|
          puts "#{grandchild.name}"
        end
        puts "\n"
      else
        puts "#{parent.name} has no grandchildren\n"
      end
    else
      puts "#{parent.name} has no children\n"
    end
  else
   puts "No person was identified; you need to enter a valid number"
   puts "You may need to add a person\n"
  end
end

menu
