require 'byebug'
require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @cols ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    @cols.first.map { |el| el.to_sym }
    # ...
  end

  def self.finalize!
    self.columns.each do |col|

      define_method(col.to_s) do
        attributes[col]
      end

      define_method("#{col.to_s}=") do |value|
        attributes[col] = value
      end
    end

  end

  def self.table_name=(table_name)

    @table_name = table_name
    # ...
  end

  def self.table_name
    @table_name = "#{self.to_s.downcase}s"
  end

  def self.all
    all = DBConnection::execute2(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL
    # ...
    self.parse_all(all[1..-1])
  end

  def self.parse_all(results)

    results.map do |params|
      self.new(params)
    end
    # ...
  end

  def self.find(id)

    row = DBConnection::execute(<<-SQL, id)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL

    self.parse_all(row).first
  end

  def initialize(params = {})
    params.each do |col, value|

      k = col.to_sym
      raise "unknown attribute \'#{col}\'" unless self.class.columns.include?(k)

      self.send("#{col}=".to_sym, value)
    end
    # ...
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |col| self.send(col) }
  end

  def insert
    col_names = self.class.columns.join(", ")
    size = self.class.columns.size
    question_marks = (["?"] * self.class.columns.size).join(", ")

    DBConnection::execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    attributes[:id] = DBConnection.last_insert_row_id
  end

  def update
    # This is very similar to the #insert method. To produce the "SET line", I mapped ::columns to #{attr_name} = ? and joined with commas.
    #
    # I again used the #attribute_values trick. I additionally passed in the id of the object (for the last ? in the WHERE clause).


    # att_values = "#{attribute_values}, #{attribute_values.first}"
    att_values = attribute_values << attribute_values.first
    set_line = self.class.columns.map { |el| "#{el} = ?" }.join(", ")

    DBConnection::execute(<<-SQL, *att_values)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL
  end

  def save
    #how to merge back with git?
    #where do I find this id?
    if @attributes && @attributes[:id]
      update
    else
      insert
    end
  end
end
