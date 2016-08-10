require 'byebug'
require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map { |key| "#{key} = ?"}.join(" AND ")
    attribute_vals = params.values
    found_items = DBConnection::execute(<<-SQL, *attribute_vals)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL

    return [] unless found_items
    found_items.map { |item| self.new(item) }
  end
end

class SQLObject
  extend Searchable
  # Mixin Searchable here...
end
