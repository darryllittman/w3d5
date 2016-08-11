require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    ActiveSupport::Inflector.constantize(class_name.to_s)
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @options = options
    @primary_key = options[:primary_key] || :id
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @class_name = options[:class_name] || name.capitalize
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @options = options
    @primary_key = options[:primary_key] || :id
    @foreign_key = options[:foreign_key] || "#{self_class_name.downcase}_id".to_sym
    @class_name = options[:class_name] || name.capitalize[0..-2]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    define_method("#{name}") do
      options.model_class
        .where(options.primary_key => send(options.foreign_key))
        .first
    end

  end

  def has_many(name, options = {})
    
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
  # Mixin Associatable here...
end
