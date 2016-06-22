require_relative "../config/environment.rb"
require 'pry'

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]  
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id=nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-sql
      CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY, name TEXT, grade INTEGER);
    sql
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-sql
      DROP TABLE IF EXISTS students;
    sql
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
    sql = <<-sql
      INSERT INTO students (name, grade) VALUES(?, ?)
    sql
    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = <<-sql
      UPDATE students SET name = ?, grade = ? WHERE id = ?
    sql
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    student = Student.new(row[0], row[1], row[2])
    student
  end

  def self.find_by_name(name)
    sql = <<-sql
      SELECT * FROM students WHERE name = ?;
    sql
    row = DB[:conn].execute(sql, name).flatten
    self.new_from_db(row)
  end
  
end
