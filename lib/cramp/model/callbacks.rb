module Cramp
  module Model
    module Callbacks
      extend ActiveSupport::Concern
      
      included do
        class_inheritable_accessor :after_save_callback_names
        class_inheritable_accessor :after_destroy_callback_names
        
        self.after_save_callback_names = []
        self.after_destroy_callback_names = []
      end
      
      module ClassMethods
        def after_save(*method_names)
          self.after_save_callback_names += method_names
        end
        
        def after_destroy(*method_names)
          self.after_destroy_callback_names += method_names
        end
      end
      
      private
      def after_save_callbacks(result)
        after_save_callback_names.collect do |callback_name|
          callback = method callback_name
          callback.arity == 1 ? callback.call(result) : callback.call if callback
        end
      end
      
      def after_destroy_callbacks(result)
        after_destroy_callback_names.collect do |callback_name|
          callback = method callback_name
          callback.arity == 1 ? callback.call(result) : callback.call if callback
        end
      end
      
    end
  end
end
