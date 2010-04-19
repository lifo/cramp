module Cramp
  module Model
    class Engine
      class Connection
        def initialize(settings)
          EventedMysql.settings.update(settings)
        end
        
        def execute_now(sql)
          EventedMysql.execute_now sql
        end
        
        def create(sql, &block)
          EventedMysql.insert sql, block
        end
        
        def select(sql, &block)
          EventedMysql.select sql, block
        end
        
        def update(sql, &block)
          EventedMysql.update sql, block
        end
        
        def delete(sql, &block)
          EventedMysql.delete sql, block
        end
        
      end
    end
  end
end
