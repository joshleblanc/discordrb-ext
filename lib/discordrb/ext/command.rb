module Discordrb
    module Ext
        class Command
            class << self 
                attr_reader :attributes, :blk, :middleware

                def cmd(name = nil)
                    if name 
                        @cmd = name
                    else
                        @cmd
                    end
                end
            
                def method_missing(method, *args, &blk)
                    @attributes ||= {}
                    @attributes[method.to_sym] = args.first
                end
            
                def call(blk)
                    @blk = blk
                end
            end
        end
    end

end
