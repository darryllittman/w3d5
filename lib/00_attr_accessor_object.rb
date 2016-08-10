<<<<<<< HEAD
=======
require 'byebug'
>>>>>>> abf7e64d762e2eeb5052193d466fb832e36e3903
class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # ...
    names.each do |name|
      define_method name do
<<<<<<< HEAD

=======
        
>>>>>>> abf7e64d762e2eeb5052193d466fb832e36e3903
        self.instance_variable_get("@#{name}".to_sym)
        # name
      end

      define_method "#{name}=" do |value|
        self.instance_variable_set("@#{name}".to_sym, value)
      end

    end
  end

end
