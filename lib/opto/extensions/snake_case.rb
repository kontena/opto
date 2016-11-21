module Opto
  module Extension
    # Refines String to have .snakecase method that turns
    # StringLikeThis into a string_like_this
    module SnakeCase
      refine String do
        def snakecase
          gsub(/::/, '/')
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr('-', '_').
          gsub(/\s/, '_').
          gsub(/__+/, '_').
          downcase
        end

        alias_method :underscore, :snakecase
        alias_method :snakeize, :snakecase
      end
    end
  end
end
