# frozen_string_literal: true

require_relative "ext/version"
require_relative "ext/command"

module Discordrb
  module Ext
    class Error < StandardError; end
    # Your code goes here...

    class << self 
      def find_commands
        ObjectSpace.each_object(Class).select { _1 < Discordrb::Ext::Command }
      end

      def inject_middleware(command)
        method = command.blk
        middleware = []

        if command.middleware
          middleware.push *command.middleware
        end

        method.define_singleton_method(:call) do |event, *args|
          begin
            transformed_args = args.dup
            middleware.each do |m|
              transformed_args = m.before(event, *transformed_args)
            end
            transformed_output = super(event, *transformed_args)
            middleware.each do |m|
              transformed_output = m.after(event, transformed_output, *transformed_args)
            end
            transformed_output
          rescue StandardError => e
            raise e
          end
        end
        method
      end

      def extend(bot)
        find_commands.flatten.compact.each do |command|
          p command.name, command.attributes, inject_middleware(command)
          bot.command(command.cmd, command.attributes, &inject_middleware(command))
        end


        # Discordrb::Ext::Reactions.constants.map do |r|
        #   reaction = Reactions.const_get(r)
        #   reaction.is_a?(Class) ? reaction : nil
        # end.compact.each do |reaction|
        #   BOT.message(reaction.attributes, &reaction.method(:command))
        # end
  
      end
    end
  end
end
